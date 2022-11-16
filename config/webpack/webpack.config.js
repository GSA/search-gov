const { webpackConfig, merge } = require('shakapacker');
const ForkTSCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");

const customConfig = {
  plugins: [new ForkTSCheckerWebpackPlugin()],
  resolve: {
    extensions: ['.css']
  }
};

module.exports = merge(webpackConfig, customConfig);
