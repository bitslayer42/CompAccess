import React from 'react';
import moment from 'moment'; //date library
import DatePicker  from 'react-datepicker'; //datepicker library
import LibPath from './LibPath';
import AddElements from './AddElements';
import Edit from './Edit';
import './css/react-datepicker.css';
import { Link } from 'react-router';

export default class Element extends React.Component {   //An element can be any row returned from stored proc
  render() { 
    return ( 
      <div>
      {
        this.props.tree.map((curr) => {
          if      (curr.Type==="FORM"||curr.Type==="UNPUB"){
            return <ElementForm       curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw} header={this.props.header} /> 
          }else if(curr.Type==="SECTION"){
            return <ElementSection    curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw} />
          }else if(curr.Type==="NODE"){
            return <ElementNode       curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw} /> 
          }else if(curr.Type==="MESSAGE"){
            return <ElementMessage       curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/> 
          }else if(curr.Type==="REQUEST"){
            return <ElementRequest    curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/> 
          }else if(curr.Type==="RESPONSE"){
            return <ElementResponse   curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/>
          }else if(curr.Type==="INPUT"){
            return <ElementInput      curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/> 
          }else if(curr.Type==="DATE"){
            return <ElementDate       curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/> 
          }else if(curr.Type==="RADIO"){
            return <ElementRadio      curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/> 
          }else if(curr.Type==="SELECT"){
            return <ElementSelect     curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/>

          }else{
            return <div key={curr.FormID}>Unknown Element {curr.Type}</div>
          }
          
        })
      }
      </div>
    ) 
  }
}
function ElementFormHeader(props) {
  return (
      <div className="formclass" key={props.curr.FormID}>
        {   props.view==="EDIT"
          ? <h1 style={{color:"red"}}>Add and remove form elements</h1>
          : props.view==="HEADER"
          ? <h1 style={{color:"red"}}>Set fields to appear in Unresolved Queue</h1>
          : props.view==="REQUIRED"
          ? <h1 style={{color:"red"}}>Set fields that are Required</h1>
        : <h1>Computer Access Authorization E-Form</h1>}
          
          <h2>{props.curr.Descrip}</h2>
            {props.curr.Type==="UNPUB" && <div style={{color:"red"}}>Unpublished Form</div>}
          {props.header.SupvName && <p><i>Entered by:</i> {props.header.SupvName}</p>} 
          {props.formatdate}

      </div>
  )
}

function ElementForm(props) {
  let formatdate = moment(props.header.EnteredDate).format("MMMM Do YYYY, h:mm a"); //if no date in header, is NOW    
  return (
    <div>
      {props.view!=="SUPV" && (
        <div>
        <Link to={'/'}>&larr; Return to Admin menu</Link>     
          {props.view!=="EDIT"     && (<div><Link to={`/EDIT/${props.curr.FormID}`}>Add and Remove</Link></div>)}
          {props.view!=="HEADER"   && (<div><Link to={`/HEADER/${props.curr.FormID}`}>Set Unresolved Queue</Link></div>)}
          {props.view!=="REQUIRED" && (<div><Link to={`/REQUIRED/${props.curr.FormID}`}>Set REQUIRED</Link></div>)}
          {<div><Link to={`/SUPV/${props.curr.FormID}`}>Preview Form</Link></div>}          
        </div>
      )}
 
      <div className="formclass" key={props.curr.FormID}>
        <ElementFormHeader curr={props.curr} view={props.view} header={props.header} formatdate={formatdate}/>
        {props.view==="SUPV" 
        ?(
          <form method="post" action={LibPath + 'SupvPost.cfm'}>
            <Element tree={props.curr.children} view={props.view} />
            <input type="hidden" name={props.curr.FormID} id={props.curr.FormID} defaultValue={props.curr.Descrip} /> {/*form*/}
            <input type="hidden" name="DateEntered"   id={props.curr.FormID} defaultValue={formatdate} />
            <input type="hidden" name="SupvName"      id={props.curr.FormID} defaultValue={props.header.SupvName} />    
            <Signature SupvName={props.header.SupvName} />
          </form>
         )
        :(
          <div>
          <AddElements view={props.view} type="FORM" curr={props.curr} handleRedraw={props.handleRedraw} /> 
          <Element tree={props.curr.children} view={props.view} handleRedraw={props.handleRedraw} />
          </div>
        )
        }
      </div>
      <div style={{height:"100px"}}/>
    </div>

  )
}

