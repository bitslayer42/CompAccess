
-------------------------------------------------------------------
ALTER PROC InsRequest(@FormID VARCHAR(20), @EmpName VARCHAR(100), @EnteredDate DATE, @Items XML) AS
BEGIN
	DECLARE @RequestID INT
	INSERT INTO Requests (FormID, EmpName, EnteredDate)
	VALUES(@FormID, @EmpName, @EnteredDate)

	SET @RequestID = @@IDENTITY

    INSERT INTO RequestItems (RequestID, FieldID, ItemValue)
    SELECT @RequestID,
        tab.col.value( 'Field[1]', 'int' ) AS FieldID,
        tab.col.value( 'Value[1]', 'varchar(max)' ) AS ItemValue
    FROM @Items.nodes('reqrows/row') tab(col)
END
GO

-------------------------------------------------------------------
exec InsRequest @FormID = 'CCPIT', @EmpName = 'J. Staffy Wilson', @EnteredDate = '2017-02-01', @Items = N'
<reqrows>
	<row>
		<Field>9</Field>
		<Value>J. Staffy Wilson</Value>
	</row>
	<row>
		<Field>35</Field>
		<Value>1027126</Value>
	</row>
</reqrows>
'

GO
