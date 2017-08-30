 		<cfquery name="header" datasource="ITForms">
      SELECT Descrip AS Node
      FROM Forms
      WHERE Type = 'Node'
      ORDER BY lft
		</cfquery>
 		<cfquery name="body" datasource="ITForms">
			SELECT Name, Descrip AS Node,
      CASE WHEN AdminEmails.AdminID IS NULL THEN NULL ELSE 'X' END AS GetsEmail 
      FROM Admins
      CROSS JOIN (
        SELECT *
        FROM Forms
        WHERE Type = 'Node'
      ) AS Nodes
      LEFT JOIN AdminEmails
      ON Admins.AdminID = AdminEmails.AdminID
      AND AdminEmails.SubscribedNode = Nodes.ID
      ORDER BY Name, lft
		</cfquery>
    
<!doctype html>
<html>
<head>
<style>
th.rotate {
  /* Something you can count on */
  height: 140px;
  white-space: nowrap;
}

th.rotate > div {
  transform: 
    /* Magic Numbers */
    translate(25px, 51px)
    /* 45 is really 360 - 45 */
    rotate(315deg);
  width: 30px;
}
th.rotate > div > span {
  border-bottom: 1px solid #ccc;
  padding: 5px 10px;
}
td.body {
  border: 1px solid #ccc;
  padding: 5px 10px;
}
td.name {
  border-bottom: 1px solid #ccc;
  height: 30px;
  font-weight: bold;
}
</style>
</head>
<body>
			
    <hr size="1" color="black" style="border:1px;color:black;background-color:black;">
    <h2>Computer Access Form Report: IT Emails for each Node</h2>
    
    <hr size="1" color="black" style="border:1px;color:black;background-color:black;">

    <table>
    <tr>
      <td>
      &nbsp;
      </td>
      <cfoutput query="header">
        <th class="rotate"><div><span>
          #Node#
        </span></div></th>
      </cfoutput>
    </tr>
    <cfoutput query="body" group="Name">
      <tr>
        <td class="name">
          #Name#
        </td>
        <cfoutput>
          <td class="body">
            #GetsEmail#
          </td>
        </cfoutput>
      </tr>
    </cfoutput>
    </table>
</body>

