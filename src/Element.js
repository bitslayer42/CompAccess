import React from 'react';
class Element extends React.Component {   //An element can be any row returned from stored proc
  render() {               
    return (
      <div>
      {this.props.tree.map((curr) => {
        if(curr.Type==="FORM"){
          return (
            <div className="formclass" key={curr.ID}>
              <h1>{curr.Descrip}:</h1>
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
          return (
            <div className="nodeclass" key={curr.ID}>
            <label >
             {curr.Descrip}:
            </label>
           <input type="checkbox"/>
            
            <Element tree={curr.children}/>
            </div>
          )
        }else if(curr.Type==="TEXT"){
          return (
            <div className="textclass" key={curr.ID}>
              <div>{curr.Descrip}</div>
            </div>
          )          
        }else {
          //the remaining types are html form types, which have a code of REQUEST or RESPONSE
          //RESPONSES are only used in Admin screen
          //if(curr.Code==="REQUEST"){
          if(curr.Type==="INPUT"){
            return (
            <div key={curr.ID}>
              <label>
              {curr.Descrip}:              
              </label>
              <input type="text" id={curr.ID}/>
            </div>
            )
          }else if(curr.Type==="RADIO"){
            return (
            curr.children.map((chld,ix) => { //these should be OPTIONS
              return( 
              <div key={chld.ID}>
                <label>{ix!==0?"":curr.Descrip+":"}</label>
                <input type="radio" name={curr.ID} value={chld.Code} id={chld.ID}/>
                {chld.Descrip}
                </div>
              )
            })
            )            
          }else if(curr.Type==="SELECT"){
            return (
              <div key={curr.ID}>
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
          }else{
            return <div key={curr.ID}>TODO:{curr.Descrip}:</div>
          }
        }
      })}
      </div>
    )
  }
}
export default Element;