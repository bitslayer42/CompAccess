let data = { "fieldlist": [ 
  
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
};

    //Create a tree for optgroup 
	//const nodes = data.fieldlist.map( obj => obj.FormName );

	var unique = data.fieldlist.map( obj => obj.FormName )
							   .filter((value, index, self) => self.indexOf(value) === index); 
							   
							   
	
	console.log(unique);
	// let formObj = {};
    // let fieldNode;
	// let prevFormName = '';
    // const atree = [];
    // for (let i = 0; i < nodes.length; i += 1) {
        // fieldNode = nodes[i];
		// if (prevFormName!==fieldNode.FormName){
			// formObj[fieldNode.FormName].push(fieldNode);
		// }
			
			
		
		
		
		
		  