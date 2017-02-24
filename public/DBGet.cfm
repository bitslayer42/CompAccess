<!---This is called using ajax for fetching from database--->
<cfif url.Proc EQ "IsAdminOrSupv">
    <!---IsAdminOrSupv - checks if logged in user is SUPV, ADMIN, or neither--->
    <cfif IsDefined("CLIENT.EMPID")>
      <cfset UserID = CLIENT.EMPID>
    <cfelse>
      <cfset UserID = "1027126">  <!--- CAUTION DEBUGGING ONLY!!! SUPV: '1027143'    ADMIN: "1027126"--->
    </cfif>
    <cfstoredproc procedure="IsAdminOrSupv" datasource="ITForms">
      <cfprocparam cfsqltype="cf_sql_varchar" value="#UserID#">
      <cfprocresult name="list">
    </cfstoredproc>
    <cfoutput query="list">
    ["#trim(list.Results)#"]
    </cfoutput>
<cfelseif url.Proc EQ "ListForms">
    <!---ListForms - --->   
    <cfcontent type="application/json" reset="yes">
    <cfquery name="list" datasource="ITForms">
      SELECT ID, Descrip FROM Forms WHERE Type = 'FORM'
    </cfquery>
    <cfset loopctr = 1>
    [
    <cfoutput query="list">
      {
        "FormID":#list.ID#,
        "Descrip":"#trim(list.Descrip)#"
      }
      <cfif loopctr NEQ list.RecordCount>,</cfif>
      <cfset loopctr = loopctr + 1>
    </cfoutput> 
    ]
</cfif>
   
 

<!---

https://ccp1.msj.org/CompAccess/DBGet.cfm?Proc=IsAdminOrSupv&UserID=1027126
https://ccp1.msj.org/CompAccess/DBGet.cfm?Proc=ListForms

--->