---
layout: post
title: Running Elasticsearch in docker container
category: Tech
tags:
  - elasticsearch
  - docker
  - development
---

Running Elasticsearch in docker container should be straightforward, Following the official instructions, I could not establish. Here is how I solved the issue.

Today I decided to do some messing around with Elasticsearch on my machine. I wanted my experiments not to interfere with other developments on the on the same machine so I went with docker installation. Unfortunately the [instructions provided on Dockerhub page](https://hub.docker.com/_/elasticsearch/) were not enough. After running `docker run -d elasticsearch`, the ports were not mapped to *9200* and *9300* respectively. There were multiple threads regarding the issue (e.g. [https://github.com/docker-library/elasticsearch/issues/58]())

The working solution was to run `docker run --rm -p 9200:9200 -p 9300:9300 --name=es elasticsearch:latest -Des.network.host=0.0.0.0`.

Parameter descriptions:

  - `-p xxxx:yyyy` will map the xxx *host machine* port to yyyy port *in container*
  - `--name=[name]` will give the container a name which you can use later to execute commands against (e.g. `docker stop es`)
  - `--rm` will clean up after the container after it is stopped e.g. removing data directory
  - `-Des.network.host=0.0.0.0` has to be after the image name so that the parameters would be passed to the command running inside container
