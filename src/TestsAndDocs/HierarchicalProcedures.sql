ALTER PROC [dbo].[GetForm] (@FormID INT, @RequestID INT = NULL) AS 
--Based on Nested Set Model here: http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/
-- If called with formid=0, the form will be looked up from requestid
-- GetForm 4
-- GetForm 0, 9
DECLARE @ReqDate datetime

IF @FormID = 0 --Pull the request, first figure out which form this is.
	BEGIN
		SELECT @FormID = RequestItems.FieldID, @ReqDate = Requests.EnteredDate
		FROM RequestItems 
		INNER JOIN Requests
		ON RequestItems.RequestID = Requests.RequestID
		INNER JOIN Forms 
		ON RequestItems.FieldID = Forms.ID
		WHERE Forms.Type IN ('FORM','UNPUB')
		AND RequestItems.RequestID = @RequestID
	END
ELSE           --Pull just the form.
	BEGIN
		SET @ReqDate = GETDATE()
	END

SELECT * FROM Requests WHERE RequestID = @RequestID
SELECT inr2.ID AS FormID, inr2.depth, inr2.Type, inr2.Descrip, ParentID, ItemValue FROM (
	SELECT inr.ID, inr.depth, inr.Type, inr.Descrip, inr.lft, (SELECT TOP 1 ID 
			   FROM Forms parent 
			   WHERE parent.lft < inr.lft AND parent.rgt > inr.rgt    
			   ORDER BY parent.rgt-inr.rgt ASC) AS ParentID
	FROM (
		SELECT node.ID, (COUNT(parent.ID) - 1) AS depth, 
		node.lft, node.rgt, node.Type, node.Descrip
		FROM Forms AS node
		INNER JOIN Forms AS parent
		ON node.lft BETWEEN parent.lft AND parent.rgt
		WHERE (node.Created <= @ReqDate AND (node.Deleted >= @ReqDate OR node.Deleted IS NULL))
		GROUP BY node.ID, node.lft, node.rgt, node.Type, node.Descrip
	) As inr
	INNER JOIN (
		SELECT *
		FROM Forms
		WHERE ID = @FormID
	) AS newroot
	ON inr.lft BETWEEN newroot.lft AND newroot.rgt
) AS inr2
LEFT JOIN (
	SELECT FieldID, ItemValue
	FROM RequestItems
	WHERE RequestID = @RequestID
) AS req
ON inr2.ID = req.FieldID
ORDER BY inr2.lft

GO


---------------------------------------------------------------------------------------------------------------
ALTER PROC [dbo].[AddChild] (@IntoCategory INT, @Type VARCHAR(10), @Descrip VARCHAR(MAX)) AS
-- Adds first child to category
-- AddChild 129, 'SECTION', 'OneSizeFitsAll?'
BEGIN
	BEGIN TRANSACTION
		DECLARE @FormID INT
		DECLARE @myLeft int
		SELECT @myLeft = lft FROM Forms
		WHERE ID = @IntoCategory;

		UPDATE Forms SET rgt = rgt + 2 WHERE rgt > @myLeft;
		UPDATE Forms SET lft = lft + 2 WHERE lft > @myLeft;

		INSERT INTO Forms(Type,Descrip,lft,rgt,Created) VALUES(@Type, @Descrip, @myLeft + 1, @myLeft + 2, GETDATE());
		SET @FormID = @@IDENTITY

		IF @Type = 'NODE' --Nodes always have request and response
		BEGIN
			EXEC AddChild @FormID, 'RESPONSE', 'RESPONSE'
			EXEC AddChild @FormID, 'REQUEST', 'REQUEST'
		END

		SELECT @FormID AS FormID, @Type AS Type, @Descrip AS Descrip, dbo.GetParent(@FormID) AS ParentID
	COMMIT TRANSACTION
END

GO
---------------------------------------------------------------------------------------------------------------

ALTER PROC [dbo].AddSister (@ToRightOf INT, @Type VARCHAR(10), @Descrip VARCHAR(MAX)) AS
-- Adds a sibling after @ToRightOf
-- AddSister 13, 'INPUT', 'Email Password'
BEGIN
	BEGIN TRANSACTION
		DECLARE @FormID INT
		
		DECLARE @myRight int
		SELECT @myRight = rgt FROM Forms
		WHERE ID = @ToRightOf;

		UPDATE Forms SET rgt = rgt + 2 WHERE rgt > @myRight;
		UPDATE Forms SET lft = lft + 2 WHERE lft > @myRight;

		INSERT INTO Forms(Type,Descrip,lft,rgt,Created) VALUES(@Type, @Descrip, @myRight + 1, @myRight + 2, GETDATE());
		SET @FormID = @@IDENTITY

		IF @Type = 'NODE' --Nodes always have request and response
		BEGIN
			EXEC AddChild @FormID, 'RESPONSE', 'RESPONSE'
			EXEC AddChild @FormID, 'REQUEST', 'REQUEST'
		END

		SELECT @FormID AS FormID, @Type AS Type, @Descrip AS Descrip, dbo.GetParent(@FormID) AS ParentID
	COMMIT TRANSACTION
