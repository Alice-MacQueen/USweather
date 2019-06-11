
<!-- README.md is generated from README.Rmd. Please edit that file -->

# USweather

<!-- badges: start -->

<!-- badges: end -->

USweather is a collection of functions and examples to interact with
APIs - “Application Program Interfaces” - and download weather and
climate data for further use. The goal is to have researchers at
Fermilab, UT Austin, and Temple collaborate on this project and share
resources and approaches so we obtain and use this data in a way that
follows FAIR data principles (findable, accessible, interoperable, and
reusable data - (Wilkinson et al., 2016)).

# Goals

We need two major types of
    data:

    1. Daily weather data for each planting location from, say, April 2018 until the present.
    2. Historical weather data for each location of origin for each switchgrass genotype that we have geocoordinates of collection for.

We may also need soil data, and future climate data, but these can be
added as required.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Alice-MacQueen/USweather")
```

If this doesn’t work, please fork the repository to your GitHub and make
changes there, or in your own version of RStudio, then submit changes
back to USweather as a pull request.

## Examples

Three vignettes are included in the package at the moment. The one that
actually looks at functions included in this R package is called
“Get\_mesonet\_data.Rmd”. It shows you the current functions and
pipeline put in place to get a certain set of weather data from the Iowa
Environmental Mesonet. It uses functions from the R package “httr”.

There are also vignettes to get weather data from NOAA and from the
World Bank Climate data. These use functions in the R packages “rnoaa”
and “rWBclimate”.
