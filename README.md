# docker-treepl

This repo contains a snapshot of [treePL](https://github.com/blackrim/treePL)
and a [Dockerfile](Dockerfile) that builds it into an image. The purpose of 
this is to hide some of the installation challenges that treePL users face,
and to make the program more widely available across platforms that support
[docker](https://www.docker.com/), albeit with some overhead.

## Installation

The dockerized version of treePL is available on docker hub as the image
[naturalis/docker-treepl](https://hub.docker.com/r/naturalis/docker-treepl). You
can install this locally using the following command:

```{bash}
docker pull naturalis/docker-treepl
```

Once this has downloaded successfully you should be all set to 
run an analysis.

## Running an analysis

treePL requires a configuration file and a tree file. This is a bit nasty
with Docker because paths in the host and in the image are not the same
thing. To get around this, we're going to map a host folder into the image,
and then refer to the folder inside the image in our configuration file.

You can see in [example/test.cppr8s](example/test.cppr8s) how we refer to
`/input/test.tre` on line one. I.e. the [example/test.tre](example/test.tre) 
file is going to reside inside the `/input` folder from the perspective of the
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

### Deployment tips and tricks

I developed this docker image in order to have treePL available on a shared
resource where I did not want to pollute the environment with additional 
libraries and updates to the dynamic library paths for all users. So, instead,
treePL is now available as a `docker run` command. That's all well and good,
except that it is not such a great idea if all users have access to all docker
commands, because that would mean that they can pull/push/run anything. The
default installation of docker on Ubuntu also makes this clear by making
docker a `sudo` command.

The way I set this up was to have a wrapper script that looks on the outside
as if it is the actual treePL command (i.e. `treePL <infile>`) but that 
dispatches to `docker run` under the hood. I then added the wrapper script
to the list of allowed commands with `visudo`. 

So, all the people inside group `researchers` have access to the command, as
per the sudoers file:

```
# Allow members of group researchers to execute docker run (but not pull, etc.)
%researchers    ALL=(ALL) NOPASSWD: /usr/local/bin/treePL
```

The script has the following privileges (so researchers can't inject other
stuff in there):

```bash
ls -la /usr/local/bin/treePL
-rwxr-xr-x 1 root root 360 Jun 21 11:13 /usr/local/bin/treePL
```

And then the script does the dispatching with the following code:

```perl
#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
if ( $< != 0 ) {
	die "This command has to be run with sudo, i.e. 'sudo treePL <infile>'\n";
}
my $cwd = getcwd;
my $infile = shift;
if ( not $infile ) {
	die "This command needs an input file, i.e. 'sudo treePL <infile>'\n";
}
exec("docker run -v ${cwd}:/input -w /input naturalis/docker-treepl ${infile}");
```
