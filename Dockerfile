FROM livelink/web-prism:latest

RUN mkdir /pipeline-app

WORKDIR /pipeline-app

COPY ./Gemfile* /pipeline-app/
RUN bundle install --without nothing

ADD . /pipeline-app

CMD rake 'run[*]'
