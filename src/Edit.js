import React from 'react';
import AddNew from './AddNew';
import DeleteNode from './DeleteNode';

export default class Edit extends React.Component {  
  constructor(props) {
    super(props);
    this.handleRedraw = this.handleRedraw.bind(this);
  }

  handleRedraw=(obj)=>{ //debugger;
    this.props.handleRedraw();
  }
  
  render() { 
    if(this.props.view !== "EDIT"){
      return null
    }else{
    return ( 
        <div className="editclass" >
          {this.props.type==="FORM"
          && <AddNew typeToAdd="SECTION" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />} 
          
          {this.props.type==="SECTION"
          && (
            <div>
            <DeleteNode DelID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />
            <AddNew typeToAdd="INPUT" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />   
            <AddNew typeToAdd="RADIO" procToCall="AddChild" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />   
            </div>
          )

          }
          {this.props.type==="SECTIONAFTER"
          && <AddNew typeToAdd="SECTION" procToCall="InsNode" code="" parNodeID={this.props.curr.FormID} handleRedraw={this.handleRedraw} />}   
        </div>
      )
    }
  }
}
