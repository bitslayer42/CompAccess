import React from 'react';
import AddElement from './AddElement';

export default class Edit extends React.Component {  
  constructor(props) {
    super(props);
    this.handleRedraw = this.handleRedraw.bind(this);
  }

  handleRedraw=()=>{ 
    this.props.handleRedraw();
  }
  
  render() { 
    if(this.props.view !== "EDIT"){
      return null
    }else{
    return ( 
        <div className="editclass" >
          {
              this.props.type==="FORM" ? (
              <AddElement typeToAdd="SECTION" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="SECTION" ? (
              <AddElement typeToAdd=">>>" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="SECTIONAFTER" ? (
              <AddElement typeToAdd="SECTION" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="AFTER" ? (
              <AddElement typeToAdd=">>>" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : (this.props.type==="REQUEST" || this.props.type==="RESPONSE") ? (
              <AddElement typeToAdd=">>" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="OPTION" ? (
              <AddElement typeToAdd="OPTION" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : this.props.type==="OPTIONAFTER" ? (
              <AddElement typeToAdd="OPTION" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            )
            : <AddElement typeToAdd="TODO" procToCall="AddChild" parNodeID="0" handleRedraw={this.handleRedraw} />

          }   
          
        </div>
      )
    }
  }
}
          // {this.props.type==="NODE"
          // && (

            // <AddElement typeToAdd="REQUEST" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            // <AddElement typeToAdd="RESPONSE" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />

          // )