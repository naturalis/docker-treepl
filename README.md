# docker-treepl

This repo contains a snapshot of [treePL](https://github.com/blackrim/treePL)
and a [Dockerfile](Dockerfile) that builds it into an image.



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
docker run -v `pwd`/example:/input naturalis/docker-treepl /input/test.cppr8s
```

## Developer section 

The following sections are strictly here for people who are in the process
of making the existing Dockefile less bad. As a quick reminder, this
would probably entail updating the package installs and build instructions
in the Dockerfile, then building, then testing (i.e. 'Running an analysis'),
and pushing any improvements to the resulting image into the docker hub.

### Building the Dockerfile

The basic procedure is as follows, assuming you wish to build from source:

```{bash}
docker build --tag naturalis/docker-treepl .
```

### Pushing the rebuilt image to docker hub

If the image has improved it might make sense to push that to docker hub.
Assuming you are part of the Naturalis organization and have your 
credentials already set up, this would be (after building):

```{bash}
docker push naturalis/docker-treepl
```
