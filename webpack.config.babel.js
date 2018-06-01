import path from 'path';
import webpack from 'webpack';
import ExtractTextPlugin from 'extract-text-webpack-plugin';

const isProduction = process.env.NODE_ENV === 'production';

export default {
  entry: {
    application: './assets/javascripts/application.js',
  },
  output: {
    path: path.join(__dirname, 'public/assets/'),
    publicPath: '/assets/',
    filename: '[name].js',
    chunkFilename: '[id].js',
  },
  module: {
    loaders: [
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: {
            loader: 'css-loader',
            options: {
              minimize: true,
            },
          },
        })
      },
      {
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: [
            {
              loader: 'css-loader',
              options: {
                minimize: true,
              },
            },
            {
              loader: 'sass-loader',
            },
          ],
        })
      },
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
      },
      {
        test: /\.woff2?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        // Limiting the size of the woff fonts breaks font-awesome ONLY for the extract text plugin
        // loader: "url?limit=10000"
        loader: 'url-loader',
      },
      {
        test: /\.(ttf|eot|svg)(\?[\s\S]+)?$/,
        loader: 'file-loader',
      },
      {
        test: /bootstrap-sass\/assets\/javascripts\//,
        loader: 'imports-loader?jQuery=jquery',
      },
    ],
  },
  plugins: [
    new ExtractTextPlugin("[name].css"),
    new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /ja/),
    ...(isProduction ? [
      new webpack.DefinePlugin({
        'process.env': {
          NODE_ENV: JSON.stringify(process.env.NODE_ENV),
        },
      }),
      new webpack.optimize.UglifyJsPlugin({
        compress: {
          warnings: false,
        },
      }),
      new webpack.optimize.OccurrenceOrderPlugin()
    ] : []),
  ],
  resolve: {
    alias: {
      vue: 'vue/dist/vue.min.js', // TODO: use runtime-only build
    },
  },
};
