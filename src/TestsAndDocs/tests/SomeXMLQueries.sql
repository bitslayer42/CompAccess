--Query XML 
-- https://www.simple-talk.com/sql/learn-sql-server/using-the-for-xml-clause-to-return-query-results-as-xml/
-- https://www.simple-talk.com/sql/learn-sql-server/the-xml-methods-in-sql-server/
-- https://www.simple-talk.com/sql/learn-sql-server/working-with-the-xml-data-type-in-sql-server/
---------------------------------------------------------------------------------------------------------------------
declare @t table (data xml)

insert
into @t
select
'
<employees>
	<employee id="1">
		<firstname> Jay</firstname><lastname> Fox </lastname>
	</employee>
	<employee id="2"><firstname> Mike</firstname><lastname> Smith </lastname>
	</employee>
</employees>
'

declare @deteteid int=2,
        @insertedValue xml
        
set @insertedValue='
<employee id="2">
	<firstname> Joe</firstname><lastname> black </lastname><address><st> some where </st><city> some city </city><state> some state</state></address>
</employee>
'

select * from @t

update @t
set data.modify('delete /employees/employee[@id =sql:variable("@deteteid")]'
)
select * from @t
update @t
set data.modify('insert sql:variable("@insertedValue") as last into /employees[1]'
)
select * from @t
-----------------------------
go

declare @LoggedInName VARCHAR(100) = 'Wilson, Jon T.'
declare @Editdate datetime = GETDATE()
DECLARE @xmlrow xml

set @xmlrow = '<row/>'
set @xmlrow.modify('insert <UserName>{sql:variable("@LoggedInName")}</UserName> into (/row)[1]')
set @xmlrow.modify('insert <DateMod>{sql:variable("@EditDate")}</DateMod> into (/row)[1]')
select @xmlrow

--create empty root node
update Requests
set editedXML = '<root />' --(SELECT NULL FOR XML PATH('root'))
where RequestID = 108

select * from Requests where RequestID = 108

--insert new row node
update Requests
set editedXML.modify('insert sql:variable("@xmlrow") as last into (/root)[1]')
where RequestID = 108

select * from Requests where RequestID = 108

/* --INSERTING INTO ANOTHER VARIABLE
DECLARE @xml2 xml
set @xml2 = '<root/>'
set @xml2.modify('insert sql:variable("@xml") as last into  (/root)[1]')
select @xml2

*/
GO
-----------------------------------------------
-- These two queries return the same thing (PATH vs. RAW)
SELECT CASE WHEN Forms.Type = 'FORM' THEN 'Form' ELSE Descrip END AS Col,
		RequestItems.ItemValue ItemValue 
		FROM Requests req
		INNER JOIN RequestItems
		ON req.RequestID = RequestItems.RequestID
		INNER JOIN Forms
		ON RequestItems.FieldID = Forms.ID
		WHERE Completed = 0
		AND HeaderRecord = 1
		AND req.RequestID = 107 --@RequestID
		FOR XML PATH, ROOT

SELECT CASE WHEN Forms.Type = 'FORM' THEN 'Form' ELSE Descrip END AS Col,
		RequestItems.ItemValue ItemValue 
		FROM Requests req
		INNER JOIN RequestItems
		ON req.RequestID = RequestItems.RequestID
		INNER JOIN Forms
		ON RequestItems.FieldID = Forms.ID
		WHERE Completed = 0
		AND HeaderRecord = 1
		AND req.RequestID = 107 --@RequestID
		FOR XML RAW ('row'), ROOT, ELEMENTS