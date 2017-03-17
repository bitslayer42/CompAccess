var listt, results; 

// All the ItemValues inside this response node have been filled in.
// Call: var isComplete = curr.children.reduce(AllAreFilled, true);
function AllAreFilled(accumulator,eachItem){ return accumulator && (eachItem.ItemValue!==""?true:false)}


var curr = JSON.parse('{"FormID":8,"Type":"RESPONSE","Descrip":"RESPONSE","Required":0,"HeaderRecord":0,"ParentID":7,"ItemValue":"x","nodeid":9,"children":[{"FormID":12,"Type":"INPUT","Descrip":"A1","Required":1,"HeaderRecord":0,"ParentID":8,"ItemValue":"x","nodeid":10,"children":[]},{"FormID":13,"Type":"INPUT","Descrip":"A2","Required":1,"HeaderRecord":0,"ParentID":8,"ItemValue":"x","nodeid":11,"children":[]}]}');
console.log(JSON.stringify(curr.children));


var isComplete = curr.children.reduce(AllAreFilled, true);
console.log(isComplete);


listt = JSON.parse('[{"ItemValue":""},{"ItemValue":""}]');
results = listt.reduce(AllAreFilled, true);

console.log(results);

listt = JSON.parse('[{"ItemValue":""},{"ItemValue":"d"}]');
results = listt.reduce(AllAreFilled, true);

console.log(results);

listt = JSON.parse('[{"ItemValue":"s"},{"ItemValue":"d"}]');
results = listt.reduce(AllAreFilled, true);

console.log(results);