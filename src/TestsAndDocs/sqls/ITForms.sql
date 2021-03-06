USE [master]
GO
/****** Object:  Database [ITForms]    Script Date: 6/7/2017 7:58:12 AM ******/
CREATE DATABASE [ITForms] ON  PRIMARY 
( NAME = N'ITForms', FILENAME = N'e:\MSSQL\Data\ITForms.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'ITForms_log', FILENAME = N'f:\MSSQL\Log\ITForms_log.ldf' , SIZE = 1536KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [ITForms] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ITForms].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ITForms] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ITForms] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ITForms] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ITForms] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ITForms] SET ARITHABORT OFF 
GO
ALTER DATABASE [ITForms] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ITForms] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [ITForms] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ITForms] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ITForms] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ITForms] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ITForms] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ITForms] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ITForms] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ITForms] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ITForms] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ITForms] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ITForms] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ITForms] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ITForms] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ITForms] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ITForms] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ITForms] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ITForms] SET RECOVERY FULL 
GO
ALTER DATABASE [ITForms] SET  MULTI_USER 
GO
ALTER DATABASE [ITForms] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ITForms] SET DB_CHAINING OFF 
GO
USE [ITForms]
GO
/****** Object:  User [ColdFusionUser]    Script Date: 6/7/2017 7:58:12 AM ******/
CREATE USER [ColdFusionUser] FOR LOGIN [ColdFusionUser] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [db_executor]    Script Date: 6/7/2017 7:58:12 AM ******/
CREATE ROLE [db_executor]
GO
ALTER ROLE [db_executor] ADD MEMBER [ColdFusionUser]
GO
ALTER ROLE [db_datareader] ADD MEMBER [ColdFusionUser]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [ColdFusionUser]
GO
/****** Object:  StoredProcedure [dbo].[AddChild]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[AddSister]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[AddSpecial]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[AddSpecialCriteria]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[AddSpecialCriteria]
@SpecialID int,
@Field int,
@IsNot bit,
@ItExists bit,
@IsValue varchar(max), 
@HumanCriteria varchar(max) AS
INSERT INTO [dbo].[SpecialCriteria]
([SpecialID]
,[Field]
,[IsNot]
,[ItExists]
,[IsValue]
,[HumanCriteria])
VALUES
(
@SpecialID,
@Field ,
@IsNot ,
@ItExists ,
@IsValue , 
@HumanCriteria
)
SELECT @@ERROR


GO
/****** Object:  StoredProcedure [dbo].[AddSpecialEmail]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[AddSpecialEmail]
@SpecialID int,
@Email varchar(200) AS
INSERT INTO [dbo].SpecialEmail
([SpecialID]
,Email)
VALUES
(
@SpecialID,
@Email 
)
SELECT @@ERROR


GO
/****** Object:  StoredProcedure [dbo].[AddSpecialEmailFields]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[AddSpecialEmailFields]
@SpecialID int,
@Field int AS
INSERT INTO [dbo].SpecialEmailFields
([SpecialID]
,FieldID)
VALUES
(
@SpecialID,
@Field
)
SELECT @@ERROR


GO
/****** Object:  StoredProcedure [dbo].[AddSpecialHiddenFields]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[AddSpecialHiddenFields]
@SpecialID int,
@Field int AS
INSERT INTO [dbo].SpecialFieldsToHide
([SpecialID]
,FieldToHide)
VALUES
(
@SpecialID,
@Field 
)
SELECT @@ERROR


GO
/****** Object:  StoredProcedure [dbo].[AdminScreen]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[DelAdmin]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[DelAdmin](@AdminID VARCHAR(15)) AS
DELETE FROM Admins
WHERE AdminID = @AdminID



GO
/****** Object:  StoredProcedure [dbo].[DelCriteria]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[DelCriteria] (@ID INT) AS
DELETE FROM SpecialCriteria
WHERE ID = @ID




GO
/****** Object:  StoredProcedure [dbo].[DelEmail]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[DelEmail] (@ID INT) AS
DELETE FROM SpecialEmail
WHERE ID = @ID




GO
/****** Object:  StoredProcedure [dbo].[DelEmailFields]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[DelEmailFields] (@ID INT) AS
DELETE FROM SpecialEmailFields
WHERE ID = @ID




GO
/****** Object:  StoredProcedure [dbo].[DelHiddenFields]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[DelHiddenFields] (@ID INT) AS
DELETE FROM SpecialFieldsToHide
WHERE ID = @ID




GO
/****** Object:  StoredProcedure [dbo].[DelNode]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[DelSpecial]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[GetAdmin]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[GetEmailForSupv]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[GetEmailForSupv](@BadgeNum VARCHAR(15)) AS
SELECT Name, EmailAddress
FROM Staff
WHERE BadgeNum = @BadgeNum





GO
/****** Object:  StoredProcedure [dbo].[GetEmailsForRequest]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[GetForm]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[GetForm] (@FormID INT, @RequestID INT = NULL, @View VARCHAR(10) = NULL) AS 
--Based on Nested Set Model here: http://mikehillyer.com/articles/managing-hierarchical-data-in-mysql/
-- If called with formid=0, the form will be looked up from requestid
-- GetForm 2, NULL, 'SUPV'
-- GetForm 0, 141
DECLARE @ReqDate datetime
DECLARE @HiddenFields TABLE (
	FieldID INT
)
IF @FormID = 0 --Pull the request, first figure out which form this is.
	BEGIN
		--Find the hidden fields for this request
		INSERT INTO @HiddenFields
		SELECT inr.ID FROM RequestHiddenFields rhf
		INNER JOIN Forms
		ON rhf.FieldID = Forms.ID
		INNER JOIN Forms inr
		ON Forms.lft <= inr.lft
		AND Forms.rgt >= inr.rgt
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
			SELECT DISTINCT inr.ID FROM SpecialFieldsToHide sfth
			INNER JOIN Special
			ON sfth.SpecialID = Special.ID
			INNER JOIN Forms
			ON sfth.FieldToHide = Forms.ID
			INNER JOIN Forms inr
			ON Forms.lft <= inr.lft
			AND Forms.rgt >= inr.rgt
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
/****** Object:  StoredProcedure [dbo].[GetOptions]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[GetOptions]( @FormID INT) AS
-- GetOptions 8
	SELECT inr.ID, inr.Descrip FROM (
		SELECT Forms.*, (SELECT TOP 1 ID 
				   FROM Forms parent 
				   WHERE parent.lft < forms.lft AND parent.rgt > forms.rgt    
				   ORDER BY parent.rgt-forms.rgt ASC) AS ParentID
		FROM Forms
	) inr
	WHERE ParentID = @FormID
	ORDER BY inr.lft

GO
/****** Object:  StoredProcedure [dbo].[GetRequest]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[GetSpecial]    Script Date: 6/7/2017 7:58:13 AM ******/
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
 spc.ID, spc.Field, spc.IsNot, spc.ItExists, spc.IsValue, spc.HumanCriteria
 FROM SpecialCriteria spc
 WHERE SpecialID = @SpecialID

 --FieldsToHide
 SELECT spfth.ID, Forms.Type, Forms.Descrip
 FROM SpecialFieldsToHide spfth
 INNER JOIN Forms
 ON spfth.FieldToHide = Forms.ID
 WHERE spfth.SpecialID = @SpecialID

 --Email 
 SELECT ID, Email
 FROM SpecialEmail 
 WHERE SpecialID = @SpecialID

 -- EmailFields
 SELECT spef.ID, spef.FieldID,
 Forms.Type, Forms.Descrip
 FROM SpecialEmailFields spef
 INNER JOIN Forms
 ON spef.FieldID = Forms.ID
 WHERE spef.SpecialID = @SpecialID

 --Field List
 SELECT ID, Type, Descrip, FormName 
 FROM GetFieldList 
 ORDER BY FormName, Sorter
