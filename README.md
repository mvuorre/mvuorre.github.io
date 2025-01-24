## Matti's homepage

This repository contains the source of my website <https://vuorre.com>.

## Instructions

Created with Quarto. Render everything with `quarto render`, outputs are in `docs/`.

### Environment variables

In `.env`:
# Zotero API key for fetching data from my Zotero library
ZOTERO_API_KEY=""


### Publications

The publications page, and content therein, is programmatically generated from Zotero. Steps are:

1. Export my `bibliography` Zotero collection (Saved Search, "My Publications" can't be exported) as "Better BibLaTeX" (select "Export Files") to `/bibliography/`.
    - This uses info from Zotero so ensure items have up-to date info, tags, and attachments. `Extra` field can include `tex.data` and `tex.code` which are used to surface publications' `data` and `code`.
