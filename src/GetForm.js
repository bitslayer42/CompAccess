import React from 'react';
import axios from 'axios'; //ajax library
import { LibPath } from './LibPath';
import Element from './Element';

export default class GetForm extends React.Component {
  constructor(props) { //console.log("getform constructor props",props.match.params.view); 
    super(props);
    this.state = {
      view: props.match.params.view, //params comes from router :view . Can be "SUPV", "ADMIN", "EDIT", "HEADER", "REQUIRED", "REQRESP"
      formID: props.match.params.formID,
      reqID: props.match.params.reqID,
      nodes: [], //the tree 'flat'
      header: {},
      loading: true,
      error: null,
    };
    this.handleRedraw = this.handleRedraw.bind(this);
    this.getFromServer = this.getFromServer.bind(this);
  }
 
  componentDidMount() {
    this.getFromServer();
  }
  componentWillReceiveProps(nextProps) {
    if(this.props!==nextProps){
      this.setState({
        view: nextProps.match.params.view
      })
    }
  }
  getFromServer(){ 
    axios.get(LibPath + 'FormJSON.cfm', {
      params: {
        FormID: this.state.formID,
        reqID: this.state.reqID,
		view: this.state.view,
        cachebuster: Math.random()
      }
    })
    .then(res => {
      const nodes = res.data.body; 
      const header = {};
      header.RequestID = res.data.RequestID;
      header.Completed = res.data.Completed;
      header.LoggedInID = res.data.LoggedInID;
      header.LoggedInName = res.data.LoggedInName;
      header.SupvName = res.data.SupvName;      
      header.EnteredDate = res.data.EnteredDate;
      
      this.setState({ 
        view: this.props.match.params.view,
        nodes,
        header,
        loading: false,
        error: null
      });
    })
    .catch(err => { 
      this.setState({
        loading: false,
        error: err
      });
    }); 
  }

  handleRedraw() {  
  // CallBack after adding or deleting node, or toggling header/required fields. 
  // Element is already changed in db, now repull tree. 
    this.getFromServer();
  } 
  
  renderLoading() {
    return <div>Loading...</div>;
  }

  renderError() { 
    return (
      <div>
        Uh oh: {this.state.error.message}
      </div>
    );
  }
  
  makeTree() { 
    const nodes = JSON.parse(JSON.stringify(this.state.nodes));
    const rootID = nodes[0].FormID;
    const amap = {};
    let node;
    const atree = [];
    for (let i = 0; i < nodes.length; i += 1) {
        node = nodes[i];
        node.nodeid = i;
        node.children = [];
        amap[node.FormID] = i; // used to look-up the parents:stackoverflow.com/questions/18017869/
        if (node.FormID !== rootID) {
            nodes[amap[node.ParentID]].children.push(node);
        } else {
            atree.push(node); // first
        }
    }
                                                                   console.log("atree",atree);       //console.log("state",this.state); //console.log("localnodes",nodes);//
    return <Element tree={atree} view={this.state.view} header={this.state.header} handleRedraw={this.handleRedraw}/>
  }
  
  render()  {
    return (
      <div className="outerdiv">
          {this.state.loading ?
          this.renderLoading()
          : this.makeTree()}
      </div>
    );
  }
}
