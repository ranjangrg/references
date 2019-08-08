# JavaScript Cheat Sheet 

###	Call JavaScript function by entering a key (instead of using buttons)
```javascript
function allowEnterKeyToAdd() {
	var inputAtForm = document.getElementsByClassName("submit-form");
		var i;
		for (i = 0; i < inputAtForm.length; i++) {
		// iterating through the divs with the same class
		inputAtForm[i].addEventListener("keyup", function(event) {            
			event.preventDefault(); // cancel the default action (if any)
			var e = event || window.event;
			if (e.keyCode == 13) { // when enter key (code:13) is pressed
				//alert("Function works");
				addLoc(); // it is a 'js' function/method
			}
		});
	}
}
```

### Trigger a Button click on Enter (from w3schools.com)
```javascript
// Get the input field
var input = document.getElementById("myInput");

// Execute a function when the user releases a key on the keyboard
input.addEventListener("keyup", function(event) {
// Cancel the default action, if needed
event.preventDefault();
// Number 13 is the "Enter" key on the keyboard
if (event.keyCode === 13) {
	// Trigger the button element with a click
	document.getElementById("myBtn").click();
}
});
```

### Add table rows via JavaScript (from w3schools.com)
```javascript
// Find a <table> element with id="myTable":
var table = document.getElementById("myTable");

// Create an empty <tr> element and add it to the 1st position of the table:
var row = table.insertRow(0);

// Insert new cells (<td> elements) at the 1st and 2nd position of the "new" <tr> element:
var cell1 = row.insertCell(0);
var cell2 = row.insertCell(1);

// Add some text to the new cells:
cell1.innerHTML = "NEW CELL1";
cell2.innerHTML = "NEW CELL2";
```

### Cast/Parse string to float
Basic casting to a float number:
```javascript
var num = parseFloat(document.getElementById(amtid4).innerHTML);
```

Formatting the number further (e.g. 2 decimal places):
```javascript
var num = parseFloat(document.getElementById(amtid4).innerHTML).toFixed(2);
```

### Empty `<a>` link that doesn't reload page
```html
<a href="#" onclick="alert(); return false;"> Link </a> 
```
It alerts then does nothing. Can add some functions before doing nothing ... okay!?

### Read a file
Use html5:
```html
<input type="file" id="csv-file" name="files[]"/> // name = array of files
```
In JavaScript:
1. Set a file: 
```javascript
var file = document.getElementById("csv-file").files[0]; // First file from the selected files
```
2. Set reader: 
```javascript
var reader = new FileReader();
```
3. Read the specific file: 
```javascript
reader.readAsText(file);
```
4. Contents: 
`reader.result` contains the contents of the file.

### Number of rows in a table.
```javascript
var x = document.getElementById("myTable").rows.length;
```

### Loop through table rows and columns.
```javascript
var table = document.getElementById("mytab1");
for (var i = 0, row; row = table.rows[i]; i++) {
	//iterate through rows
	//rows would be accessed using the "row" variable assigned in the for loop
	for (var j = 0, col; col = row.cells[j]; j++) {
		//iterate through columns
		//columns would be accessed using the "col" variable assigned in the for loop
	}  
}
```

### Change number of entries shown in DataTable
```javascript
$('#example').dataTable( {
	"pageLength": 50
} );
```
OR
```javascript
var dt = $('#data-table').DataTable({
	data: [],
	pageLength: 15, // number of entries shown
	deferRender: true,
```

### Sort data in D3.js + Get first 15 values (largest/smallest)
```javascript
// Returns the top 15 vtops !! Returns whole row
function calculateTop15Vtop() {
	var _data = dt.data().sort(function(a,b) {return b.m - a.m;}); // Sort data by Vtop first
	_data = _data.filter(function(d,i) {return i < 15;}); // Get the first 15 values
	return _data; // !!returns the whole row
}
```

### To select an input defined by aria-controls and change the value
```javascript
$("input[aria-controls='dt-17063']").val(1529443675)
```

> Source: https://stackoverflow.com/questions/45689156/set-value-to-an-aria-controls-input
Change the selector like this. Your selector target the id not the aria-controls so use with attr selector. Also Input not have `text()` property so change with `val()`

```javascript
function showMessage() {
	var message = jQuery("#textToDisplay").val();
	$("input[aria-controls=example]").val(message);
}
```
```html
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
<input type="text" id="textToDisplay" />
<input type="button" value="Add message" onClick="showMessage()" />
<input aria-controls="example" type="text">
```

### Set ID to elements without ID.
```javascript
$('.event-table label input').attr('id', 'searchMod'); // Giving ID to the search Input in mod table
```
For an `input` element inside element with class `event-table` and within a `label` element.

### Trigger a key up (as in manual key up) when onchange doesn't detect change (esp. when done via command)
```javascript
$('#elementID').keyup();
```
Triggers a key-up event inside the element with ID `elementID`

### Store Filter settings in DC.js
```javascript
names = []; filters = [];
for (var chart of dc.chartRegistry.list()) { names.push(chart.anchor()); filters.push(chart.filters())}
```

### Change filter in DC.js manually/programmatically
```javascript
directionChart.filter('Wat.'); // Selects only Wat. values
directionChart.render(); // renders the chart again to reflect the changes
```

