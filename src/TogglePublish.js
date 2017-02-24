import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

export default class TogglePublish extends React.Component {
 
  onChange=()=>{
    //event && event.preventDefault();    
    axios.get(LibPath + 'DBUpdate.cfm', {
      params: {
        Proc: "PublishForm",
        FormID: this.props.FormID,
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

  render()  {
    return (
        <div className="pubclass">
          <input type="checkbox" onChange={() => this.onChange()} checked={this.props.published} /> 
          {this.props.published ? " Published " : "Unpublished"}
        </div>
    )
  }
};



 