END
GO
---------------------------------------------------------------------------------------------------------------
ALTER PROC DelNode (@FormID INT) AS
-- Mark as Deleted Node and all it's children 
-- DelNode 119
BEGIN
	BEGIN TRANSACTION
		DECLARE @myLeft INT, @myRight INT, @myWidth INT
		SELECT @myLeft = lft, @myRight = rgt, @myWidth = rgt - lft + 1
		FROM Forms
		WHERE ID = @FormID

		UPDATE Forms SET Deleted = GETDATE() WHERE lft BETWEEN @myLeft AND @myRight;
	COMMIT TRANSACTION
END
GO
---------------------------------------------------------------------------------------------------------------
ALTER PROC PublishForm (@FormID INT) AS
-- Toggles form from Type FORM to UNPUB
-- PublishForm 4
BEGIN
	UPDATE f
	SET Type = opt 
	FROM Forms f
	CROSS JOIN (
		SELECT 'FORM' AS opt UNION SELECT 'UNPUB'
	) AS opts
	WHERE opt <> Type
	AND ID = @FormID
END
GO

-------------------------------------------------------------------
ALTER PROC [dbo].[InsRequest](@SupvName VARCHAR(100), @Items XML) AS
BEGIN
	DECLARE @RequestID INT
	INSERT INTO Requests (SupvName, EnteredDate, Completed)
	VALUES(@SupvName, GETDATE(), 0)

	SET @RequestID = @@IDENTITY

    INSERT INTO RequestItems (RequestID, FieldID, ItemValue)
    SELECT @RequestID,
        tab.col.value( 'Field[1]', 'int' ) AS FieldID,
        tab.col.value( 'Value[1]', 'varchar(max)' ) AS ItemValue
    FROM @Items.nodes('reqrows/row') tab(col)


	DECLARE @xml xml
	SELECT @xml = (
		SELECT --CASE WHEN Forms.Type = 'FORM' THEN 'Form' ELSE Descrip END AS Col, 
		RequestItems.ItemValue ItemValue 
		FROM Requests req
		INNER JOIN RequestItems
		ON req.RequestID = RequestItems.RequestID
		INNER JOIN Forms
		ON RequestItems.FieldID = Forms.ID
		WHERE Completed = 0
		AND HeaderRecord = 1
		AND req.RequestID = @RequestID
		FOR XML PATH)
	
	UPDATE Requests SET HeaderXML = @xml
	WHERE RequestID = @RequestID

	SELECT @RequestID AS RequestID
END

GO
-------------------------------------------------------------------

ALTER PROC [dbo].[AdminScreen] AS
	SELECT * FROM Requests
	WHERE Completed = 0

	SELECT ID AS FormID, Descrip, Type FROM Forms
	WHERE Type IN('FORM','UNPUB')
	AND Deleted IS NULL
	ORDER BY Descrip

	SELECT ID AS FormID, Descrip FROM Forms
	WHERE Type = 'ROOT'

	SELECT AdminID, Name FROM Admins

GO

-------------------------------------------------------------------
ALTER PROC IsAdminOrSupv(@UserID VARCHAR(15)) AS
--returns 'SUPV','ADMIN', or null
/*
exec IsAdminOrSupv '1027126'
exec IsAdminOrSupv '1027143'
exec IsAdminOrSupv 'moo'
*/
DECLARE @CheckID VARCHAR(10)
DECLARE @RetType VARCHAR(10)

SELECT @CheckID = AdminID FROM  Admins 
WHERE AdminID = @UserID

IF @@ROWCOUNT > 0 
	SET @RetType = 'ADMIN'
ELSE
	BEGIN
	SELECT @CheckID = empid FROM (
		SELECT empid
		FROM Intranet..SupervisorExceptions
		WHERE empid = @UserID
		UNION
		SELECT supervisorid
		FROM Intranet..PHONE 
		WHERE supervisorid = @UserID
	) AS inr
	IF @@ROWCOUNT > 0 
		SET @RetType = 'SUPV'
	ELSE
		SET @RetType = 'NEITHER'
	END
SELECT @RetType AS Results
GO
-------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------
exec InsRequest @SupvName = 'J. Supv Wilson', @Items = N'
<reqrows>
	<row>
		<Field>9</Field>
		<Value>J. Staffy Wilson</Value>
	</row>
	<row>
		<Field>35</Field>
		<Value>1027126</Value>
	</row>
	<row>
		<Field>37</Field>
		<Value>2017-03-01</Value>
	</row>
	<row>
		<Field>36</Field>
		<Value>Johannes Staffy Wilson</Value>
	</row>
	<row>
		<Field>19</Field>
		<Value>External Temp Agency Staff</Value>
	</row>
</reqrows>
	
'

GO

---------------------------------------------------------------------------------------------------------------
PublishForm 2
GO
---------------------------------------------------------

GetForm 2
go
GetForm 129

go
DelNode 8
go
DelNode 9
go
DelNode 203
go
DelNode 197
go
DelNode 198
go
DelNode 199