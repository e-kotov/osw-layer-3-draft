FROM ghcr.io/e-kotov/osw-layer-3-draft:latest

COPY --chown=${NB_USER} . ${HOME}
RUN rm -rf ${HOME}/renv ${HOME}/renv.lock ${HOME}/.Rprofile
