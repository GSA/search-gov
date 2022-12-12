module.exports = {
  plugins: [
    require('postcss-import'), // eslint-disable-line global-require
    require('postcss-flexbugs-fixes'), // eslint-disable-line global-require
    require('postcss-preset-env')({ // eslint-disable-line global-require
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 3
    })
  ]
};
