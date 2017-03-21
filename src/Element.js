import React from 'react';
import moment from 'moment'; //date library
import DatePicker  from 'react-datepicker'; //datepicker library
import LibPath from './LibPath';
import AddElements from './AddElements';
import Edit from './Edit';
import './css/react-datepicker.css';
import { Link } from 'react-router';

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
            return <ElementInput ix={ix} curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/> 
          }else if(curr.Type==="DATE"){
            return <ElementDate ix={ix} curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/> 
          }else if(curr.Type==="RADIO"){
            return <ElementRadio ix={ix} curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/> 
          }else if(curr.Type==="SELECT"){
            return <ElementSelect ix={ix} curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw} handleChangeResponse={this.props.handleChangeResponse}/>

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
      {props.view!=="SUPV" && <Link to={'/'}>&larr; Return to Admin menu</Link> }    
      {props.view!=="SUPV" && props.view!=="ADMIN" &&(
        <div>
          {props.view!=="EDIT"     && (<div><Link to={`/EDIT/${props.curr.FormID}`}>Add and Remove</Link></div>)}
          {props.view!=="HEADER"   && (<div><Link to={`/HEADER/${props.curr.FormID}`}>Set Unresolved Queue</Link></div>)}
          {props.view!=="REQUIRED" && (<div><Link to={`/REQUIRED/${props.curr.FormID}`}>Set REQUIRED</Link></div>)}
          <div><Link to={`/SUPV/${props.curr.FormID}`}>Preview Form</Link></div>         
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
        :props.view==="ADMIN" 
        ?(
          <form method="post" action={LibPath + 'AdminPost.cfm'}>
            <Element tree={props.curr.children} view={props.view} />
            <input type="hidden" name={props.curr.FormID} id={props.curr.FormID} defaultValue={props.curr.Descrip} /> {/*form*/}
            <input type="hidden" name="DateEntered"   id={props.curr.FormID} defaultValue={formatdate} />
            <input type="hidden" name="AdminName"      id={props.curr.FormID} defaultValue={props.header.SupvName} />    
            <button className="submit" >Submit</button>
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
      childVisible: props.curr.ItemValue==="on"||props.view==="EDIT"||props.view==="REQUIRED"||props.view==="HEADER"?true:false 
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
    let curr = this.props.curr;
    return (
      <div key={curr.FormID} className="requestclass">
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
  componentDidMount() { 
    let newResultsSet = this.props.curr.children.map(function(item){return item.ItemValue!==""});
    let newComplete = newResultsSet.indexOf(false) === -1;  //returns true if all true
    this.setState({
      resultsSet: newResultsSet,
      completed: newComplete
    }); 
  }
  handleChangeResponse=(ix,completed)=>{ //the index is given to the child by the Element component
    let newResultsSet = this.state.resultsSet.slice();
    newResultsSet.splice(ix,1,completed);
    let newComplete = newResultsSet.indexOf(false) === -1;  //returns true if all true
    this.setState({
      resultsSet: newResultsSet,
      completed: newComplete
    });    
  }
  handleMarkAsNotNeeded=()=>{ 
    this.setState({
      completed: true
    });
  }   
  render() { //console.log(JSON.stringify(this.props.curr));
    let curr = this.props.curr;
    if(this.props.view === "SUPV"){ //RESPONSES don't appear when SUPV is filling out form
      return null;
    }else{
      return (
        <div key={curr.FormID} className={this.state.completed?"responsecompleteclass":"responseclass"}>
          <AddElements view={this.props.view} type="RESPONSE" curr={curr} handleRedraw={this.props.handleRedraw} /> 
          <Element tree={curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} handleChangeResponse={this.handleChangeResponse} />
          <label/>
          {this.state.completed
          ?<span>Completed</span>
          :<span><input type="checkbox" onChange={this.handleMarkAsNotNeeded} />Not needed</span>
          }
        </div>
      ) 
    }
  }
}

class ElementInput extends React.Component { 
  handleChange=(event)=>{ 
    this.props.handleChangeResponse(this.props.ix,event.target.value !== "");
  }
  render() { 
    let curr = this.props.curr;
    return (
      <div key={curr.FormID}>
        <div>
          <label>
          {curr.Required ? <span >*</span> : null}
          {curr.Descrip}:
          <Edit className="delclass" view={this.props.view} curr={curr} handleRedraw={this.props.handleRedraw} />            
          </label>
          {curr.Required
          ?<input type="text" className="inputclass" name={curr.FormID} id={curr.FormID} defaultValue={curr.ItemValue} onChange={this.handleChange} required />
          :<input type="text" className="inputclass" name={curr.FormID} id={curr.FormID} defaultValue={curr.ItemValue} onChange={this.handleChange} />}
        </div>
        <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
      </div>
    ) 
  }
}

class ElementDate extends React.Component { 

  constructor(props) {  //
    super(props);
    let thedate = props.curr.ItemValue?moment(props.curr.ItemValue):null
    this.state = {
      adate: thedate
    };
  }
  handleChange=(date)=>{ //debugger;
    this.setState({
      adate:date
    });
    this.props.handleChangeResponse(this.props.ix, date !== null);
  }
  render() { 
    let curr = this.props.curr;
      return (
        <div key={curr.FormID}>
          <div>
            <label>
            {curr.Required ? <span >*</span> : null}
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
    this.props.handleChangeResponse(this.props.ix,changeEvent.target.value !== "");
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
            {curr.Required ? <span >*</span> : null}
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
                {curr.Required
                ?<input type="radio" name={curr.FormID}  value={chld.Descrip} 
                                checked={this.state.selectedOption === chld.Descrip} 
                                onChange={this.handleOptionChange} required/>
                :<input type="radio" name={curr.FormID} value={chld.Descrip} 
                                checked={this.state.selectedOption === chld.Descrip} 
                                onChange={this.handleOptionChange} />}                
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
  handleOptionChange=(changeEvent)=>{
    this.props.handleChangeResponse(this.props.ix,changeEvent.target.value !== "");
  }
  render() { 
    let curr = this.props.curr;
    return (
      <div key={curr.FormID}>

        <label>
        {curr.Required ? <span >*</span> : null}
        {curr.Descrip}:
        <Edit className="delclass" view={this.props.view} curr={this.props.curr} handleRedraw={this.props.handleRedraw} /> 
        </label>
        {curr.Required
          ? (<select id={curr.FormID} name={curr.FormID} defaultValue={curr.ItemValue} onChange={this.handleOptionChange} required>
              <option key={0} value="">(Choose One)</option>
              {curr.children.map((chld) => { //these should be OPTIONS
                return( 
                  <option key={chld.FormID} value={chld.Descrip}>{chld.Descrip}</option>
                )
              })}
            </select>)
          
          : (<select id={curr.FormID} name={curr.FormID} defaultValue={curr.ItemValue} onChange={this.handleOptionChange}>
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
        *Supervisor Authorization Signature:
        </label>
       
        <input type="text" name="SupvSig" className="inputclass" required />

        <p style={{fontSize:"0.9em"}}><i>      
        (Typing your name above implies you are authorizing these changes.) 
        </i></p>
        <p>
        You are logged in as <span style={{"color":"#fb7560"}}>{this.props.SupvName}</span>
        </p>
        <p>
        <button className="submit" >Submit</button>
        </p>
        <p style={{fontSize:"0.7em"}}>
        * Required Field
        </p>
      </div>
    )
  }
}


