# Steps
## 1. Install `nodejs` (includes `npm`)
## 2. Install `react` and `react-dom` via `npm`
```bash
npm install react react-dom
```
## 3. Install `babel` w/ presets (for ES*, JSX -> Vanilla, `babel-loader` for connect to webpack)
```bash
npm install @babel/core @babel/preset-env @babel/preset-react babel-loader
```
> `webpack` for packaging, `babel` for transpiling
## 4. Setup `babel`
Create `.babelrc` file within project root directory.
```
{
	"presets": [
		"@babel/preset-env",
		"@babel/preset-react"
	]
}
```
## 5. Install and configure `webpack`
```bash
npm install webpack webpack-cli webpack-dev-server 
# also helpful
npm install html-webpack-plugin
```
For webpack configuration:
```js
const HtmlWebpackPlugin = require("html-webpack-plugin");
const path = require("path");

module.exports = {
	entry: "./src/index.js",	// which file to look at
	output: {
		filename: "bundle.[fullhash].js",
		path: path.resolve(__dirname, "dist"),
	},
	plugins: [
		new HtmlWebpackPlugin({
			template: "./public/index.html",
			// where to find the main html(template) files
		}),
	],
	resolve: {
		modules: [__dirname, "src", "node_modules"],
		extensions: ["*", ".js", ".jsx", ".tsx", ".ts"],
	},
	module: {
		rules: [
			{
				// use babel loader on '.jsx' files
				test: /\.jsx?$/,
				exclude: /node_modules/,
				loader: require.resolve("babel-loader"),
			},
			{
				test: /\.css$/,
				use: ["style-loader", "css-loader"],
			},
			{
				test: /\.png|svg|jpg|gif$/,
				use: ["file-loader"],
			},
		],
	},
};
```

## 6. Basic app directory structure
(Convention only)
Create `src` directory and entry files `App.js` and `index.js`. Also, create an `index.html` to render react-app to.
```jsx
// App.js
import React from "react";

const App = () => {
	return (<div> 
		<h1>Main app here </h1>
	</div>);
};

export default App;
```

```jsx
// index.js
import React from "react";
import ReactDOM from "react-dom";

import App from "./App";

ReactDOM.render(
	<App />,
	document.querySelector("#root")
);
```

## 7. Edit `package.json` scripts
Some scripts to add to `package.json` for webpack.
```json
// ...
"scripts": {
    "start": "webpack-dev-server --hot --open",
	// --hot  : watch for changes command
	// --open : Open browser after server starts
	"build": "webpack --config webpack.config.js --mode production",
	// use webpack.config.js for building production 
	// normally, as configured in 'webpack.config.js'
	// new build is created within new 'dist' directory
  },
// ...
```

## 8. Load plugins and loaders
We need to install CSS (or SASS if needed) loaders via `npm` as well.
```bash
npm install style-loader css-loader
# for file loaders (public images etc)
npm install --save-dev file-loader
```
```jsx
// within 'webpack.config.js', module -> rules
// ...
{
	test: /\.css$/,
	use: ["style-loader", "css-loader"],
}, {
	test: /\.png|svg|jpg|gif$/,
	use: ["file-loader"],
}, 
// ...
```

## 9. batch-script for simplicity
```bash
#!/bin/bash
npm install react react-dom
npm install @babel/core @babel/preset-env @babel/preset-react babel-loader
npm install webpack webpack-cli webpack-dev-server 
npm install html-webpack-plugin
```
