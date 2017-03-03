import React from 'react';
import delbutton from './images/delete.png';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

export default class DeleteElement extends React.Component {
 
  onClick=(event)=>{
    event && event.preventDefault();    
    var r = confirm("Are you sure you want to delete?");
    if(r){
      axios.get(LibPath + 'DBUpdate.cfm', {
        params: {
          Proc: "DelNode",
          DelID: this.props.DelID,
          cachebuster: Math.random()
        }
      })
      .then(() => {  
        this.props.handleRedraw();
      })
      .catch(err => {
        this.setState({
          loading: false,
          error: err
        });
      });
    }
  }  

  render()  {
    if(this.props.view !== "EDIT"){
      return null
    }else{    
    return (
        <span className="addelement"><a onClick={this.onClick}><img src={delbutton} title="Delete" alt="Delete" /></a></span>
    )
    }
  }
};
 


 

