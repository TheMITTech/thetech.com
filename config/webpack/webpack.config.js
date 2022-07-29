const { webpackConfig, merge } = require('shakapacker');
const customConfig = {
  resolve: {
    extensions: ['.jsx', '.css', '.scss', '.jsx.coffee']
  },
};

module.exports = merge(webpackConfig, customConfig);