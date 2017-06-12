<!---This is called using ajax for updating database while editing urls--->
<!--- Use POST to call this page (NOTE I changed it to GET so I wouldn't have to deal with CORS issues in devel. Slack.)--->
<cfif IsDefined("url.Descrip")>
	<cfset quotedDescrip = quoteTheString(url.Descrip)>
</cfif>
<cfif url.Proc EQ "AddSister">
  <!---AddSister - Inserts new node (url,section,field,etc) to right of (after) given--->
	<cfstoredproc procedure="AddSister" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Type#">
    <cfprocparam cfsqltype="cf_sql_varchar" value='#quotedDescrip#'>
    <cfprocresult name="ret">    
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfoutput query="ret">
  {"FormID":#ret.FormID#,"Type":"#ret.Type#","Descrip":"#ret.Descrip#","ParentID":#ret.ParentID#}
  </cfoutput>
<cfelseif url.Proc EQ "AddChild">
  <!---AddChild - Inserts new node (url,section,field,etc) as first child of given--->
	<cfstoredproc procedure="AddChild" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Type#">
    <cfprocparam cfsqltype="cf_sql_varchar" value='#quotedDescrip#'>
    <cfprocresult name="ret">    
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfoutput query="ret">
  {"FormID":#ret.FormID#,"Type":"#ret.Type#","Descrip":"#ret.Descrip#","ParentID":#ret.ParentID#}
  </cfoutput>
<cfelseif url.Proc EQ "DelNode">
  <!---DelNode - Mark as Deleted Node and all it's children --->
	<cfstoredproc procedure="DelNode" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc>
<cfelseif url.Proc EQ "PublishForm">
  <!---Publishurl - Toggles url from Type url to UNPUB--->
	<cfstoredproc procedure="PublishForm" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc>  
<cfelseif url.Proc EQ "ToggleHeaderRecord">
  <!--- Toggles HeaderRecord field true/false--->
	<cfstoredproc procedure="ToggleHeaderRecord" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc> 
<cfelseif url.Proc EQ "ToggleRequired">
  <!--- Toggles Required field true/false--->
	<cfstoredproc procedure="ToggleRequired" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc>
<cfelseif url.Proc EQ "ToggleReqResp">
  <!--- Toggles ReqResp field true/false--->
	<cfstoredproc procedure="ToggleReqResp" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc>
</cfif>

<cffunction name="quoteTheString" output="false" access="public" returnType="string">
    <cfargument name="aString" type="string" required="false" default="" />

	<cfset var quotedString = Replace(arguments.aString,"\","\\","all")>
	<cfset quotedString = Replace(quotedString,'"','\"',"all")>

    <cfreturn quotedString />
</cffunction>