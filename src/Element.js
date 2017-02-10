import React from 'react';
//import { Link } from 'react-router'
import moment from 'moment'; //date library
import LibPath from './LibPath';

export default class Element extends React.Component {   //An element can be any row returned from stored proc
  render() {
    return ( 
      <div>
      {
        this.props.tree.map((curr) => {
          if      (curr.Type==="FORM"){
            return <ElementForm curr={curr} key={curr.ID} view={this.props.view} header={this.props.header} submitForm={()=>this.props.submitForm()}/> 
          }else if(curr.Type==="SECTION"){
            return <ElementSection curr={curr} key={curr.ID} view={this.props.view}/>
          }else if(curr.Type==="NODE"){
            return <ElementNode curr={curr} key={curr.ID} view={this.props.view}/> 
          }else if(curr.Type==="TEXT"){
            return <ElementText curr={curr} key={curr.ID} view={this.props.view}/> 
          }else if(curr.Type==="INPUT"||curr.Type==="RADIO"||curr.Type==="SELECT"){
            //html form types, first check if it is a RESPONSE
            return <ElementIsResponse curr={curr} key={curr.ID} view={this.props.view}/> 
          }else{
            return <div>No</div>
          }
        })
      }
      </div>
    )
  }
}

function Edit(props) {
  return(
    props.view === "EDIT" && <div className="editclass">Add things for {props.type}</div>
  )
}

function ElementForm(props) {
  let formatdate = moment(props.header.EnteredDate).format("MMMM Do YYYY, h:mm a"); //if no date in header, is NOW
  return (
    <div className="formclass" key={props.curr.ID}>
      <form method="post" action={LibPath + 'SupvPost.cfm'}>
        <h1>Computer Access Authorization E-Form</h1>
        <h2>{props.curr.Descrip}</h2>
        {props.header.SupvName && <p><i>Entered by:</i> {props.header.SupvName}</p>} 
        {formatdate}
        <input type="hidden" name={props.curr.ID} id={props.curr.ID} defaultValue={props.curr.Descrip}/>
        <input type="hidden" name="DateEntered"   id={props.curr.ID} defaultValue={formatdate}/>
        <input type="hidden" name="SupvName"      id={props.curr.ID} defaultValue={props.header.SupvName}/>
        <Element tree={props.curr.children} view={props.view}/>
          {props.view === "SUPV" && <Signature SupvName={props.header.SupvName}/>}
        
        <Edit view={props.view} type="Form"/> 
        <div style={{height:"200px"}}/>
      </form>
    </div>
  )
}

function ElementSection(props) {  
  return (
    <div className="sectionclass" key={props.curr.ID}>
      <h2>{props.curr.Descrip}</h2>
      <Element tree={props.curr.children} view={props.view}/>
      <Edit view={props.view} type="Section"/> 
    </div>
  )
}
function ElementText(props) {  
  return (
    <div className="textclass" key={props.curr.ID}>
      <div>{props.curr.Descrip}</div>
      <Edit view={props.view} type="Text"/> 
    </div>
  )
}

class ElementNode extends React.Component { 
  constructor(props) {
    super(props);
    this.state = {
      childVisible: props.curr.ItemValue==="on"?true:false 
    };
    this.onClick = this.onClick.bind(this); //React components using ES6 classes don't autobind "this"
  }
  onClick() {
    this.setState({childVisible: !this.state.childVisible});
  }
  render() { 
    let curr = this.props.curr;
    return (
      <div className="nodeclass" key={curr.ID}>
      <label >
       {curr.Descrip}:
      </label>

      <input type="checkbox" name={curr.ID} onClick={this.onClick} defaultChecked={this.state.childVisible}/>
        {
          this.state.childVisible
            ? <Element tree={curr.children} view={this.props.view}/>
            : null
        }      
      <Edit view={this.props.view} type="Node"/>       
      </div>
    )
  }
}

