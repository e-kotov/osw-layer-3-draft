get_osf_data <- function(
  tmp_dir
) {
  # lines for manual testing ---------------------------------------------
  # library(osfr) ; library(dplyr) ; library(fs)
  # tmp_dir <- "data/tmp"

  if (!fs::dir_exists(tmp_dir)) {
    fs::dir_create(tmp_dir, recurse = TRUE)
  }

  x_url <- "https://osf.io/k84rz/"

  osf_project <- osfr::osf_retrieve_node(x_url)
  osf_files <- osfr::osf_ls_files(osf_project)
  osf_tmp_data <- osfr::osf_download(
    x = osf_files |>
      dplyr::filter(name == "mocy.zip"),
    path = tmp_dir,
    progress = TRUE,
    conflicts = "overwrite"
  )

  file_to_unzip <- osf_tmp_data |>
    dplyr::filter(name == "mocy.zip") |>
    dplyr::pull(local_path)

  files_inside_zip <- utils::unzip(file_to_unzip, list = TRUE)
  rdata_file_in_zip <- files_inside_zip |>
    dplyr::filter(grepl("Rdata", Name)) |>
    dplyr::pull(Name)

  # extract just the Rdata file
  rdata_file_path <- utils::unzip(
    file_to_unzip,
    files = rdata_file_in_zip,
    overwrite = TRUE,
    junkpaths = FALSE,
    exdir = tmp_dir
  )

  # load the rdata file - this loads the `mocy` object
  load(rdata_file_path)

  return(mocy)
}