### Store and apply filters in DC.js
In JavaScript code,
```javascript
// Stores All filter settings
var currentFilters = [];

// Stores all the filters used to 'currentFilters'
function storeAllFilters() {
	currentFilters = []; // empty list first
	for (var i = 0; i < dc.chartRegistry.list().length; i++){
		var chart = dc.chartRegistry.list()[i];	
		for (var j = 0; j < chart.filters().length; j++){
			currentFilters.push({ChartID: chart.chartID(), Filter: chart.filters()[j]});
		}
	}
}

// Applies filters stored in 'currentFilters' list
function applyStoredFilters() {
	for (var i = 0; i< currentFilters.length; i++){
		var filter = currentFilters[i].Filter;
		if(filter instanceof Array) filter = dc.filters.RangedFilter(filter[0], filter[1]);
		dc.chartRegistry.list()[currentFilters[i].ChartID-1].filter(filter);
	}
}

function reloadData() {
	storeAllFilters(); 
	updateData(document.getElementById('location').options[document.getElementById('location').options.selectedIndex].value, document.getElementById('axis').value); 
}

function loadFilters() {
	applyStoredFilters();
	dc.renderAll();
}
```

### Check if a div exists
JavaScript:
```javascript
document.getElementById("elementId") returns null if it doesn't exist
```
jQuery:
```javascript
if ($('#diff-chart').length > 0) { // do something }
```

### (LEAFLET.js)	Add a button to a map
```javascript
L.easyButton('fa-comment', function (){alert();}).addTo(map);
// 'map' is the variable containing the map
```

### (LEAFLET.js)	Remove all Layers
```javascript
map.eachLayer(function (layer) { // Looping through each layer in the map
	console.log(layer);
	// Check if layer.feature is defined and remove layers whose value exceeds 100
	if (layer.feature && layer.feature.properties.value > 100 ) {map.removeLayer(layer);}
});
```

### (DC.js) Remove labels from axis of barchart in DC.js
```javascript
.xAxis().tickValues([]);
.yAxis().tickValues([]);
```

### (jQuery) Quick tooltip
html: (using font awesome for this example)
```html
<i data-toggle="tooltip" title="Content of the tooltip" class="fa fa-refresh" aria-hidden="true" onclick="javascript: renderDiffChart();"> </i> 
```
JavaScript:
```javascript
$(function() {
	$('[data-toggle="tooltip"]').tooltip();
}
```
CSS: (fix tooltip width)
```css
div.ui-tooltip {
	max-width: 150px;
}
```

### Clone an array (no reference)
```javascript
var clone = myArray.slice(0);
```

### (D3.js) Remove selection
```javascript
d3.selectAll("rect.class1").remove(); // Removes all rect tags with class "class1"
```

### (DC.js) Event and Listeners
API URL: https://dc-js.github.io/dc.js/docs/html/dc.baseMixin.html 
Search on(event, listener)

### (D3.js) Change style (when attr doesn't work)
```javascript
d3.selectAll('rect').style('fill', 'black'); // Changes fill colour of every rect tags 
```

### (D3.js) Selections API
URL: http://d3indepth.com/selections/

### (D3.js |& DC.js) Fix overlapping x-axis labels
```javascript
chart.on('renderlet', function (c) {
	// selcting x axis texts from the chart and transforming them
	c.selectAll('g.x text').attr('transform','translate(-10, 10) rotate(315)');
});
```
> Source: https://github.com/dc-js/dc.js/issues/731#issuecomment-59599016

### Remove all characters after a certain character in a string
```javascript
let data = "2015/01/01: 100.5";
let newData = data.split(':')[0]; // splits where ':' is present into array. Then choose the first element
// newData is "2015/01/01"
```

### Convert Date(string) to timestamp
```javascript
var barDate = "1 September 2014";
var dt = Date.parse(barDate); // dt = 1409522400000 (timestamp milliseconds)
var dtObj = new Date(bardate); // creates a date object (so more date methods)
```

### Get id of parent element (e.g. get id of `<table>` from `<td>`
```javascript
var parentid = currentNode.parentNode.id;
```
ALSO possible
```javascript
var grandparentid = currentNode.parentNode.parentNode.id;
```

### Variable values within strings
Using \` quotes.  Example:
```javascript
let code = "int i = 100;";
var fileContent = `File content:\n ${code} \n End`;
```

### Load JSON data into table (using Bootstrap)
First, the Bootstrap AND jQuery API must be included in the header
```html
<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
```
Then in JavaScript (inline or external file)
```javascript
function prepareHTML(data) {
	let html = '<table class="table table-striped table-hover table-condensed">';
    html += '<tr>';	
    $.each(data[0], function(index, value){
		html += '<th>'+index+'</th>';
	}
    });
    html += '</tr>';
     $.each(data, function(index, value){
        html += '<tr>';
        $.each(value, function(index2, value2){
            html += '<td align="center">'+value2+'</td>';
        });
        html += '<tr>';
     });
     html += '</table>';
	 return html;
}

function loadJSON() {
	let html = '<h1 align="center"> JSON to table </h1>';
	let data = json_data;	// json_data should contain JSON 
    html += prepareHTML(data);
     $('#table-div').html(html);	// 'table-div' is the ID of the div that will populate the table contents
}

$(document).ready(loadJSON);
```

### Add tooltip to div (using Bootstrap)
```html
...
<div data-toggle="tooltip" title="Tooltip contents"> Something </div>
...
```
Then via jQuery/JavaScript,
```javascript
$('[data-toggle="tooltip"]').tooltip();
```

### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 


### 
