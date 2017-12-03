const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const UglifyJSPlugin = require('uglifyjs-webpack-plugin');

const PRODUCTION = 'PRODUCTION';
const environment = process.env.ENV || PRODUCTION
const isProd = environment === PRODUCTION
const elmLoader = [{
  loader: 'elm-webpack-loader',
  options: {
    debug: !isProd,
  }
}];

const cssExtract =new ExtractTextPlugin('bundle.min.css');
const elmLoaderDev = [{ loader: 'elm-hot-loader' }, ...elmLoader];

const cssLoader = cssExtract.extract({
  fallback: 'style-loader',
  use: [
    'css-loader',
    'elm-css-webpack-loader'
  ]
});
const cssLoaderDev = [
  'style-loader',
  'css-loader',
  'elm-css-webpack-loader'
];

const uglify = new UglifyJSPlugin({ sourceMap: !isProd });

module.exports = {
  entry: {
    app: ["./src/index.js"]
  },
  output: {
    path: path.resolve(__dirname, './build'),
    publicPath: "/",
    filename: "bundle.min.js"
  },
  resolve: {
    extensions: ['.js', '.elm'],
    modules: ['node_modules']
  },
  plugins: isProd ? [cssExtract, uglify] : [cssExtract],
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/, /Stylesheets\.elm$/],
        use: isProd? elmLoader : elmLoaderDev
      }, {
        test: /Stylesheets\.elm$/,
        use: isProd? cssLoader : cssLoaderDev
      }
    ]
  },
  devServer: {
    inline: true,
    contentBase: './src'
  }
};
