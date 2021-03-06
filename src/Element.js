import React from 'react';
import moment from 'moment'; //date library
import DatePicker  from 'react-datepicker'; //datepicker  library
import Textarea from 'react-textarea-autosize'; //auto resize text area component
import { CSSTransitionGroup } from 'react-transition-group';
import { LibPath, HomePath } from './LibPath';
import AddElements from './AddElements';
import SendHREmail from './SendHREmail';
import Edit from './Edit';
import './css/react-datepicker.css';
import { NavLink } from 'react-router-dom'  //NavLink is just like Link with styling options

export default class Element extends React.Component {   
  //An element can be any row returned from stored proc
  //This class iterates muliple children at this level of the tree, and delegates to the proper element type
  render() { 
    return ( 
      <div>
      {
        this.props.tree.map((curr,ix) => {
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
            return <ElementInput ix={ix}  curr={curr} key={curr.FormID} view={this.props.view} inResponse={this.props.inResponse}
				handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/> 
          }else if(curr.Type==="TEXTAREA"){
            return <ElementTextArea ix={ix}  curr={curr} key={curr.FormID} view={this.props.view} inResponse={this.props.inResponse}
				handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/> 
          }else if(curr.Type==="DATE"){
            return <ElementDate ix={ix}   curr={curr} key={curr.FormID} view={this.props.view} inResponse={this.props.inResponse} 
				handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/> 
          }else if(curr.Type==="RADIO"){
            return <ElementRadio ix={ix}  curr={curr} key={curr.FormID} view={this.props.view} inResponse={this.props.inResponse} 
				handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/> 
          }else if(curr.Type==="CHECKBOX"){
            return <ElementCheckbox ix={ix}  curr={curr} key={curr.FormID} view={this.props.view} inResponse={this.props.inResponse} 
				handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/> 
          }else if(curr.Type==="SELECT"){
            return <ElementSelect ix={ix} curr={curr} key={curr.FormID} view={this.props.view} inResponse={this.props.inResponse} 
				handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/>

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
      <div className="headerclass formclass" key={props.curr.FormID}>
        {   props.view==="EDIT"
          ? <h1 style={{color:"black"}}>Add and remove form elements</h1>
          : props.view==="PREVIEW"
          ? <h1 style={{color:"black"}}>Preview Form</h1>
          : props.view==="HEADER"
          ? <h1 style={{color:"black"}}>Fields in Unresolved Queue</h1>
          : props.view==="REQUIRED"
          ? <h1 style={{color:"black"}}>Set which fields are Required</h1>
          : props.view==="REQRESP"
          ? <h1 style={{color:"black"}}>Fields required to <span style={{color:"red"}}>complete</span> response</h1>
          : <h1>Computer Access Authorization E-Form</h1>
        }
          
        <h2>{props.curr.Descrip}</h2>
        {props.curr.Type==="UNPUB" && <div style={{color:"black"}}>Unpublished Form</div>}
        {props.view==="ADMIN" && props.header.SupvName && <p><i>Entered by:</i> {props.header.SupvName}</p>} 
        {props.formatdate}

      </div>
  )
}

function ElementForm(props) { 
  const formatdate = moment(props.header.EnteredDate).format("MMMM Do YYYY, h:mm a"); //if no date in header, is NOW    
  return (
    <div>
      <ElementMenu view={props.view} FormID={props.curr.FormID} header={props.header} />
      {props.view==="SUPV" 
      ?(
        <div className="formclass">
          <ElementFormHeader curr={props.curr} view={props.view} header={props.header} formatdate={formatdate}/>
            <form method="post" action={LibPath + 'SupvPost.cfm'}> 
              <Element tree={props.curr.children} view={props.view} />
              <input type="hidden" name={props.curr.FormID} defaultValue={props.curr.Descrip} /> {/*form*/}
              <input type="hidden" name="DateEntered"   defaultValue={formatdate} />
              <input type="hidden" name="LoggedInID"      defaultValue={props.header.LoggedInID} />    
              <input type="hidden" name="LoggedInName"      defaultValue={props.header.LoggedInName} />  
              <Signature LoggedInName={props.header.LoggedInName} />
            </form>
        </div>
       )
      :props.view==="ADMIN" 
      ?(
        <div className="formclass">
          <ElementFormHeader curr={props.curr} view={props.view} header={props.header} formatdate={formatdate}/>
            <form method="post" action={LibPath + 'AdminPost.cfm'}>
              <Element tree={props.curr.children} view={props.view} />
              <input type="hidden" name={props.curr.FormID} defaultValue={props.curr.Descrip} /> {/*form*/}
              <input type="hidden" name="DateEntered"   defaultValue={formatdate} />
              <input type="hidden" name="LoggedInID"      defaultValue={props.header.LoggedInID} />    
              <input type="hidden" name="LoggedInName"      defaultValue={props.header.LoggedInName} />    
              <input type="hidden" name="ReqID"   defaultValue={props.header.RequestID} />
              {<div style={{color:"black"}} >&#10033; Required to Submit</div>}
              {<div style={{color:"red"}} >&#10033; Required to Complete</div>}
              {props.header.Completed===1 && <div>Completed</div>}
              <button className="submit" >Submit</button>
            </form>
        </div>
      )
      :(
        <div className="formclass" style={{overflowY:"scroll",height:"calc(100vh - 100px)"}}>
          <ElementFormHeader curr={props.curr} view={props.view} header={props.header} formatdate={formatdate}/>
            <AddElements view={props.view} type="FORM" curr={props.curr} handleRedraw={props.handleRedraw} /> 
            <Element tree={props.curr.children} view={props.view} handleRedraw={props.handleRedraw} />
            {<div style={{color:"black"}} >&#10033; Required to Submit</div>}
            {<div style={{color:"red"}} >&#10033; Required to Complete</div>}
        </div>
      )
      }

    </div>

  )
}

class ElementSection extends React.Component { 
  handleChangeResponse=()=>{
    //Nothing happens
  }
  render() { 
  return (
      <div key={this.props.curr.FormID}>
        <div className="sectionclass">
          <h2>{this.props.curr.Descrip}
          <Edit className="delclass" view={this.props.view} curr={this.props.curr} handleRedraw={this.props.handleRedraw} />
          </h2>
          <AddElements view={this.props.view} type="SECTION" curr={this.props.curr} handleRedraw={this.props.handleRedraw} />  
          <Element tree={this.props.curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} handleChangeResponse={this.handleChangeResponse} />
        </div>
        <AddElements view={this.props.view} type="SECTIONAFTER" curr={this.props.curr} handleRedraw={this.props.handleRedraw} />  
      </div>
    )
  }
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
    const curr = this.props.curr;
    return (
      <div key={curr.FormID}>
        <div className="nodeclass" >
        <label >
         {curr.Descrip}:
         <Edit className="delclass" view={this.props.view} curr={this.props.curr} handleRedraw={this.props.handleRedraw} /> 
        </label>

        <input type="checkbox" name={curr.FormID} onClick={this.onClick} defaultChecked={this.state.childVisible} />      
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
  handleChangeResponse=()=>{
    //Nothing happens
  }
  render() { 
    const curr = this.props.curr;
    return (
      <div key={curr.FormID} className="requestclass">
        {this.props.view==="EDIT" && <span style={{color:"grey"}}>Request</span>}
        <AddElements view={this.props.view} type="REQUEST" curr={curr} handleRedraw={this.props.handleRedraw} /> 
        <Element tree={curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} handleChangeResponse={this.handleChangeResponse} />
      </div>
    ) 
  }
}

//RESPONSES are only used in Admin screens
class ElementResponse extends React.Component { 
  constructor(props) { 
    super(props);
    this.state = {
      resultsSet: [],   //Array of bool, whether each child is complete
      completed: false  //ALL children are complete
    }
  }
  componentDidMount() { //debugger;
    let newComplete = false,
        newResultsSet = [];
    if(this.props.curr.children.length > 0){
      newResultsSet = this.props.curr.children.map(function(item){return item.ItemValue!==""});
      newComplete = newResultsSet.indexOf(false) === -1;  //returns true if all true
    } else {newComplete=true};   
    if(this.props.view === "EDIT"){newComplete=false};
    if(this.props.curr.ItemValue === 'true'){newComplete=true};
    this.setState({
      resultsSet: newResultsSet,
      completed: newComplete
    });
  }
  handleChangeResponse=(ix,completed)=>{ //the index is given to the child by the Element component
    const newResultsSet = this.state.resultsSet.slice();      //copy
    newResultsSet.splice(ix,1,completed);                   //mark this one as complete or not
    let newComplete = newResultsSet.indexOf(false) === -1;  //returns true if all true
    if(this.props.view === "EDIT"){newComplete=false};
    this.setState({
      resultsSet: newResultsSet,
      completed: newComplete
    });    
  }
  handleMarkAsNotNeeded=()=>{ 
    this.setState({ completed: true });
  }   
  render() { 
    const curr = this.props.curr;
    if(this.props.view === "SUPV"){ //RESPONSES don't appear when SUPV is filling out form
      return (
        <input type="hidden" name={curr.FormID} value="false" />
      )
    }else{
      return (
        <div key={curr.FormID} className={this.state.completed?"responsecompleteclass":"responseclass"}>
          {this.props.view==="EDIT" && <span style={{color:"grey"}}>Response</span>}
          <AddElements view={this.props.view} type="RESPONSE" curr={curr} handleRedraw={this.props.handleRedraw} /> 
          <Element tree={curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} handleChangeResponse={this.handleChangeResponse} />
          <label/>
          {this.state.completed
          ? <span>Completed</span>
          : this.props.view==="ADMIN"
          ? <span><input type="checkbox" onChange={this.handleMarkAsNotNeeded} />Mark as complete or not needed</span>
          : null
          }
          <input type="hidden" name={curr.FormID} value={this.state.completed} />
        </div>
      ) 
    }
  }
}

class ElementInput extends React.Component { 
  constructor(props) { 
    super(props);
	this.state = {
	  isFilled: !(this.props.curr.ItemValue === "")
	}
	this.handleChange = this.handleChange.bind(this);	
  }
  
  handleChange=(event)=>{ 
	this.setState({ isFilled: event.target.value !== "" },()=>{
		this.props.handleChangeResponse(this.props.ix,this.state.isFilled);
	});
  }
  render() { 
    const curr = this.props.curr;
    return (
      <div key={curr.FormID}>
        <div>
          <label>
          {this.props.view!=="SUPV" && !this.state.isFilled && curr.ReqResp ? <span className="redasterisk">&#10033;</span> : null}
          {curr.Required ? <span >&#10033;</span> : null}
          {curr.Descrip}:
          <Edit className="delclass" view={this.props.view} curr={curr} handleRedraw={this.props.handleRedraw} />            
          </label>
          {curr.Required
          ?<input type="text" className="inputclass" name={curr.FormID} defaultValue={curr.ItemValue} onChange={this.handleChange} required />
          :<input type="text" className="inputclass" name={curr.FormID} defaultValue={curr.ItemValue} onChange={this.handleChange} />}
        </div>
        <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
      </div>
    ) 
  }
}

class ElementTextArea extends React.Component { 
  constructor(props) { 
    super(props);
	this.state = {
	  isFilled: !(this.props.curr.ItemValue === "")
	}
	this.handleChange = this.handleChange.bind(this);	
  }
  
  handleChange=(event)=>{ 
	this.setState({ isFilled: event.target.value !== "" },()=>{
		this.props.handleChangeResponse(this.props.ix,this.state.isFilled);
	});
  }
  render() { 
    const curr = this.props.curr; 
    const itemVal = curr.ItemValue.replace(/\\r\\n/g, String.fromCharCode(13, 10));
    return (
      <div key={curr.FormID}>
        <div>
          <label>
          {this.props.view!=="SUPV" && !this.state.isFilled && curr.ReqResp ? <span className="redasterisk">&#10033;</span> : null}
          {curr.Required ? <span >&#10033;</span> : null}
          {curr.Descrip}:
          <Edit className="delclass" view={this.props.view} curr={curr} handleRedraw={this.props.handleRedraw} />            
          </label>
          {curr.Required
          ?<Textarea minRows={2} className="inputclass" name={curr.FormID} defaultValue={itemVal} onChange={this.handleChange} required />
          :<Textarea minRows={2} className="inputclass" name={curr.FormID} defaultValue={itemVal} onChange={this.handleChange} />}
        </div>
        <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
      </div>
    ) 
  }
}

class ElementDate extends React.Component { 

  constructor(props) {  //debugger;
    super(props);
    const dateFormat = "MM/DD/YYYY"; //check for valid date
    const thedate = props.curr.ItemValue
                    ? moment(props.curr.ItemValue, dateFormat, true).isValid()
                      ? moment(props.curr.ItemValue)
                      : null
                    : null;
      
    this.state = {
      adate: thedate,
      isFilled: !(props.curr.ItemValue === "")
    };
  }
  handleChange=(date)=>{ //debugger;
	this.setState({ 
		adate:date,
		isFilled: !(date === null)
	},()=>{
		this.props.handleChangeResponse(this.props.ix,this.state.isFilled);
	});	
  }
  render() { 
    const curr = this.props.curr;
    if(this.props.view==="ADMIN"){ //work around for bad dates. just use input. better solution: proper validation on input.
      return (
        <ElementInput ix={this.props.ix} curr={curr} key={curr.FormID} view={this.props.view} inResponse={this.props.inResponse}
				handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/> 
      )
    }else{
      return (
        <div key={curr.FormID}>
          <div>
            <label>
            {this.props.view!=="SUPV"  && !this.state.isFilled && curr.ReqResp ? <span className="redasterisk">&#10033;</span> : null}
            {curr.Required ? <span >&#10033;</span> : null}
            {curr.Descrip}:
            <Edit className="delclass" view={this.props.view} curr={curr} handleRedraw={this.props.handleRedraw} />            
            </label>
            {curr.Required
            ?<DatePicker selected={this.state.adate} name={curr.FormID} onChange={this.handleChange} className="inputclass" required />
            :<DatePicker selected={this.state.adate} name={curr.FormID} onChange={this.handleChange} className="inputclass" />}
          </div>
          <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
        </div>
      ) 
    }
  }
}

class ElementRadio extends React.Component {    
  constructor(props) { 
    super(props);
    this.state = {
      selectedOption: this.props.curr.ItemValue,
	  isSelected: this.props.curr.ItemValue !== ""
    };
  }
  handleOptionChange=(changeEvent)=>{
	let self=this;  
    this.setState({
      selectedOption: changeEvent.target.value,
	  isSelected: changeEvent.target.value !== ""
    },()=>{ 
		self.props.handleChangeResponse(self.props.ix, self.state.isSelected)
	});
  }
  render() { 
    const curr = this.props.curr;
    const optcount = curr.children.length;
    return ( 
      <div>
      {optcount>0 ?
        curr.children.map((chld,ix) => { //children of RADIO can be OPTION or SUBFORM
          const firstlabel = ix===0  //Only put the label for the radio on the first line
          ?(<label>
			{this.props.view!=="SUPV" && !this.state.isSelected && curr.ReqResp ? <span className="redasterisk">&#10033;</span> : null}
            {curr.Required ? <span >&#10033;</span> : null}
            {curr.Descrip+":"}
            <Edit className="delclass" view={this.props.view} curr={this.props.curr} handleRedraw={this.props.handleRedraw} /> 
            </label>
          )
          :<label/>;
          return( 
            <div key={chld.FormID} > {/*An "Add Opts>>" will appear above first line in EDIT view*/}  
                {(this.props.view==="EDIT" && ix===0) && (
                  <span>
                    <label></label>
                    <AddElements view={this.props.view} type="OPTION" curr={curr} handleRedraw={this.props.handleRedraw} />
                  </span>)
                }
                {firstlabel}
                {curr.Required
                ?<input type="radio" name={curr.FormID}  value={chld.Descrip} 
                                checked={this.state.selectedOption === chld.Descrip} 
                                onChange={this.handleOptionChange} required/>
                :<input type="radio" name={curr.FormID} value={chld.Descrip} 
                                checked={this.state.selectedOption === chld.Descrip} 
                                onChange={this.handleOptionChange} />}                
                <Edit className="delclass" view={this.props.view} curr={chld} handleRedraw={this.props.handleRedraw} /> 
					{/*<div style={{display:"inline-block",width:"280px"}}></div>*/}
                {chld.Descrip} 
				
                  <CSSTransitionGroup
                    transitionName="SubForm"
                    transitionEnterTimeout={300}
                    transitionLeaveTimeout={300}>
                          {chld.Type==="SUBFORM" 
                            && (this.state.selectedOption === chld.Descrip || this.props.view==="EDIT")
                            ? (
                              <div key={chld.FormID} className="subformstyle">
                              <AddElements view={this.props.view} type="SUBFORM" curr={chld} handleRedraw={this.props.handleRedraw} />
                                <Element tree={chld.children} view={this.props.view} handleRedraw={this.props.handleRedraw} />
                              </div>
                              )
                            : null
                          }
                  </CSSTransitionGroup> 
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

// ElementRadio.propTypes = {
    // curr: React.PropTypes.object,
    // view: React.PropTypes.string,
    // handleRedraw: React.PropTypes.func
// }; 

class ElementCheckbox extends React.Component { 
  constructor(props) { 
    super(props);
    this.state = {
	  isSelected: this.props.curr.ItemValue !== ""
    };
  }
  handleChange=(event)=>{ 
    let self=this;
    this.setState({
	  isSelected: event.target.checked
    },()=>{
		self.props.handleChangeResponse(self.props.ix, self.state.isSelected);
	});
  }
  render() { 
    const curr = this.props.curr;
    return (
      <div key={curr.FormID}>
        <div>
          <label>
			{this.props.view!=="SUPV" && !this.state.isSelected && curr.ReqResp ? <span className="redasterisk">&#10033;</span> : null}
			{curr.Required ? <span >&#10033;</span> : null}		  
			<Edit className="delclass" view={this.props.view} curr={curr} handleRedraw={this.props.handleRedraw} />            
          </label>
          <div style={{display:"inline-block",width:"360px"}}>
		  <input type="checkbox"  name={curr.FormID} value="on"
			defaultChecked={this.props.curr.ItemValue==="on"} onChange={this.handleChange} />
		  {curr.Descrip}
		  </div>
        </div>
        <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
      </div>
    ) 
  }
}

class ElementSelect extends React.Component { 
  constructor(props) { 
    super(props);
    this.state = {
	  isSelected: this.props.curr.ItemValue !== ""
    };
  }
  handleOptionChange=(changeEvent)=>{
	let self=this;
    this.setState({
	  isSelected: changeEvent.target.value !== ""
    },()=>{  
		self.props.handleChangeResponse(self.props.ix, self.state.isSelected);
	});
  }
  render() { 
    const curr = this.props.curr;
    return (
      <div key={curr.FormID}>

        <label>
        {this.props.view!=="SUPV" && !this.state.isSelected && curr.ReqResp ? <span className="redasterisk">&#10033;</span> : null}
		{curr.Required ? <span >&#10033;</span> : null}
        {curr.Descrip}:
        <Edit className="delclass" view={this.props.view} curr={this.props.curr} handleRedraw={this.props.handleRedraw} /> 
        </label>
        {curr.Required
          ? (<select name={curr.FormID} defaultValue={curr.ItemValue} onChange={this.handleOptionChange} required>
              <option key={0} value="">(Choose One)</option>
              {curr.children.map((chld) => { //these should be OPTIONS
                return( 
                  <option key={chld.FormID} value={chld.Descrip}>{chld.Descrip}</option>
                )
              })}
            </select>)
          
          : (<select name={curr.FormID} defaultValue={curr.ItemValue} onChange={this.handleOptionChange}>
              <option key={0} value="">(Choose One)</option>
              {curr.children.map((chld) => { //these should be OPTIONS
                return( 
                  <option key={chld.FormID} value={chld.Descrip}>{chld.Descrip}</option>
                )
              })}
            </select>)
        }
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
        &#10033; Supervisor Authorization Signature:
        </label>
       
        <input type="text" name="SupvSig" className="inputclass" required />

        <p style={{fontSize:"0.9em"}}><i>      
        (Typing your name above implies you are authorizing these changes.) 
        </i></p>
        <p>
        You are logged in as <span style={{"color":"#fb7560"}}>{this.props.LoggedInName}</span>
        </p>
        <p>
        <button className="submit" >Submit</button>
        </p>
        <p style={{fontSize:"0.7em"}}>
        &#10033; Required Field
        </p>
      </div>
    )
  }
}

function ElementMenu(props) {
  return (
    <div>
      {props.view==="SUPV" 
      ? <a href="https://ccp1.msj.org/login/login/home.cfm"> &larr; Intranet Login Menu </a>
      : <NavLink to={HomePath}>&larr; Return to Admin menu</NavLink> }    
      {props.view==="ADMIN" &&(
        <SendHREmail reqID={props.header.RequestID} />
      )}    
      {props.view!=="SUPV" && props.view!=="ADMIN" &&(
        <div>
          <NavLink to={`${HomePath}PREVIEW/${props.FormID}`} activeClassName="active-btn-class"><span className="btn-class">Preview...</span></NavLink>
          <NavLink to={`${HomePath}EDIT/${props.FormID}`} activeClassName="active-btn-class"><span className="btn-class">Add/Remove</span></NavLink>
           <NavLink to={`${HomePath}REQUIRED/${props.FormID}`} activeClassName="active-btn-class"><span className="btn-class">REQUIRED</span></NavLink>
           <NavLink to={`${HomePath}REQRESP/${props.FormID}`} activeClassName="active-btn-class"><span className="btn-class">Req Complete</span></NavLink>
         <NavLink to={`${HomePath}HEADER/${props.FormID}`} activeClassName="active-btn-class"><span className="btn-class">Queue</span></NavLink>
        </div>
      )}
    </div>

  )
}
