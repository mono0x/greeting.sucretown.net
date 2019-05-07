import path from 'path';
import webpack from 'webpack';
import MiniCssExtractPlugin from 'mini-css-extract-plugin';

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
    rules: [
      {
        test: /\.css$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
            options: {
              hmr: !isProduction,
            },
          },
          'css-loader',
        ],
      },
      {
        test: /\.scss$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
            options: {
              hmr: !isProduction,
            },
          },
          'css-loader',
          'sass-loader',
        ],
      },
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: [
          'babel-loader',
        ],
      },
      {
        test: /\.woff2?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        // Limiting the size of the woff fonts breaks font-awesome ONLY for the extract text plugin
        // loader: "url?limit=10000"
        use: [
          'url-loader',
        ],
      },
      {
        test: /\.(ttf|eot|svg)(\?[\s\S]+)?$/,
        use: [
          'file-loader',
        ],
      },
      {
        test: /bootstrap-sass\/assets\/javascripts\//,
        use: [
          'imports-loader?jQuery=jquery',
        ],
      },
    ],
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name].css',
    }),
    new webpack.ContextReplacementPlugin(/moment[\/\\]locale$/, /ja/),
    new webpack.EnvironmentPlugin({
      NODE_ENV: 'development',
    }),
    ...(isProduction ? [
      new webpack.optimize.OccurrenceOrderPlugin(),
    ] : []),
  ],
  resolve: {
    alias: {
      vue: 'vue/dist/vue.min.js', // TODO: use runtime-only build
    },
  },
};
