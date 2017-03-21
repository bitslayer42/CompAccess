import React from 'react';
//callback checking if a child field is filled in

//for this to work: pass indexes to children?
export default class ResponseTest extends React.Component {
  constructor(props) { 
    super(props);
    this.state = {
      completed: false,
      resultsSet: [],
      responseClassName: "responseclass"
    }
  }
  componentDidMount() { 
    let newResultsSet = [false,false,false]; //this.props.curr.children
    this.setState({
      resultsSet: newResultsSet
    }); 
  }
  handleChangeResponse=(id,completed)=>{
    let newResultsSet = this.state.resultsSet.slice();
    newResultsSet.splice(id,1,completed);
    let newComplete = newResultsSet.indexOf(false) === -1;  //returns true if all true
    this.setState({
      resultsSet: newResultsSet,
      completed: newComplete
    });    
  }  
  render() { 
    return (
  <div className={this.state.responseClassName}>
        <ElementInputTest ix="0" handleChangeResponse={this.handleChangeResponse}/>
        <ElementInputTest ix="1" handleChangeResponse={this.handleChangeResponse}/>
        <ElementInputTest ix="2" handleChangeResponse={this.handleChangeResponse}/>
        <label>
          ALL ARE FILLED:        
        </label>
        <input type="text" name="theresults" value={this.state.completed} />
      </div>
    ) 
  }
}

class ElementInputTest extends React.Component {  
  handleChange=(event)=>{ 
    this.props.handleChangeResponse(this.props.ix,event.target.value !== "");
  }  
  render() { 
    return (
        <div>
          <label>
          {this.props.ix}        
          </label>
          <input type="text" onChange={this.handleChange} />
        </div>
    ) 
  }
} 

  
  