import React from 'react';
import addbutton from './images/plus.png';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

//USAGE:   // <AddNew typeToAdd="FORM" procToCall={this.props.procToCall} code="" parNodeID={this.state.adminData.root} handleRedraw={self.handleRedraw} />

export default class AddNew extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      showPrompt: false,
      showClosedList: false,
      showOpenedList: false,
      promptBoxText: '',
      listToAdd: []
    };
  }  
  componentDidMount() { 
    if(this.props.typeToAdd===">>"){
      this.setState({
        listToAdd: ["NODE","INPUT","SELECT","RADIO","TEXT"],
        showClosedList: true
      });   
    }
    if(this.props.typeToAdd==="REQUEST"||this.props.typeToAdd==="RESPONSE"){
      this.setState({
        listToAdd: ["INPUT","SELECT","RADIO","TEXT"],
        showClosedList: true
      });   
    }    
  }    
  addForm=()=>{
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
        showClosedList: true,
        promptBoxText: ''
      });  
    this.props.handleRedraw();
  }
  
  handleChange=(event)=>{
    this.setState({promptBoxText: event.target.value});
  }  
  handleSubmit=(event)=>{
    let self=this;
    event && event.preventDefault();    

    axios.get(LibPath + 'DBUpdate.cfm', {
      params: {
        Proc: this.props.procToCall,
        FormID: this.props.parNodeID,
        Type: this.props.typeToAdd,
        Code: this.props.code,
        Descrip: this.state.promptBoxText,
        cachebuster: Math.random()
      }
    })
    .then(res => {   //debugger;
      self.setState({ 
        showPrompt: false,
        showOpenedList: false,
        showClosedList: true,
        promptBoxText: ''
      });
      self.props.handleRedraw();
    })
    .catch(err => {
      self.setState({
        loading: false,
        error: err
      });
    });
  }  

  render()  {
    var self = this; //so nested funcs can see the parent object
    let convertUnpubLabel = this.props.typeToAdd==="UNPUB"?"FORM":this.props.typeToAdd;
    let typeToAddLabel = convertUnpubLabel.replace(/(.)(.*)/g, function(match, p1, p2){return p1+p2.toLowerCase()}); //converts NODE to Node
    let placehold = typeToAddLabel + " Name";
    let clickName = "Add " + typeToAddLabel;
    let listExpanded = this.state.listToAdd.map(function(toAdd,ix){
      return (
        <td key={ix}>
          <AddNew typeToAdd={toAdd} procToCall={self.props.procToCall} code="" parNodeID={self.props.parNodeID} handleRedraw={self.handleRedraw} /> 
        </td>
      )
    });    
    return (
      <span className="addnew">
        {
          this.state.showClosedList ? (
            <span><a className="editclass" onClick={this.showList}>{clickName}</a></span>
          )
          : this.state.showOpenedList ? (
            <table className="addnewtable"><tbody>
            <tr>{listExpanded}</tr>
            </tbody></table>
          )
          : this.state.showPrompt ? (
              <form id="AddNewForm" onSubmit={this.handleSubmit}>
                <input type="text" autoFocus value={this.state.promptBoxText} onChange={this.handleChange} placeholder={placehold} />
                <a onClick={() => this.handleSubmit()}><img src={addbutton} alt="Add"/></a>
              </form>
          )
          : <span><a className="editclass" onClick={this.addForm}>{clickName}</a></span>
        }
        
     </span>
    )
  }
};


