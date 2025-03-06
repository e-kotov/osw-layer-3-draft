# Instructions


## Run this repository in a web browser using Binder. Push the button \>\> [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/e-kotov/osw-layer-3-draft/HEAD?urlpath=rstudio)

# Initial sequence of actions before building the Docker image

``` r
# check the current repos, it will probably be default CRAN or cran.rstudio.com
getOption("repos")
# change the repos to Posit Package Manager
options(repos = "https://packagemanager.posit.co/cran/2025-02-28")
# double check that it is set
getOption("repos")

# init renv
renv::init()

# RESTART R SESSION

# double check that repos is still set as it was
getOption("repos")

# set some renv settings to force it to use Posit Package Manager
# this will allow to install pre-built binaries for most packages
# and therefore save a lot of time during the building of the Docker container image
renv::settings$ppm.enabled(value = TRUE)
renv::settings$snapshot.type(value = "all")

# install targets
# visNetwork (for visualisation of the workflows)
# qs2 (for targets snapshots)
# also styler (for linting the code)
renv::install("targets", "visNetwork", "qs2", "styler", prompt = FALSE)

# activate targets
targets::use_targets()

# WRITE A TARGETS PIPELINE

# install some packages that will be used in the project by the analysis scripts
renv::install(c("osfr", "tidyverse", "fs"), prompt = FALSE)

# try visualising the targets workflow
targets::tar_visnetwork()

# check packages snapshot status with renv
renv::status()

# snapshot to freeze package versions
renv::snapshot()

# install any missing packages if snapshot complains
renv::install(c("cpp11", "progress"), prompt = FALSE)

# snapshot again
renv::snapshot()

# double check the status
renv::status()
```

# Prepare the Docker image

## Build the Docker image locally

``` bash
docker build --platform linux/amd64 -f Dockerfile4build/Dockerfile -t r442 .
```

## Test run the Docker image locally

``` bash
docker run --platform linux/amd64 -it --rm -v "$(pwd):/home/rstudio" -p 8888:8888 r442
```

## Tag the Docker image before pushing it to the container registry

``` bash
docker tag r442 ghcr.io/e-kotov/osw-layer-3-draft:latest
```

## Push the image to the container registry

``` bash
docker push ghcr.io/e-kotov/osw-layer-3-draft:latest
```

## Save the Docker image to a file

``` bash
docker save -o myimage.tar r442
```
