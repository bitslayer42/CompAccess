import React from 'react';
class Element extends React.Component {   //An element can be any row returned from stored proc
  render() {               
    return (
      <div>
      {this.props.tree.map((curr) => {
        if(curr.Type==="FORM"){
          return (
            <div className="formclass" key={curr.ID}>
              <h1>{curr.Descrip}</h1>
              <Element tree={curr.children}/>
              <button className="submit" onClick={() => this.props.submitForm()}>Submit</button>
            </div>
          )
        }else if(curr.Type==="SECTION"){
          return (
            <div className="sectionclass" key={curr.ID}>
              <h2>{curr.Descrip}:</h2>
              <Element tree={curr.children}/>
            </div>
          )
        }else if(curr.Type==="NODE"){
          return <ElementNode curr={curr} key={curr.ID}/> 
          
        }else if(curr.Type==="TEXT"){
          return (
            <div className="textclass" key={curr.ID}>
              <div>{curr.Descrip}</div>
            </div>
          )
        //the remaining types are html form types, which have a code of REQUEST or RESPONSE
        //RESPONSES are only used in Admin screen
        //
        }else if(curr.Type==="INPUT"){
          return <ElementInput curr={curr} key={curr.ID}/> 
          
        }else if(curr.Type==="RADIO"){
          return <ElementRadio curr={curr} key={curr.ID}/> 
          
        }else if(curr.Type==="SELECT"){
          return <ElementSelect curr={curr} key={curr.ID}/>
          
        }else{
          return <div key={curr.ID}>TODO:{curr.Descrip}:</div>
          
        }
        
      })}
      </div>
    )
  }
}

//if(curr.Code==="REQUEST"){

class ElementNode extends React.Component { 
  constructor(props) {
    super(props);
    this.state = {
      childVisible: false 
    };
    this.onClick = this.onClick.bind(this); //React components using ES6 classes don't autobind "this"
  }
  onClick() {
    this.setState({childVisible: !this.state.childVisible});
  }
  render() { 
    let curr = this.props.curr;
    return (
      <div className="nodeclass" key={curr.ID}>
      <label >
       {curr.Descrip}:
      </label>
     <input type="checkbox" onClick={this.onClick}/>
        {
          this.state.childVisible
            ? <Element tree={curr.children}/>
            : null
        }      
      
      </div>
    )
  }
}

class ElementInput extends React.Component { 
  render() { 
    let curr = this.props.curr;
    return (
    <div key={curr.ID}>
      <label>
      {curr.Descrip}:              
      </label>
      <input type="text" size="50" id={curr.ID}/>
    </div>
    ) 
  }
}

class ElementRadio extends React.Component { 
  render() { 
    let curr = this.props.curr;
      return (
      <div>
      {curr.children.map((chld,ix) => { //these should be OPTIONS
        return( 
        <div key={chld.ID}>
          <label>{ix!==0?"":curr.Descrip+":"}</label>
          <input type="radio" name={curr.ID} value={chld.Code} id={chld.ID}/>
          {chld.Descrip}
          </div>
        )
      })}
      </div>      
      ) 
  }
}

class ElementSelect extends React.Component { 
  render() { 
    let curr = this.props.curr;
    return (
      <div>
        <label>
        {curr.Descrip}:
        </label>
        <select id={curr.ID}>
        {curr.children.map((chld) => { //these should be OPTIONS
          return( 
            <option key={chld.ID} value={chld.Code}>{chld.Descrip}</option>
          )
        })}
        </select>
      </div>
    )
  }
}

export default Element;