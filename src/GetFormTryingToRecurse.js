import React from 'react';
import axios from 'axios'; //ajax library
import LibPath from './LibPath';
/////////////////////////////////////////////////////////////////////////
class GetForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      nodes: [],
      loading: true,
      error: null
    };
  }
  /////////////////////////////////////////////////////////////////////////
  componentDidMount() {
      axios.get(LibPath + 'FormJSON.cfm', {
        params: {
          FORMCODE: 'Network'
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
  /////////////////////////////////////////////////////////////////////////
  renderLoading() {
    return <div>Loading...</div>;
  }
  /////////////////////////////////////////////////////////////////////////
  renderError() {
    return (
      <div>
        Render Error: {this.state.error.message}
      </div>
    );
  }
  /////////////////////////////////////////////////////////////////////////
  renderNode(curr){  //Render each Type of Node
                                                                console.log(curr.Descrip); 
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
        }else if(curr.Type==="RADIO"){
          return (
            <label>
            <input type="radio" key={curr.ID}/>
            {curr.Descrip}
            </label>
          )
        }
      //}
    }
  }
  /////////////////////////////////////////////////////////////////////////
  renderForm(start,end) { //This renders the recursive divs that make up the form
                                                          console.log(start,end); 
    if(this.state.error) {
      return this.renderError();
    }
    
    let kids = null;
    let previd = null;
    
    let curr = this.state.nodes[start];  
    let nextdepth = (curr.depth+1);
    
                                                      console.log("next depth:"+nextdepth ); 
    if(start!==end){
      let childnodeIDs = this.state.nodes
            .filter((node)=>{ 
               // eslint-disable-next-line
              return node.depth == nextdepth 
              && node.ID >= start && node.ID <= end 
            })
            .map((node)=>{ 
              return node.ID 
            });                              
                                                                        
      childnodeIDs.push((end+1));                                 console.log(childnodeIDs); 
                                                              
      kids = childnodeIDs.forEach((ID)=>{                       //console.log(previd,ID); 
        if (previd !== null){
          return (
            this.renderForm(previd,(ID-1))
          )
        }
        previd = ID;
      });  
    }
                                                                        console.log(kids); 
    return (
      <div>
        { this.renderNode(curr) }
        { kids }      
      </div>
    );
  }
  /////////////////////////////////////////////////////////////////////////    
    
  render() {
    return (
      <div className="outerdiv">
          {this.state.loading ?
          this.renderLoading()
          : this.renderForm(0,this.state.nodes.length-1)}
      </div>
    );
  }
}
export default GetForm;