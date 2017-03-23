<cfcontent type="application/json" reset="yes">

<cfstoredproc procedure="SearchXML" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#url.searchString#">
  <cfprocresult name="results">
</cfstoredproc>

<cfset loopctr = 1>
{
  "requests": [ 
  <cfoutput query="results">
  { "RequestID": #RequestID#
  , "SupvName": "#SupvName#"
  , "EnteredDate": "#EnteredDate#"
  , "Completed": #Completed#
  , "headerXML": "#headerXML#"
  , "EditedXML": "#EditedXML#"  
  }
  <cfif loopctr NEQ results.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ]  
}


<!---

https://ccp1.msj.org/CompAccess/SearchJSON.cfm?searchString=Henny

--->