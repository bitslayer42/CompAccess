import React from 'react';

export default class RadioTest extends React.Component {
    constructor(props) { 
      super(props);
      this.state = {
        moo:{"curr":{"FormID":139,
                     "depth":3,
                     "Type":"RADIO",
                     "Descrip":"Radio Question",
                     "ParentID":113,
                     "ItemValue":"",
                     "nodeid":5,
                     "children":[{"FormID":140,
                                  "depth":4,
                                  "Type":"OPTION",
                                  "Descrip":"Answer One",
                                  "ParentID":139,
                                  "ItemValue":"",
                                  "nodeid":6,
                                  "children":[]},
                                 {"FormID":141,
                                  "depth":4,
                                  "Type":"OPTION",
                                  "Descrip":"Answer Two",
                                  "ParentID":139,
                                  "ItemValue":"",
                                  "nodeid":7,
                                  "children":[]},
                                 {"FormID":142,
                                  "depth":4,
                                  "Type":"SUBFORM",
                                  "Descrip":"Answer Three subform",
                                  "ParentID":139,
                                  "ItemValue":"",
                                  "nodeid":8,
                                  "children":[{"FormID":144,
                                               "depth":5,
                                               "Type":"INPUT",
                                               "Descrip":"ASubFormInput",
                                               "ParentID":142,
                                               "ItemValue":"",
                                               "nodeid":9,
                                               "children":[]}]}]},
               "view":"EDIT"}
      }
    }
  handleRedraw=()=>{
    console.log("handleRedraw");
  }
  render() { 
    return (  
      <ElementRadioNew curr={this.state.moo.curr} key={this.state.moo.curr.FormID} 
        view={this.state.moo.view} handleRedraw={this.handleRedraw}/> 
    )
  }
}

class ElementRadioNew extends React.Component {    
  constructor(props) { 
    super(props);                   console.log("curr",this.props.curr); 
    this.state = {
      selectedOption: this.props.curr.ItemValue
    };
  }
  
  handleOptionChange=(changeEvent)=>{
    this.setState({
      selectedOption: changeEvent.target.value
    });
  }
  render() { 
    let curr = this.props.curr;
    let optcount = curr.children.length;
    return ( 
      <div>
      {optcount>0 ?
        curr.children.map((chld,ix) => { //these should be OPTION or SUBFORM
          let firstlabel = ix===0
          ?(<label>
            {curr.Descrip+":"}
            </label>
          )
          :<label/>;
          return( 
            <div key={chld.FormID}>
              {chld.Type==="OPTION"
              ?(
                <div>              
                {firstlabel}
                <input type="radio"  value={chld.Descrip} 
                                checked={this.state.selectedOption === chld.Descrip} 
                                onChange={this.handleOptionChange} />
                </div>
              )
              : chld.Type==="SUBFORM" 
                ?(
                  <div>              
                  {firstlabel}
                  <input type="radio"  value={chld.Descrip} 
                                  checked={this.state.selectedOption === chld.Descrip} 
                                  onChange={this.handleOptionChange} />
                   {this.state.selectedOption === chld.Descrip && <Element tree={curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} />}
                 </div>
                )
                : <div key={curr.FormID}>Incorrect Element</div>
              }
            </div>
          )
        })
      :null
      }
      </div>
    )
  }
}  

ElementRadioNew.propTypes = {
    curr: React.PropTypes.object,
    view: React.PropTypes.string,
    handleRedraw: React.PropTypes.func
}; 
  
  