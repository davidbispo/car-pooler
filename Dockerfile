FROM ruby:3.1.2-slim
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs libsqlite3-dev

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

COPY . .
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