function ElementSection(props) {  
  return (
    <div key={props.curr.FormID}>
      <div className="sectionclass">
        <h2>{props.curr.Descrip}
        <Edit className="delclass" view={props.view} curr={props.curr} handleRedraw={props.handleRedraw} />
        </h2>
        <AddElements view={props.view} type="SECTION" curr={props.curr} handleRedraw={props.handleRedraw} />  
        <Element tree={props.curr.children} view={props.view} handleRedraw={props.handleRedraw}/>
      </div>
      <AddElements view={props.view} type="SECTIONAFTER" curr={props.curr} handleRedraw={props.handleRedraw} />  
    </div>
  )
}
function ElementMessage(props) {  
  return (
    <div key={props.curr.FormID}>
      <div className="messageclass">
        <div>{props.curr.Descrip}
        <Edit className="delclass" view={props.view} curr={props.curr} handleRedraw={props.handleRedraw} /> 
        </div>
      </div>
      <AddElements view={props.view} type="AFTER" curr={props.curr} handleRedraw={props.handleRedraw} /> 
    </div>
  )
}

class ElementNode extends React.Component { 
  constructor(props) {
    super(props);
    this.state = {
      childVisible: props.curr.ItemValue==="on"||props.view==="EDIT"?true:false 
    };
  }
  onClick=()=>{
    this.setState({childVisible: !this.state.childVisible});
  }
  render() { 
    let curr = this.props.curr;
    return (
      <div key={curr.FormID}>
        <div className="nodeclass" >
        <label >
         {curr.Descrip}:
         <Edit className="delclass" view={this.props.view} curr={this.props.curr} handleRedraw={this.props.handleRedraw} /> 
        </label>

        <input type="checkbox" name={curr.FormID} onClick={this.onClick} defaultChecked={this.state.childVisible}/>      
         {
            this.state.childVisible
              ? <Element tree={curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} />
              : null
          }      
        </div>
        <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
      </div>
    )
  }
}

class ElementRequest extends React.Component {
  render() { 
    let curr = this.props.curr;
    return (
      <div key={curr.FormID} className="requestclass">
        <AddElements view={this.props.view} type="REQUEST" curr={curr} handleRedraw={this.props.handleRedraw} /> 
        <Element tree={curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} />
      </div>
    ) 
  }
}

//RESPONSES are only used in Admin screens
class ElementResponse extends React.Component { 
  render() { 
    let curr = this.props.curr;
    if(this.props.view === "SUPV"){
      return null;
    }else{
      return (
        <div key={curr.FormID} className="responseclass">
          <AddElements view={this.props.view} type="RESPONSE" curr={curr} handleRedraw={this.props.handleRedraw} /> 
          <Element tree={curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} />
        </div>
      ) 
    }
  }
}

class ElementInput extends React.Component { 
  render() { 
    let curr = this.props.curr;
      return (
        <div key={curr.FormID}>
          <div>
            <label>
            {curr.Descrip}:
            <Edit className="delclass" view={this.props.view} curr={curr} handleRedraw={this.props.handleRedraw} />            
            </label>
            <input type="text" className="inputclass" name={curr.FormID} id={curr.FormID} defaultValue={curr.ItemValue}/>
          </div>
          <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
        </div>
      ) 
  }
}

class ElementDate extends React.Component { 

  constructor(props) {  //debugger;
    super(props);
    let thedate = props.curr.ItemValue?moment(props.curr.ItemValue):null
    this.state = {
      adate: thedate
    };
  }
  handleChange=(date)=>{
    this.setState({
      adate:date
    });
  }
  render() { 
    let curr = this.props.curr;
      return (
        <div key={curr.FormID}>
          <div>
            <label>
            {curr.Descrip}:
            <Edit className="delclass" view={this.props.view} curr={curr} handleRedraw={this.props.handleRedraw} />            
            </label>
            <DatePicker selected={this.state.adate} onChange={this.handleChange} className="inputclass"/>
          </div>
          <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
        </div>
      ) 
  }
}

