## code to prepare `pvdiv` dataset goes here
library(XLConnect)
wb_metadata <- loadWorkbook(file.path("C:", "Users", "ahm543", "OneDrive",
                                      "Juenger Projects", "SwitchgrassGWAS",
                                      "Metadata_and_Phenotypes",
                                      "PVDIV_Master Metadata File_5-8-2019.xlsx"))
lst_metadata <- readWorksheet(wb_metadata, sheet = getSheets(wb_metadata))

pvdiv <- as_tibble(lst_metadata$`PVDIV METADATA MASTER LIST`)
pvdiv <- pvdiv %>%
  select(PLANT_ID, ECOTYPE_SNP_CHLR, SUBPOP_SNP, PLOIDY, LATITUDE:HABITAT) %>%
  rename(Latitude = LATITUDE, Longitude = LONGITUDE, Elevation = ELEVATION,
         Taxon = TAXON, Habitat = HABITAT, Collector = COLLECTOR,
         Locality = LOCALITY, Notes_LatLong = NOTE_LATLONG,
         Collection_date = COLL_DATE) %>%
  mutate(Latitude = as.numeric(Latitude),
         Longitude = as.numeric(Longitude),
         Elevation = as.numeric(Elevation))

usethis::use_data(pvdiv, compress = "gzip")
