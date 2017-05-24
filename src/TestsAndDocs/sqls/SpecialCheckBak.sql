USE [ITFormsTest]
GO
/****** Object:  StoredProcedure [dbo].[SpecialCheck]    Script Date: 5/12/2017 11:05:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpecialCheckBak](@RequestID INT) AS
-- SpecialCheck 110
--Runs when form is submitted by supv or IT
--Fills RequestHiddenFields table and returns any special emails that should be sent.
BEGIN
	DECLARE @SQLString NVARCHAR(500)  
	DECLARE @ParmDefinition NVARCHAR(500) = N'@RequestID INT,@TheCount INT OUTPUT';
	DECLARE @Criteria VARCHAR(MAX)
	DECLARE @Action VARCHAR(15)
	DECLARE @FieldsToHide VARCHAR(200)
	DECLARE @Email VARCHAR(200)
	DECLARE @TheCount INT
	DECLARE @CurrID INT
	DECLARE @PrevID INT = 0
	DECLARE @TempID INT
	DECLARE @Junk INT
	DECLARE @emailreturn TABLE
	(
	FieldID int,
	EmailAddress varchar(200),
	Descrip varchar(max),
	ItemValue varchar(max) 
	)

	--Get hidden field criteria
	DECLARE HideCur CURSOR
	FOR
	SELECT SpecialID, Criteria FROM SpecialCriteria 
	ORDER BY SpecialID
	OPEN HideCur
		FETCH HideCur
		INTO @CurrID, @Criteria

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @CurrID <> @PrevID  --first time for this SpecialFormID
		BEGIN
			-- Build the @SQLString 
			SET @SQLString = N'SELECT @TheCount = COUNT(*) WHERE 1=1 '
		END
		SET @SQLString = @SQLString + ' AND EXISTS(SELECT * FROM RequestItems WHERE RequestID = ' + CONVERT(VARCHAR(4),@RequestID)  + ' AND ' + @Criteria + ')'

		SET @TempID = @CurrID

		FETCH HideCur
		INTO @CurrID, @Criteria

		IF @CurrID <> @TempID OR @@FETCH_STATUS <> 0  -- last time for SpecialFormID
		BEGIN
			EXEC sp_executesql @SQLString, @ParmDefinition, @RequestID, @TheCount OUTPUT
			--print @TheCount
			IF @TheCount > 0  --special criteria matched. either mark the field as hidden or send an email
			BEGIN
				SELECT @Action = Action FROM Special WHERE ID = @TempID
				--print '..' + @Action + '..'
				IF @Action = 'HIDERESPONSE'
				BEGIN
					--Hide the fields
					INSERT INTO RequestHiddenFields (ReqID, FieldID)
					SELECT @RequestID,FieldsToHide 
					FROM SpecialFieldsToHide 
					WHERE SpecialID = @TempID 
					AND NOT EXISTS (
						SELECT * FROM RequestHiddenFields
						WHERE ReqID = @RequestID AND FieldID = FieldsToHide)
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
						SELECT sfef.ID, sfe.Email AS EmailAddress,  
						Forms.Descrip, req.ItemValue 
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
END
/*
------------------------------------------------------
-- How the @SQLString is constructed
SELECT COUNT(*) AS flag
WHERE 1=1

AND EXISTS(SELECT * FROM RequestItems WHERE 
	RequestID = 97 AND FieldID=386 AND NOT(ItemValue = '')
) 

AND EXISTS(SELECT * FROM RequestItems WHERE 
	RequestID = 97 AND FieldID=393 AND (ItemValue = 'on')
) 

*/
