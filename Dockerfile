FROM node:10.15.3-alpine AS node

RUN mkdir -p /app
WORKDIR /app

ADD package.json package.json
ADD package-lock.json package-lock.json

RUN npm install

ADD .babelrc .babelrc
ADD .bootstraprc .bootstraprc
ADD webpack.config.js webpack.config.js
ADD webpack.config.babel.js webpack.config.babel.js
ADD assets assets

RUN npm run build

FROM ruby:2.6.3

ENV DOCKERIZE_VERSION v0.6.1

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    wget \
 && wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 && rm -rf /var/lib/apt/lists/*

RUN gem install bundler

RUN mkdir -p /app
WORKDIR /app

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

ADD . .

COPY --from=node /app/public/assets /app/public/assets

EXPOSE 11000
CMD ["bundle", "exec", "unicorn", "-c", "unicorn.conf", "-E", "deployment"]
