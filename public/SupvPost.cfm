<!--- 
<cfdump var="#form#"><cfabort>
 --->
<cfif IsDefined("url.reqID")><!--- supervisor requesting own copy --->
  <cfset theReqID = url.reqID>
    <cfif IsDefined("CLIENT.EMPID")>
      <cfset UserID = CLIENT.EMPID>
    <cfelse>
      <cfset UserID = "1027126">  <!--- CAUTION DEBUGGING ONLY!!! SUPV: '1027143'    ADMIN: "1027126"--->
    </cfif>  
  <cfstoredproc procedure="GetEmailForSupv" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#UserID#">
    <cfprocresult name="emails">
  </cfstoredproc>  
<cfelse>
  <cfset ItemStr = "<reqrows>">
  <cfloop collection="#form#" item="theField">
    <cfif theField NEQ "fieldNames" AND theField NEQ "DateEntered" AND theField NEQ "LoggedInName" 
          AND theField NEQ "LoggedInID" AND theField NEQ "SupvSig">
    <cfset ItemStr = ItemStr & "<row><Field>#XmlFormat(theField)#</Field><Value>#XmlFormat(form[theField])#</Value></row>" >
    </cfif>
  </cfloop>
  <cfset ItemStr = ItemStr & "</reqrows>">

  <cfset LoggedInID = form.LoggedInID>
  <cfset LoggedInName = form.LoggedInName & " - Signature:" & form.SupvSig>

  <cfstoredproc procedure="UpsertRequest" datasource="ITForms">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#LoggedInID#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#LoggedInName#">
    <cfprocparam cfsqltype="cf_sql_varchar" value="#ItemStr#">
    <cfprocparam cfsqltype="cf_sql_integer" null="true">
    <cfprocresult name="ret">
  </cfstoredproc>
  <cfset theReqID = ret.RequestID>

  <cfstoredproc procedure="GetEmailsForRequest" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="#theReqID#">
  <cfprocresult name="emails">
  </cfstoredproc>
  
</cfif>
<!--- ---------------------- --->
<cfstoredproc procedure="getForm" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="0">
  <cfprocparam cfsqltype="cf_sql_integer" value="#theReqID#">
  <cfprocparam cfsqltype="cf_sql_varchar" null=yes>	
  <cfprocresult resultset="1" name="header">
  <cfprocresult resultset="2" name="detail">
</cfstoredproc>

<cfset xmlheader = XmlParse(header.HeaderXML)>
<cfset emailsubject = "Computer Access">
<cfoutput>
      <cfloop array="#xmlheader.root.xmlchildren#" index="i" >
        <cfset emailsubject = emailsubject & "-" & i.itemvalue.xmltext>
      </cfloop>
</cfoutput> 
    
<div class="formclass">
  <h1>Computer Access Forms</h1>
  <div class="sectionclass">
    <cfif IsDefined("url.reqID")> <!--- supv sends email to self --->
      <div style="color:red;font-size:1.6em;">E-MAIL SENT</div>
      <div>to: <cfoutput>#emails.EmailAddress#</cfoutput></div>
    <cfelse>
      You have successfully submitted a <b>Computer Access Authorization E-Form.<br>
      <cfif emails.RecordCount GT 0>
        <span style="color:#777;">Email sent to <cfoutput query="emails"> : #EmailAddress# </cfoutput></span><br>
      </cfif>
      <div>
        <a href="SupvPost.cfm?reqID=<cfoutput>#theReqID#</cfoutput> ">Click here to email a copy to yourself</a> 
      </div>
    </cfif>
    <div style="width:400px">
    <table>
    <cfoutput>
          <cfloop query="detail">
            <cfif ItemValue NEQ "" AND Type NEQ "FORM" AND Type NEQ "RESPONSE">
              <cfif Type EQ "NODE">
                <tr><td colspan="2" style="text-align:center;"><b>Access requested for: <span style="color:orange;">#Descrip#</span></b></td></tr>
              <cfelse>
                <tr><td>#Descrip#</td><td>#ItemValue#</td></tr>
              </cfif>
            </cfif>
          </cfloop>
    </cfoutput> 
    </table>
    </div>
    &larr; <a href="https://ccp1.msj.org/login/login/CompAccess/">Enter another Computer Access Form</a><br> 
    &larr; <a href="https://ccp1.msj.org/login/login/home.cfm">Intranet login menu</a><br> 
  </div>
