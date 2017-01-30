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
            <div className="nodeclass" key={curr.ID}>
            <label>
            <input type="checkbox"/>
            {curr.Descrip}
            </label>
            <Element tree={curr.children}/>
            </div>
          )
        }else{
          //the remaining types are html form types, which have a code of REQUEST or RESPONSE
          //RESPONSES are only used in Admin screen
          //if(curr.Code==="REQUEST"){
          if(curr.Type==="INPUT"){
            return (
            <div key={curr.ID}>
              <label>
              <input type="text"/>
              {curr.Descrip}
              </label>
            </div>
            )
          }else if(curr.Type==="RADIO"){
            return (
              <div key={curr.ID}>
                {curr.Descrip}
                {curr.children.map((chld) => {
                 //if(chld.Type==="OPTION"){
                  return( 
                    <div key={chld.ID}>
                    <input type="radio" name={curr.ID} value={chld.Code}/>
                    {chld.Descrip}
                    </div>
                  )
                 //}
                })}
              </div>
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
export default Element;