
<cfstoredproc procedure="getForm" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="0">
  <cfprocparam cfsqltype="cf_sql_integer" value="32">
  <cfprocresult resultset="1" name="header">
  <cfprocresult resultset="2" name="detail">
</cfstoredproc>
<cfstoredproc procedure="GetEmailsForRequest" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="32">
  <cfprocresult name="emails">
</cfstoredproc>

<cfset xmlheader = XmlParse(header.HeaderXML)>
<cfset emailsubject = "Computer Access">
<cfoutput>
      <cfloop array="#xmlheader.root.xmlchildren#" index="i" >
        <cfset emailsubject = emailsubject & "-" & i.itemvalue.xmltext>
        #i.col.xmltext#: #i.itemvalue.xmltext#<br>
      </cfloop>
</cfoutput> 
<hr>
<div style="width:400px">
<table>
<cfoutput>
      <cfloop query="detail">
        <cfif ItemValue NEQ "" AND Type NEQ "FORM" AND Type NEQ "RESPONSE">
          <cfif Type EQ "NODE">
            <tr><th colspan="2">#Descrip#</th></tr>
          <cfelse>
            <tr><td>#Descrip#</td><td>#ItemValue#</td></tr>
          </cfif>
        </cfif>
      </cfloop>
</cfoutput> 
</table>
</div>
    
<cfif emails.RecordCount GT 0>
  <cfmail to = "#emails.Name#<#emails.EmailAddress#>" 
  from = "cpisc@msj.org"
  subject = "#emailsubject#"
  type="html">
  <html>
  <head>
     <style type="text/css">
      td{border:1px solid ##CCC};
     </style>
  </head>
  <body>
    <div style="width:400px">
    <a href="https://ccp1.msj.org/login/login/CompAccess/index.cfm/ADMIN/0/<cfoutput>#header.RequestID#</cfoutput>">
      EDIT THIS COMPUTER ACCESS AUTHORIZATION E-FORM.</a><br>
    
    Submitted By: #header.SupvName# <br>
    On #DateFormat(header.EnteredDate,"M/D/YY")# at #TimeFormat(header.EnteredDate,"HH:MM")#<br>
      <table style="width:100%; padding-left:5px;font-family:Arial, Helvetica, sans-serif;">
      <cfloop query="detail">
        <cfif ItemValue NEQ "" AND Type NEQ "FORM" AND Type NEQ "RESPONSE">
          <cfif Type EQ "NODE">
            <tr><td colspan="2" style="text-align:center;"><b>Access requested for: <span style="color:orange;">#Descrip#</span></b></td></tr>
          <cfelse>
            <tr><td style="text-align:right; padding-right:5px;">#Descrip#</td><td><b>#ItemValue#</b></td></tr>
          </cfif>
        </cfif>
      </cfloop>
      </table>
    </div>
  </body>
  </html>
  </cfmail>
</cfif>
    
    
    <!--- 
 <cfdump var="#header#">
  <cfdump var="#detail#">
   <cfdump var="#emails#">
      <cfdump var="#xmlheader#">
     --->