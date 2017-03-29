import React from 'react';
//import { hashHistory } from 'react-router'
import axios from 'axios'; //ajax library
//import Autosuggest from 'react-autosuggest';
import LibPath from './LibPath';

export default class StaffList extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      SearchString: ""
    };
  }

  onChange=(event)=>{
    this.setState({
      SearchString: event.target.value
    });    
    axios.get(LibPath + 'Administrator.cfm', {
      params: {
        Proc: "GetStaffList",
        SearchString: event.target.value,
        cachebuster: Math.random()
      }
    })
    .then(res => {
      const userData = res.data; 
      console.log(userData);

    })
    .catch(err => {
      console.log(err);
    }); 
  }
  

  
  render()  {
    return (
      <div>
          <input value={this.state.SearchString} onChange={this.onChange} placeholder="Staff Name"/>
      </div>
    );
  }
}
