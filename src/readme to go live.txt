To go live:

Toggle the path variable in LibPath.js
Run: npm run build
Copy: build folder contents to \\ccp1.msj.org\wwwroot\login\login\CompAccess
Make sure all the cfm files in \\ccp1.msj.org\wwwroot\CompAccess are copied to \login\login\CompAccess (maybe via public folder so they can get in git)

rename index.html to index.cfm

remove debugging code from DBGet.cfm

