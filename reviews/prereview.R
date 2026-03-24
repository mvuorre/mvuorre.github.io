# Scrape my PREreview profile and write to YAML

library(tidyverse)
library(httr2)
library(rvest)
library(yaml)

page <- request(
  "https://prereview.org/profiles/0000-0001-5052-066X"
) |>
  req_perform() |>
  resp_body_string() |>
  read_html()

dat <- page |>
  html_elements("ol.cards article") |>
  map_dfr(\(item) {
    tibble(
      title = item |> html_element("cite") |> html_text2(),
      date = item |> html_element("time") |> html_attr("datetime"),
      path = str_c(
        "https://prereview.org",
        item |> html_element("a") |> html_attr("href")
      )
    )
  })

out <- dat |>
  mutate(
    title = str_glue('Review of "{title}"')
  )

out <- pmap(
  out,
  \(title, date, path) {
    list(
      title = title,
      date = date,
      path = path,
      categories = list("PREreview")
    )
  }
)

write_yaml(out, "reviews/prereview.yaml")
