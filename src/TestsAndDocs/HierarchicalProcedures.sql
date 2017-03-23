ALTER PROC [dbo].[GetForm] (@FormID INT, @RequestID INT = NULL) AS 
--Based on Nested Set Model here: http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/
-- If called with formid=0, the form will be looked up from requestid
-- GetForm 24
-- GetForm 0, 101
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
SELECT inr2.ID AS FormID, inr2.Type, inr2.Descrip, inr2.Required, inr2.HeaderRecord, ParentID, ItemValue FROM (
	SELECT inr.ID, inr.Type, inr.Descrip, inr.Required, inr.HeaderRecord, inr.lft, (SELECT TOP 1 ID 
			   FROM Forms parent 
			   WHERE parent.lft < inr.lft AND parent.rgt > inr.rgt    
			   ORDER BY parent.rgt-inr.rgt ASC) AS ParentID
	FROM (
		SELECT node.ID, node.Required, node.HeaderRecord, --(COUNT(parent.ID) - 1) AS depth, 
		node.lft, node.rgt, node.Type, node.Descrip
		FROM Forms AS node
		INNER JOIN Forms AS parent
		ON node.lft BETWEEN parent.lft AND parent.rgt
		WHERE (node.Created <= @ReqDate AND (node.Deleted >= @ReqDate OR node.Deleted IS NULL))
		GROUP BY node.ID, node.lft, node.rgt, node.Type, node.Descrip, node.Required, node.HeaderRecord
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
		DECLARE @Head BIT
		SELECT @myLeft = lft FROM Forms
		WHERE ID = @IntoCategory;

		UPDATE Forms SET rgt = rgt + 2 WHERE rgt > @myLeft;
		UPDATE Forms SET lft = lft + 2 WHERE lft > @myLeft;

		IF @Type = 'UNPUB' SET @Head = 1 ELSE SET @Head = 0
		INSERT INTO Forms(Type,Descrip,lft,rgt,Created,HeaderRecord) VALUES(@Type, @Descrip, @myLeft + 1, @myLeft + 2, GETDATE(),@Head);
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
-- Checks if element has ever been used in a request. If yes, mark as Deleted 
-- if no delete Node and all it's children 
-- DelNode 119
BEGIN
	BEGIN TRANSACTION
		DECLARE @myLeft INT, @myRight INT, @myWidth INT, @IsUsed INT
		SELECT @myLeft = lft, @myRight = rgt, @myWidth = rgt - lft + 1
		FROM Forms
		WHERE ID = @FormID

		SELECT @IsUsed = count(*) FROM RequestItems
		WHERE FieldID = @FormID
		IF @IsUsed = 0
		BEGIN
			DELETE FROM Forms WHERE lft BETWEEN @myLeft AND @myRight;
			UPDATE Forms SET rgt = rgt - @myWidth WHERE rgt > @myRight;
			UPDATE Forms SET lft = lft - @myWidth WHERE lft > @myRight;
		END 
		ELSE 
		BEGIN
			UPDATE Forms SET Deleted = GETDATE() WHERE lft BETWEEN @myLeft AND @myRight;
		END
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
---------------------------------------------------------------------------------------------------------------
ALTER PROC ToggleHeaderRecord (@FormID INT) AS
-- Toggles form HeaderRecord true/false
-- ToggleHeaderRecord 4
BEGIN
	UPDATE f
	SET HeaderRecord = opt 
	FROM Forms f
	CROSS JOIN (
		SELECT 1 AS opt UNION SELECT 0
	) AS opts
	WHERE opt <> HeaderRecord
	AND ID = @FormID
END
GO
---------------------------------------------------------------------------------------------------------------
ALTER PROC ToggleRequired (@FormID INT) AS
-- Toggles form Required  true/false
-- ToggleRequired 4
BEGIN
	UPDATE f
	SET Required = opt 
	FROM Forms f
	CROSS JOIN (
		SELECT 1 AS opt UNION SELECT 0
	) AS opts
	WHERE opt <> Required 
	AND ID = @FormID
END
GO
-------------------------------------------------------------------
ALTER PROC UpsertRequest(@LoggedInName VARCHAR(100), @Items XML, @ReqID INT = NULL) AS
-- If @ReqID param is null, adds new Request and RequestItems (Supervisor creating original)
-- Otherwise just updates RequestItems (Admins updating)
BEGIN
	DECLARE @RequestID INT
	DECLARE @Completed BIT
	IF @ReqID IS NULL
	BEGIN   --(Supervisor creating original)
		INSERT INTO Requests (SupvName, EnteredDate, Completed, EditedXML)
		VALUES(@LoggedInName, GETDATE(), 0, '<root />')

		SET @RequestID = @@IDENTITY
		SET @Completed = 0
	END
	ELSE
	BEGIN   --(Admins updating)
		SET @RequestID = @ReqID

		--update "Edited by"
		DECLARE @EditDate datetime = GETDATE()
		DECLARE @xmlrow xml = '<row/>'
		SET @xmlrow.modify('insert <UserName>{sql:variable("@LoggedInName")}</UserName> into (/row)[1]')
		SET @xmlrow.modify('insert <DateMod>{sql:variable("@EditDate")}</DateMod> into (/row)[1]')
		update Requests
		set editedXML.modify('insert sql:variable("@xmlrow") as last into (/root)[1]')
		where RequestID = @RequestID

		--clear out requested items before re-adding edited ones
		DELETE RequestItems
		WHERE RequestID = @RequestID
	END

    INSERT INTO RequestItems (RequestID, FieldID, ItemValue)
    SELECT @RequestID,
        tab.col.value( 'Field[1]', 'int' ) AS FieldID,
        tab.col.value( 'Value[1]', 'varchar(max)' ) AS ItemValue
    FROM @Items.nodes('reqrows/row') tab(col)

	--Check if completed
	SELECT @Completed = CASE WHEN NOT EXISTS (
		SELECT RequestItems.ItemValue
		FROM RequestItems 
		INNER JOIN Forms 
		ON RequestItems.FieldID = Forms.ID
		WHERE Forms.Type = 'RESPONSE' AND RequestItems.RequestID = @RequestID
		GROUP BY RequestItems.ItemValue
		HAVING RequestItems.ItemValue <> 'true'
	)
	THEN 1 ELSE 0 END 

	-- Update the HeaderRecord XML field in Requests table
	DECLARE @xml xml
	SELECT @xml = (
		SELECT CASE WHEN Forms.Type = 'FORM' THEN 'Form' ELSE Descrip END AS Col,
		RequestItems.ItemValue ItemValue 
		FROM Requests req
		INNER JOIN RequestItems
		ON req.RequestID = RequestItems.RequestID
		INNER JOIN Forms
		ON RequestItems.FieldID = Forms.ID
		WHERE Completed = 0
		AND HeaderRecord = 1
		AND req.RequestID = @RequestID
		FOR XML PATH, ROOT)
	
	UPDATE Requests SET 
	HeaderXML = @xml,
	Completed = @Completed
	WHERE RequestID = @RequestID

	SELECT @Completed AS Completed
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
ALTER PROC SearchXML(@SearchString VARCHAR(MAX)) AS
-- SearchXML 'ANew'
-- TEST THIS SOME MORE...
--Also create an XML index https://msdn.microsoft.com/en-us/library/bb934097.aspx
SELECT [RequestID]
      ,[EmpName]
      ,[SupvName]
      ,[EnteredDate]
      ,[Completed]
      ,[headerXML]
  FROM Requests
WHERE headerXML.value('(/row/ItemValue)[1]', 'varchar(max)') like '%'+@SearchString+'%'

---------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------
exec UpsertRequest @SupvName = 'J. Supv Wilson', @Items = N'
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