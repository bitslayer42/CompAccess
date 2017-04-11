import React from 'react';
import delbutton from './images/delete.png';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';

//Delete an Administrator
export default class DeleteAdmin extends React.Component {
 
  onClick=(event)=>{
    event && event.preventDefault();    
    const r = confirm("Are you sure you want to delete?");
    if(r){
      axios.get(LibPath + 'Administrator.cfm', {
        params: {
          Proc: "DelAdmin",
          AdminID: this.props.AdminID,
          cachebuster: Math.random()
        }
      })
      .then(() => {  
        this.props.handleRedraw();
      })
      .catch(err => {
        console.log(err);
      });
    }
  }  

  render()  {  
    return (
        <span className="addelement"><a onClick={this.onClick}><img src={delbutton} title="Delete" alt="Delete" /></a></span>
    )
  }
};
 


 

