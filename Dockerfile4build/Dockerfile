FROM rocker/binder:4.4.2

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


# install packages in the default R package library of the container
# RUN R -e "renv::restore(library = '/usr/local/lib/R/site-library')"
RUN R -e "renv::restore(library = '/usr/local/lib/R/site-library', repos = 'https://packagemanager.posit.co/cran/2025-02-28')"

# remove the temporary project folder
RUN chmod -R u+w /home/rstudio/project && rm -rf /home/rstudio/project

EXPOSE 8888

CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--no-browser"]
