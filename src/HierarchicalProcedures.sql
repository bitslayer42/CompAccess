ALTER PROC GetForm (@FormID INT, @RequestID INT = NULL) AS 
--Based on Nested Set Model here: http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/
-- GetForm 4
-- GetForm 4, 5
SELECT inr2.ID, inr2.Code, inr2.depth, inr2.Type, inr2.Descrip, ParentID, ItemValue FROM (
	SELECT inr.ID, inr.Code, inr.depth, inr.Type, inr.Descrip, inr.lft, (SELECT TOP 1 ID 
			   FROM Forms parent 
			   WHERE parent.lft < inr.lft AND parent.rgt > inr.rgt    
			   ORDER BY parent.rgt-inr.rgt ASC) AS ParentID
	FROM (
		SELECT node.ID, node.Code, (COUNT(parent.ID) - 1) AS depth, 
		node.lft, node.rgt, node.Type, node.Descrip
		FROM Forms AS node
		INNER JOIN Forms AS parent
		ON node.lft BETWEEN parent.lft AND parent.rgt
		GROUP BY node.ID,node.Code,node.lft, node.rgt, node.Type, node.Descrip
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
ALTER PROC InsNode (@ToRightOf INT, @Code VARCHAR(10), @Type VARCHAR(10), @Descrip VARCHAR(100)) AS
-- Adds a sibling after @ToRightOf
-- InsNode 13, 'RESPONSE', 'INPUT', 'Email Password'
BEGIN
	BEGIN TRANSACTION
		DECLARE @myRight int
		SELECT @myRight = rgt FROM Forms
		WHERE ID = @ToRightOf;

		UPDATE Forms SET rgt = rgt + 2 WHERE rgt > @myRight;
		UPDATE Forms SET lft = lft + 2 WHERE lft > @myRight;

		INSERT INTO Forms(Type,Code,Descrip,lft,rgt) VALUES(@Type, @Code, @Descrip, @myRight + 1, @myRight + 2);
	COMMIT TRANSACTION
	RETURN 0
END
GO
---------------------------------------------------------------------------------------------------------------
ALTER PROC AddChild (@IntoCategory INT, @Code VARCHAR(10), @Type VARCHAR(10), @Descrip VARCHAR(100)) AS
-- Adds first child to category
-- AddChild 6, 'REQUEST', 'INPUT', 'questionsquestionquestions'
BEGIN
	BEGIN TRANSACTION
		DECLARE @myLeft int
		SELECT @myLeft = lft FROM Forms
		WHERE ID = @IntoCategory;

		UPDATE Forms SET rgt = rgt + 2 WHERE rgt > @myLeft;
		UPDATE Forms SET lft = lft + 2 WHERE lft > @myLeft;

		INSERT INTO Forms(Type,Code,Descrip,lft,rgt) VALUES(@Type, @Code, @Descrip, @myLeft + 1, @myLeft + 2);
	COMMIT TRANSACTION
END
GO
---------------------------------------------------------------------------------------------------------------
ALTER PROC DelNode (@ID INT) AS
-- Delete Node and all it's children (Yikes!)
-- DelNode 31
BEGIN
	BEGIN TRANSACTION
		DECLARE @myLeft INT, @myRight INT, @myWidth INT
		SELECT @myLeft = lft, @myRight = rgt, @myWidth = rgt - lft + 1
		FROM Forms
		WHERE ID = @ID

		DELETE FROM Forms WHERE lft BETWEEN @myLeft AND @myRight;

		UPDATE Forms SET rgt = rgt - @myWidth WHERE rgt > @myRight;
		UPDATE Forms SET lft = lft - @myWidth WHERE lft > @myRight;
	COMMIT TRANSACTION
END
GO
---------------------------------------------------------------------------------------------------------------
ALTER PROC PublishForm (@ID INT) AS
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
	AND ID = @ID
END
GO
---------------------------------------------------------------------------------------------------------------
	DECLARE	@return_value int

	EXEC	@return_value = AddChild
			@IntoCategory = 47,
			@Code = N'',
			@Type = N'OPTION',
			@Descrip = N'(Choose One)'

	SELECT	'Return Value' = @return_value
GO
---------------------------------------------------------------------------------------------------------------
	DECLARE	@return_value int

	EXEC	@return_value = InsNode
			@ToRightOf = 56,
			@Code = N'',
			@Type = N'TEXT',
			@Descrip = N'(Note: Includes email distribution groups, Meditech and Cerner as applicable.)'

	SELECT	'Return Value' = @return_value
GO



---------------------------------------------------------------------------------------------------------------
PublishForm 4
GO

GetForm 4
go
-------------------------------------------------------------------
ALTER PROC InsRequest(@FormID VARCHAR(20), @SupvID VARCHAR(20), @SupvName VARCHAR(100), @EnteredDate DATETIME, @Items XML) AS
BEGIN
	DECLARE @RequestID INT
	INSERT INTO Requests (FormID, SupvID, SupvName, EnteredDate)
	VALUES(@FormID, @SupvID , @SupvName, @EnteredDate)

	SET @RequestID = @@IDENTITY

    INSERT INTO RequestItems (RequestID, FieldID, ItemValue)
    SELECT @RequestID,
        tab.col.value( 'Field[1]', 'int' ) AS FieldID,
        tab.col.value( 'Value[1]', 'varchar(max)' ) AS ItemValue
    FROM @Items.nodes('reqrows/row') tab(col)
END
GO

-------------------------------------------------------------------
exec InsRequest @FormID = 'CCPIT', @SupvID = '1027126', @SupvName = 'J. Supv Wilson', @EnteredDate = '2017-02-01', @Items = N'
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


