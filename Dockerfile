FROM ghcr.io/e-kotov/osw-layer-3-draft:latest
# this line above instructs mybinder.org to use our container that was pre-built and uploaded to the github container registry as a base layer

# Copy everything to /home/rstudio
COPY --chown=rstudio . /home/rstudio

# Remove the files related to renv, so that renv does not take over the project
# We have (hopefully) all the packages already installed and burned into the container image
RUN rm -rf /home/rstudio/renv \
           /home/rstudio/renv.lock \
           /home/rstudio/.Rprofile
