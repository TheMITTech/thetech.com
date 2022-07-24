FROM ruby:2.7-bullseye

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

RUN set -ex \
    \
    && apt-get update \
    && apt-get install -y \
        libmagickwand-dev \
        imagemagick \
        libmariadb-dev \
        libpq-dev \
	nodejs \
        npm

RUN gem install bundler:1.17.3
RUN npm version
RUN npm install -g yarn
RUN yarn install

COPY Gemfile Gemfile.lock ./
RUN bundle install --path /usr/src/bundle

COPY . .

CMD ["./docker/web/entrypoint.sh", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
