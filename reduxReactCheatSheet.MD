# Redux w/ ReactJS Tutorial
`Redux` provides a predictable state container for JavScript applications. The app state is centralized.

`react-redux` is the official React binding for Redux.


## Installing `redux` and `react-redux`
```bash
npm install --save redux react-redux
```
> `--save` to include 'redux' and 'react-redux' within `dependencies`

## Basic Directory Tree
<pre>
main-app/
├── node_modules/
├── public/
├── ...
├── src/
│   ├── actions/
│   ├── reducers/
│   ├── App.js
│   ├── index.js
│   └── ...
├── package.json
└── ...
</pre>

## Reducers
Reducers are `functions` that return a new `state` depending on the current `state` and `action` passed. <br>
`(state, action) => newState`

Some guidelines on reducers:
1. By concept, `state` is immutable  
2. Handling `undefined` behaviour:
	* Handle `undefined` state arguments provided to the reducer function. <br> e.g. 
	`const reducer = (initial_state = 0, action) => {...}` <br>
	Here, if passed `state` is undefined, 
	* And try not to return any `undefined` states. 

### Files and directories
Convention: `./src/reducers/<reducerFileName>.js`. Include `./src/reducers/index.js` for a main reducer file.
> note: assuming we are in the react-app's root directory

A typical reducer JS file:
```jsx
const counter_reducer = (initial_state = 0, action) => {
	switch (action.type) {
		/* Convention: 
		action = {
			type: '...', 
			payload: '...'
			}
		*/
		case 'ADD':
			return initial_state + action.payload;
		case 'SUB':
			return initial_state - action.payload;
		default:
			return initial_state;
		// better to run some checks on 'action.payload' 
		// e.g. datatypes(string or number) etc.
	}
}

export default counter_reducer;
```

### Combining multiple reducers 
Why? To reduce complexity from having multiple reducers.
Afterall, `createStore` takes a single reducer funtion.

Import required:
`import { combineReducers } from 'redux';`

Combining several reducers to a single `index.js` file:
```jsx
import <reducerName> from './<reducerFileName>';
import counter_reducer from './counterReducer.js'; //assuming within same dir

// import other reducers from their respective reducer files

import { combineReducers } from 'redux';

const allReducers = combineReducers({
	<keyName>: <reducerName>, // syntax
	counter: counter_reducer, // example 1
	username: username_reducer // example 2
	//...
});

export default allReducers;
```

## Global State (`store`) and `Provider`
### `store`
`createStore()` is used to create a storage/state object (import required from `redux`).

Syntax:<br>
```jsx
import allReducers from './reducers/index.js'; 
// or simply './reducers', index.js is implied

import { createStore } from 'redux';

const store = createStore(allReducers);

```
### `Provider`
`Provider` is used to link/connect our global state/`store` object to our app. <br>

From 'react-redux' api webpage:

> The `<Provider>` component makes the Redux `store` available to any nested components that need to access the Redux store.<br> ... <br>
The `Hooks` and `connect` APIs can then access the provided store instance via React's Context mechanism.

Import statement:
```jsx
// app-root's 'index.js' file

import { Provider } from 'react-redux';
// ...
const global_store = createStore(...);
ReactDOM.render(
	<Provider store={global_store}>
		<App />
	</Provider>,
	document.getElementById('root')
);

```

## Using redux `store`
### For function-based Components
`Hooks` are used to access the redux `store` object. <br>
`useSelector` function from `react-redux` is required. Its basic syntax:
```jsx
const result: any = useSelector(selector: Function, equalityFn?: Function)
```

```jsx
import { useSelector } from 'react-redux';

function CustomComponent() {
	const redux_state = useSelector(state => state);
	// OR
	const _username = useSelector(state => state.username);
	return (
		<div>
			Username: {_username}
		</div>
	);
}

export default CustomComponent;
```

