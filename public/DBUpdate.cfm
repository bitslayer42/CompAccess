<!---This is called using ajax for updating database while editing urls--->
<!--- Use POST to call this page (NOTE I changed it to GET so I wouldn't have to deal with CORS issues in devel. Slack.)--->
<cfif url.Proc EQ "InsNode">
  <!---InsNode - Inserts new node (url,section,field,etc) to right of (after) given--->
	<cfstoredproc procedure="InsNode" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Code#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Type#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Descrip#">
    <cfprocresult name="retformid">    
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfoutput query="retformid">
  {"FormID":#retformid.FormID#,"Type":"#retformid.Type#","Code":"#retformid.Code#","Descrip":"#retformid.Descrip#","ParID":#retformid.ParID#}
  </cfoutput>
<cfelseif url.Proc EQ "AddChild">
  <!---AddChild - Inserts new node (url,section,field,etc) as first child of given--->
	<cfstoredproc procedure="AddChild" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Code#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Type#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Descrip#">
    <cfprocresult name="retformid">    
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfoutput query="retformid">
  {"FormID":#retformid.FormID#,"Type":"#retformid.Type#","Code":"#retformid.Code#","Descrip":"#retformid.Descrip#","ParID":#retformid.ParID#}
  </cfoutput>
<cfelseif url.Proc EQ "DelNode">
  <!---DelNode - Delete Node and all it's children (Yikes!)--->
	<cfstoredproc procedure="DelNode" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#">
  </cfstoredproc>
<cfelseif url.Proc EQ "Publishurl">
  <!---Publishurl - Toggles url from Type url to UNPUB--->
	<cfstoredproc procedure="Publishurl" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#">
  </cfstoredproc>  
</cfif>
