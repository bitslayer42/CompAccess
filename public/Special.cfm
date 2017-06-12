<!---This is called using ajax for updating database Special--->

<cfif url.Proc EQ "DelSpecial">
  <cfstoredproc procedure="DelSpecial" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.SpecialID#">   
  </cfstoredproc>
<cfelseif url.Proc EQ "DelCriteria">
  <cfstoredproc procedure="DelCriteria" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#"> 
  </cfstoredproc>
<cfelseif url.Proc EQ "DelHiddenFields">
  <cfstoredproc procedure="DelHiddenFields" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#"> 
  </cfstoredproc>
<cfelseif url.Proc EQ "DelEmail">
  <cfstoredproc procedure="DelEmail" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#"> 
  </cfstoredproc>
<cfelseif url.Proc EQ "DelEmailFields">
  <cfstoredproc procedure="DelEmailFields" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.ID#"> 
  </cfstoredproc>
<cfelseif url.Proc EQ "AddSpecial">
  <!---AddSpecial - --->
	<cfset quotedDescrip = quoteTheString(url.Description)>
  
  <cfstoredproc procedure="AddSpecial" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Action#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#quotedDescrip#">
    <cfprocresult name="ret">    
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfoutput query="ret">
  {"ID":#ret.ID#}
  </cfoutput>
<cfelseif url.Proc EQ "AddSpecialCriteria">
  <!---AddSpecialCriteria - --->
  <cfstoredproc procedure="AddSpecialCriteria" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.SpecialID#">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.Field#">
	<cfif IsDefined("url.IsNot")>
		<cfprocparam cfsqltype="cf_sql_bit" value="#url.IsNot#">
	<cfelse>
		<cfprocparam cfsqltype="cf_sql_bit" null="true">
	</cfif>
	<cfif IsDefined("url.ItExists")>
		<cfprocparam cfsqltype="cf_sql_bit" value="#url.ItExists#">
	<cfelse>
		<cfprocparam cfsqltype="cf_sql_bit" null="true">
	</cfif>
	<cfif IsDefined("url.IsValue")>
		<cfprocparam cfsqltype="cf_sql_varchar" value="#url.IsValue#">
	<cfelse>
		<cfprocparam cfsqltype="cf_sql_varchar" null="true">
	</cfif>
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.HumanCriteria#">	
    <cfprocresult name="ret">    
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfoutput query="ret">
  {"ret":#ret.ret#}
  </cfoutput>
<cfelseif url.Proc EQ "AddSpecialHiddenFields">
  <cfstoredproc procedure="AddSpecialHiddenFields" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.SpecialID#"> 
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.Field#">
  </cfstoredproc>
<cfelseif url.Proc EQ "AddSpecialEmail">
  <cfstoredproc procedure="AddSpecialEmail" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.SpecialID#"> 
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.Email#">	
  </cfstoredproc>
<cfelseif url.Proc EQ "AddSpecialEmailFields">
  <cfstoredproc procedure="AddSpecialEmailFields" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.SpecialID#"> 
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.Field#">	
  </cfstoredproc>
<cfelseif url.Proc EQ "GetOptions">
  <!---GetOptions - Lists all the Options for a given Radio or Select--->
  <cfstoredproc procedure="GetOptions" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.FormID#"> 
	<cfprocresult name="optlist"> 	
  </cfstoredproc>
  <cfcontent type="application/json" reset="yes">  
  <cfset loopctr = 1>
  [
  <cfoutput query="optlist">
  {"ID":#optlist.ID#,
   "Descrip":"#optlist.Descrip#"
   }
  <cfif loopctr NEQ optlist.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>   
  </cfoutput>
  ]
 </cfif>

 <cffunction name="quoteTheString" output="false" access="public" returnType="string">
    <cfargument name="aString" type="string" required="false" default="" />

	<cfset var quotedString = Replace(arguments.aString,"\","\\","all")>
	<cfset quotedString = Replace(quotedString,'"','\"',"all")>

    <cfreturn quotedString />
</cffunction>
<!---
https://ccp1.msj.org/CompAccess/Special.cfm?Proc=AddSpecial&Action=SENDEMAIL&Description=whatisthisidonteven
https://ccp1.msj.org/CompAccess/Special.cfm?Proc=GetOptions&FormID=13
--->

