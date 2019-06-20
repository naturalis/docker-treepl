# docker-treePL

This repo contains a snapshot of [treePL](https://github.com/blackrim/treePL)
and a [Dockerfile](Dockerfile) that builds it into an image.

## Building the Dockerfile

The basic procedure is as follows, assuming you wish to build from source:

```{bash}
docker build --tag naturalis/docker-treepl .
```

## Running an analysis

treePL requires a configuration file and a tree file. This is a bit nasty
with Docker because paths in the host and in the image are not the same
thing. To get around this, we're going to map a host folder into the image,
and then refer to the folder inside the image in our configuration file.

You can see in [example/test.cppr8s](example/test.cppr8s) how we refer to
`/input/test.tre` on line one. I.e. the [example/test.tre](example/test.tre) 
file is going to reside inside a virtual `/input` folder from the perspective of the
executable (and the same for the configuration file once we do the invocation):

```{bash}
docker run -v `pwd`/example:/input docker-treepl /input/test.cppr8s
```
