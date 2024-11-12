
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tutorial_maps1

<!-- badges: start -->
<!-- badges: end -->

# Bibliographies

The project uses the quarto extension “multibib.” Details can be found
[here](https://github.com/pandoc-ext/multibib). Because the project is a
website and not a book, the `yaml` configuration is protracted. Each
page requires a bibliography to be generated at the end. There are four
bibliographies: 1. R-spatial - contains all entries for the Zotero
subdirectories tools and main 2. main - contains everything that is not
a tool, i.e. academic articles and websites 3. tools - contains
interactive, web-based tools 4. packages - contains all software
dependencies from within the project and is generated via `knitr`.

The `./bibs/packages.bib` file is generated from this snippet:

``` r
#| eval: FALSE
#| echo: TRUE
deps <- renv::dependencies()
pkgs <- setdiff(unique(deps$Package), "R")
bibtex::write.bib(entry = pkgs, file = ".bibs/packages.bib", append = FALSE)
```
