class ElementRadio extends React.Component { 
  render() { 
  console.log("props",JSON.stringify(this.props));
    let curr = this.props.curr;
    let optcount = curr.children.length;
      return (
      <div>
      {optcount>0 ?
        curr.children.map((chld,ix) => { //these should be OPTION or SUBFORM
        let firstlabel = ix===0
        ?(<label>
          {curr.Descrip+":"}
          <DeleteElement className="delclass" view={this.props.view} DelID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} /> 
          </label>
        )
        :<label/>;
        
        return( 
          <div key={chld.FormID}>
            {(this.props.view==="EDIT" && ix===0) && (
              <span>
                <label></label>
                <AddElements view={this.props.view} type="OPTION" curr={curr} handleRedraw={this.props.handleRedraw} />
              </span>)
            }
            {chld.Type==="OPTION" 
              ?(
              <div>
              {firstlabel}
              <input type="radio" name={curr.FormID} defaultChecked={chld.Descrip===curr.ItemValue?"checked":""} value={chld.Descrip} id={chld.FormID} />
              <DeleteElement className="delclass" view={this.props.view} DelID={chld.FormID} handleRedraw={this.props.handleRedraw} /> 
              {chld.Descrip} 
              <AddElements view={this.props.view} type="OPTIONAFTER" curr={chld} handleRedraw={this.props.handleRedraw} /> 
              </div>
              )
              : chld.Type==="SUBFORM" 
              ? <ElementSubform  curr={chld} key={chld.FormID} name={curr.FormID} view={this.props.view} firstlabel={firstlabel} handleRedraw={this.props.handleRedraw}/>
              : <div key={curr.FormID}>Incorrect Element</div>
            }
          </div>
        )
      })//if no OPTIONS
      :(  
          <div>
            <label>{curr.Descrip}
              <DeleteElement className="delclass" view={this.props.view} DelID={this.props.curr.FormID} handleRedraw={this.props.handleRedraw} /> 
            </label>
            <input type="radio" name={curr.FormID} />

            <AddElements view={this.props.view} type="OPTION" curr={curr} handleRedraw={this.props.handleRedraw} />  
          </div>
      )
      }
      <AddElements view={this.props.view} type="AFTER" curr={curr} handleRedraw={this.props.handleRedraw} />       
      </div>      
      ) 
  }
}

class ElementSubform extends React.Component { 
  constructor(props) { 
    super(props);
    this.state = {
      childVisible: props.curr.ItemValue==="on"||props.view==="EDIT"?true:false 
    };
  }
  onChange=()=>{
    this.setState({childVisible: !this.state.childVisible});
  }
  render() { 
    let curr = this.props.curr;
    return (
      <div>
        {this.props.firstlabel}
        <input type="radio" name={this.props.name} defaultChecked={curr.Descrip===curr.ItemValue?"checked":""} onChange={this.onChange} value={curr.Descrip} id={curr.FormID} />
        <DeleteElement className="delclass" view={this.props.view} DelID={curr.FormID} handleRedraw={this.props.handleRedraw} /> 
        {curr.Descrip} 
         {
            this.state.childVisible
              ? <Element tree={curr.children} view={this.props.view} handleRedraw={this.props.handleRedraw} />
              : null
         }  
        <AddElements view={this.props.view} type="OPTIONAFTER" curr={curr} handleRedraw={this.props.handleRedraw} /> 
      </div>  
      

    )
  }
}