<cfdump var="#form#">

<cfset ItemStr = "<reqrows>">
<cfloop collection="#form#" item="theField">
  <cfif theField NEQ "fieldNames" AND theField NEQ "DateEntered" AND theField NEQ "LoggedInName" AND theField NEQ "ReqID">
  <cfset ItemStr = ItemStr & "<row><Field>#theField#</Field><Value>#form[theField]#</Value></row>" >
  </cfif>
</cfloop>
<cfset ItemStr = ItemStr & "</reqrows>">

<cfset LoggedInName = form.LoggedInName>


<cfstoredproc procedure="UpsertRequest" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#LoggedInName#">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#ItemStr#">
  <cfprocparam cfsqltype="cf_sql_integer" value="#ReqID#">
  <cfprocresult name="Return">
</cfstoredproc>



<div style="text-align:center;padding-top:100px;">
  <p>
  <cfif Return.Completed EQ 1>
    You have <span style="color:red">COMPLETED</span> this <b>Computer Access Authorization E-Form.<br>
    An email has been sent to the submitting supervisor with all passwords.
  <cfelse>
    Successfully updated.
  </cfif>
  </p>  
  <p>
  <a href="https://ccp1.msj.org/login/login/CompAccess/">Computer Access Form ADMIN</a><br> 
  <a href="https://ccp1.msj.org/login/login/home.cfm">Intranet login menu</a><br> 
  </p>  
</div>
