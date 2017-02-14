import React from 'react';
import { hashHistory, Router, Route } from 'react-router'
import ReactDOM from 'react-dom';
import GetForm from './GetForm';
import CheckAdmin from './CheckAdmin';
import UserAdmin from './UserAdmin';
import AddNew2 from './AddNew'

import './index.css';

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={CheckAdmin} />
      <Route path="/AddNew" component={AddNew2} />{/**/}
      
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

//<Route path="/edit" component={() => (<GetForm view="EDIT"  />)} /> 

