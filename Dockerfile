FROM ruby:3.0.3

ENV PATH /root/.yarn/bin:$PATH
ENV RAILS_ENV production
ENV NODE_ENV production
ENV SECRET_KEY_BASE not_set
ENV OLD_AWS_SECRET_ACCESS_KEY not_set
ENV OLD_AWS_ACCESS_KEY_ID not_set

ARG build_without
ARG rails_env
RUN apt-get update -qq && apt-get install -y binutils curl git gnupg cmake python python-dev postgresql-client supervisor tar tzdata
RUN apt-get install -y apt-transport-https apt-utils
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn
RUN mkdir /sample_rails_app
COPY . /sample_rails_app
WORKDIR /sample_rails_app

RUN gem install bundler -v 2.3.8

RUN bundle install
RUN yarn install

RUN bundle exec rake assets:precompile

# Add a script to be executed every time the container starts.
# COPY entrypoint.sh /usr/bin/
# RUN chmod +x /usr/bin/entrypoint.sh
# ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]