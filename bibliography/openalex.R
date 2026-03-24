# Download, wrangle, and save all my works from OpenAlex
# There be dragons

library(tidyverse)
library(fs)
library(yaml)
library(openalexR)

# Some variables
options(openalexR.apikey = Sys.getenv("OA_API_KEY"))
path_target <- path("bibliography", "openalex.rds")
date_today <- Sys.Date()
path_timestamp <- path("bibliography", "openalex.timestamp")

# Get previous OpenAlex fetch date or create timestamp if first time
date_last_fetch <- if (file_exists(path_timestamp)) {
  as.Date(read_lines(path_timestamp))
} else {
  write_lines(date_today, path_timestamp)
  date_today
}

# If fetched over 30 days ago, fetch and rewrite, otherwise use existing data
if (date_last_fetch < (date_today - day(30))) {
  dat <- oa_fetch(
    entity = "works",
    author.id = "3Aa5028380935"
  )
  write_rds(dat, path_target, compress = "gz")
} else {
  dat <- read_rds(path_target)
}

# Keep only things that are likely publications for a website
dat <- dat |>
  filter(type %in% c("article", "preprint", "review")) |>
  filter(str_detect(landing_page_url, "doi.org")) |>
  filter(!str_detect(doi, "pci\\.rr|researchsquare|zenodo"))

# Fix some OSF types
dat <- dat |>
  mutate(type = if_else(str_detect(doi, "osf.io"), "preprint", type)) |>
  mutate(
    source = if_else(str_detect(doi, "osf.io"), "PsyArXiv", source_display_name)
  )

# Create clean authors string
dat <- dat |>
  mutate(
    authors = map_chr(
      authorships,
      ~ pull(.x, display_name) |>
        map(~ word(.x, -1)) |>
        str_flatten(collapse = ", ", last = " & ")
    )
  )

# Keep only fields we need
dat <- dat |>
  mutate(
    title,
    doi,
    type,
    version,
    date = publication_date,
    url = landing_page_url,
    is_oa,
    oa_url,
    license,
    pdf_url,
    abstract,
    source,
    authors,
    .keep = "none"
  )

# Take only latest PsyArXiv versions
dat <- dat |>
  mutate(
    doi_number = str_extract(doi, "_v[0-9]+$") |>
      str_extract("[0-9]") |>
      as.integer(),
    doi_number = coalesce(doi_number, 0),
    doi = str_remove(doi, "_v[0-9]+$")
  ) |>
  filter(doi_number == max(doi_number), .by = doi) |>
  select(-doi_number)

# Convert to Quarto's expected format
dat |>
  mutate(
    title,
    date = as.character(date),
    description = abstract,
    path = doi,
    type,
    source,
    authors,
    .keep = "none",
  ) |>
  view()
write_yaml("bibliography/openalex.yaml", column.major = FALSE)
