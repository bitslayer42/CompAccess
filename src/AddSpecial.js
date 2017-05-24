import React from 'react';
import addbutton from './images/plus.png';
import axios from 'axios'; //ajax library
import { LibPath, HomePath } from './LibPath';
import { Link } from 'react-router-dom'

//USAGE:   // <AddSpecial handleSpecialID={self.handleSpecialID} />

export default class AddSpecial extends React.Component {
  constructor(props) { 
    super(props); 
    this.state = {
      showPrompt: false, //show the text box to enter a description
      promptBoxText: '',
	  whichAction: null,
	  placehold: null
    };
  }  

  showThePrompt=(event)=>{
	const placehold = (event.target.value==="HIDERESPONSE" ? "Hidden Field"  : 
					   event.target.value==="SENDEMAIL"    ? "Special Email" : "");
    this.setState({ 
      showPrompt: true,
	  whichAction: event.target.value,
	  placehold: placehold + " Description"
    });
  }

  
  handleChange=(event)=>{
    this.setState({   
      promptBoxText: event.target.value
    });
  }  
  handleSubmit=(event)=>{
    const self=this;
    event && event.preventDefault();    

    axios.get(LibPath + 'Special.cfm', {
      params: {
        Proc: "AddSpecial",
        Action: this.state.whichAction,
        Description: this.state.promptBoxText,
        cachebuster: Math.random()
      }
    })
    .then(res => {  
		this.props.history.push(`${HomePath}special/${res.data.ID}`);
    })
    .catch(err => {
      self.setState({
        loading: false,
        error: err
      });
    });
  }  

  render()  {
    return (
      <div className="outerdiv">
        <Link to={HomePath}>&larr; Return to Admin menu</Link>
        <div className="formclass">
          <h1> Computer Access Forms </h1>
          <div className="sectionclass" >	
			  <span className="addelement">
				{
				  this.state.showPrompt ? (
					  <form onSubmit={this.handleSubmit}>
						<input type="text" autoFocus value={this.state.promptBoxText} 
							onChange={this.handleChange} placeholder={this.state.placehold}  style={{width: "450px"}}/>
						<a onClick={this.handleSubmit}><img src={addbutton} alt="Add" title="Add"/></a>
					  </form>
				  )
				  : (
					<ul>
						<li><button className="editclass" onClick={this.showThePrompt} value="HIDERESPONSE">New Hidden Field</button></li>
						<li><button className="editclass" onClick={this.showThePrompt} value="SENDEMAIL">New Special Email</button></li>
					</ul>
					)
				}
			 </span>
          </div>
        </div>
      </div>  			 
    )
  }
};


