# targets::tar_make()
# targets::tar_visnetwork()

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  format = "qs"
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("R")

# Replace the target list below with your own:
list(
  # get data from osf ------------------------------------------------------
  tar_target(
    name = main_dataset,
    packages = c("osfr", "dplyr", "fs"),
    command = get_osf_data(
      tmp_dir = "data/tmp"
    )
  )
)