END

GO
/****** Object:  StoredProcedure [dbo].[GetStaffList]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[IsAdminOrSupv]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[PublishForm]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[SearchXML]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[SpecialCheck]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SpecialCheck](@RequestID INT) AS
-- SpecialCheck 158
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
	SELECT SpecialID, Field, IsNot, ItExists , ISNULL(IsValue,'') FROM SpecialCriteria 
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
/****** Object:  StoredProcedure [dbo].[ToggleEmail]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[ToggleHeaderRecord]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[ToggleReqResp]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[ToggleRequired]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  StoredProcedure [dbo].[UpsertRequest]    Script Date: 6/7/2017 7:58:13 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetParent]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetParent](@ID INT) 
-- SELECT dbo.GetParent(24)
RETURNS INT
AS
BEGIN
	DECLARE @ParID INT 
	SELECT @ParID = ID FROM Forms WHERE lft = (
		SELECT MAX(parent.lft) AS parlft from Forms parent
		INNER JOIN (
			SELECT * FROM Forms
			WHERE ID = @ID
		) As child
		ON  parent.lft < child.lft
		AND parent.rgt > child.rgt
	)
	RETURN @ParID
END

GO
/****** Object:  Table [dbo].[_FormsRedo]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[_FormsRedo](
	[Type] [varchar](10) NULL,
	[Descrip] [varchar](max) NULL,
	[lft] [int] NULL,
	[rgt] [int] NULL,
	[Created] [datetime] NOT NULL,
	[Deleted] [datetime] NULL,
	[HeaderRecord] [bit] NULL,
	[Required] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AdminEmails]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AdminEmails](
	[AdminID] [varchar](15) NOT NULL,
	[SubscribedNode] [int] NOT NULL,
 CONSTRAINT [PK_AdminEmails] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC,
	[SubscribedNode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Admins]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Admins](
	[AdminID] [varchar](15) NOT NULL,
	[Name] [varchar](100) NULL,
	[EMailAddress] [varchar](40) NULL,
 CONSTRAINT [PK_Admin] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AdminsREAL]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AdminsREAL](
	[AdminID] [varchar](15) NOT NULL,
	[Name] [varchar](100) NULL,
	[EMailAddress] [varchar](40) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Forms]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Forms](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](10) NULL,
	[Descrip] [varchar](max) NULL,
	[lft] [int] NULL,
	[rgt] [int] NULL,
	[Created] [datetime] NULL,
	[Deleted] [datetime] NULL,
	[HeaderRecord] [bit] NULL,
	[Required] [bit] NULL,
	[ReqResp] [bit] NULL,
 CONSTRAINT [PK_nested_category] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RequestHiddenFields]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RequestHiddenFields](
	[ReqID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
 CONSTRAINT [PK_HiddenFields] PRIMARY KEY CLUSTERED 
(
	[ReqID] ASC,
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RequestItems]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RequestItems](
	[RequestID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
	[ItemValue] [varchar](max) NULL,
 CONSTRAINT [PK_RequestItem] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC,
	[FieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Requests]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Requests](
	[RequestID] [int] IDENTITY(1,1) NOT NULL,
	[SupvID] [varchar](15) NULL,
	[SupvName] [varchar](100) NULL,
	[EnteredDate] [datetime] NULL,
	[Completed] [bit] NULL,
	[headerXML] [xml] NULL,
	[EditedXML] [xml] NULL,
 CONSTRAINT [PK_Request] PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RequestSpecialEMailSent]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RequestSpecialEMailSent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RequestID] [int] NOT NULL,
	[SpecialID] [int] NOT NULL,
 CONSTRAINT [PK_RequestSFEMailSent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Special]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Special](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Action] [varchar](15) NOT NULL,
	[Description] [varchar](max) NULL,
 CONSTRAINT [PK_SpecialFork] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SpecialCriteria]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SpecialCriteria](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SpecialID] [int] NULL,
	[Field] [int] NULL,
	[IsNot] [bit] NULL,
	[ItExists] [bit] NULL,
	[IsValue] [varchar](max) NULL,
	[HumanCriteria] [varchar](max) NULL,
 CONSTRAINT [PK_SpecialCriteria] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SpecialEmail]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SpecialEmail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SpecialID] [int] NOT NULL,
	[Email] [varchar](200) NOT NULL,
 CONSTRAINT [PK_SpecialEmail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SpecialEmailFields]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SpecialEmailFields](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SpecialID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
 CONSTRAINT [PK_SpecialForkEmailFields] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SpecialFieldsToHide]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SpecialFieldsToHide](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SpecialID] [int] NOT NULL,
	[FieldToHide] [int] NOT NULL,
 CONSTRAINT [PK_SpecialFieldsToHide] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[GetFieldList]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[GetFieldList] AS
-- Used by SP GetSpecial
-- select * from GetFieldList ORDER BY FormName, Sorter
SELECT node.ID, node.Type, node.Descrip, form.Descrip AS FormName, node.lft AS Sorter FROM (
	SELECT * FROM Forms
	WHERE Type IN ('INPUT','DATE','RADIO','SELECT','CHECKBOX','NODE','MESSAGE')
	AND Deleted IS NULL
) AS node
INNER JOIN (
	SELECT * FROM Forms
	WHERE Type IN ('FORM','UNPUB')
	AND Deleted IS NULL
) AS form
ON form.lft < node.lft
AND form.rgt > node.rgt


GO
/****** Object:  View [dbo].[GetNodeList]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[GetNodeList] AS
-- Used by SP GetAdmin
-- select * from GetNodeList ORDER BY Sorter
SELECT node.ID, node.Descrip, form.Descrip AS FormName, node.lft AS Sorter FROM (
	SELECT * FROM Forms
	WHERE Type = 'NODE'
	AND Deleted IS NULL
) AS node
INNER JOIN (
	SELECT * FROM Forms
	WHERE Type IN ('FORM','UNPUB')
	AND Deleted IS NULL
) AS form
ON form.lft < node.lft
AND form.rgt > node.rgt



GO
/****** Object:  View [dbo].[Staff]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[Staff] AS 
SELECT BadgeNum, Name, EmailAddress
  FROM [data-other-sources].dbo._Staff





GO
/****** Object:  View [dbo].[vSpecialEmail]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSpecialEmail]
AS
SELECT        dbo.Special.ID, dbo.Special.Action, dbo.SpecialCriteria.Field, dbo.SpecialCriteria.IsNot, dbo.SpecialCriteria.IsValue, dbo.SpecialCriteria.HumanCriteria, 
                         Forms_1.Type AS CriteriaFieldType, Forms_1.Descrip AS CriteriaField, dbo.SpecialEmail.Email, dbo.SpecialEmailFields.FieldID, dbo.Forms.Type AS EmailFieldType, 
                         dbo.Forms.Descrip AS EmailField
FROM            dbo.SpecialEmail RIGHT OUTER JOIN
                         dbo.Special LEFT OUTER JOIN
                         dbo.Forms RIGHT OUTER JOIN
                         dbo.SpecialEmailFields ON dbo.Forms.ID = dbo.SpecialEmailFields.FieldID ON dbo.Special.ID = dbo.SpecialEmailFields.SpecialID ON 
                         dbo.SpecialEmail.SpecialID = dbo.Special.ID LEFT OUTER JOIN
                         dbo.SpecialCriteria LEFT OUTER JOIN
                         dbo.Forms AS Forms_1 ON dbo.SpecialCriteria.Field = Forms_1.ID ON dbo.Special.ID = dbo.SpecialCriteria.SpecialID
WHERE        (dbo.Special.Action = 'SENDEMAIL')



GO
/****** Object:  View [dbo].[vSpecialToHide]    Script Date: 6/7/2017 7:58:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vSpecialToHide]
AS
SELECT        dbo.Special.ID, dbo.Special.Action, dbo.SpecialCriteria.Field, dbo.SpecialCriteria.IsNot, dbo.SpecialCriteria.IsValue, dbo.SpecialCriteria.HumanCriteria, 
                         dbo.SpecialFieldsToHide.FieldToHide, dbo.Forms.Type, dbo.Forms.Descrip
FROM            dbo.Forms RIGHT OUTER JOIN
                         dbo.SpecialFieldsToHide ON dbo.Forms.ID = dbo.SpecialFieldsToHide.FieldToHide RIGHT OUTER JOIN
                         dbo.Special ON dbo.SpecialFieldsToHide.SpecialID = dbo.Special.ID LEFT OUTER JOIN
                         dbo.SpecialCriteria ON dbo.Special.ID = dbo.SpecialCriteria.SpecialID
WHERE        (dbo.Special.Action = 'HIDERESPONSE')

GO
ALTER TABLE [dbo].[Forms] ADD  CONSTRAINT [DF_Forms_HeaderRecord]  DEFAULT ((0)) FOR [HeaderRecord]
GO
ALTER TABLE [dbo].[Forms] ADD  CONSTRAINT [DF_Forms_Required]  DEFAULT ((0)) FOR [Required]
GO
ALTER TABLE [dbo].[Forms] ADD  CONSTRAINT [DF_Forms_ReqResp]  DEFAULT ((0)) FOR [ReqResp]
GO
ALTER TABLE [dbo].[AdminEmails]  WITH CHECK ADD  CONSTRAINT [fk_AdminEmails] FOREIGN KEY([AdminID])
REFERENCES [dbo].[Admins] ([AdminID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AdminEmails] CHECK CONSTRAINT [fk_AdminEmails]
GO
ALTER TABLE [dbo].[RequestItems]  WITH CHECK ADD  CONSTRAINT [fk_RequestItems] FOREIGN KEY([RequestID])
REFERENCES [dbo].[Requests] ([RequestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RequestItems] CHECK CONSTRAINT [fk_RequestItems]
GO
ALTER TABLE [dbo].[SpecialCriteria]  WITH CHECK ADD  CONSTRAINT [FK_SpecialCriteria] FOREIGN KEY([SpecialID])
REFERENCES [dbo].[Special] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SpecialCriteria] CHECK CONSTRAINT [FK_SpecialCriteria]
GO
USE [master]
GO
ALTER DATABASE [ITForms] SET  READ_WRITE 
GO
