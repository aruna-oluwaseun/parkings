
FROM node:10.21-slim as node
FROM ruby:2.7-bullseye as build-base



COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /opt/yarn-v1.22.4 /opt/yarn-v1.22.4

RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs
RUN ln -s /opt/yarn-v1.22.4/bin/yarn /usr/local/bin/yarn
RUN ln -s /opt/yarn-v1.22.4/bin/yarnpkg /usr/local/bin/yarnpkg

# Use archived Debian repos because stretch is EOL
RUN apt-get update -y && apt-get install -y \
    gcc \
    make \
    g++ \
    postgresql-client \
    python \
    libpq-dev \
    imagemagick \
    curl \
    wget \
    gnupg \
    git \
  && rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1

WORKDIR /opt/parkings

# not install docs
# not install docs
RUN echo "install: --no-rdoc --no-ri" >> ~/.gemrc
RUN echo "update:  --no-rdoc --no-ri" >> ~/.gemrc

# Upgrade RubyGems so it’s compatible with newer gems like ffi
RUN gem update --system 3.3.22

RUN bundle config --global jobs 3

COPY Gemfile ./
RUN bundle install



COPY package.json yarn.lock ./
RUN yarn install
