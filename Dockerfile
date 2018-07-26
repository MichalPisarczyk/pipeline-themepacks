FROM essjayhch/ruby:2.5.1

RUN mkdir /app

WORKDIR /app

COPY ./Gemfile* /app/
RUN bundle install --without nothing

ADD . /app

CMD rake 'run[*]'
