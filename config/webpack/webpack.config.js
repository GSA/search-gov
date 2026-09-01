const { generateWebpackConfig, merge } = require('shakapacker-webpack');
const ForkTSCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");

const customConfig = {
  plugins: [new ForkTSCheckerWebpackPlugin()],
  resolve: {
    extensions: ['.css']
  }
};

module.exports = merge(generateWebpackConfig(), customConfig);
