# React Contexts and Providers

## Creating `context` and `Provider` component
```jsx
import { createContext } from 'react';

const CustomContext = createContext({});

function CustomProvider(props) {
	const _foo1 = () => { ... };
	const _foo2 = () => { ... };
	// ...
	return (<CustomContext.Provider value={{
		foo1: _foo1,
		foo2: _foo2
	}}>
		{ props.children }
	</CustomContext.Provider>);
}

export { CustomContext, CustomProvider };
```

## Wrapping `Provider`
```jsx
import { CustomProvider } from '<contextPath>/<contextFile>';

function TopMostComponent() {
	return (<>
		<CustomProvider>
			<ChildComponent1 />
			<ChildComponent2 />
			<ChildComponent3 />
			{/* ... */}
		</CustomProvider>
	</>);
}
```
All `<ChildComponent? />` will have access to our `context` through the `Provider`.

## Using `context` 
```jsx
import { useContext } from 'react';
import { CustomContext, CustomProvider } from '<contextPath>/<contextFile>';

function TestComponent() {
	const { foo1, foo2 } = useContext(CustomContext);
	return (<>
		<button onClick={foo1}> Function 1 </button>
		<button onClick={foo2}> Function 2 </button>
	</>);
}
// ...
```
