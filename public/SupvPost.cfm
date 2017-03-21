<cfdump var="#form#">
<cfset ItemStr = "<reqrows>">
<cfloop collection="#form#" item="theField">
  <cfif theField NEQ "fieldNames" AND theField NEQ "DateEntered" AND theField NEQ "SupvName" AND theField NEQ "SupvSig">
  <cfset ItemStr = ItemStr & "<row><Field>#theField#</Field><Value>#form[theField]#</Value></row>" >
  </cfif>
</cfloop>
<cfset ItemStr = ItemStr & "</reqrows>">

<cfset supv = form.SupvName & " - Signature:" & form.SupvSig>


<cfstoredproc procedure="UpsertRequest" datasource="ITForms">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#supv#">
  <cfprocparam cfsqltype="cf_sql_varchar" value="#ItemStr#">
  <cfprocresult name="reqid">
</cfstoredproc>



<div style="text-align:center;padding-top:100px;">
  You have successfully submitted a <b>Computer Access Authorization E-Form.<br>
  <div>
    <a href="EmailSelf.cfm">Click here to email a copy to yourself</a> 
  </div>
  <a href="https://ccp1.msj.org/login/login/home.cfm">Return to intranet login menu</a> 
</div>

<!--- <cfoutput>#reqid.RequestID#</cfoutput> <br>
<cfdump var="#form#">
<cfabort>
<cfcontent type="application/xml" reset="yes">
<cfoutput>#ItemStr#</cfoutput>

exec InsRequest @SupvName = 'J. Supv Wilson', @Items = N'
<reqrows>
	<row>
		<Field>9</Field>
		<Value>J. Staffy Wilson</Value>
	</row>
	<row>
		<Field>35</Field>
		<Value>1027126</Value>
	</row>
	<row>
		<Field>37</Field>
		<Value>2017-03-01</Value>
	</row>
	<row>
		<Field>36</Field>
		<Value>Johannes Staffy Wilson</Value>
	</row>
	<row>
		<Field>19</Field>
		<Value>External Temp Agency Staff</Value>
	</row>
</reqrows>
	
'

--->