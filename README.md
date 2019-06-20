# docker-treepl

This repo contains a snapshot of [treePL](https://github.com/blackrim/treePL)
and a [Dockerfile](Dockerfile) that builds it into an image.

## Installation

The dockerized version of treePL is available on docker hub as the image
[naturalis/treepl](https://hub.docker.com/r/naturalis/docker-treepl). You
can install this locally using the following command:

```{bash}
docker pull naturalis/docker-treepl
```

Once this has downloaded everything successfully you should be all set to 
run an analysis.

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

Like all invocations of dockerized executables it starts with `docker run`.
The salient point is that we then create an mapping from the ./example folder
(which I here make into an absolute path by prefixing it with the output of
`pwd`) to the /input folder. This mapping is the value of the `-v` argument.
What follows is the fully qualified name of the image (i.e. 
`naturalis/docker-treepl`), which internally launches the treePL executable.
The last argument is the full path to the input file from the perspective
of the image, i.e. `/input/test.cppr8s`.


## Developer section 

The following sections are strictly here for people who are in the process
of making the existing Dockerfile less bad. As a quick reminder, this
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
