<!---This is called using ajax for updating database--->
<cfif url.Proc EQ "InsNode">
  <!---InsNode - Inserts new node (form,section,field,etc) to right of (after) given--->
	<cfstoredproc procedure="InsNode" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Code#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Type#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Descrip#">
  </cfstoredproc>
<cfelseif url.Proc EQ "AddChild">
  <!---AddChild - Inserts new node (form,section,field,etc) as first child of given--->
	<cfstoredproc procedure="AddChild" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Code#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Type#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Descrip#">
  </cfstoredproc>
<cfelseif url.Proc EQ "DelNode">
  <!---DelNode - Delete Node and all it's children (Yikes!)--->
	<cfstoredproc procedure="DelNode" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#">
  </cfstoredproc>
<cfelseif url.Proc EQ "PublishForm">
  <!---PublishForm - Toggles form from Type FORM to UNPUB--->
	<cfstoredproc procedure="PublishForm" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#">
  </cfstoredproc>  
</cfif>
