import React from 'react';
import { hashHistory, Router, Route } from 'react-router'
import ReactDOM from 'react-dom';
import GetForm from './GetForm';
import CheckAdmin from './CheckAdmin';
import UserAdmin from './UserAdmin';
import ResponseTest from './ResponseTest';   
import './css/index.css';

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={CheckAdmin} />
    
<Route path="/Test" component={ResponseTest} />
    
    <Route path="/useradmin/:user" component={UserAdmin} />   
      
    <Route path="/:view/:formID" component={GetForm}>    
        <Route path="/:view/:formID/:reqID" /> 
    </Route>
    
  </Router>,
  document.getElementById('root') 
);

// GetForm :view options:
//    /SUPV/:formid,      Supv is filling out a form
//    /ADMIN/0/:reqid     The IS department is working a request
//    /EDIT/:formid       Add and remove form elements
//    /HEADER/:formid     Set form elements as header records to appear in Unresolved Queue
//    /REQUIRED/:formid   Set form elements as Requred

