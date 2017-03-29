import React from 'react';
import { hashHistory, Router, Route } from 'react-router'
import ReactDOM from 'react-dom';
import GetForm from './GetForm';
import CheckAdmin from './CheckAdmin';
import UserAdmin from './UserAdmin';
import './css/index.css';
//import ResponseTest from './ResponseTest';   <Route path="/Test" component={ResponseTest} />

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={CheckAdmin} />
    
    <Route path="/useradmin" component={UserAdmin}>   
        <Route path="/useradmin/:AdminID" /> 
    </Route>
    
    <Route path="/:view/:formID" component={GetForm}>    
        <Route path="/:view/:formID/:reqID" /> 
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

