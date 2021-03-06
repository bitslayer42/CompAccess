import React from 'react';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';
import DeleteElement from './DeleteElement';
import './css/checkbox.css';

//There are four views that edit the forms: 
//    /EDIT/:formid       Add and remove form elements
//    /HEADER/:formid     Set form elements as header records to appear in Unresolved Queue
//    /REQUIRED/:formid   Set form elements as Requred
//    /REQRESP/:formid    Set form elements as Requred Response (element required to complete)
export default class Edit extends React.Component {
  //Edit renders the little checkboxes in various edit modes
  render()  { 
    return (
    <span className="linkmouseover">
    {
      this.props.view === "EDIT"
      ? <DeleteElement FormID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw}  />
      :this.props.view === "HEADER"
      ? <ToggleHeader curr={this.props.curr} handleRedraw={this.props.handleRedraw}  />
      :this.props.view === "REQUIRED"
      ? <ToggleRequired curr={this.props.curr} handleRedraw={this.props.handleRedraw}  />
      :this.props.view === "REQRESP"
      ? <ToggleReqResp curr={this.props.curr} handleRedraw={this.props.handleRedraw}  />
      : null

    }
    </span>
    )
  }
};
// Edit.propTypes = {
    // curr: React.PropTypes.object,
    // view: React.PropTypes.string,
    // handleRedraw: React.PropTypes.func
// };

////////////////////////////////////////////////////////////////////////////////////////////
class ToggleHeader extends React.Component {
 constructor(props) { 
    super(props);
    this.state = {
      value: this.props.curr.HeaderRecord
    };

    this.onChange = this.onChange.bind(this);
  }
  
  onChange=(event)=>{ 
    event && event.preventDefault();   
    this.setState({value: !this.state.value});    
    axios.get(LibPath + 'DBUpdate.cfm', {
      params: {
        Proc: "ToggleHeaderRecord",
        FormID: this.props.curr.FormID,
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

  render()  {   
    if(this.props.curr.Type === "INPUT"||this.props.curr.Type === "RADIO"||this.props.curr.Type === "SELECT"
		||this.props.curr.Type === "DATE"||this.props.curr.Type === "CHECKBOX"||this.props.curr.Type === "TEXTAREA"){
      return (
      <span className="addelement">
        <input type="checkbox" id={this.props.curr.FormID} className="css-checkbox" checked={this.state.value} onChange={this.onChange} />
        <label htmlFor={this.props.curr.FormID} className="css-label  queckbox" />
      </span>
      )
    }else return null
  }
};

// ToggleHeader.propTypes = {
    // curr: React.PropTypes.object,
    // handleRedraw: React.PropTypes.func
// };


////////////////////////////////////////////////////////////////////////////////////////////
class ToggleRequired extends React.Component {
 constructor(props) { 
    super(props);
    this.state = {
      value: this.props.curr.Required
    };

    this.onChange = this.onChange.bind(this);
  }
  
  onChange=(event)=>{ 
    event && event.preventDefault();   
    this.setState({value: !this.state.value});    
    axios.get(LibPath + 'DBUpdate.cfm', {
      params: {
        Proc: "ToggleRequired",
        FormID: this.props.curr.FormID,
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

  render()  {   
    if(this.props.curr.Type === "INPUT"||this.props.curr.Type === "RADIO"||this.props.curr.Type === "SELECT"
		||this.props.curr.Type === "DATE"||this.props.curr.Type === "TEXTAREA"){
      return (
      <span className="addelement">
        <input type="checkbox" id={this.props.curr.FormID} className="css-checkbox" checked={this.state.value} onChange={this.onChange} />
        <label htmlFor={this.props.curr.FormID} className="css-label  reqckbox" />
      </span>
      )
    }else return null
  }
};

// ToggleRequired.propTypes = {
    // curr: React.PropTypes.object,
    // handleRedraw: React.PropTypes.func
// };
 
////////////////////////////////////////////////////////////////////////////////////////////
class ToggleReqResp extends React.Component {
 constructor(props) { 
    super(props);
    this.state = {
      value: this.props.curr.ReqResp
    };

    this.onChange = this.onChange.bind(this);
  }
  
  onChange=(event)=>{ 
    event && event.preventDefault();   
    this.setState({value: !this.state.value});    
    axios.get(LibPath + 'DBUpdate.cfm', {
      params: {
        Proc: "ToggleReqResp",
        FormID: this.props.curr.FormID,
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

  render()  {   
    if(this.props.curr.Type === "INPUT"||this.props.curr.Type === "RADIO"||this.props.curr.Type === "SELECT"
		||this.props.curr.Type === "DATE"||this.props.curr.Type === "CHECKBOX"||this.props.curr.Type === "TEXTAREA"){
      return (
      <span className="addelement">
        <input type="checkbox" id={this.props.curr.FormID} className="css-checkbox" checked={this.state.value} onChange={this.onChange} />
        <label htmlFor={this.props.curr.FormID} className="css-label  respckbox" />
      </span>
      )
    }else return null
  }
};

// ToggleReqResp.propTypes = {
    // curr: React.PropTypes.object,
    // handleRedraw: React.PropTypes.func
// };
 

