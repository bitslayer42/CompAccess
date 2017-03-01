import React from 'react';
import moment from 'moment'; //date library
import LibPath from './LibPath';
import AddElements from './AddElements';
import DeleteElement from './DeleteElement';

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
          }else if(curr.Type==="TEXT"){
            return <ElementText       curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/> 
          }else if(curr.Type==="REQUEST"){
            return <ElementRequest    curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/> 
          }else if(curr.Type==="RESPONSE"){
            return <ElementResponse   curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/>
          }else if(curr.Type==="INPUT"){
            return <ElementInput      curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/> 
          }else if(curr.Type==="RADIO"){
            return <ElementRadio      curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/> 
          }else if(curr.Type==="SELECT"){
            return <ElementSelect     curr={curr} key={curr.FormID} view={this.props.view} handleRedraw={this.props.handleRedraw}/>
          }else{
            return <div>Unknown Element</div>
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
        <h1>Computer Access Authorization E-Form</h1>
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
    <div className="formclass" key={props.curr.FormID}>
      <ElementFormHeader curr={props.curr} header={props.header} formatdate={formatdate}/>
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
  )
}

function ElementSection(props) {  
  return (
    <div key={props.curr.FormID}>
      <div className="sectionclass">
        <h2>{props.curr.Descrip}
        <DeleteElement className="delclass" view={props.view} DelID={props.curr.FormID} handleRedraw={props.handleRedraw} />
        </h2>
        <AddElements view={props.view} type="SECTION" curr={props.curr} handleRedraw={props.handleRedraw} />  
        <Element tree={props.curr.children} view={props.view} handleRedraw={props.handleRedraw}/>
      </div>
      <AddElements view={props.view} type="SECTIONAFTER" curr={props.curr} handleRedraw={props.handleRedraw} />  
    </div>
  )
}
function ElementText(props) {  
  return (
    <div key={props.curr.FormID}>
      <div className="textclass">
        <div>{props.curr.Descrip}
        <DeleteElement className="delclass" view={props.view} DelID={props.curr.FormID} handleRedraw={props.handleRedraw} /> 
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
    //this.onClick = this.onClick.bind(this); //React components using ES6 classes don't autobind "this". You can add a "bind" or use arrow funcs 
    //https://facebook.github.io/react/docs/handling-events.html The latter is called "property initializer syntax" Warning: this is *experimental* syntax.
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
         <DeleteElement className="delclass" view={this.props.view} DelID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} /> 
        </label>

        <input type="checkbox" name={curr.FormID} onClick={this.onClick} defaultChecked={this.state.childVisible}/>      
         {
            this.state.childVisible
              ? <Element tree={curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} />
              : null
          }      
        </div>
        <AddElements view={this.props.view} type="AFTER" curr={this.props.curr} handleRedraw={this.props.handleRedraw} /> 
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
            <DeleteElement className="delclass" view={this.props.view} DelID={curr.FormID} handleRedraw={this.props.handleRedraw} />            
            </label>
            <input type="text" className="inputclass" name={curr.FormID} id={curr.FormID} defaultValue={curr.ItemValue}/>
          </div>
          <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
        </div>
      ) 
  }
}

class ElementRadio extends React.Component { 
  render() { 
    let curr = this.props.curr;
      return (
      <div>
      {curr.children[0] ?
        curr.children.map((chld,ix) => { //these should be OPTIONS
        return( 
          <div key={chld.FormID}>
            <label>{ix!==0?"":curr.Descrip+":"}
              <DeleteElement className="delclass" view={this.props.view} DelID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} /> 
            </label>
            <input type="radio" name={curr.FormID} defaultChecked={chld.Descrip===curr.ItemValue?"checked":""} value={chld.Descrip} id={chld.FormID} />
            <DeleteElement className="delclass" view={this.props.view} DelID={chld.FormID} handleRedraw={this.props.handleRedraw} /> 
            {chld.Descrip}
            <AddElements view={this.props.view} type="RADIO"/>  
          </div>
        )
      })//if no OPTIONS
      :(  
          <div>
            <label>{curr.Descrip}
              <DeleteElement className="delclass" view={this.props.view} DelID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} /> 
            </label>
            <input type="radio" name={curr.FormID} />

            <AddElements view={this.props.view} type="RADIO"/>  
          </div>
      )
      }
      <AddElements view={this.props.view} type="AFTER"/>       
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
        <DeleteElement className="delclass" view={this.props.view} DelID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} /> 
        </label>
        <select id={curr.FormID} name={curr.FormID} defaultValue={curr.ItemValue}>
          <option key={0} value="">(Choose One)</option>
          {curr.children.map((chld) => { //these should be OPTIONS
            return( 
              <option key={chld.FormID} value={chld.Descrip}>{chld.Descrip}</option>
            )
          })}
        </select>
        <AddElements view={this.props.view} type="OPTION"/> 
        <AddElements view={this.props.view} type="SELECT"/> 
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
        We will verify your signature with the employee FormID you are currently logged in with.) 
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


