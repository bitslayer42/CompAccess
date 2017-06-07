let fieldlist = [ 
  
			  { "ID": 496
			  , "Type": "INPUT"
			  , "Descrip": "id"
			  , "FormName": "aform"
			  }
			  , 
			  { "ID": 497
			  , "Type": "INPUT"
			  , "Descrip": "tocomplete"
			  , "FormName": "aform"
			  }
			  , 
			  { "ID": 501
			  , "Type": "SELECT"
			  , "Descrip": "hide the message?"
			  , "FormName": "bform"
			  }
			  , 
			  { "ID": 499
			  , "Type": "MESSAGE"
			  , "Descrip": "a message to hide"
			  , "FormName": "bform"
			  }
			  
			  ] 
;

    //Create a tree for optgroup  [ { form1: [ {obj1},{obj2} ] },{ form2 : [] } ]
	var finalObj = [];
	fieldlist.map( obj => obj.FormName )                         //get list of FormNames
	   .filter((value, index, self) => self.indexOf(value) === index) //make unique
	   .forEach((form)=>{                                             //for each FormName build an array of its objects
			var o = {formname: form};	
			o.fields = fieldlist.filter((item)=>{return item.FormName===form}) ;
			finalObj.push(o);
		})

	
	console.log(finalObj);
	console.log(finalObj[0]);
			
			
		
		
		
		
		  