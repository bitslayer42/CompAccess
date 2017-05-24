<!---This is called using ajax for updating database while editing urls--->
<!--- Use POST to call this page (NOTE I changed it to GET so I wouldn't have to deal with CORS issues in devel. Slack.)--->
<cfif IsDefined("url.Descrip")>
	<cfset quotedDescrip = Replace(url.Descrip,"\","\\","all")>
	<cfset quotedDescrip = Replace(quotedDescrip,'"','\"',"all")>
</cfif>
<cfif url.Proc EQ "AddSister">
  <!---AddSister - Inserts new node (url,section,field,etc) to right of (after) given--->
	<cfstoredproc procedure="AddSister" datasource="ITFormsTest">
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
	<cfstoredproc procedure="AddChild" datasource="ITFormsTest">
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
	<cfstoredproc procedure="DelNode" datasource="ITFormsTest">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc>
<cfelseif url.Proc EQ "PublishForm">
  <!---Publishurl - Toggles url from Type url to UNPUB--->
	<cfstoredproc procedure="PublishForm" datasource="ITFormsTest">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc>  
<cfelseif url.Proc EQ "ToggleHeaderRecord">
  <!--- Toggles HeaderRecord field true/false--->
	<cfstoredproc procedure="ToggleHeaderRecord" datasource="ITFormsTest">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc> 
<cfelseif url.Proc EQ "ToggleRequired">
  <!--- Toggles Required field true/false--->
	<cfstoredproc procedure="ToggleRequired" datasource="ITFormsTest">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc>
<cfelseif url.Proc EQ "ToggleReqResp">
  <!--- Toggles ReqResp field true/false--->
	<cfstoredproc procedure="ToggleReqResp" datasource="ITFormsTest">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#">
  </cfstoredproc>
</cfif>
