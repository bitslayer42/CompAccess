
<cfset ItemStr = "<reqrows>">
<cfloop collection="#form#" item="theField">
  <cfif theField NEQ "fieldNames" AND theField NEQ "DateEntered" AND theField NEQ "LoggedInID" 
        AND theField NEQ "LoggedInName" AND theField NEQ "ReqID">
  <cfset ItemStr = ItemStr & "<row><Field>#XmlFormat(theField)#</Field><Value>#XmlFormat(form[theField])#</Value></row>" >
  </cfif>
</cfloop>
<cfset ItemStr = ItemStr & "</reqrows>">

<cfset LoggedInID = form.LoggedInID>
<cfset LoggedInName = form.LoggedInName>

<cfstoredproc procedure="UpsertRequest" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#LoggedInID#">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#LoggedInName#">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#ItemStr#">
  <cfprocparam cfsqltype="cf_sql_integer" value="#ReqID#">
  <cfprocresult name="ret">
</cfstoredproc>

<cfif ret.Completed EQ 1> <!--- form complete: send emails --->
  <cfset theReqID = ret.RequestID>
  <cfstoredproc procedure="GetEmailsForRequest" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#theReqID#">
    <cfprocresult name="emails">
  </cfstoredproc>
  <cfstoredproc procedure="getForm" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="0">
    <cfprocparam cfsqltype="cf_sql_integer" value="#theReqID#">
    <cfprocresult resultset="1" name="header">
    <cfprocresult resultset="2" name="detail">
  </cfstoredproc>
  <cfstoredproc procedure="GetEmailForSupv" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#header.SupvID#">
    <cfprocresult name="emails">
  </cfstoredproc>  

  <cfset xmlheader = XmlParse(header.HeaderXML)>
  <cfset emailsubject = "COMPLETED Computer Access">
  <cfoutput>
        <cfloop array="#xmlheader.root.xmlchildren#" index="i" >
          <cfset emailsubject = emailsubject & "-" & i.itemvalue.xmltext>
        </cfloop>
  </cfoutput> 
  
  <cfmail to = "#emails.EmailAddress#" 
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
    <p>This request has been COMPLETED </p>
    <p>
    Submitted By: #header.SupvName# <br>
    On #DateFormat(header.EnteredDate,"M/D/YY")# at #TimeFormat(header.EnteredDate,"HH:MM")#
    </p>
      <table style="width:100%; padding-left:5px;font-family:Arial, Helvetica, sans-serif;">
      <cfset inResponse = 0>
      <cfloop query="detail">
        <cfif Type EQ "FORM">
        <cfelseif Type EQ "RESPONSE">
          <cfset inResponse = 1>
        <cfelseif Type EQ "NODE">
          <cfset inResponse = 0>
          <cfif ItemValue EQ "on">
            <tr><td colspan="2" style="text-align:center;"><b>Access requested for: <span style="color:orange;">#Descrip#</span></b></td></tr>          
          </cfif>
        <cfelseif ItemValue NEQ "">
          <cfif inResponse EQ 1>
            <tr>
              <td style="text-align:right; padding-right:5px;color:orange;">#Descrip#</td>
              <td style="font-size:1.2em;color:orange;"><b>#ItemValue#</b></td>
            </tr>
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
 

<div class="formclass">
  <h1>Computer Access Forms</h1>
  <div class="sectionclass">
    <p>
    <cfif ret.Completed EQ 1>
      You have <span style="color:red">COMPLETED</span> this <b>Computer Access Authorization E-Form.<br>
      An email has been sent to the submitting supervisor with all passwords.<br>
      <span style="color:#777;">Email sent to <cfoutput>#emails.EmailAddress#</cfoutput></span><br>
    <cfelse>
      Successfully updated.
    </cfif>
    </p>  
  </div>
    <p>
    &larr; <a href="https://ccp1.msj.org/login/login/CompAccess/">Computer Access Form ADMIN</a><br> 
    &larr; <a href="https://ccp1.msj.org/login/login/home.cfm">Intranet login menu</a><br> 
    </p>  
</div>
 
<style>
body {
  background-image: url(./background.png);
  background-attachment: fixed;
  font-family: sans-serif;
  text-align:center;
}
div {
  margin: 20px auto;
  text-align:center;
  border-radius: 4px;
}
div.formclass {
  width: 700px;
  background-color: rgba(0,0,0, 0.1);
  color: white;
  padding: 3px;
  border: 2px solid #3b5969;
  text-align:left;
  font-weight:bold;
  
} 
div.sectionclass {
  background-color: #f0f4f7;
  color: black;
  padding: 10px;
  border: 1px solid #3b5969;
  text-align:left;
  font-weight:bold;
}
</style>