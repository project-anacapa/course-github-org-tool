FROM ruby:2.3.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /anacapa
WORKDIR /anacapa
ADD Gemfile /anacapa/Gemfile
ADD Gemfile.lock /anacapa/Gemfile.lock
RUN bundle install
ADD . /anacapa
RUN bundle exec rake assets:precompile
