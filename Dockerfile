FROM public.ecr.aws/docker/library/ruby:3.3.5
ENV TZ=Asia/Tokyo
ARG RUBYGEMS_VERSION=3.5.23

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
RUN set -uex; \
    apt-get update; \
    apt-get install -y ca-certificates curl gnupg default-libmysqlclient-dev; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
     | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    NODE_MAJOR=18; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
     > /etc/apt/sources.list.d/nodesource.list; \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
    apt-get update -qq && apt-get install -y nodejs yarn default-mysql-client vim

WORKDIR /webapp
COPY Gemfile /webapp/Gemfile
COPY Gemfile.lock /webapp/Gemfile.lock

# Update RubyGems
RUN gem update --system ${RUBYGEMS_VERSION} && \
    bundle install

COPY . /webapp

# Update Node modules
RUN yarn install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
# CMD ["rails", "server", "-b", "0.0.0.0"]
CMD ["bin/dev"]
