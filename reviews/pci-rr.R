# Scrape mny PCI: RR page and write to YAML

library(tidyverse)
library(httr2)
library(rvest)
library(yaml)

# Fetch my profile page
page <- request(
  "https://rr.peercommunityin.org/public/user_public_page?userId=1570"
) |>
  req_perform() |>
  resp_body_string() |>
  read_html()

# Parse reviews and recommendations
sections <- page |> html_elements(".pci2-article-list-titled")
dat <- map_dfr(sections, \(section) {
  type <- section |>
    html_element("h2") |>
    html_text2() |>
    str_squish() |>
    str_remove(":.*$") |>
    str_to_lower() |>
    str_remove("s$")

  section |>
    html_elements(".pci2-articles-list > .pci2-flex-row.pci2-article-row") |>
    map_dfr(\(item) {
      tibble(
        type = type,
        title = item |> html_element("h3 span") |> html_text2(),
        path = str_c(
          "https://rr.peercommunityin.org",
          item |> html_element("a.btn.btn-success") |> html_attr("href")
        ),
        date = item |>
          html_element(".pci2-article-left-div > i span") |>
          html_text2() |>
          str_squish() |>
          as.Date(format = "%d %b %Y") |>
          as.character(),
        stage = item |>
          html_element(".pci-preprintTagText") |>
          html_text2() |>
          str_squish() |>
          str_to_title()
      )
    })
})

# Create title and discard unused variables
out <- dat |>
  mutate(
    title = str_glue(
      '{str_to_sentence(type)} of ',
      '"{title}" [{stage} RR]'
    )
  ) |>
  select(title, date, path)

# Coerce into YAML friendly list and add categories
out <- pmap(
  out,
  \(title, date, path) {
    list(
      title = title,
      date = date,
      path = path,
      categories = list("PCI RR")
    )
  }
)

# Write file
write_yaml(out, "reviews/pci-rr.yaml")
