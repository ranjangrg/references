
## Dependencies
```bash
npx create-react-app <projectName>
npm install --save redux react-redux

# Optional Installations
npm install --save bootstrap
npm install @material-ui/icons	
```

## `redux` setup


## Use `store`
1. Create `action`, `reducer` (and `store`) <br>
> Don't forget to import them
2. Dependencies: <br>
```jsx
// for class-based component
import { connect } from 'react-redux';
```
3. Access the global `redux-store` object <br>
Create `mapStateToProps` function object
```jsx
const mapStateToProps = (state) => {
	return {
		currentAppId: state.currentAppId,
		currentView: state.currentView,
		<stateName>: state.<reducerName>
	};
};
// ...
export default connect(mapStateToProps, null)(<ComponentClass>);
// null if acccess-only i.e. no dispatch is required
```
4. Modify the global `redux-state` <br>
Create `mapDispatchToProps` function object 
```jsx
import { <actionObj> } from '../actions';
// ...
const mapDispatchToProps = (dispatch) => {
	return {
		<propFunctionName>: <actionObj>,
		// if you get 'undefined' action errors
		<propFunctionName>: () => <actionObj>(),
	};
};
/* to use this dispatch
... 
{ (..) => this.props.<propFunctionName>(<args>) }
...
*/
```