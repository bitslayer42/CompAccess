import React from 'react';
import delbutton from './images/delete.png';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';

export default class DeleteSpecial extends React.Component {
 
  onClick=(event)=>{
    event && event.preventDefault();    
    //const r = confirm("Are you sure you want to delete?");
    //if(r){
      axios.get(LibPath + 'Special.cfm', {
        params: {
          Proc: "DelSpecial",
          SpecialID: this.props.SpecialID,
          cachebuster: Math.random()
        }
      })
      .then(() => {  
        this.props.handleRedraw();
      })
      .catch(err => {
        console.log(err);
      });
    //}
  }  

  render()  {  
    return (
        <span className="addelement"><a onClick={this.onClick}><img src={delbutton} title="Delete" alt="Delete" /></a></span>
    )
  }
};
 


 

