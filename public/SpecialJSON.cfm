<cfcontent type="application/json" reset="yes">

<cfstoredproc procedure="GetSpecial" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="#url.SpecialID#">
  <cfprocresult resultset="1" name="special">
  <cfprocresult resultset="2" name="criteria">
  <cfprocresult resultset="3" name="hide">
  <cfprocresult resultset="4" name="email">
  <cfprocresult resultset="5" name="emailfields">
  <cfprocresult resultset="6" name="fieldlist">
</cfstoredproc>

<cfset loopctr = 1>
{
  "special": 
  <cfoutput query="special">  
  { "ID": #ID#
  , "Action": "#Action#"
  , "Description": "#Description#"
  } 
  </cfoutput>  
  ,
  "criteria": [ 
  <cfoutput query="criteria">
  { "ID": "#ID#"
  , "Field": "#Field#"
  , "IsNot": "#IsNot#"
  , "ItExists": "#ItExists#"  
  , "IsValue": "#IsValue#"  
  , "HumanCriteria": "#HumanCriteria#"  
  }
  <cfif loopctr NEQ criteria.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ],
  
  <cfset loopctr = 1>
  "hide": [ 
  <cfoutput query="hide">
  { "ID": #ID#
  , "Type": "#Type#"
  , "Descrip": "#Descrip#"
  }
  <cfif loopctr NEQ hide.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ],
  
  <cfset loopctr = 1>
  "email": [ 
  <cfoutput query="email">
  { "ID": #ID#
  , "Email": "#Email#"
  }
  <cfif loopctr NEQ email.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ],

  <cfset loopctr = 1>
  "emailfields": [ 
  <cfoutput query="emailfields">
  { "ID": #ID#
  ,"FieldID": "#FieldID#"
  , "Type": "#Type#"
  , "Descrip": "#Descrip#"
  }
  <cfif loopctr NEQ emailfields.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ],

  <cfset loopctr = 1>
  "fieldlist": [ 
  <cfoutput query="fieldlist">
  { "ID": #ID#
  , "Type": "#Type#"
  , "Descrip": "#Descrip#"
  , "FormName": "#FormName#"
  }
  <cfif loopctr NEQ fieldlist.RecordCount>,</cfif>
  <cfset loopctr = loopctr + 1>
  </cfoutput>
  ]  
}


<!---

https://ccp1.msj.org/CompAccess/SpecialJSON.cfm?SpecialID=3

--->