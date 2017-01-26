//Testing: Run npm start
//to run on my local computer
//This calls the db using cfm here: \\ccp1.msj.org\wwwroot\CompAccess

//To go live:
//Toggle the path variable in this file.
//Run: npm run build
//Copy: build folder contents to \\ccp1.msj.org\wwwroot\login\login\CompAccess

//Test
var LibPath = 'https://ccp1.msj.org/CompAccess/';

//Live
//var LibPath = 'https://ccp1.msj.org/login/login/CompAccess/';

export default LibPath;