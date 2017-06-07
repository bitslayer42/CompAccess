

	let data = [ 
	  { "ID": 1
	  , "Type": "red"
	  }, 
	  { "ID": 2
	  , "Type": "red"
	  }, 
	  { "ID": 3
	  , "Type": "blue"
	  } 
	]; 



	var theTypes = data.map( obj => obj.Type )
						.filter((value, index, self) => self.indexOf(value) === index); //make unique
	
	console.log(theTypes);
	console.log('\n');
	
	var finalObj = [];
	
	theTypes.forEach((type)=>{
		var o = {};	
		o[type] = data.filter((item)=>{return item.Type===type}) ;
		finalObj.push(o);

	})

	
	
	console.log(finalObj[0]);
	
			
			
		
		
		
		
	let newdata = [ 
		"red", [
			{ "ID": 1
			, "Type": "red"
			}, 
			{ "ID": 2
			, "Type": "red"
			}
		]
		, 
		"blue", [
			{ "ID": 3
			, "Type": "blue"
			}
		]			
	]; 