USE [ITForms]
GO

/****** Object:  StoredProcedure [dbo].[AddChild]    Script Date: 5/24/2017 3:07:11 PM ******/
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

/****** Object:  StoredProcedure [dbo].[AddSister]    Script Date: 5/24/2017 3:07:11 PM ******/
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

/****** Object:  StoredProcedure [dbo].[AddSpecial]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddSpecial] (@Action VARCHAR(15), @Description VARCHAR(MAX)) AS
-- AddSpecial 'SENDEMAIL','fake'
BEGIN
 INSERT INTO Special VALUES(
 @Action,
 @Description
 )
SELECT @@IDENTITY AS ID
END
GO

/****** Object:  StoredProcedure [dbo].[AdminScreen]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[AdminScreen] AS
	SELECT * FROM Requests
	WHERE Completed = 0

	SELECT ID AS FormID, Descrip, Type FROM Forms
	WHERE Type IN('FORM','UNPUB')
	AND Deleted IS NULL
	ORDER BY Descrip

	SELECT ID AS FormID, Descrip FROM Forms
	WHERE Type = 'ROOT'

	SELECT ID, Action, Description
	FROM Special
	ORDER BY ID

	SELECT AdminID, Name FROM Admins
	ORDER BY Name



GO

/****** Object:  StoredProcedure [dbo].[DelAdmin]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[DelAdmin](@AdminID VARCHAR(15)) AS
DELETE FROM Admins
WHERE AdminID = @AdminID


GO

/****** Object:  StoredProcedure [dbo].[DelNode]    Script Date: 5/24/2017 3:07:11 PM ******/
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

