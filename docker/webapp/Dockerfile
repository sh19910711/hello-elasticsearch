FROM ruby:2.6.5

RUN mkdir -p /webapp
ADD Gemfile /webapp
ADD Gemfile.lock /webapp

WORKDIR /webapp
RUN bundle install -j4