const path = require('path');

module.exports = {
  entry: {
    app: ["./src/index.js"]
  },
  output: {
    path: path.resolve(__dirname, './build'),
    publicPath: "/assets/",
    filename: "bundle.js"
  },
  resolve: {
    extensions: ['.js', '.elm'],
    modules: ['node_modules']
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: [/elm-stuff/, /node_modules/, /\.elm$/],
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['env']
          }
        }
      }, {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/, /Stylesheets\.elm$/],
        use: [{
          loader: 'elm-hot-loader'
        }, {
          loader: 'elm-webpack-loader',
          options: {
            debug: true,
          }
        }]
      }, {
        test: /Stylesheets\.elm$/,
        use: [
          'style-loader',
          'css-loader',
          'elm-css-webpack-loader'
        ]
      }
    ]
  },
  devServer: {
    inline: true
  }
};
