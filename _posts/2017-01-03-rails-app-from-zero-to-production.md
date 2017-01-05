---
layout: post
title: Rails app from zero to production in 1 hour [Part 1]
tags:
  - rails
  - rubocop
  - continuous integration
  - continuous deployment
  - rapid prototyping
---

New rails applications can be created quickly with `rails new [name]` when the defaults suit you. To go from empty application with couple scaffolds to production-ready application with your own database, continuous integration, continuous deployments, monitoring etc. will takes time. I collected together steps that I usually do to formalise the process and to make it easier.

First part goes over the main steps of how I like to approach quickly getting rails applications up and running. Second part deals with monitoring the application.

## General process

Usually my process goes as follows:

1. Create new rails application
2. Develop some functionality using TDD
3. Deploy & monitor it.

Then rinse & repeat steps 2 & 3

The issue is that both steps require some initial setup before the actual work can be started. Setting up testing, continuous integration, deployment & monitoring can take at least couple hours. This can discourage and reduce the enthusiasm greatly when starting on a new idea. I write up how speed up these and hopefully it helps me and others to try out new ideas more easily in the future.

### Create new rails application

While the rails defaults work for many, I found that I make small changes in many projects. These include:

- using PostgreSQL as database
- using RSpec for testing
- using some CSS framework (Bootstrap usually)
- configuring the RSpec certain way

To automate these steps, I created the [Speedrail](https://github.com/madis/speedrail) project. It allows me to get the new rails app to look excactly as I want it to.

I have also a global Rails configuration set up (at `$HOME/.railsrc`):

```
--skip-test
--skip-bundle
--database=postgresql
--skip-keeps
```

Usage:

```bash
$ git clone git@github.com:madis/speedrail.git
$ gem install rails
$ rails new botista --template speedrail/template.rb
```

To stop RSpec and rails from generating some test files I add to `config/application.rb` inside Application class body:

```ruby
config.generators do |generate|
  generate.helper false
  generate.assets false
  generate.view_specs false
end
```

Inside the project I use [Overcommit](https://github.com/brigade/overcommit) to run rubocop before every commit to make sure code has uniform look throughout the project. Some generated files have offenses but most of them are easy to fix. See overcommit documentation for more info on how to set it up. Basically it is:

```bash
gem install overcommit
overcommit --install
overcommit --sign
```

### Develop functionality

I prefer outside-in development. So I start with high level acceptance test (or feature spec or integration test, call it as you may). This makes sure that user can actually use the app.

This can look like:

```ruby
require 'rails_helper'

feature 'Landing page' do
  it 'welcomes user' do
    visit '/'
    expect(page).to have_content 'Welcome to speedrail'
  end
end
```

And the implementation to pass it:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def welcome
    render plain: 'Welcome to speedrail'
  end
end
```

After the initial test passes it's time to commit. Whwn you installed overcommit, then rubocop will be run before committing and you probably have to resolve the offenses.

### Deploy

I want to get the application out to the world as soon as possible while still following the good practices. The application should have:

1. Continuous integration running the tests
2. Continous delivery
3. App monitoring

#### Continuous integration

There are many options available, such as [Jenkins](https://jenkins.io/), [Travis](https://travis-ci.org/), [CircleCi](https://circleci.com/) and others. I have found CircleCi to be very easy to integrate and their free plan gives 1500 build minutes, which is plenty to get started.

CircleCi integration consists just picking your project from their interface and you should be done. I noticed sometimes my CircleCi build failed with ` Could not find 'bundler' (>= 0.a) among 6 total gem(s)`. It is solved by manually installing bundler before the build. Create `circle.yml` at the root of your project with:

```yaml
dependencies:
  pre:
    - gem install bundler
```

After that it is useful to add badge to repository's readme so that curious onlookers can see whether the tests are passing.

#### Continuous delivery

A very clear step-by-step tutorial can be found at digitalocean [Deploying a Rails App on Ubuntu 14.04 with Capistrano, Nginx, and Puma](https://www.digitalocean.com/community/tutorials/deploying-a-rails-app-on-ubuntu-14-04-with-capistrano-nginx-and-puma)

Server side steps:

1. Create new server
2. Install nginx
3. Install database
4. Install ruby
  - when `rvm install 2.3.3` fails with `Error running 'requirements_debian_update_system ruby-2.3.3'` see the instructions from [stackoverflow](http://stackoverflow.com/questions/23650992/ruby-rvm-apt-get-update-error). Basically `sudo add-apt-repository --remove ppa:{failing ppa}`
  - install bundler `gem install bundler` when done
5. Install other dependencies
  - `sudo apt-get install libpq-dev` to avoid getting `Can't find the 'libpq-fe.h header` when installing `An error occurred while installing pg (0.19.0), and Bundler cannot continue.`
  - *Uglifier* gem needs JavaScript runtime. One way to get it is by installing Node.js.
  - E.g. `curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash`
  - and `nvm install v6.9.2`

Local steps:

1. Set up ssh-agen key forwarding so you don't have to generate & register separate key to
  - `ssh-agent`
  - `ssh-add ~/.ssh/id_rsa`
  - suitable for personal projects. For multiple-contributors, you probably want to have separate credentials for deployer.
2. Set up Capistrano
3. Deploy with `capi`

Some issues I encountered and how to solve them:

1. Bundler gem not found. Log into server and install bundler to global gemset: `rvm gemset use global` and `gem install bundler`
2. Bundle install runs out of memory.
  - Servers when SSD-s usually disable Swap (virtual memory)
  - Can happen when installing dependencies or precompiling assets. Happened to me on 512MB server
  - Solution is to enable swap: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04
  - To be a good citizen, reduce the swap usage by [Adjusting the swappiness property](https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04#tweak-your-swap-settings)
3. Database needs to be created for `rake db:migrate to succeed`
  - NB: Following can be good enough for prototyping and small team usage. It uses Postgres *peer* authentication - meaning the database use has to have same name as the system user.
  - `sudo -i -u postgres`
  - `createuser --createdb --superuser deployer`
  - `createdb botista`
  - [More information on peer vs password authentication](http://stackoverflow.com/questions/18664074/getting-error-peer-authentication-failed-for-user-postgres-when-trying-to-ge)
4. Secrets file (config/secrets.yml) has to be created & linked on production
  - there are other options, like reading it from environment variable
  - this is not suitable when you deploy multiple apps on the same machine
  - old school approach: symlink
