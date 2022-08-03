FROM ruby:3.0.4

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install
COPY . .
EXPOSE 9091
CMD ["bundle", "exec", "rackup", "-d", "-p", "9091", "-o", "0.0.0.0"]