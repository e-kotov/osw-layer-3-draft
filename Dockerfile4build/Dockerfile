FROM rocker/binder:4.4.2
# the line above instructs Docker to use the https://rocker-project.org/images/versioned/binder.html image as a base. It has preinstalled RStudio, lots of dependencies for spatial packages, and also tidyverse and spatial packages. It also has Jupyter Lab so that you can use it with binder.org

# this is optional, it allows to link the container with a specific repo, so that it would be listed in this repo's `Packages` section on the right side
LABEL org.opencontainers.image.source="https://github.com/e-kotov/osw-layer-3-draft"

# create a temporary project directory in the default container user folder
RUN mkdir -p /home/rstudio/project && \ 
    chown -R rstudio:rstudio /home/rstudio/project
WORKDIR /home/rstudio/project


# Copy the renv-related files from the repository root
COPY --chown=rstudio:rstudio ../renv.lock renv.lock
RUN mkdir -p renv
COPY --chown=rstudio:rstudio ../.Rprofile .Rprofile
COPY --chown=rstudio:rstudio ../renv/activate.R renv/activate.R
COPY --chown=rstudio:rstudio ../renv/settings.json renv/settings.json


# install packages in the default R package library of the container by specifying it in `library` argument
# we also have to set the `repos` even though it is already set in the renv configuration files and lock file, it does not seem to work unless we set the `repos` explicitly here
RUN R -e "renv::restore(library = '/usr/local/lib/R/site-library', repos = 'https://packagemanager.posit.co/cran/2025-02-28')"

# remove the temporary project folder
RUN chmod -R u+w /home/rstudio/project && rm -rf /home/rstudio/project

# just in case, resture the exposed port and init command as in the original rocker binder image
# see source here: https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/binder_4.4.2.Dockerfile
EXPOSE 8888

CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--no-browser"]
