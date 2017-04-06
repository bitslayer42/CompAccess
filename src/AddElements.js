import React from 'react';
import AddElement from './AddElement';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

export default class AddElements extends React.Component {  
  render() { 
    return (
      <ReactCSSTransitionGroup
        transitionName="AddElements"
        transitionEnterTimeout={500}
        transitionLeaveTimeout={500}>
        
        {this.props.view !== "EDIT"
          ? null
          : <div className="editclass" key={this.props.curr.FormID} >
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
      }
      </ReactCSSTransitionGroup> 
    )    
  }
}
