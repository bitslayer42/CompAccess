
<cfset ItemStr = "<reqrows>">
<cfloop collection="#form#" item="theField">
  <cfif theField NEQ "fieldNames" AND theField NEQ "DateEntered" AND theField NEQ "LoggedInID" 
        AND theField NEQ "LoggedInName" AND theField NEQ "ReqID">
  <cfset ItemStr = ItemStr & "<row><Field>#theField#</Field><Value>#form[theField]#</Value></row>" >
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
  <cfprocresult name="Return">
</cfstoredproc>

<div class="formclass">
  <h1>Computer Access Forms</h1>
  <div class="sectionclass">
    <p>
    <cfif Return.Completed EQ 1>
      You have <span style="color:red">COMPLETED</span> this <b>Computer Access Authorization E-Form.<br>
      An email has been sent to the submitting supervisor with all passwords.
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