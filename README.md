

# Initial manual install of R packages with `renv`

```{r}
packages_to_install <- c("usethis", "targets", "pak", "visNetwork", "cpp11", "usethis", "tidyverse", "osfr", "fs")
renv::install(packages_to_install, prompt = FALSE)
```

#  Build the Docker image locally


```bash
docker build --platform linux/amd64 -f Dockerfile4build/Dockerfile -t r442 .
```

# Test run the Docker image locally

```bash
docker run --platform linux/amd64 -it --rm -v "$(pwd):/home/rstudio" -p 8888:8888 r442
```
