FROM ruby:2.6.5-buster

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

RUN set -ex \
    \
    && apt-get update \
    && apt-get install -y \
        libmagickwand-dev \
        imagemagick \
        libmysqlclient-dev \
        libpq-dev

COPY Gemfile Gemfile.lock ./
RUN bundle install --path /usr/src/bundle

COPY . .

CMD ["./docker/web/entrypoint.sh", "rails", "server", "-p", "3000"]
