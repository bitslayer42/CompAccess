<!doctype html>
<HTML>
<HEAD>

<TITLE>Computer Access Form Reports</TITLE>
  
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
</HEAD>
<BODY>
<cfif NOT Isdefined("form.EmpID")>
      <cfquery name="listStaff" datasource="ITForms">
        SELECT DISTINCT EmpID, EmpName
        FROM ReportView
        ORDER BY EmpName
      </cfquery>
      <cfquery name="listNodes" datasource="ITForms">
        SELECT DISTINCT NodeID, NodeName
        FROM ReportView
        ORDER BY NodeName
      </cfquery>    

  <div style="display:flex;flex-direction: column;align-items: center;">
    
    <div class="formclass">
      <h1>Computer Access Form Reports</h1>
      List by Staff or Node
      <div class="sectionclass">
        <p>

          <cfform action="Report.cfm" method="post">
            <div style="display:flex;flex-direction: column;align-items: flex-start;">
              <div style="margin:10px;">
                <label>
                Staff:
                <select name="EmpID">
                  <option value="%">ALL</option>
                  <cfoutput query="listStaff">
                    <option value="#EmpID#">#EmpName#:#EmpID#</option>
                  </cfoutput>
                </select>
                </label>
              </div><div style="margin:10px;">
                <label>
                Node:
                <select name="NodeID">
                  <option value="%">ALL</option>
                  <cfoutput query="listNodes">
                    <option value="#NodeID#">#NodeName#</option>
                  </cfoutput>
                </select>
                </label>
              </div><div>
                <cfinput type="submit" name="butn" value=" OK " id="submitbutton" >
              </div>
            </div>
          </cfform>
        </div>
          <a href="https://ccp1.msj.org/login/login/CompAccess/">Return to Admin Menu</a>
            <br><br><br>
        </p>  
      </div>
        <p>
        &larr; <a href="https://ccp1.msj.org/login/login/CompAccess/">Computer Access Form ADMIN</a><br> 
        </p>  
    </div>


  </div>
  </BODY>
  </HTML>

<cfelse>
 		<cfquery name="list" datasource="ITForms">
			SELECT DISTINCT EmpName, NodeName
			FROM ReportView
      WHERE EmpID LIKE '#form.EmpID#'
      AND NodeID LIKE '#form.NodeID#'
			ORDER BY EmpName, NodeName
		</cfquery>
    <cfif form.EmpID EQ '%'>
      <cfquery name="listStaff" datasource="ITForms">
        SELECT 'ALL' AS EmpName
      </cfquery> 
    <cfelse>
      <cfquery name="listStaff" datasource="ITForms">
          SELECT DISTINCT EmpName
          FROM ReportView
          WHERE EmpID LIKE '#form.EmpID#'
      </cfquery>
    </cfif>
    <cfif form.NodeID EQ '%'>
      <cfquery name="listNodes" datasource="ITForms">
        SELECT 'ALL' AS NodeName
      </cfquery> 
    <cfelse>   
      <cfquery name="listNodes" datasource="ITForms">
        SELECT DISTINCT NodeName
        FROM ReportView
        WHERE NodeID LIKE '#form.NodeID#'
      </cfquery>     
    </cfif>

			<cfdocument
			format="PDF" 
			localurl="true"
			unit="in" 
			backgroundvisible="yes" 
			marginbottom=".4" 
			margintop=".4" 
			marginright=".15"
			marginleft=".15"
			fontembed="yes"
			pagetype="letter"
			orientation="portrait">
				<html>
				<link href="https://ccp1.msj.org/styles/mainstyles.css" type="text/css" rel="STYLESHEET">
				<style>
				th {
					text-align:left;
				}
				</style>
			
				<hr size="1" color="black" style="border:1px;color:black;background-color:black;">
				<h2>Computer Access Form Report</h2>
				
				<i>Run parameters</i><br>
        Employee: <cfoutput query="listStaff">#EmpName# </cfoutput><br>
        Node: <cfoutput query="listNodes">#NodeName# </cfoutput> 
				<hr size="1" color="black" style="border:1px;color:black;background-color:black;">

				<table>
				<tr>
				<th>
				Name
				</th>
				<th>
				Node
				</th>
				</tr>
				<cfoutput query="list">
				<tr>
				<td>
				#EmpName#
				</td>
				<td>
				#NodeName#
				</td>			
        </tr>
			
				</cfoutput>
				</table>
				</html>
				<!--- END MAIN --->
            
            <cfdocumentitem type="footer">
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
            <td align="left">
				<cfoutput>Report Date: #DateFormat(Now(),"MM/DD/YYYY")#</cfoutput> 
            </td>
            <td align="right">
            <font style="font-family:Arial, Helvetica, sans-serif;font-size:9px">
				<cfoutput>Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</cfoutput> 
            </font>
            </td>
            </tr>
            </table></cfdocumentitem>  
               
            </cfdocument>
</cfif>