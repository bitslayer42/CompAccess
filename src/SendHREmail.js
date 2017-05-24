import React from 'react';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';

export default class SendHREmail extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      complete: false //if false, show button, if true, show message
    };
  }  

  handleDone=()=>{ 
    axios.get(LibPath + 'SendHREmail.cfm', {
      params: {
        reqID: this.props.reqID,
        cachebuster: Math.random()
      }
    })
    .then(res => {   //debugger;
      if(res.data[0]===0)
      this.setState({ 
        complete: true
      }); 
    })
    .catch(err => {
      console.log(err);
    });
  }  

  render()  { 
    return (
      <span className="addelement">
        {
          this.state.complete
          ? <div style={{width:"600px",margin:"10px auto",textAlign:"center"}}>
              Email sent to supervisor.
            </div>
          : <div style={{width:"600px",margin:"10px auto"}}>
              <button onClick={this.handleDone}>
                Click here to send email to supervisor to alert them that their employee is not set-up in HR yet
              </button>
            </div>
        }
     </span>
    )
  }
};


