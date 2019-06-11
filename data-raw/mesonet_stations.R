## code to prepare `mesonet_stations` dataset goes here
library(lubridate)
library(readr)

mesonet_stations <- read_csv(file = "data-raw/All_Mesonet_Stations.csv",
                             col_types = "ccnnncc")

mesonet_stations <- mesonet_stations %>%
  mutate(begins = parse_date_time(begints, c("%Y-%m%-%d %H:%M:%S-%z",
                                                  "%m/%d/%Y %H:%M")))

usethis::use_data(mesonet_stations, compress = "gzip")
