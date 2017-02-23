import React from 'react';
import delbutton from './images/delete.png';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

//USAGE:   // <DeleteNode FormID={form.FormID} handleDelete={this.handleDelete} index={ix}/>

export default class DeleteNode extends React.Component {
 
  onClick=(event)=>{
    event && event.preventDefault();    
    var r = confirm("Are you sure you want to delete?");
    if(r){
      axios.get(LibPath + 'DBUpdate.cfm', {
        params: {
          Proc: "DelNode",
          FormID: this.props.FormID,
          cachebuster: Math.random()
        }
      })
      .then(() => {  
        this.props.handleDelete(this.props.index);
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
    return (
        <span className="addnew"><a onClick={() => this.onClick()}><img src={delbutton} alt="Delete" /></a></span>
    )
  }
};

// class DeleteNodeTest extends React.Component {
  
  // handleDelete(){
    // console.log("handleDelete");
  // }
  
  // render()  {
    // return (
  // <DeleteNode FormID="107" handleDelete={this.handleDelete}/>
    // )
  // }
// } 


 

