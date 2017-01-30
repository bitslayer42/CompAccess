import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

class GetForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      nodes: [],
      loading: true,
      error: null
    };
  }

  componentDidMount() {
      axios.get(LibPath + 'FormJSON.cfm', {
        params: {
          FORMCODE: 'CCPIT'
        }
      })
      .then(res => {
        const nodes = res.data; 
        
        // Update state to trigger a re-render.
        this.setState({
          nodes,
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
    let nodes = this.state.nodes;
    let rootID = nodes[0].ID;
    var map = {}, node, atree = [];
    for (var i = 0; i < nodes.length; i += 1) {
        node = nodes[i];
        node.children = [];
        map[node.ID] = i; // use map to look-up the parents:stackoverflow.com/questions/18017869/
        if (node.ID !== rootID) {
            nodes[map[node.ParentID]].children.push(node);
        } else {
            atree.push(node);
        }
    }
    console.log(atree);
    return (
      <Element tree={atree}/>
    )
    
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

class Element extends React.Component {   //An element can be any row returned from stored proc
  render() {               //debugger;
    return (
      <div>
      {this.props.tree.map((curr,i) => {
        if(curr.Type==="FORM"){
          return (
            <div className="formclass" key={curr.ID}>
              <h1>{curr.Descrip}</h1>
              <Element tree={curr.children}/>
            </div>
          )
        }else if(curr.Type==="SECTION"){
          return (
            <div className="sectionclass" key={curr.ID}>
              <h2>{curr.Descrip}</h2>
              <Element tree={curr.children}/>
            </div>
          )
        }else if(curr.Type==="NODE"){
          return (
            <label key={curr.ID}>
            <input type="checkbox"/>
            {curr.Descrip}
            </label>
           )
        }else{
          //the remaining types are html form types, which have a code of REQUEST or RESPONSE
          //RESPONSES are only used in Admin screen
          //if(curr.Code==="REQUEST"){
          if(curr.Type==="INPUT"){
            return (
              <label key={curr.ID}>
              <input type="text"/>
              {curr.Descrip}
              </label>
            )
          }else if(curr.Type==="RADIO"||curr.Type==="OPTION"){
            return (
              <label key={curr.ID}>
              <input type="radio" name="ption"/>
              {curr.Descrip}
              </label>

            ) 
          }else{
            return <div key={curr.ID}>{curr.Descrip}</div>
          }
        }
      })}
      </div>
    )
  }
}
export default GetForm;