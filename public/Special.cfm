<!---This is called using ajax for updating database Special--->
<!---
<cfif IsDefined("url.Descrip")>
	<cfset quotedDescrip = Replace(url.Descrip,"\","\\","all")>
	<cfset quotedDescrip = Replace(quotedDescrip,'"','\"',"all")>
</cfif>
--->
<cfif url.Proc EQ "DelSpecial">
  <!---DelSpecial - --->
  <cfstoredproc procedure="DelSpecial" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.SpecialID#">   
  </cfstoredproc>
<cfelseif url.Proc EQ "AddSpecial">
  <!---AddSpecial - --->
  <cfstoredproc procedure="AddSpecial" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Action#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Description#">
    <cfprocresult name="ret">    
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfoutput query="ret">
  {"ID":#ret.ID#}
  </cfoutput>
</cfif>

<!---
https://ccp1.msj.org/CompAccess/Special.cfm?Proc=AddSpecial&Action=SENDEMAIL&Description=whatisthisidonteven
--->

