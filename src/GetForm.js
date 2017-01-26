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
        console.log(nodes);
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

  renderSection(curr){
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
      if(curr.Code==="REQUEST"){
        if(curr.Type==="INPUT"){
          return (
            <label>
            <input type="text" key={curr.ID}/>
            {curr.Descrip}
            </label>
          )
        }else if(curr.Type==="RADIO"){
          return (
            <label>
            <input type="radio" key={curr.ID}/>
            {curr.Descrip}
            </label>

          )
        }
      }
    }
  }
  
  renderForm(key) { //This renders the recursive divs that make up the form
    if(this.state.error) {
      return this.renderError();
    }
    let curr = this.state.nodes[key];
                                        
    if(this.state.nodes.length>key+1){
      return(
        <div className={curr.Type}>
          {this.renderSection(curr)}
          {this.renderForm(key+1)}
        </div>
      )
    }else{  //final node
          return <div>{this.renderSection(curr)}</div>;
    }
  }

  
  render() {
    return (
      <div className="outerdiv">
          {this.state.loading ?
          this.renderLoading()
          : this.renderForm(0)}
      </div>
    );
  }
}
export default GetForm;