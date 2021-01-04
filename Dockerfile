FROM ruby:2.5.7
RUN mkdir /bot
WORKDIR /bot
COPY . /bot
RUN gem install bundler -v 1.16.6
RUN bundler install
RUN useradd -m bot
RUN chown -R bot:bot /bot
USER bot
CMD ["ruby", "app.rb"]
