import path from 'path';
import webpack from 'webpack';
import MiniCssExtractPlugin from 'mini-css-extract-plugin';
import OptimizeCssAssetsPlugin from 'optimize-css-assets-webpack-plugin';

export default (env, argv) => {
  const isProduction = argv.mode === 'production';
  return {
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
      ...(isProduction ? [
        new OptimizeCssAssetsPlugin({
          assetNameRegExp: /\.css$/g,
          cssProcessor: require('cssnano'),
          cssProcessorPluginOptions: {
            preset: ['default', { discardComments: { removeAll: true } }],
          },
          canPrint: true,
        }),
        new webpack.optimize.OccurrenceOrderPlugin(),
      ] : []),
    ],
    resolve: {
      alias: {
        vue: 'vue/dist/vue.min.js', // TODO: use runtime-only build
      },
    },
  };
};
