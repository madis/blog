---
title:  "Serving web application locally over https"
date:   2016-01-08 15:04:23
categories: [Development]
tags: [https web]
---

As the browser vendors are moving towards *https*, it is useful to keep the local development environment on https too. Here are couple simple ways for doing it.

## Prerequisites

First step in getting your page to be served over https is to have certificates. Here's how:

```bash
openssl req -nodes -sha256 -days 365 -newkey rsa:2048 -new -x509 -subj \
"/C=GC/ST=Garbage/L=Collector/O=ProgrammerMan/OU=Codeland/CN=localhost.ssl/emailAddress=me@example.com" \
-keyout localhost.ssl.key -out localhost.ssl.cert
```

> Feel free to change the fields to be better fit for you (e.g. ProgrammerMan, Codeland, etc.)

To view the certificate info use `openssl x509 -in localhost.ssl.cert -noout -text`

## Serve static files over https

Sometimes all you need is to serve some static html/js/css from a folder. Here's how to do it.

1. Install sinatra `gem install sinatra`
2. Use the following start script to start simple web app

`config.ru` file for the simple rack application

```ruby
require 'sinatra'

class Webapp < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/webapp'
end

run Webapp
```

`start` shell script for starting *thin* web server with *ssl*

```bash
thin start -p 3001 --ssl --ssl-key-file ../localhost.ssl.key --ssl-cert-file ../localhost.ssl.cert
```

Now the contents in `webapp` are available from https://localhost.ssl:3001/index.html

### Using nginx

With nginx things are simple. Basically the only directive needed is the `root`. Complete config for getting nginx to serve over https is below:

Notice the mime type definitions. Nginx will use these to send back proper response header (Content-Type). It must be correct because browsers do not render css for example when the content type is wrong (e.g. `text/plain`).

#### Install nginx

Installation depends on your system, but on OS X it's common to use [Homebrew](http://brew.sh/): `brew install nginx`

#### Https using nginx for static files

Below is example config for getting nginx to serve the same *webapp* folder but now over *3002* port. Https is turned on with the *ssl* keyword in *listen* instruction. Also the *ssl_certificate* and *ssl_certificate_key* are important. `start` `stop` and `reload` files are provided for your conveniency. They allow starting the nginx example in self-contained way and isolated in case there is nginx already running on the machine.

```nginx
error_log  error.log;
pid        nginx.pid;

events {
  worker_connections  1024;
}

http {
  # Usually nginx has much more comprehensive list of mime types
  # But to keep the example self contained, here are some essential
  # definitions
  types {
    text/html                             html htm shtml;
    text/css                              css;
    text/xml                              xml;
    image/gif                             gif;
    image/jpeg                            jpeg jpg;
    application/javascript                js;
    image/png                             png;
  }

  server {
    listen              3002 ssl;
    server_name         localhost.ssl;
    ssl_certificate     ../localhost.ssl.cert;
    ssl_certificate_key ../localhost.ssl.key;

    root ../webapp;

    location / {
      autoindex on;
      index index.html;
    }
  }
}

```

Start the nginx with provided config using `./start` and see the result in https://localhost.ssl:3002/index.html
