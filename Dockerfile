FROM ruby:2.5.3
WORKDIR /app
COPY Gemfile /app
COPY bot.rb /app
RUN mkdir -p /data/se 
COPY se/ /data/se
RUN apt-get update && apt-get install -y \
    locales \
    locales-all \
    libopus-dev \
    ffmpeg \
    libopus0 \
    libsodium-dev
ENV LANG ja_JP.UTF-8
RUN bundle install --path vendor/bundle
CMD ["bundle", "exec", "ruby", "bot.rb"]
