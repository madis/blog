---
layout: post
title: Rails app from zero to production in 1 hour [Part 2]
tags:
  - rails
  - monitoring rails app
  - capistrano slack integration
  - securing rails app
  - https certificates
---

[Part 1](2017/01/new-rails-app-from-zero-to-production/) described how I create and deploy new Rails applications quickly with preconfigured preferences. In the this part I will describe how to set up https for rails production with free ssl certificates, integrate rails app with Slack and how to put in place monitoring with Sentry.

## Get SSL certificates for HTTPS

1. Install letsencrypt: `sudo apt-get install letsencrypt`
2. Get the certificates: `sudo letsencrypt certonly --webroot -w /var/www/html -d botista.xyz`
3. Configure nginx to use the certs

```nginx
upstream puma {
  server unix:///home/deployer/apps/botista-production/shared/tmp/sockets/botista-puma.sock;
}

server {
  listen 80;
  listen [::]:80;
  server_name botista.io;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl;
  server_name botista.io;

  listen [::]:443 ssl;
  ssl_certificate /etc/letsencrypt/live/botista.io/cert.pem;
  ssl_certificate_key /etc/letsencrypt/live/botista.io/privkey.pem;

  root /home/deployer/apps/botista-production/current/public;
  access_log /home/deployer/apps/botista-production/current/log/nginx.access.log;
  error_log /home/deployer/apps/botista-production/current/log/nginx.error.log info;

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  try_files $uri/index.html $uri @puma;
  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;

    proxy_pass http://puma;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 10M;
  keepalive_timeout 10;
}
```

## Integrate with Slack

I have seen the following pattern in various places: whenever there is a deploy,
  - People ask in chat whether it's ok to deploy
  - They will announce when they start
  - Then they'll say that they are finished

Most of this can reliably be reliably automated with Capistrano+Slack integration.

Steps:

1. Create [incoming webhook](https://api.slack.com/incoming-webhooks) url for the application
2. Add [slackistrano](https://github.com/phallstrom/slackistrano) to your project


If you don't want to share the slack incoming webhook url (e.g. in public projects), it's easy to use [rvm's environment variable loading](http://trevmex.com/post/58452818690/they-did-it-rvm-can-now-store-environment) by creating `.ruby-env` to the project's root with `SLACK_OPS_WEBHOOK_URL=https://hooks.slack.com/services/<your token>` and reading the url from environment variable in `deploy.rb` like:`set :slackistrano, channel: '#ops', webhook: ENV['SLACK_OPS_WEBHOOK_URL']`

I found easiest to load the `.ruby-env` file with [Dotenv gem](https://github.com/bkeepers/dotenv) by adding the following to `config/application.rb`:

```ruby
require 'dotenv'
Dotenv.load('.ruby-env')
```

When using capistrano, then the release folder changes with each deploy, so adding the following task helped me:

```ruby
  desc 'Copy environment variables file to current'
  task :set_up_environment_variables do
    on roles(:all) do |_|
      env_vars_for_stage = "#{ENV['PROJECT_REMOTE_CONFIGS']}/#{fetch(:stage)}/ruby-env"
      ruby_env_in_current = "#{fetch(:release_path)}/.ruby-env"
      upload! env_vars_for_stage, ruby_env_in_current
    end
  end
```

## Setting up monitoring

I have used [sentry.io](https://sentry.io) with great success. They have clear instruction on how to set up [Sentry for rails](https://sentry.io/for/rails/)
