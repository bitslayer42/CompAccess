<cfcontent type="application/json" reset="yes">

<cfstoredproc procedure="GetForm" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  <cfif IsDefined("url.reqID")>
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.reqID#">
  <cfelse>
    <cfprocparam cfsqltype="cf_sql_integer" null=yes>
  </cfif>
  <cfprocresult resultset="1" name="header">
  <cfprocresult resultset="2" name="body">
</cfstoredproc>

<cfif NOT IsDefined("url.reqID")>
    <cfif IsDefined("CLIENT.EMPNAME")>
      <cfset SupvName = CLIENT.EMPNAME>
    <cfelse>
      <cfset SupvName = "Super Jario Brothers">  <!--- CAUTION DEBUGGING ONLY!!! --->
    </cfif>
      <cfset EnteredDate = DateFormat(Now(),"YYYY-MM-DD") & "T" & TimeFormat(Now(),"HH:MM")>
<cfelse>
      <cfset EnteredDate = header.EnteredDate>
      <cfset SupvName = header.SupvName>
</cfif>

<cfset loopctr = 1>
{
  <cfoutput>
  <cfif header.RecordCount GT 0>
  "RequestID": #header.RequestID#,
  "Completed": #header.Completed#,
  </cfif>
  "SupvName": "#SupvName#",
  "EnteredDate": "#EnteredDate#",
  </cfoutput>
  "body": [ 
  <cfoutput query="body">
  { "FormID": #body.FormID#
  , "Code": "#body.Code#"
  , "depth": #body.depth#
  , "Type": "#body.Type#"
  , "Descrip": "#body.Descrip#"
  , "ParentID": #body.ParentID#
  , "ItemValue": "#body.ItemValue#"
  }
  <cfif loopctr NEQ body.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ]
}


<!---

https://ccp1.msj.org/CompAccess/FormJSON.cfm?FormID=4
https://ccp1.msj.org/CompAccess/FormJSON.cfm?FormID=4&reqID=5
--->