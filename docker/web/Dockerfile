FROM ruby:2.3-jessie

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
RUN bundle install

COPY . .
RUN rm -r docker

COPY docker/web/entrypoint.sh .

CMD ["./entrypoint.sh", "rails", "server", "-p", "3000"]
