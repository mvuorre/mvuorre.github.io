## Matti's homepage

This repository contains the source of my website <https://vuorre.com>. Created with Quarto. 

## Requirements

- Quarto
- ZOTERO_API_KEY set in `.env`

## Publications

The publications page, and content therein, is programmatically generated from Zotero. Steps are:

- Right-click "bibliography" --> "Export saved search..." --> Better BibTeX JSON with "Export Files" and "Items" --> [website root]/bibliography/
  - "bibliography" is a Saved Search in Zotero that filters from my publications
  - "My Publications" can't be exported
- This uses info from Zotero so ensure items have up-to date info, tags, and attachments. `Extra` field can include `data` and `code` which are used to surface publications' `data` and `code`
