<cfcontent type="application/json" reset="yes">

<cfstoredproc procedure="AdminScreen" datasource="ITForms">
  <cfprocresult resultset="1" name="requests">
  <cfprocresult resultset="2" name="forms">
  <cfprocresult resultset="3" name="root">
  <cfprocresult resultset="4" name="specials">
  <cfprocresult resultset="5" name="admins">
</cfstoredproc>

<cfset loopctr = 1>
{
  "requests": [ 
  <cfoutput query="requests">
  { "RequestID": #RequestID#
  , "SupvName": "#quoteTheString(SupvName)#"
  , "EnteredDate": "#EnteredDate#"
  , "Completed": #Completed#
  , "headerXML": "#quoteTheString(headerXML)#"
  , "EditedXML": "#quoteTheString(EditedXML)#"  
  }
  <cfif loopctr NEQ requests.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ],
  
  <cfset loopctr = 1>
  "forms": [ 
  <cfoutput query="forms">
  { "FormID": #FormID#
  , "Descrip": "#Descrip#"
  , "Type": "#Type#"
  }
  <cfif loopctr NEQ forms.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ],
  
  "root": <cfoutput>#root.FormID#,</cfoutput>
  
  <cfset loopctr = 1>
  "specials": [ 
  <cfoutput query="specials">
  { "ID": #ID#
  , "Action": "#Action#"
  , "Description": "#Description#"
  }
  <cfif loopctr NEQ specials.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ],

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

<cffunction name="quoteTheString" output="false" access="public" returnType="string">
    <cfargument name="aString" type="string" required="false" default="" />

	<cfset var quotedString = Replace(arguments.aString,"\","\\","all")>
	<cfset quotedString = Replace(quotedString,'"','\"',"all")>

    <cfreturn quotedString />
</cffunction>
<!---

https://ccp1.msj.org/CompAccess/AdminJSON.cfm

--->