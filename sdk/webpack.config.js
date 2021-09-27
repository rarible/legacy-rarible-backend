const path = require('path');
const NodePolyfillPlugin = require("node-polyfill-webpack-plugin");

module.exports = [
  {
    entry: path.resolve(__dirname, "./main/rarible.ts"),
    module: {
      rules: [
        {
          test: /\.tsx?$/,
          use: path.resolve(__dirname, "node_modules/ts-loader"),
          exclude: /node_modules/,
        },
      ],
    },
    resolve: {
      extensions: ['.tsx', '.ts', '.js'],
    },
    mode: 'production',
    output: {
      filename: 'rarible-web.js',
      library: { name : 'rarible', type: 'var' },
      path: path.resolve(__dirname, 'dist'),
    },
    plugins: [
      new NodePolyfillPlugin()
    ],
    performance: {
      hints: false,
    },
  },

  {
    entry: path.resolve(__dirname, "./providers/temple/temple_provider.ts"),
    module: {
      rules: [
        {
          test: /\.tsx?$/,
          use: path.resolve(__dirname, "node_modules/ts-loader"),
          exclude: /node_modules/,
        },
      ],
    },
    resolve: {
      extensions: ['.tsx', '.ts', '.js'],
    },
    mode: 'production',
    output: {
      filename: 'rarible-temple.js',
      library: { name : 'rarible_temple', type: 'var' },
      path: path.resolve(__dirname, 'dist'),
    },
    plugins: [
      new NodePolyfillPlugin()
    ],
    performance: {
      hints: false,
    },
  }
]
