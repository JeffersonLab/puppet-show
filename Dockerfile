# https://github.com/puppeteer/puppeteer/tree/main/docker

FROM ghcr.io/puppeteer/puppeteer:23

USER root

# If running Docker >= 1.13.0 use docker run's --init arg to reap zombie processes, otherwise
# uncomment the following lines to have `dumb-init` as PID 1
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init
ENTRYPOINT ["dumb-init", "--"]

COPY . /home/pptruser/puppet-show
WORKDIR /home/pptruser/puppet-show

RUN chown -R pptruser:pptruser /home/pptruser/puppet-show

USER pptruser

# Install puppet-show deps from package-lock.json
RUN npm ci .

EXPOSE 3000

CMD ["node", "bin/www"]

# Now navigate web browser to http://localhost:3000/puppet-show/
