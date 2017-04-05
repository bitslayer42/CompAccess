To go live:

Toggle the path variable in LibPath.js
Copy all the cfm files in \\ccp1.msj.org\wwwroot\CompAccess to local \public folder

Run: npm run build
Copy: build folder contents to \\ccp1.msj.org\wwwroot\login\login\CompAccess

rename index.html to index.cfm

remove debugging code from DBGet.cfm and SupvPost.cfm