</div>

<!--- send emails to IT dept --->
<cfif emails.RecordCount GT 0>
  <cfset EmailList = "">
  <cfoutput query="emails">
  <cfset EmailList = ListAppend(EmailList,#EMailAddress#)>
  </cfoutput>

  <cfmail to="#EmailList#" 
  from = "cpisc@msj.org"
  subject = "#emailsubject#"
  type="html">
  <html>
  <head>
     <style type="text/css">
      td{border:1px solid ##CCC};
     </style>
  </head>
  <body>
    <div style="width:400px">
    <cfif IsDefined("url.reqID")>
    <cfelse>
      <a href="https://ccp1.msj.org/login/login/CompAccess/index.cfm?reqid=<cfoutput>#header.RequestID#</cfoutput>">
        EDIT THIS COMPUTER ACCESS AUTHORIZATION E-FORM.</a><br>
    </cfif>
    Submitted By: #header.SupvName# <br>
    On #DateFormat(header.EnteredDate,"M/D/YY")# at #TimeFormat(header.EnteredDate,"HH:MM")#<br>
      <table style="width:100%; padding-left:5px;font-family:Arial, Helvetica, sans-serif;">
      <cfloop query="detail">
        <cfif ItemValue NEQ "" AND Type NEQ "FORM" AND Type NEQ "RESPONSE">
          <cfif Type EQ "NODE">
            <tr><td colspan="2" style="text-align:center;"><b>Access requested for: <span style="color:orange;">#Descrip#</span></b></td></tr>
          <cfelse>
            <tr><td style="text-align:right; padding-right:5px;">#Descrip#</td><td><b>#ItemValue#</b></td></tr>
          </cfif>
        </cfif>
      </cfloop>
      </table>
    </div>
    Sent to #EmailList#<br>
  </body>
  </html>
  </cfmail>
</cfif>
 
<!--- send Special emails --->
<cfif NOT IsDefined("url.reqID")>
  <!--- "SpecialCheck" marks hidden fields AND returns special emails --->
  <cfstoredproc procedure="SpecialCheck" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_integer" value="#theReqID#">
  <cfprocresult resultset="1" name="specialemails">
  <cfprocresult resultset="2" name="debugsql">
  </cfstoredproc>
  <!---    
  <cfoutput query="debugsql">
	#SQLString#
  </cfoutput>
--->
  <cfif specialemails.RecordCount GT 0> 
    <cfoutput query="specialemails" group="SpecialID">
      <cfmail to="#EMailAddress#" 
      from = "cpisc@msj.org"
      subject = "#emailsubject#"
      type="html">
        <html>
        <head>
           <style type="text/css">
            td{border:1px solid ##CCC};
           </style>
        </head>
        <body>
          <div style="width:400px">
          <h3>#emailsubject#</h3>
          Submitted By: #header.SupvName# <br>
          On #DateFormat(header.EnteredDate,"M/D/YY")# at #TimeFormat(header.EnteredDate,"HH:MM")#<br>
            <table style="width:100%; padding-left:5px;font-family:Arial, Helvetica, sans-serif;">
            <cfoutput>
                  <tr><td style="text-align:right; padding-right:5px;">#Descrip#</td><td><b>#ItemValue#</b></td></tr>
            </cfoutput>
            </table>
          </div>
        </body>
        </html>
      </cfmail>     
    </cfoutput>
  </cfif>
</cfif>
 
<style>
body {
  background-image: url(./background.png);
  background-attachment: fixed;
  font-family: sans-serif;
  text-align:center;
}
  div {
    margin: 20px auto;
    text-align:center;
    border-radius: 4px;
  }
  div.formclass {
    width: 700px;
    background-color: rgba(0,0,0, 0.1);
    color: white;
    padding: 3px;
    border: 2px solid #3b5969;
    text-align:left;
    font-weight:bold;
    
  } 
  div.sectionclass {
    background-color: #f0f4f7;
    color: black;
    padding: 10px;
    border: 1px solid #3b5969;
    text-align:left;
    font-weight:bold;
  }
</style> 