//Check for a Code of REQUEST or RESPONSE (or null if used outside a Node)
//RESPONSES are only used in Admin screen
class ElementIsResponse extends React.Component { 
  render() { 
    let curr = this.props.curr;
    let view = this.props.view; 
    if(view === "SUPV" && curr.Code === "RESPONSE"){
      return null;
    }else if(curr.Code === "RESPONSE"){
      return (
        <div key={curr.ID} className="responseclass">
          <ElementHtml curr={curr} key={curr.ID} view={view}/> 
        </div>
      )      
    }else{
      return (
        <div key={curr.ID}>
          <ElementHtml curr={curr} key={curr.ID} view={view}/> 
        </div>
      ) 
    }
  }
}

class ElementHtml extends React.Component {
  render() { 
    let curr = this.props.curr;
    let view = this.props.view; 
    if(curr.Type==="INPUT"){
      return <ElementInput curr={curr} key={curr.ID} view={view}/> 
    }else if(curr.Type==="RADIO"){
      return <ElementRadio curr={curr} key={curr.ID} view={view}/> 
    }else if(curr.Type==="SELECT"){
      return <ElementSelect curr={curr} key={curr.ID} view={view}/>

    }else{
      return <div key={curr.ID}>TODO:{curr.Descrip}:</div>
    }
  }
}

class ElementInput extends React.Component { 
  render() { 
    let curr = this.props.curr;
    let view = this.props.view; 
    if(view === "SUPV" && curr.Code === "RESPONSE"){
      return null;
    }else if(view === "IS" && curr.Code === "RESPONSE"){
       return (
        <div key={curr.ID} className="responseclass">
          <label>
          {curr.Descrip}:              
          </label>
          <input type="text" size="50" name={curr.ID} id={curr.ID} defaultValue={curr.ItemValue}/>
          <Edit view={this.props.view} type="Response"/> 
          
        </div>
      )      
    }else{
      return (
        <div key={curr.ID}>
          <label>
          {curr.Descrip}:              
          </label>
          <input type="text" size="50" name={curr.ID} id={curr.ID} defaultValue={curr.ItemValue}/>
          <Edit view={this.props.view} type="Request"/> 
        </div>
      ) 
    }
  }
}

class ElementRadio extends React.Component { 
  render() { 
    let curr = this.props.curr;
      return (
      <div>
      {curr.children.map((chld,ix) => { //these should be OPTIONS
        return( 
          <div key={chld.ID}>
          <label>{ix!==0?"":curr.Descrip+":"}</label>
          <input type="radio" name={curr.ID} defaultChecked={chld.Descrip===curr.ItemValue?"checked":""} value={chld.Descrip} id={chld.ID}/>
          {chld.Descrip}
          <Edit view={this.props.view} type="Option"/>  
          </div>
        )
      })}
      <Edit view={this.props.view} type="Radio"/>       
      </div>      
      ) 
  }
}

class ElementSelect extends React.Component { 
  render() { 
    let curr = this.props.curr;
    return (
      <div>
        <label>
        {curr.Descrip}:
        </label>
        <select id={curr.ID} name={curr.ID} defaultValue={curr.ItemValue}>
          <option key={0} value="">(Choose One)</option>
          {curr.children.map((chld) => { //these should be OPTIONS
            return( 
              <option key={chld.ID} value={chld.Descrip}>{chld.Descrip}</option>
            )
          })}
        </select>
        <Edit view={this.props.view} type="Option"/> 
        <Edit view={this.props.view} type="Select"/> 
      </div>
    )
  }
}

function Signature(props) {  
  return (
    <div className="sectionclass" key="Sig">
      <h2>AUTHORIZATION INFORMATION</h2>
      <label>
      *Supervisor Authorization Signature:
      </label>
     
      <input type="text" name="SupvSig" size="50"/>

      <p>      
      (Typing your name above implies you are authorizing the above computer access form.
      We will verify your signature with the employee id you are currently logged in with.) 
      </p>
      <p>
      You are logged in as {props.SupvName}
      </p>
      <p>
      <button className="submit" onClick={() => props.submitForm()}>Submit</button>
      </p>
    </div>
  )
}


