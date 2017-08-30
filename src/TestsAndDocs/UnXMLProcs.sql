
ALTER PROC [dbo].[GetAdmin](@AdminID VARCHAR(15)) AS
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


GO

/****** Object:  StoredProcedure [dbo].[SearchXML]    Script Date: 8/29/2017 10:48:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROC [dbo].[SearchXML](@SearchString VARCHAR(MAX)) AS
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



ALTER PROC [dbo].[UpsertRequest](@LoggedInID VARCHAR(15), @LoggedInName VARCHAR(100), @Items XML, @ReqID INT = NULL) AS
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
		WHERE --Completed = 0 AND
		 HeaderRecord = 1
		AND req.RequestID = @RequestID
		FOR XML PATH, ROOT)
	
	UPDATE Requests SET 
	HeaderXML = @xml,
	Completed = @Completed
	WHERE RequestID = @RequestID

	SELECT @RequestID AS RequestID, @Completed AS Completed
END




GO


