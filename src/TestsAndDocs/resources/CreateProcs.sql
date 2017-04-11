/****** Object:  StoredProcedure [dbo].[AddChild]    Script Date: 4/6/2017 11:14:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[AddChild] (@IntoCategory INT, @Type VARCHAR(10), @Descrip VARCHAR(MAX)) AS
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

/****** Object:  StoredProcedure [dbo].[AddSister]    Script Date: 4/6/2017 11:14:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[AddSister] (@ToRightOf INT, @Type VARCHAR(10), @Descrip VARCHAR(MAX)) AS
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

/****** Object:  StoredProcedure [dbo].[AdminScreen]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create PROC [dbo].[AdminScreen] AS
	SELECT * FROM Requests
	WHERE Completed = 0

	SELECT ID AS FormID, Descrip, Type FROM Forms
	WHERE Type IN('FORM','UNPUB')
	AND Deleted IS NULL
	ORDER BY Descrip

	SELECT ID AS FormID, Descrip FROM Forms
	WHERE Type = 'ROOT'

	SELECT AdminID, Name FROM Admins
	ORDER BY Name


GO

/****** Object:  StoredProcedure [dbo].[DelAdmin]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[DelAdmin](@AdminID VARCHAR(15)) AS
DELETE FROM Admins
WHERE AdminID = @AdminID

GO

/****** Object:  StoredProcedure [dbo].[DelNode]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[DelNode] (@FormID INT) AS
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

/****** Object:  StoredProcedure [dbo].[GetAdmin]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[GetAdmin](@AdminID VARCHAR(15),@Name VARCHAR(200) = NULL,@EmailAddress VARCHAR(40) = NULL) AS
-- GetAdmin '1027126'
-- GetAdmin '1','name','nam@nom'
BEGIN
	INSERT INTO Admins(AdminID,Name,EmailAddress)
	SELECT @AdminID, @Name, @EmailAddress
	WHERE NOT EXISTS(SELECT * FROM Admins
					WHERE AdminID = @AdminID)

	SELECT Admins.AdminID, Admins.Name, Admins.EmailAddress
	FROM Admins WHERE AdminID = @AdminID

	SELECT
	GetNodeList.FormName, GetNodeList.ID, GetNodeList.Descrip,
	CASE WHEN ae.SubscribedNode IS NULL THEN 0 ELSE 1 END AS Subscribed
	FROM Admins
	CROSS JOIN GetNodeList
	LEFT JOIN (
		SELECT * FROM AdminEmails
		WHERE AdminID = @AdminID
	) AS ae
	ON Admins.AdminID = ae.AdminID
	AND ae.SubscribedNode = GetNodeList.ID
	WHERE Admins.AdminID = @AdminID
	ORDER BY Sorter
END
GO

/****** Object:  StoredProcedure [dbo].[GetEmailForSupv]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[GetEmailForSupv](@BadgeNum VARCHAR(15)) AS
SELECT Name, EmailAddress
FROM Staff
WHERE BadgeNum = @BadgeNum



GO

/****** Object:  StoredProcedure [dbo].[GetEmailsForRequest]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[GetEmailsForRequest](@RequestID INT) AS
	--For a given supervisor's request, return the list of email addresses that have subscribed to selected nodes.
	SELECT DISTINCT Admins.EMailAddress, Admins.Name
	FROM RequestItems
	INNER JOIN Forms
	ON RequestItems.FieldID = Forms.ID
	INNER JOIN AdminEmails
	ON RequestItems.FieldID = AdminEmails.SubscribedNode
	INNER JOIN Admins
	ON Admins.AdminID = AdminEmails.AdminID
	WHERE RequestItems.RequestID = @RequestID
	AND Forms.Type = 'NODE'
GO

/****** Object:  StoredProcedure [dbo].[GetForm]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[GetForm] (@FormID INT, @RequestID INT = NULL) AS 
--Based on Nested Set Model here: http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/
-- If called with formid=0, the form will be looked up from requestid
-- GetForm 112
-- GetForm 0, 47
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

/****** Object:  StoredProcedure [dbo].[GetStaffList]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[GetStaffList](@SearchString VARCHAR(20)) AS
-- GetStaffList 'C'
SELECT TOP 20 BadgeNum, Name, EMailAddress,1 as sorter
FROM Staff
WHERE Name LIKE @SearchString + '%'
UNION
SELECT TOP 20 BadgeNum, Name, EMailAddress,2 as sorter
FROM Staff
WHERE Name LIKE '%' + @SearchString + '%'
ORDER BY sorter,Name
GO

/****** Object:  StoredProcedure [dbo].[IsAdminOrSupv]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-------------------------------------------------------------------
CREATE PROC [dbo].[IsAdminOrSupv](@UserID VARCHAR(15)) AS
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

/****** Object:  StoredProcedure [dbo].[PublishForm]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[PublishForm] (@FormID INT) AS
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

/****** Object:  StoredProcedure [dbo].[SearchXML]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SearchXML](@SearchString VARCHAR(MAX)) AS
-- I created an XML index https://msdn.microsoft.com/en-us/library/bb934097.aspx
-- CREATE PRIMARY XML INDEX Requests_headerXML ON Requests (headerXML)
-- SearchXML 'Henny'
SET @SearchString = UPPER(@SearchString)
SELECT TOP 10
[RequestID]
,[SupvID]
,[SupvName]
,[EnteredDate]
,[Completed]
,[headerXML]
,[EditedXML]
FROM Requests
WHERE headerXML.exist('/root/row/ItemValue/text()[contains(upper-case(.), sql:variable("@SearchString"))]') = 1

GO

/****** Object:  StoredProcedure [dbo].[ToggleEmail]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[ToggleEmail](@AdminID VARCHAR(15), @NodeID INT) AS
IF EXISTS(
	SELECT 1 FROM AdminEmails
	WHERE AdminID = @AdminID
	AND SubscribedNode = @NodeID
)
	DELETE FROM AdminEmails
	WHERE AdminID = @AdminID
	AND SubscribedNode = @NodeID
ELSE
	INSERT INTO AdminEmails(AdminID, SubscribedNode)
	VALUES (@AdminID, @NodeID)
GO

/****** Object:  StoredProcedure [dbo].[ToggleHeaderRecord]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[ToggleHeaderRecord] (@FormID INT) AS
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

/****** Object:  StoredProcedure [dbo].[ToggleRequired]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[ToggleRequired] (@FormID INT) AS
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

/****** Object:  StoredProcedure [dbo].[UpsertRequest]    Script Date: 4/6/2017 11:14:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[UpsertRequest](@LoggedInID VARCHAR(15), @LoggedInName VARCHAR(100), @Items XML, @ReqID INT = NULL) AS
-- If @ReqID param is null, adds new Request and RequestItems (Supervisor creating original)
-- Otherwise just updates RequestItems (Admins updating)
BEGIN
	DECLARE @RequestID INT
	DECLARE @Completed BIT
	IF @ReqID IS NULL
	BEGIN   --(Supervisor creating original)
		INSERT INTO Requests (SupvID, SupvName, EnteredDate, Completed, EditedXML)
		VALUES(@LoggedInID, @LoggedInName, GETDATE(), 0, '<root />')

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

	SELECT @RequestID AS RequestID, @Completed AS Completed
END



GO
/****** Object:  StoredProcedure [dbo].[GetEmailsForRequest]    Script Date: 4/7/2017 9:10:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC GetRequest(@RequestID INT) AS
--GetRequest  75
SELECT Staff.EMailAddress, SupvName, EnteredDate, headerXML
FROM Requests
INNER JOIN Staff
ON Requests.SupvID = Staff.BadgeNum
WHERE Requests.RequestID = @RequestID

