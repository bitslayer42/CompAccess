import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';

class Element extends React.Component {   //An element can be any row returned from stored proc
  render() {
      let curr = this.props.curr;
        if(curr.Type==="FORM"){
          return <h1 key={curr.ID}>{curr.Descrip}</h1>;
        }else if(curr.Type==="SECTION"){
          return <h2 key={curr.ID}>{curr.Descrip}</h2>;
        }else if(curr.Type==="NODE"){
          return (
            <label>
            <input type="checkbox" key={curr.ID}/>
            {curr.Descrip}
            </label>
           )
        }else{
          //the remaining types are html form types, which have a code of REQUEST or RESPONSE
          //RESPONSES are only used in Admin screen
          //if(curr.Code==="REQUEST"){
          if(curr.Type==="INPUT"){
            return (
              <label>
              <input type="text" key={curr.ID}/>
              {curr.Descrip}
              </label>
            )
          }else if(curr.Type==="RADIO"||curr.Type==="OPTION"){
            return (
              <label>
              <input type="radio" key={curr.ID} name="ption"/>
              {curr.Descrip}
              </label>

            )
            //}
          }else{
            return <div>{curr.Descrip}</div>
          }
        }
  }
}
class Node extends React.Component {   //Rows hold one element
  render() {
    return(<div className="SECTION"> <Element curr={this.props.curr}/> </div>)
  } 
}
class TheForm extends React.Component {
  render() {
    return ( 
      <div>
        {  this.props.nodes.map((node, ix)=>{
          return <Node key={ix} curr={node}/>;
        })}
      </div>
    );
  }
}
  
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

  render()  {
    return (
      <div className="outerdiv">
          {this.state.loading ?
          this.renderLoading()
          : <TheForm nodes={this.state.nodes}/>}
      </div>
    );
  }
}
export default GetForm;