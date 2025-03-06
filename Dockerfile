FROM ghcr.io/e-kotov/osw-layer-3-draft:latest

# Copy everything to /home/rstudio
COPY --chown=rstudio . /home/rstudio

# Remove the files you don’t want in your final image
RUN rm -rf /home/rstudio/renv \
           /home/rstudio/renv.lock \
           /home/rstudio/.Rprofile
