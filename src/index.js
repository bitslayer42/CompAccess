import "babel-polyfill";  //this has to be the first line. I needed it to use Array.prototype.find in IE11
import React from 'react';
import {
  BrowserRouter as Router,
  Switch,
  Route
} from 'react-router-dom'
import ReactDOM from 'react-dom';
import GetForm from './GetForm';
import CheckAdmin from './CheckAdmin';
import StaffList from './StaffList';
import ShowAdministrator from './ShowAdministrator';
import AddSpecial from './AddSpecial';
import EditSpecial from './EditSpecial';
import { HomePath } from './LibPath';
import './css/index.css';
import registerServiceWorker from './registerServiceWorker';

ReactDOM.render(
  <Router>
   <Switch>

      <Route exact path={HomePath} component={CheckAdmin} />
      <Route exact path={`${HomePath}index.cfm`} component={CheckAdmin} /> {/* used for email */}
	  
	  <Route exact path={`${HomePath}useradmin`} component={StaffList} /> 
      <Route path={`${HomePath}useradmin/:AdminID`} component={ShowAdministrator} />   

	  <Route exact path={`${HomePath}special`} component={AddSpecial} /> 
      <Route path={`${HomePath}special/:SpecialID`} component={EditSpecial} /> 

	  <Route exact path={`${HomePath}:view/:formID`} component={GetForm} /> 
      <Route path={`${HomePath}:view/:formID/:reqID`} component={GetForm} /> 

      <Route path=":view/:formID/:reqID" component={GetForm} />    

   </Switch>
  </Router>,
  document.getElementById('root') 
);
registerServiceWorker();

// GetForm :view options
//    /SUPV/:formid,      Supv is filling out a form
//    /ADMIN/0/:reqid     The IT department is working a request
//    /EDIT/:formid       Add and remove form elements
//    /PREVIEW/:formid    Preview while editing
//    /HEADER/:formid     Set form elements as header records to appear in Unresolved Queue
//    /REQUIRED/:formid   Set form elements as Requred
//    /REQRESP/:formid    Set form elements as Requred Response (element required to complete)

//Other paths
//    /useradmin/:AdminID Edit admin
//    /useradmin          Add new admin
//    /special/:specID    Edit Special forks
//    /index.cfm          used for email-immediately forwarded
