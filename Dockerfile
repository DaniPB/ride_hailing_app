FROM ruby:2.7.1

RUN apt-get update -qq && apt-get install -y postgresql-client

ENV APP_HOME /ride_hailing_app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
ADD Gemfile.lock* $APP_HOME/

RUN apt-get update

ADD . $APP_HOME

EXPOSE 8080

ENTRYPOINT ["./script/docker_entrypoint"]
