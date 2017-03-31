import React from 'react';
import { IndexRoute, browserHistory, Router, Route } from 'react-router'
import ReactDOM from 'react-dom';
import GetForm from './GetForm';
import CheckAdmin from './CheckAdmin';
import UserAdmin from './UserAdmin';
import { HomePath } from './LibPath';
import './css/index.css';

ReactDOM.render(
  <Router history={ browserHistory }>
    <Route path={HomePath}>
      <IndexRoute component={CheckAdmin} />
      <Route path="index.html" component={CheckAdmin} /> {/* used for email */}
      <Route path="index.cfm" component={CheckAdmin} /> {/* used for email */}
      <Route path="useradmin(/:AdminID)" component={UserAdmin} />   
      <Route path=":view/:formID(/:reqID)" component={GetForm} />    
    </Route>
  </Router>,
  document.getElementById('root') 
);

// GetForm :view options:
//    /SUPV/:formid,      Supv is filling out a form
//    /ADMIN/0/:reqid     The IT department is working a request
//    /EDIT/:formid       Add and remove form elements
//    /HEADER/:formid     Set form elements as header records to appear in Unresolved Queue
//    /REQUIRED/:formid   Set form elements as Requred
//    /useradmin/:AdminID Edit admin
//    /useradmin          Add new admin
