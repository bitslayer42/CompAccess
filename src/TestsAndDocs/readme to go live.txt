To go live:

Toggle the path variable in LibPath.js

Replace background.png in local \public and \src\images folders. 
Copy all the cfm files in \\ccp1.msj.org\wwwroot\CompAccess to local \public folder (don't delete other files like web.config, etc.)

Change  datasource="ITFormsTest"  to  datasource="ITForms"  in all cfm files

Run: npm run build

Copy: build folder contents to \\ccp1.msj.org\wwwroot\login\login\CompAccess
Copy: public and source folders to \\ccp1.msj.org\wwwroot\login\login\CompAccess\SourceCode

rename index.html to index.cfm

remove debugging code from DBGet.cfm and SupvPost.cfm

