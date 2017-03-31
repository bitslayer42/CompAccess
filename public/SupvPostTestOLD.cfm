
<cfstoredproc procedure="getForm" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="0">
  <cfprocparam cfsqltype="cf_sql_integer" value="31">
  <cfprocresult resultset="1" name="header">
  <cfprocresult resultset="2" name="detail">
</cfstoredproc>
<cfstoredproc procedure="GetEmailsForRequest" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="31">
  <cfprocresult name="emails">
</cfstoredproc>


<cfset xmlheader = XmlParse(header.HeaderXML)>

<cfset emailsubject = "Computer Access">
<cfoutput>
      <cfloop array="#xmlheader.root.xmlchildren#" index="i" >
        <cfset emailsubject = emailsubject & "-" & i.itemvalue.xmltext>
        #i.col.xmltext#: #i.itemvalue.xmltext#<br>
      </cfloop>
</cfoutput> 
<hr>
<div style="width:400px">
<table>
<cfoutput>
      <cfloop query="detail">
        <cfif ItemValue NEQ "" AND Type NEQ "FORM" AND Type NEQ "RESPONSE">
          <cfif Type EQ "NODE">
            <tr><th colspan="2">#Descrip#</th></tr>
          <cfelse>
            <tr><td>#Descrip#</td><td>#ItemValue#</td></tr>
          </cfif>
        </cfif>
      </cfloop>
</cfoutput> 
</table>
</div>
    
<cfif emails.RecordCount GT 0>
  <cfmail to = "#emails.EmailAddress#" 
  from = "cpisc@msj.org"
  subject = "#emailsubject#"
  type="html">
    <div style="width:400px">
      <table>
      <cfloop query="detail">
        <cfif ItemValue NEQ "" AND Type NEQ "FORM" AND Type NEQ "RESPONSE">
          <cfif Type EQ "NODE">
            <tr><th colspan="2">#Descrip#</th></tr>
          <cfelse>
            <tr><td>#Descrip#</td><td>#ItemValue#</td></tr>
          </cfif>
        </cfif>
      </cfloop>
      </table>
    </div>
    <style type="text/css">
      td{border:1px solid grey}
    </style>
  </cfmail>
</cfif>
    
    
    
 <cfdump var="#header#">
  <cfdump var="#detail#">
   <cfdump var="#emails#">
      <cfdump var="#xmlheader#">