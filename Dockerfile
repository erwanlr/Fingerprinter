FROM ruby:2.7

WORKDIR /usr/src/app

COPY Gemfile ./
RUN bundle install

COPY . .

RUN chmod +x fingerprinter.rb
ENTRYPOINT ["/usr/src/app/fingerprinter.rb"]
CMD ["--help"]
