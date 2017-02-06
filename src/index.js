import React from 'react';
import { hashHistory, Router, Route } from 'react-router'
import ReactDOM from 'react-dom';
//import GetForm from './GetForm';
import CheckAdmin from './CheckAdmin';
//import Admin from './Admin';
import ListForms from './ListForms';

import './index.css';

ReactDOM.render(
  <Router history={hashHistory}>
    <Route path="/" component={ListForms} />
    <Route path="/:view" component={CheckAdmin}>    
      <Route path="/:view/:formID">
        <Route path="/:view/:formID/:reqID"/> 
      </Route>
    </Route>
  </Router>,
  document.getElementById('root') 
);

//view can be "SUPV", "IS", or "EDIT"

//<Route path="/edit" component={() => (<GetForm view="EDIT"  />)} /> 