/****** Object:  StoredProcedure [dbo].[DelSpecial]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[DelSpecial] (@SpecialID INT) AS
BEGIN
 DELETE Special
 WHERE ID = @SpecialID
END

GO

/****** Object:  StoredProcedure [dbo].[GetAdmin]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[GetAdmin](@AdminID VARCHAR(15)) AS
-- Main proc for UserAdmin screen. List subscribed nodes. Add new Admin if not already there.
-- GetAdmin '1027126'
BEGIN
	DECLARE @Name VARCHAR(200) = NULL
	DECLARE @EmailAddress VARCHAR(40) = NULL
	SELECT @Name = Name, @EMailAddress = EMailAddress
	FROM Staff
	WHERE BadgeNum = @AdminID

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

/****** Object:  StoredProcedure [dbo].[GetEmailForSupv]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[GetEmailForSupv](@BadgeNum VARCHAR(15)) AS
SELECT Name, EmailAddress
FROM Staff
WHERE BadgeNum = @BadgeNum




GO

/****** Object:  StoredProcedure [dbo].[GetEmailsForRequest]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[GetEmailsForRequest](@RequestID INT) AS
	--For a given supervisor's request, return the list of admin email addresses that have subscribed to selected nodes.
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

/****** Object:  StoredProcedure [dbo].[GetForm]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[GetForm] (@FormID INT, @RequestID INT = NULL, @View VARCHAR(10) = NULL) AS 
--Based on Nested Set Model here: http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/
-- If called with formid=0, the form will be looked up from requestid
-- GetForm 112
-- GetForm 0, 124
DECLARE @ReqDate datetime
DECLARE @HiddenFields TABLE (
	FieldID INT
)
IF @FormID = 0 --Pull the request, first figure out which form this is.
	BEGIN
		--Find the hidden fields for this request
		INSERT INTO @HiddenFields
		SELECT FieldID FROM RequestHiddenFields
		WHERE ReqID = @RequestID

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
		-- Supvervisors don't see any hidden fields
		IF @View = 'SUPV'
		BEGIN
			INSERT INTO @HiddenFields
			SELECT FieldToHide FROM SpecialFieldsToHide
		END
		SET @ReqDate = GETDATE()
	END

SELECT * FROM Requests WHERE RequestID = @RequestID
SELECT inr2.ID AS FormID, inr2.Type, inr2.Descrip, inr2.Required, inr2.ReqResp, inr2.HeaderRecord, ParentID, ItemValue FROM (
	SELECT inr.ID, inr.Type, inr.Descrip, inr.Required, inr.ReqResp, inr.HeaderRecord, inr.lft, (SELECT TOP 1 ID 
			   FROM Forms parent 
			   WHERE parent.lft < inr.lft AND parent.rgt > inr.rgt    
			   ORDER BY parent.rgt-inr.rgt ASC) AS ParentID
	FROM (
		SELECT node.ID, node.Required, node.ReqResp, node.HeaderRecord, --(COUNT(parent.ID) - 1) AS depth, 
		node.lft, node.rgt, node.Type, node.Descrip
		FROM Forms AS node
		INNER JOIN Forms AS parent
		ON node.lft BETWEEN parent.lft AND parent.rgt
		WHERE (node.Created <= @ReqDate AND (node.Deleted >= @ReqDate OR node.Deleted IS NULL))
		AND node.ID NOT IN (
			SELECT FieldID FROM @HiddenFields
		)
		GROUP BY node.ID, node.lft, node.rgt, node.Type, node.Descrip, node.Required, node.ReqResp, node.HeaderRecord
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

/****** Object:  StoredProcedure [dbo].[GetRequest]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[GetRequest](@RequestID INT) AS
	--
	--declare @RequestID INT = 75
	SELECT Staff.EMailAddress, SupvName, EnteredDate, headerXML
	FROM Requests
	INNER JOIN Staff
	ON Requests.SupvID = Staff.BadgeNum
	WHERE Requests.RequestID = @RequestID


GO

/****** Object:  StoredProcedure [dbo].[GetSpecial]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[GetSpecial] (@SpecialID INT) AS
-- GetSpecial 13   GetSpecial 4
BEGIN
 --Special
 SELECT sp.ID, sp.Action, sp.Description
 FROM Special sp
 WHERE ID = @SpecialID
 
 --Criteria
 SELECT 
 spc.Field, spc.IsNot, spc.ItExists, spc.IsValue, spc.HumanCriteria
 FROM SpecialCriteria spc
 WHERE SpecialID = @SpecialID

 --FieldsToHide
 SELECT Forms.ID, Forms.Type, Forms.Descrip
 FROM SpecialFieldsToHide spfth
 INNER JOIN Forms
 ON spfth.FieldToHide = Forms.ID
 WHERE spfth.SpecialID = @SpecialID

 --Email
 SELECT spe.Email,spef.FieldID,
 Forms.Type, Forms.Descrip
 FROM SpecialEmail spe
 LEFT JOIN SpecialEmailFields spef
 ON spe.SpecialID = spef.SpecialID
 INNER JOIN Forms
 ON spef.FieldID = Forms.ID
 WHERE spe.SpecialID = @SpecialID

 --Field List
 SELECT ID, Descrip, FormName 
 FROM GetFieldList 
 ORDER BY FormName, Sorter
END

GO

/****** Object:  StoredProcedure [dbo].[GetStaffList]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[GetStaffList](@SearchString VARCHAR(20)) AS
-- GetStaffList 'GUZY'
SELECT TOP 20 BadgeNum, Name, EMailAddress, MIN(sorter) AS sorter FROM (
	SELECT BadgeNum, Name, EMailAddress,1 as sorter
	FROM Staff
	WHERE Name LIKE @SearchString + '%'
	UNION
	SELECT BadgeNum, Name, EMailAddress,2 as sorter
	FROM Staff
	WHERE Name LIKE '%' + @SearchString + '%'
) AS inr
GROUP BY BadgeNum, Name, EMailAddress
ORDER BY sorter,Name

GO

/****** Object:  StoredProcedure [dbo].[IsAdminOrSupv]    Script Date: 5/24/2017 3:07:11 PM ******/
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

/****** Object:  StoredProcedure [dbo].[PublishForm]    Script Date: 5/24/2017 3:07:11 PM ******/
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

