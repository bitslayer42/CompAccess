<cfcontent type="application/json" reset="yes">

<cfstoredproc procedure="GetForm" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  <cfif IsDefined("url.reqID")>
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.reqID#">
  <cfelse>
    <cfprocparam cfsqltype="cf_sql_integer" null=yes>
  </cfif>
  <cfprocparam cfsqltype="cf_sql_varchar" value="#url.view#">
  <cfprocresult resultset="1" name="header">
  <cfprocresult resultset="2" name="body">
</cfstoredproc>

<cfif IsDefined("CLIENT.EMPNAME")>
  <cfset LoggedInID = CLIENT.EMPID>
  <cfset LoggedInName = CLIENT.EMPNAME>
<cfelse>
  <cfset LoggedInID = "1027126">
  <cfset LoggedInName = "Logged, N. az Jon">  <!--- CAUTION DEBUGGING ONLY!!! --->
</cfif>
<cfif IsDefined("url.reqID")> <!--- previously entered --->
      <cfset EnteredDate = header.EnteredDate>
      <cfset SupvName = header.SupvName>
<cfelse>
      <cfset EnteredDate = DateFormat(Now(),"YYYY-MM-DD") & "T" & TimeFormat(Now(),"HH:MM")>
      <cfset SupvName = LoggedInName>
</cfif>

<cfset loopctr = 1>
{
  <cfoutput>
  <cfif header.RecordCount GT 0>
  "RequestID": #header.RequestID#,
  "Completed": #header.Completed#,
  </cfif>
  "LoggedInID": "#LoggedInID#",  
  "LoggedInName": "#LoggedInName#",  
  "SupvName": "#SupvName#",
  "EnteredDate": "#EnteredDate#",
  </cfoutput>
  "body": [ 
  <cfoutput query="body">
  <cfif body.Type EQ "DATE">
    <cfset body.ItemValue = DateFormat(body.ItemValue,"YYYY-MM-DD") >
  </cfif>
  { "FormID": #body.FormID#
  , "Type": "#body.Type#"
  , "Descrip": "#body.Descrip#"
  , "Required": #body.Required# 
  , "ReqResp": #body.ReqResp# 
  , "HeaderRecord": #body.HeaderRecord#    
  , "ParentID": #body.ParentID#
  , "ItemValue": "#body.ItemValue#"
  }
  <cfif loopctr NEQ body.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ]
}


<!---
, "depth": #body.depth#
https://ccp1.msj.org/CompAccess/FormJSON.cfm?FormID=2
https://ccp1.msj.org/CompAccess/FormJSON.cfm?FormID=0&reqID=38
--->