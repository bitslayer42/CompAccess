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
  , "SupvName": "#quoteTheString(SupvName)#"
  , "EnteredDate": "#EnteredDate#"
  , "Completed": #Completed#
  , "headerXML": "#quoteTheString(headerXML)#"
  , "EditedXML": "#quoteTheString(EditedXML)#"  
  }
  <cfif loopctr NEQ results.RecordCount>,</cfif>
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

https://ccp1.msj.org/CompAccess/SearchJSON.cfm?searchString=Henny

--->