### For Class-based Components
`connect` function from `react-redux` is used for accessing redux `store` object within class-based components.
1. First, 
```jsx
import { connect } from 'react-redux';
// Also import all the `action` functions we need.
import { <actionName> } from '../actions'; // syntax
import { userName } from '../actions'; // example 
```
2. Create a `mapStateToProps` function object.
```jsx
const mapStateToProps = (state) => {
	return {
		// syntax
		<newPropName>: state.<reducerName>,
		// example
		usernameAsProp: state.username // as declared in our combined-reducer
	};
};
```
> `<reducerName>` references to the keyName within our combined-reducer

> `<newPropName>` can be used as `this.props.newPropName` within our connected-component
3. Display redux `state`
```jsx
class CustomComponent extends React.Component {
	render() {
		return (
			{/* syntax */}
			<h1> { this.props.<newPropName> } </h1>
			{/* example */}
			<h1> { this.props.usernameAsProp } </h1>
		);
	};
}
```

## `action` objects
`action` describes what happens within app; it could be events and can trigger updates to `state`.
### Creating `action`
Convention:
Create `<appRootDir>/src/actions` directory.
Within the directory, create action JS files, e.g. `index.js`

```jsx
// index.js contents
export const adder = () => {
	return {
		type: 'ADD',
		payload: ...
	};
};
// OR
export const adder = (num_to_add) => {
	return {
		type: 'ADD',
		payload: num_to_add
	};
};
```

### Using `action`
```jsx
import { <actionName> } from './actions/index.js';
// or simply
import { <actionName> } from './actions';
```
To use `action` objects to update `state`, we use concept of `dispatch` method within the `store` object.

## Dispatch
From 'redux.js.org/tutorials' page: <br>
> The Redux `store` has a method called `dispatch`. The only way to update the state is to call `store.dispatch()` and pass in an `action` object. The `store` will run its `reducer` function and save the `new` state value inside, and we can call `getState()` to retrieve the updated value:
```jsx
store.dispatch({ type: <type> })
```
> You can think of dispatching actions as "triggering an event" in the application. Something happened, and we want the store to know about it. Reducers act like event listeners, and when they hear an action they are interested in, they update the state in response.

### `useDispatch` for function-based Components
```jsx
import { useDispatch } from 'react-redux';
import { adder } from './actions';
// ...
function CustomComponent() {
	const dispatch = useDispatch();
	return (
		<div>
			<button onClick={ () => dispatch(adder()) }> Add (w/o arg)</button>

			<button onClick={ () => dispatch(adder(100)) }> Add (w/ arg) </button>
		</div>
	);
}
```

### for class-based Components
1. Create a `mapDispatchToProps` function object
```jsx
import { adder } from './actions';
// ...
const mapDispatchToProps = () => {
	return {
		// syntax
		<actionName>: actionFunction,
		// example
		adder: adder,
	};
};
```
> `actionFunction` that we imported from `../actions/index.js`

2. Add event to Component
```jsx
import { adder } from './actions';
// ...
const mapDispatchToProps = () => { ... };
// ...
class CustomComponent extends React.Component {
	render() {
		return (
			{/* syntax */}
			<button 
				onClick={() => this.props.<actionName>()}> 
				Press me 
			</button>
			{/* example */}
			<button 
				onClick={() => this.props.adder(10)}> 
				Add 10 
			</button>
		);
	}
}
```
3. `connect` mapper functions

From `react-redux.js.org/api/connect` page:
> The `connect()` function connects a React component to a Redux `store`. <br>
> It provides its connected component with the pieces of the data it needs from the `store`, and the functions it can use to dispatch actions to the `store`. <br>
> It does not modify the component class passed to it; instead, it returns a new, connected component class that wraps the component you passed in. <br>
```jsx
import { connect } from 'react-redux';
// ...
const mapStateToProps = (state) => { ... };
const mapDispatchToProps = (state) => { ... };

class CustomComponent extends React.Component { ... }

export default connect(
	mapStateToProps, 
	mapDispatchToProps()
	)(CustomComponent); 
```
> note: we have to call `connect(...)` function obj by `connect(...)(Component)` 
