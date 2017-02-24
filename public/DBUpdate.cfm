<!---This is called using ajax for updating database while editing urls--->
<!--- Use POST to call this page (NOTE I changed it to GET so I wouldn't have to deal with CORS issues in devel. Slack.)--->
<cfif url.Proc EQ "InsNode">
  <!---InsNode - Inserts new node (url,section,field,etc) to right of (after) given--->
	<cfstoredproc procedure="InsNode" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Code#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Type#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Descrip#">
    <cfprocresult name="ret">    
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfoutput query="ret">
  {"FormID":#ret.FormID#,"Type":"#ret.Type#","Code":"#ret.Code#","Descrip":"#ret.Descrip#","ParentID":#ret.ParentID#}
  </cfoutput>
<cfelseif url.Proc EQ "AddChild">
  <!---AddChild - Inserts new node (url,section,field,etc) as first child of given--->
	<cfstoredproc procedure="AddChild" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Code#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Type#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Descrip#">
    <cfprocresult name="ret">    
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfoutput query="ret">
  {"FormID":#ret.FormID#,"Type":"#ret.Type#","Code":"#ret.Code#","Descrip":"#ret.Descrip#","ParentID":#ret.ParentID#}
  </cfoutput>
<cfelseif url.Proc EQ "DelNode">
  <!---DelNode - Delete Node and all it's children (Yikes!)--->
	<cfstoredproc procedure="DelNode" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.DelID#">
  </cfstoredproc>
<cfelseif url.Proc EQ "PublishForm">
  <!---Publishurl - Toggles url from Type url to UNPUB--->
	<cfstoredproc procedure="PublishForm" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc>  
</cfif>
