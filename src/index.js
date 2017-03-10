import React from 'react';
import { hashHistory, Router, Route } from 'react-router'
import ReactDOM from 'react-dom';
import GetForm from './GetForm';
import CheckAdmin from './CheckAdmin';
import UserAdmin from './UserAdmin';
//import RadioTest from './Radiotest';<Route path="/rad" component={RadioTest} /> 
import './css/index.css';

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={CheckAdmin} />

    
    <Route path="/useradmin/:user" component={UserAdmin} />   
      
    <Route path="/:view/:formID" component={GetForm}>    
        <Route path="/:view/:formID/:reqID" /> 
    </Route>
    
  </Router>,
  document.getElementById('root') 
);

// GetForm :view options:
//    /SUPV/:formid, 
//    /ADMIN/0/:reqid
//    /EDIT/:formid


