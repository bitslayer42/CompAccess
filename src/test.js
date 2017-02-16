import React from 'react';

export default class Test extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      retObj: {"not":"bot"}
    };
  } 
  
  getAddedObj=(obj)=>{
    console.log(obj);
  }
  
  render()  {
    return (
  <Test2 getAddedObj={this.getAddedObj}/>
    )
  }
} 

class Test2 extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      retObj: {"moo":"boo"}
    };
  }  
  retAddedObj=()=>{
    this.props.getAddedObj(this.state.retObj);
  }
  render()  {
    return (
      <div>
            <button onClick={this.retAddedObj} >Clique</button>
     </div>
    )
  }
};

 

