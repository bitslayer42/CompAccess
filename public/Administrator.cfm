<!---This is called using ajax for updating database while in Administrators screen--->
<cfif url.Proc EQ "DelAdmin">
  <!---DelAdmin --->
	<cfstoredproc procedure="DelAdmin" datasource="ITFormsTest">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.AdminID#">
  </cfstoredproc>
<cfelseif url.Proc EQ "ToggleEmail">
  <!---ToggleEmail --->
	<cfstoredproc procedure="ToggleEmail" datasource="ITFormsTest">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.AdminID#">
    <cfprocparam cfsqltype="cf_sql_integer" value="#url.NodeID#">
  </cfstoredproc>
<cfelseif url.Proc EQ "GetAdmin">
  <!---GetAdmin --->
  <cfcontent type="application/json" reset="yes">
  <cfstoredproc procedure="GetAdmin" datasource="ITFormsTest">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.AdminID#">
    <cfprocresult resultset="1" name="header">
    <cfprocresult resultset="2" name="subscrips">    
  </cfstoredproc>

  <cfset loopctr = 1>
  {
    <cfoutput> 
    "AdminID": "#header.AdminID#"
  , "Name": "#header.Name#"
  , "EmailAddress": "#header.EmailAddress#"
  , "Subscrips":
    </cfoutput>
    [
    <cfoutput query="subscrips"> 
      { "FormName": "#FormName#"
      , "ID": "#ID#"
      , "Descrip": "#Descrip#"
      , "Subscribed": "#Subscribed#"  
      }
    <cfif loopctr NEQ subscrips.RecordCount>,</cfif>
    <cfset loopctr = loopctr + 1>
    </cfoutput>
    ]  
  }
  <!--- https://ccp1.msj.org/CompAccess/Administrator.cfm?Proc=GetAdmin&AdminID=1027126&Name=Jon&EmailAddress=jon --->
<cfelseif url.Proc EQ "GetStaffList">
  <!---GetStaffList --->
  <cfcontent type="application/json" reset="yes">
  <cfstoredproc procedure="GetStaffList" datasource="ITFormsTest">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#url.SearchString#">
    <cfprocresult name="results">
  </cfstoredproc>

  <cfset loopctr = 1>
   [ 
    <cfoutput query="results">
    { "BadgeNum": "#BadgeNum#"
    , "Name": "#Name#"
    , "EmailAddress": "#EmailAddress#"
    }
    <cfif loopctr NEQ results.RecordCount>,</cfif>
    <cfset loopctr = loopctr + 1>
    </cfoutput>
    ]  
  
  <!--- https://ccp1.msj.org/CompAccess/Administrator.cfm?Proc=GetStaffList&SearchString=WILS --->
</cfif>
