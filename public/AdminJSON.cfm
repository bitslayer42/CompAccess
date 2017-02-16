<cfcontent type="application/json" reset="yes">

<cfstoredproc procedure="AdminScreen" datasource="ITForms">
  <cfprocresult resultset="1" name="requests">
  <cfprocresult resultset="2" name="forms">
  <cfprocresult resultset="3" name="root">
  <cfprocresult resultset="4" name="admins">
</cfstoredproc>

<cfset loopctr = 1>
{
  "requests": [ 
  <cfoutput query="requests">
  { "RequestID": #RequestID#
  , "SupvName": "#SupvName#"
  , "EnteredDate": "#EnteredDate#"
  , "LastEditor": "#LastEditor#"
  , "EditedDate": "#EditedDate#"
  , "Completed": #Completed#
  , "headerXML": "#headerXML#"
  }
  <cfif loopctr NEQ requests.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ],
  <cfset loopctr = 1>
  "forms": [ 
  <cfoutput query="forms">
  { "ID": #ID#
  , "Descrip": "#Descrip#"
  }
  <cfif loopctr NEQ forms.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ], 
  "root": <cfoutput>#root.ID#,</cfoutput>
  <cfset loopctr = 1>
  "admins": [ 
  <cfoutput query="admins">
  { "AdminID": "#AdminID#"
  , "Name": "#Name#"
  }
  <cfif loopctr NEQ admins.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ]  
}


<!---

https://ccp1.msj.org/CompAccess/AdminJSON.cfm

--->