/****** Object:  StoredProcedure [dbo].[SearchXML]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[SearchXML](@SearchString VARCHAR(MAX)) AS
-- I created an XML index https://msdn.microsoft.com/en-us/library/bb934097.aspx
-- CREATE PRIMARY XML INDEX Requests_headerXML ON Requests (headerXML)
-- SearchXML 'Giz'
SET @SearchString = UPPER(@SearchString)
SELECT TOP 50
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

/****** Object:  StoredProcedure [dbo].[SpecialCheck]    Script Date: 5/24/2017 3:07:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SpecialCheck](@RequestID INT) AS
-- SpecialCheck 172
--Runs when form is submitted by supv or IT
--Fills RequestHiddenFields table and returns any special emails that should be sent.
BEGIN
	DECLARE @SQLString NVARCHAR(1000)  
	DECLARE @SQLStringALL NVARCHAR(MAX) = '' 
	DECLARE @ParmDefinition NVARCHAR(500) = N'@RequestID INT,@TheCount INT OUTPUT';
	
	DECLARE @CriteriaField INT
	DECLARE @CriteriaIsNot BIT  
	DECLARE @CriteriaItExists BIT
	DECLARE @CriteriaIsValue NVARCHAR(MAX)

	DECLARE @Action VARCHAR(15)
	DECLARE @Email VARCHAR(200)
	DECLARE @TheCount INT
	DECLARE @CurrID INT
	DECLARE @PrevID INT = 0
	DECLARE @TempID INT
	DECLARE @Junk INT
	DECLARE @emailreturn TABLE
	(
	SpecialID int,
	FieldID int,
	EmailAddress varchar(200),
	Descrip varchar(max),
	ItemValue varchar(max) 
	)

	--Get hidden field criteria
	DECLARE HideCur CURSOR
	FOR
	SELECT SpecialID, Field, IsNot, ItExists, IsValue FROM SpecialCriteria 
	ORDER BY SpecialID
	OPEN HideCur
		FETCH HideCur
		INTO @CurrID, @CriteriaField, @CriteriaIsNot, @CriteriaItExists, @CriteriaIsValue

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @CurrID <> @PrevID  --first time for this SpecialFormID
		BEGIN
			-- Build the @SQLString 
			SET @SQLString = N'SELECT @TheCount = COUNT(*) WHERE 1=1 '
		END
		SET @SQLString = @SQLString + ' AND ' + CASE WHEN @CriteriaIsNot = 1 THEN 'NOT' ELSE '' END  + ' EXISTS(SELECT * FROM RequestItems WHERE RequestID = ' + CONVERT(NVARCHAR(10),@RequestID)  
			+ ' AND FieldID = ' + CONVERT(NVARCHAR(10),@CriteriaField)  
			+ 
			CASE WHEN @CriteriaItExists = 1 THEN ' AND ItemValue <> '''''
				 ELSE ' AND ItemValue = ''' + @CriteriaIsValue + '''' END
			+ ')'
																															print '.@SQLStringUPTOP.' + @SQLString
																															print '.@CurrID.' + CONVERT(NVARCHAR(10),@CurrID)
		SET @TempID = @CurrID

		FETCH HideCur
		INTO @CurrID, @CriteriaField, @CriteriaIsNot, @CriteriaItExists, @CriteriaIsValue

		IF @CurrID <> @TempID OR @@FETCH_STATUS <> 0  -- last time for SpecialFormID
		BEGIN
			SET @SQLStringALL = @SQLStringALL + @SQLString
			EXEC sp_executesql @SQLString, @ParmDefinition, @RequestID, @TheCount OUTPUT
																															print '.@TheCount.' + CONVERT(NVARCHAR(10),@TheCount)  
																															print '.@SQLString.' + @SQLString
			IF @TheCount > 0  --special criteria matched. either mark the field as hidden or send an email
			BEGIN
				SELECT @Action = Action FROM Special WHERE ID = @TempID
																															print '.@Action.' + @Action + '.@Action.'
				IF @Action = 'HIDERESPONSE'
				BEGIN
					--Hide the fields
					INSERT INTO RequestHiddenFields (ReqID, FieldID)
					SELECT @RequestID,FieldToHide 
					FROM SpecialFieldsToHide 
					WHERE SpecialID = @TempID 
					AND NOT EXISTS (
						SELECT * FROM RequestHiddenFields
						WHERE ReqID = @RequestID AND FieldID = FieldToHide)
				END
				IF @Action = 'SENDEMAIL'
				BEGIN
					SELECT @Junk = SpecialID 
					FROM RequestSpecialEMailSent
					WHERE RequestID = @RequestID
					AND SpecialID = @TempID
					IF @@ROWCOUNT = 0  --we haven't already sent that one
					BEGIN

						INSERT INTO @emailreturn
						SELECT @TempID, sfef.ID, sfe.Email AS EmailAddress,  
						Forms.Descrip, 
						CASE WHEN Forms.Type = 'NODE' THEN 'Requested' ELSE ItemValue END
						FROM SpecialEmail sfe --returns email list
						INNER JOIN
						SpecialEmailFields sfef
						ON sfe.SpecialID = sfef.SpecialID
						INNER JOIN Forms
						ON sfef.FieldID = Forms.ID
						LEFT JOIN (
							SELECT *
							FROM RequestItems 
							WHERE RequestID = @RequestID
						)req
						ON sfef.FieldID = req.FieldID
						WHERE sfe.SpecialID = @TempID

						INSERT INTO RequestSpecialEMailSent(RequestID,SpecialID)
						VALUES(@RequestID,@TempID)
					END
				END
			END
		END
		SET @PrevID = @TempID
	END
	CLOSE HideCur
	DEALLOCATE HideCur

	SELECT * FROM @emailreturn 
	ORDER BY EmailAddress,FieldID

	SELECT @SQLStringALL AS SQLString --for debugging
END
/*
------------------------------------------------------
-- How the @SQLString is constructed
SELECT COUNT(*) AS flag
WHERE 1=1

AND NOT EXISTS(SELECT * FROM RequestItems WHERE 
	RequestID = 97 AND FieldID=386 AND (ItemValue = '')
) 

AND EXISTS(SELECT * FROM RequestItems WHERE 
	RequestID = 97 AND FieldID=393 AND (ItemValue = 'on')
) 

*/

