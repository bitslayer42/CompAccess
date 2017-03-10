import React from 'react';
import AddElement from './AddElement';
//<AddElements view={props.view} type="SECTIONAFTER" curr={props.curr} handleRedraw={props.handleRedraw} />
export default class Edit extends React.Component {  
  render() { 
    if(this.props.view !== "EDIT"){
      return null
    }else{
    return ( 
        <div className="editclass" >
          {
              this.props.type==="FORM" ? (
              <AddElement typeToAdd="SECTION" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : this.props.type==="SECTION" ? (
              <AddElement typeToAdd=">>>" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : this.props.type==="SECTIONAFTER" ? (
              <AddElement typeToAdd="SECTION" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : this.props.type==="AFTER" ? (
              <AddElement typeToAdd=">>>" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : (this.props.type==="REQUEST" || this.props.type==="RESPONSE") ? (
              <AddElement typeToAdd=">>" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : this.props.type==="SOPTION" ? (
              <AddElement typeToAdd="OPTION" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : this.props.type==="SOPTIONAFTER" ? (
              <AddElement typeToAdd="OPTION" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : this.props.type==="OPTION" ? (
              <AddElement typeToAdd="OPTS>>" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : this.props.type==="OPTIONAFTER" ? (
              <AddElement typeToAdd="OPTS>>" procToCall="AddSister" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : this.props.type==="SUBFORM" ? (
              <AddElement typeToAdd=">>" procToCall="AddChild" parNodeID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} />
            )
            : <AddElement typeToAdd="TODO" procToCall="AddChild" parNodeID="0" handleRedraw={this.props.handleRedraw} />
          }   
        </div>
      )
    }
  }
}
