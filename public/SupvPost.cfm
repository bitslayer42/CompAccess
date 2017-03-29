
<cfset ItemStr = "<reqrows>">
<cfloop collection="#form#" item="theField">
  <cfif theField NEQ "fieldNames" AND theField NEQ "DateEntered" AND theField NEQ "LoggedInName" AND theField NEQ "SupvSig">
  <cfset ItemStr = ItemStr & "<row><Field>#theField#</Field><Value>#form[theField]#</Value></row>" >
  </cfif>
</cfloop>
<cfset ItemStr = ItemStr & "</reqrows>">


<cfset LoggedInName = form.LoggedInName & " - Signature:" & form.SupvSig>

<cfstoredproc procedure="UpsertRequest" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#LoggedInName#">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#ItemStr#">
  <cfprocparam cfsqltype="cf_sql_integer" null="true">
  <cfprocresult name="ret">
</cfstoredproc>

<cfstoredproc procedure="getForm" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="0">
  <cfprocparam cfsqltype="cf_sql_integer" value="#ret.RequestID#">
  <cfprocresult resultset="1" name="header">
  <cfprocresult resultset="2" name="detail">
</cfstoredproc>
<cfstoredproc procedure="GetEmailsForRequest" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="#ret.RequestID#">
  <cfprocresult name="emails">
</cfstoredproc>

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
    
      <!---
<cfif emails.RecordCount GT 0>
  <cfmail to = "#emails.EmailAddress#" 
  from = "cpisc@msj.org"
  subject = "Computer Access Form"
  type="html">
    <div style="width:400px">
      <table>
      <cfloop query="detail">
        <cfif ItemValue NEQ "" AND Type NEQ "FORM" AND Type NEQ "RESPONSE">
          <cfif Type EQ "NODE">
            <tr><th colspan="2">#Descrip#</th></tr>
          <cfelse>
            <tr><td>#Descrip#</td><td>#ItemValue#</td></tr>
          </cfif>
        </cfif>
      </cfloop>
      </table>
    </div>
    <style type="text/css">
      td{border:1px solid grey}
    </style>
  </cfmail>
</cfif>
--->
<div class="formclass">
  <h1>Computer Access Forms</h1>
  <div class="sectionclass">
    You have successfully submitted a <b>Computer Access Authorization E-Form.<br>
    <div>
      <a href="EmailSelf.cfm">Click here to email a copy to yourself</a> 
    </div>
    &larr; <a href="https://ccp1.msj.org/login/login/CompAccess/">Enter another Computer Access Form</a><br> 
    &larr; <a href="https://ccp1.msj.org/login/login/home.cfm">Intranet login menu</a><br> 
  </div>
</div>

<style>
div {
  margin: 20px auto;
  text-align:center;
  border-radius: 4px;
}
div.formclass {
  width: 700px;
  background-color: #a4becc;
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