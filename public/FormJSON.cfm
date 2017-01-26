<cfcontent type="application/json" reset="yes">

<cfstoredproc procedure="GetForm" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#url.FormCode#">
  <cfprocresult name="list">
</cfstoredproc>

<cfset loopctr = 1>
[ 
<cfoutput query="list">
{ "ID": "#list.ID#"
, "Code": "#list.Code#"
, "depth": "#list.depth#"
, "Type": "#list.Type#"
, "Descrip": "#list.Descrip#"
}
<cfif loopctr NEQ list.RecordCount>,</cfif>
<cfset loopctr = loopctr + 1>
</cfoutput>
]



<!---

https://ccp1.msj.org/login/login/CompAccess/FormJSON.cfm?FormCode=CCPIT

--->