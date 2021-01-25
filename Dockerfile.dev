FROM ruby:2.5.7
RUN mkdir /temp
WORKDIR /temp
ADD . /temp
RUN gem install bundler
RUN bundler install
RUN mkdir /app
WORKDIR /app
EXPOSE 3000
