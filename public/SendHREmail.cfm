
<cfstoredproc procedure="GetRequest" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#url.reqID#">
  <cfprocresult name="req">
</cfstoredproc>  

<cfset xmlheader = XmlParse(req.HeaderXML)>
<cfset emailsubject = "Computer Access Authorization is on hold">
<cfoutput>
      <cfloop array="#xmlheader.root.xmlchildren#" index="i" >
        <cfset emailsubject = emailsubject & "-" & i.itemvalue.xmltext>
      </cfloop>
</cfoutput> 
  
  <cfmail to = "#req.EmailAddress#" 
  from = "cpisc@msj.org"
  subject = "#emailsubject#" 
  query="req"
  type="html">
  <html>
  <body>
    <div style="width:400px">
      <table>
        <tr>
          <cfloop array="#xmlheader.root.xmlchildren#" index="i" >
            <cfif i.col.xmltext NEQ "Form">
              <td style="border:1px solid ##CCC">
                <div style="color: green;font-size:10pt;width:120px;">#i.col.xmltext#:</div>
                #i.itemvalue.xmltext#
              </td>
            </cfif>
          </cfloop>
        </tr>
      </table>
      <h2>
      Computer Access Authorization ON HOLD
      </h2>
      <p>
      Employee has not been set-up in HR yet. 
      </p>
      <p> 
      The IT Dept. will process this Computer Access Authorization as soon as they are set-up in HR. 
      </p>
      <p> 
      This Computer Access Authorization E-Form was submitted by <b>#SupvName#</b> on <b>#DateFormat(EnteredDate,"MM/DD/YYYY")#.</b>
      </p>
      <p> 
      This is an automated email sent by the Computer Access Authorization E-System. 
      </p>

    </div>
  </body>
  </html>
  </cfmail>
  
  <!---return no error--->
  [0]
  
