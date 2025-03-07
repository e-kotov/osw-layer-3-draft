# Instructions


## Run this repository in a web browser using Binder. Push the button \>\> [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/e-kotov/osw-layer-3-draft/HEAD?urlpath=rstudio)

# Initial sequence of actions before building the Docker image

``` r
# check the current repository for pacakge installation, it will probably be default CRAN or cran.rstudio.com
getOption("repos")

# change the `repos` to Posit Package Manager, so that we can free the state of CRAN mirror even if we install more packages later
# we can change it later, when the project is done
# we may also just use options(repos = "https://packagemanager.posit.co/cran/latest") and then later freeze the date
options(repos = "https://packagemanager.posit.co/cran/2025-02-28")

# double check that it is now set corretly to Posit Package Manager
getOption("repos")

# install renv
install.packages("renv")

# initialise renv in the current directory
renv::init()
# this creates renv folder with activate.R that is always exectuted on R session start in the current project working directory
# the activate.R is executed on every run in this working directory because it is added to the .Rprofile in the project directiry

# RESTART R SESSION
# now `renv` takes over several functions (e.g. install.packages, remove.packages) and also overwrites the location for package installs
# now all packages will be installed into local cache in user profile and then will be sym-linked into the project directory under `renv` folder

# double check that repos is still set as it was
getOption("repos")

# set some renv settings to force it to use Posit Package Manager

# this will allow to install pre-built binaries for most packages when we use Linux
# and therefore save a lot of time during the building of the Docker container image
# This line below adds the value to `renv/settings.json`.
# Overall, it does not seem to have an effect, but better set it. We will have to use the specific `repos` in the Dockerfile just to be sure
renv::settings$ppm.enabled(value = TRUE)

# this forces `renv` to save all packages that we install while in this project directory to the `renv.lock` file which will later be used for re-installing them in the container. Otherwise, renv tries to scan the .R files in the working directory to detect which packages are actually used, but that does NOT work well enough
renv::settings$snapshot.type(value = "all")

# also manually add
# options(renv.config.pak.enabled = TRUE)
# to .Rprofile
# this will enable `pak` R package installation backend, which downloads and installs the pacakges in parallel
# this will significantly speed up package installation in the current session
# but it will also speed up the creation of the Docker container later

# Now install targets
# visNetwork (for visualisation of the workflows)
# qs2 (for targets snapshots in efficient format `qs` that's better than `rds`)
# also styler (for linting the code)
renv::install("targets", "visNetwork", "qs2", "styler", prompt = FALSE)
# you may also use install.packages(), as renv intercepts it and does the job, but I use renv::install just to be on the safe side

# NOW we are just goint to setup our targets workflow

# activate targets
targets::use_targets() # it will also ask you to install 'usethis', agree to that

# WRITE A TARGETS PIPELINE
# e.g. create any functions you need in the `R` folder in differnt R scripts and setup the workflow in the `_targets.R` file

# e.g. install some packages that will be used in the project by the analysis scripts
renv::install(c("osfr", "tidyverse", "fs"), prompt = FALSE)

# try visualising the targets workflow
targets::tar_visnetwork()

# rinse and repeat for any new targets steps and package that you need for them

# assuming you are done with the workflow, now is the time to freeze our package installations
# check packages snapshot status with renv
renv::status()

# you may get warnings that you need to install some more dependencies, please do that
# e.g. install any missing packages if snapshot complains
renv::install(c("cpp11", "progress"), prompt = FALSE)

# snapshot to freeze package versions
renv::snapshot()

# double check the status
renv::status()
# it shoud print `No issues found -- the project is in a consistent state.`
```

# Prepare the Docker image

See the [Dockerfile4build/Dockerfile](Dockerfile4build/Dockerfile) for
details.

## Build the Docker image locally

Launch Docker or whichever drop-in replacement for it you use and run in
the root of the working directory.

``` bash
docker build --platform linux/amd64 -f Dockerfile4build/Dockerfile -t r442 .
```

You can use any other name/tag instead of `r442`.

The dot `.` at the end means that the base directory for the docker
builder process is the current project working directory, so all paths
in the [Dockerfile4build/Dockerfile](Dockerfile4build/Dockerfile) will
be interpreted relative to this folder, so it is important to run this
from the current project working directory, otherwise you need to change
paths accoridngly in the
[Dockerfile4build/Dockerfile](Dockerfile4build/Dockerfile).

To stop the container, press `Ctrl+C` in the terminal.

## Test run the Docker image locally

``` bash
docker run --platform linux/amd64 -it --rm -v "$(pwd):/home/rstudio" -p 8888:8888 r442
```

After running this, look for the link in the terminal output that has
127.0.0.1 in it and open it in a web browser. You will get Jupyter Lab
interface, from which you can start RStudio.

This will bind the current working dir into the container. Once there,
make sure you comment out the `source("renv/activate.R")` line in the
`.Rprofile` file and restart the R session so that the R session in the
container looks for the packages that are already installed in it and
does not try to install everything from online locaitons again.

Also test run without binding the local folder:

``` bash
docker run --platform linux/amd64 -it --rm -p 8888:8888 r442
```

You will be able to check that all the packages we used are already
installed in the container.

## Optional steps to push the local container to the container registry, if you have it set up

### Tag the Docker image before pushing it to the container registry

``` bash
docker tag r442 ghcr.io/e-kotov/osw-layer-3-draft:latest
```

It could be hub.docker.com or any other registry too.

### Push the image to the container registry

``` bash
docker push ghcr.io/e-kotov/osw-layer-3-draft:latest
```

By default, this container image will be private. To make it public go
to your packages (e.g. https://github.com/e-kotov?tab=packages ) and
make it public in the settings of a specific ‘package’. Otherwise, you
will not be able to use it with mybinder.org, as it can only access
public container images.

## Save the Docker image to a file

``` bash
docker save -o ../myimage.tar r442
```

This should put the container image file one level above your current
working dir, feel free to set any path here.

The tar file can now be stored in Zenodo or similar in case container
registry you use goes down in the future, or starts charging for storage
or deletes your container image.

## Load the Docker image from tar file

Later, you can load the image back

``` bash
docker load -i ../myimage.tar
```

Then

``` bash
docker images
```

Find the image name, it should be the same tag you used, e.g.:

``` bash
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
r442         latest    abcdef123456   2 hours ago   500MB
```

So now as before you can use this tag to run the container, therefore
you are not dependent on a remote container registry.

# Create a Dockerfile for running the repo in mybinder.org

1.  See [Dockerfile](Dockerfile) for details.
2.  See the code for the `launch in Binder` button in the source code of
    this readme at the top.
