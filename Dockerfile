# Inspired by: https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md

FROM node:lts-slim

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# If running Docker >= 1.13.0 use docker run's --init arg to reap zombie processes, otherwise
# uncomment the following lines to have `dumb-init` as PID 1
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init
ENTRYPOINT ["dumb-init", "--"]

RUN groupadd -r pptruser  \
    && useradd -r -g pptruser pptruser \
    && mkdir -p /home/pptruser/puppet-show \
    && chown -R pptruser:pptruser /home/pptruser

# Corporate SSL proxy
RUN npm config set strict-ssl false -g

# Run everything after as non-privileged user.
USER pptruser

WORKDIR /home/pptruser/puppet-show

RUN npm install puppet-show

EXPOSE 3000

CMD ["node", "node_modules/puppet-show/bin/www"]

# Now navigate web browser to http://localhost:3000/puppet-show/