class ElementRadio extends React.Component {    
  constructor(props) { 
    super(props);                    //
    this.state = {
      selectedOption: this.props.curr.ItemValue
    };
  }
  handleOptionChange=(changeEvent)=>{
    this.setState({
      selectedOption: changeEvent.target.value
    });
  }
  render() { 
    let curr = this.props.curr;
    let optcount = curr.children.length;
    return ( 
      <div>
      {optcount>0 ?
        curr.children.map((chld,ix) => { //children of RADIO can be OPTION or SUBFORM
          let firstlabel = ix===0  //Only put the label for the radio on the first line
          ?(<label>
            {curr.Descrip+":"}
            <Edit className="delclass" view={this.props.view} curr={this.props.curr} handleRedraw={this.props.handleRedraw} /> 
            </label>
          )
          :<label/>;
          return( 
            <div key={chld.FormID}> {/*An "Add Opts>>" will appear above first line in EDIT view*/}
                {(this.props.view==="EDIT" && ix===0) && (
                  <span>
                    <label></label>
                    <AddElements view={this.props.view} type="OPTION" curr={curr} handleRedraw={this.props.handleRedraw} />
                  </span>)
                }
                {firstlabel}
                <input type="radio"  value={chld.Descrip} 
                                checked={this.state.selectedOption === chld.Descrip} 
                                onChange={this.handleOptionChange} />
                <Edit className="delclass" view={this.props.view} curr={chld} handleRedraw={this.props.handleRedraw} /> 
                {chld.Descrip} 
                {chld.Type==="SUBFORM" 
                  && (this.state.selectedOption === chld.Descrip || this.props.view==="EDIT")
                  && (
                    <div className="subformstyle">
                    <AddElements view={this.props.view} type="SUBFORM" curr={chld} handleRedraw={this.props.handleRedraw} /> 
                    <Element tree={chld.children} view={this.props.view} handleRedraw={this.props.handleRedraw} />
                    </div>
                    )
                }
                <AddElements view={this.props.view} type="OPTIONAFTER" curr={chld} handleRedraw={this.props.handleRedraw} /> 
              </div>
              
          )
        })

      //if no OPTIONS  
      :(
        <div>
            <label>{curr.Descrip}
              <Edit className="delclass" view={this.props.view} curr={this.props.curr} handleRedraw={this.props.handleRedraw} /> 
            </label>
            <input type="radio" name={curr.FormID} />

            <AddElements view={this.props.view} type="OPTION" curr={curr} handleRedraw={this.props.handleRedraw} />  
        </div>
      )
      }
      <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
      </div>
    )
  }
}  

ElementRadio.propTypes = {
    curr: React.PropTypes.object,
    view: React.PropTypes.string,
    handleRedraw: React.PropTypes.func
}; 

class ElementSelect extends React.Component { 
  render() { 
    let curr = this.props.curr;
    return (
      <div key={curr.FormID}>

        <label>
        {curr.Descrip}:
        <Edit className="delclass" view={this.props.view} curr={this.props.curr} handleRedraw={this.props.handleRedraw} /> 
        </label>
        <select id={curr.FormID} name={curr.FormID} defaultValue={curr.ItemValue}>
          <option key={0} value="">(Choose One)</option>
          {curr.children.map((chld) => { //these should be OPTIONS
            return( 
              <option key={chld.FormID} value={chld.Descrip}>{chld.Descrip}</option>
            )
          })}
        </select>
        <AddElements view={this.props.view} type="SOPTION" curr={curr} handleRedraw={this.props.handleRedraw} />  
          {this.props.view==="EDIT" && 
            curr.children.map((chld) => { //these should be OPTIONS
              return(
                <span key={chld.FormID}>
                  
                  <div className="editselectoption">
                    <label></label>
                    <Edit className="delclass" view={this.props.view} curr={chld} handleRedraw={this.props.handleRedraw} />
                    {chld.Descrip}
                  </div>
                  <AddElements view={this.props.view} type="SOPTIONAFTER" curr={chld} handleRedraw={this.props.handleRedraw} /> 
                </span>
              )
            })
          }
        <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} />       
      </div>
    )
  }
}

class Signature extends React.Component {  

  render() {
    return (
      <div className="sectionclass" key="Sig">
        <h2>AUTHORIZATION INFORMATION</h2>
        <label>
        *Supervisor Authorization Signature:
        </label>
       
        <input type="text" name="SupvSig" className="inputclass"/>

        <p><i>      
        (Typing your name above implies you are authorizing the above computer access form.
        We will verify your signature with the employee ID you are currently logged in with.) 
        </i></p>
        <p>
        You are logged in as <span style={{"color":"#fb7560"}}>{this.props.SupvName}</span>
        </p>
        <p>
        <button className="submit" >Submit</button>
        </p>
      </div>
    )
  }
}


