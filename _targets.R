# targets::tar_make() # build the project
# targets::tar_visnetwork() # visualise the workflow
# x <- targets::tar_read(main_dataset) # load the saved output of a targets step into var x (e.g. for interactive testing)
# targets::tar_load(main_dataset) # load the saved output of a targets step with its original saved name `main_dataset` into current session's environemnt (e.g. for interactive testing)
# targets::tar_destroy() delete all saved results of all targets steps

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  format = "qs" # targets will use `qs2` R package to efficiently save and load results of each step
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source("R")

# Replace the target list below with your own:
list(
  # get data from osf ------------------------------------------------------
  tar_target(
    name = main_dataset,
    packages = c("osfr", "dplyr", "fs"), # this way we only use the packages we need in this particular step, keeping the environment clean of unneeded packages taht may be used in other steps
    command = get_osf_data(
      tmp_dir = "data/tmp"
    )
  ),

  tar_target(
    name = main_data_summary,
    command = summary(main_dataset)
  )
)
