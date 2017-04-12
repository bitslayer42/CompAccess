import React from 'react';
import delbutton from './images/delete.png';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';

export default class DeleteElement extends React.Component {
 
  onClick=(event)=>{
    event && event.preventDefault();    
    const r = confirm("Are you sure you want to delete?");
    if(r){
      axios.get(LibPath + 'DBUpdate.cfm', {
        params: {
          Proc: "DelNode",
          FormID: this.props.FormID,
          //cachebuster: Math.random()
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
 


 