GO

/****** Object:  StoredProcedure [dbo].[ToggleEmail]    Script Date: 5/24/2017 3:07:11 PM ******/
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

/****** Object:  StoredProcedure [dbo].[ToggleHeaderRecord]    Script Date: 5/24/2017 3:07:11 PM ******/
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

/****** Object:  StoredProcedure [dbo].[ToggleReqResp]    Script Date: 5/24/2017 3:07:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[ToggleReqResp] (@FormID INT) AS
-- Toggles form ReqResp  true/false
-- ToggleReqResp 4
BEGIN
	UPDATE f
	SET ReqResp = opt 
	FROM Forms f
	CROSS JOIN (
		SELECT 1 AS opt UNION SELECT 0
	) AS opts
	WHERE opt <> ReqResp
	AND ID = @FormID
END

GO

/****** Object:  StoredProcedure [dbo].[ToggleRequired]    Script Date: 5/24/2017 3:07:12 PM ******/
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

/****** Object:  StoredProcedure [dbo].[UpsertRequest]    Script Date: 5/24/2017 3:07:12 PM ******/
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
	--Finding counter examples: Uncompleted response sections
	SELECT @Completed =  CASE WHEN NOT EXISTS (
		SELECT RequestItems.ItemValue
		FROM RequestItems 
		INNER JOIN Forms 
		ON RequestItems.FieldID = Forms.ID
		WHERE Forms.Type = 'RESPONSE' AND RequestItems.RequestID = @RequestID
		GROUP BY RequestItems.ItemValue
		HAVING RequestItems.ItemValue <> 'true'
	)
	--Finding counter examples: ReqResp fields (that are not hidden) not filled in
	AND NOT EXISTS (
		SELECT Forms.*, ri.*
		FROM Forms 
		LEFT JOIN (
			SELECT *
			FROM Forms 
			INNER JOIN  RequestItems
			ON RequestItems.FieldID = Forms.ID
			WHERE RequestItems.RequestID = @RequestID
		) AS ri
		ON ri.FieldID = Forms.ID
		INNER JOIN (
			-- get form for this request
			SELECT Forms.lft AS Formlft, Forms.rgt AS Formrgt
			FROM RequestItems 
			INNER JOIN Forms 
			ON RequestItems.FieldID = Forms.ID
			WHERE RequestItems.RequestID = @RequestID
			AND (Forms.Type IN ('FORM', 'UNPUB'))
		) theform
		ON Forms.lft > theform.Formlft AND Forms.rgt < theform.Formrgt
		WHERE Forms.ReqResp = 1  
		AND (ri.ItemValue IS NULL OR ri.ItemValue = '')
		AND Forms.ID NOT IN (
			SELECT FieldID
			FROM RequestHiddenFields
			WHERE ReqID = @RequestID
		)
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


