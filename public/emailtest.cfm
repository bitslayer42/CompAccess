
<cfquery name="emails" datasource="ITForms">
select 'Jon.Wilson@msj.org' AS EMailAddress
UNION
select 'jontwilson@gmail.com'
</cfquery>

<cfset EmailList = "">

<cfoutput query="emails">
<cfset EmailList = ListAppend(EmailList,#EMailAddress#)>
</cfoutput>

<cfif emails.RecordCount GT 0>
  <cfmail to="#EmailList#" 
  from = "cpisc@msj.org"
  subject = "test"
  type="html">
  <html>
  <head>
     <style type="text/css">
      td{border:1px solid ##CCC};
     </style>
  </head>
  <body>
    <div style="width:400px">
    Test email sent to #EmailList#<br>
 
    </div>
  </body>
  </html>
  </cfmail>
</cfif>
