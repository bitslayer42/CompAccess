import React from 'react';
import addbutton from './images/plus.png';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';

//USAGE:   // <AddElement typeToAdd="FORM" procToCall={this.props.procToCall} parNodeID={this.state.adminData.root} handleRedraw={self.handleRedraw} />

export default class AddElement extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      showPrompt: false, //show the text box to enter a name
      showClosedList: false,
      showOpenedList: false,
      promptBoxText: '',
      listToAdd: []
    };
  }  
  componentDidMount() { 
    this.setUpClosedList();
  } 
  setUpClosedList(){
    if(this.props.typeToAdd===">>"){
      this.setState({
        listToAdd: ["INPUT","DATE","SELECT","RADIO","MESSAGE"],
        showClosedList: true
      });   
    }   
    if(this.props.typeToAdd===">>>"){
      this.setState({
        listToAdd: ["NODE","INPUT","DATE","SELECT","RADIO","MESSAGE"],
        showClosedList: true
      });   
    } 
    if(this.props.typeToAdd==="OPTS>>"){
      this.setState({
        listToAdd: ["OPTION","SUBFORM"],
        showClosedList: true
      });   
    }   
    
  }
  showThePrompt=()=>{
    this.setState({ 
      showPrompt: true
    });
  }
  showList=()=>{
    this.setState({
      showClosedList: false,
      showOpenedList: true
    });   
  }
  handleRedraw=()=>{ 
    this.setState({ 
      showPrompt: false,
      showOpenedList: false,
      showClosedList: false,
      promptBoxText: ''
    }); 
    this.setUpClosedList();      
    this.props.handleRedraw();
  }
  
  handleChange=(event)=>{
    this.setState({   
      promptBoxText: event.target.value
    });
  }  
  handleSubmit=(event)=>{
    const self=this;
    event && event.preventDefault();    

    axios.get(LibPath + 'DBUpdate.cfm', {
      params: {
        Proc: this.props.procToCall,
        FormID: this.props.parNodeID,
        Type: this.props.typeToAdd,
        Descrip: this.state.promptBoxText,
        cachebuster: Math.random()
      }
    })
    .then(res => {   //debugger;
      self.handleRedraw();
    })
    .catch(err => {
      self.setState({
        loading: false,
        error: err
      });
    });
  }  

  render()  {
    const self = this; //so nested funcs can see the parent object
    const convertUnpubLabel = this.props.typeToAdd==="UNPUB"?"FORM":this.props.typeToAdd;
    const typeToAddLabel = convertUnpubLabel.replace(/(.)(.*)/g, function(match, p1, p2){return p1+p2.toLowerCase()}); //converts NODE to Node
    const placehold = typeToAddLabel==="Message" ? "Message" : typeToAddLabel + " Name";
    const clickName = "Add " + typeToAddLabel;
    const listExpanded = this.state.listToAdd.map(function(toAdd,ix){
      return (
        <td key={ix}>
          <AddElement typeToAdd={toAdd} procToCall={self.props.procToCall} parNodeID={self.props.parNodeID} handleRedraw={self.handleRedraw} /> 
        </td>
      )
    });    
    return (
      <span className="addelement">
        {
          this.state.showClosedList ? (
            <span><a className="editclass" onClick={this.showList}>{clickName}</a></span>
          )
          : this.state.showOpenedList ? (
            <table className="addelementtable"><tbody>
            <tr>{listExpanded}</tr>
            </tbody></table>
          )
          : this.state.showPrompt ? (
              <form onSubmit={this.handleSubmit}>
                <input type="text" autoFocus value={this.state.promptBoxText} onChange={this.handleChange} placeholder={placehold} />
                <a onClick={this.handleSubmit}><img src={addbutton} alt="Add" title="Add"/></a>
              </form>
          )
          : <span><a className="editclass" onClick={this.showThePrompt}>{clickName}</a></span>
        }
        
     </span>
    )
  }
};


