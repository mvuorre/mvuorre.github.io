# Create bibliographies from Zotero collections

library(jsonlite)
library(fs)
library(janitor)
library(tidyverse)
library(bib2df)
library(knitr)
library(httr2)

# Input and output paths for attached PDFs
PATH_ZOTERO <- "/Users/matti/Zotero/storage"
PATH_OUT <- "bibliography/files"

# `matti-vuorre` -> bibliography/bibliography.bib
# and repair paths
# Get data from local Zotero using better bibtex API
request(
  "http://127.0.0.1:23119/better-bibtex/export?/library;name:My%20Library/collection/cv/cv.biblatex"
) |>
  req_perform() |>
  resp_body_string() |>
  str_replace_all(PATH_ZOTERO, PATH_OUT) |>
  writeLines(path(dirname(PATH_OUT), "bibliography.bib"))

# Get JSON for listings
dat <- request(
  "http://127.0.0.1:23119/better-bibtex/export?/library;name:My%20Library/collection/cv/cv.jzon"
) |>
  req_perform() |>
  resp_body_string() |>
  fromJSON() |>
  pluck("items") |>
  tibble()

# Copy files to repaired paths
dat <- dat |>
  mutate(
    file = map_chr(attachments, ~ pluck(.x, "path", .default = NA_character_)),
    path = str_replace(file, PATH_ZOTERO, PATH_OUT)
  )
walk2(
  dat$file,
  dat$path,
  ~ if (!is.na(.y)) {
    dir_create(dirname(.y))
    file_copy(.x, .y, overwrite = TRUE)
  }
)

# Wrangle data
dat <- dat |>
  clean_names() |>
  filter(
    item_type %in%
      c("journalArticle", "preprint", "presentation", "computerProgram")
  ) |>
  mutate(
    publication = ifelse(
      item_type == "preprint",
      library_catalog,
      publication_title
    ),
    authors = map_chr(
      creators,
      ~ combine_words(.x$lastName, and = " & ")
    ),
    tags = map_chr(
      tags,
      ~ pluck(.x, "tag", .default = "") |>
        combine_words(and = "") |>
        str_to_lower()
    ),
    # Presentation place or publication venue
    outlet = coalesce(publication, place)
  )

# Note the Zotero 'Extra' field can contain items like
# license: CC-BY
# data: <URL>

dat |>
  mutate(extra = ifelse(is.na(extra), "extra: ~", extra)) |>
  str_glue_data(
    "
- title: >-
    {title}
  url: {url}
  date: {date}
  type: {item_type}
  authors: |
    {authors}
  doi: {doi}
  outlet: >-
    {outlet}
  file: {path}
  meeting: >-
    {meeting_name}
  categories: [{tags}]
  abstract: |
    {str_remove_all(abstract_note, '\\n')}
  {str_replace_all(extra, '\\n', '\\n  ')}
"
  ) |>
  cat(file = "bibliography/items.yml", sep = "\n")

# Readings
request(
  "http://127.0.0.1:23119/better-bibtex/export?/library;name:My%20Library/collection/readings.jzon"
) |>
  req_perform() |>
  resp_body_string() |>
  fromJSON() |>
  pluck("items") |>
  tibble() |>
  filter(!(itemType %in% c("attachment", "note"))) |>
  # Crazy hack to harmonize different author table formats
  mutate(
    creators = map(
      creators,
      ~ if ("name" %in% names(.x)) {
        mutate(
          .x,
          lastName = str_split_1(name, " ")[2],
          firstName = str_split_1(name, " ")[1],
          name = str_c(firstName, lastName, sep = " ")
        )
      } else {
        mutate(
          .x,
          name = str_c(firstName, lastName, sep = " ")
        )
      }
    )
  ) |>
  mutate(
    type = itemType,
    title = title,
    abstract = abstractNote,
    authors = map_chr(
      creators,
      ~ combine_words(.x$name, and = " & ")
    )
  ) |>
  mutate(extra = ifelse(is.na(extra), "extra: ~", extra)) |>
  str_glue_data(
    "
- title: >-
    {title}
  url: {url}
  date: {date}
  date_read: {dateModified}
  type: {type}
  authors: >-
    {authors}
  abstract: |
    {str_remove_all(abstract, '\\n')}
  {str_replace(extra, '\\n', '\\n  ')}
"
  ) |>
  cat(file = "bibliography/readings.yml", sep = "\n")
