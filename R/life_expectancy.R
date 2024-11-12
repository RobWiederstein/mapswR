library(dplyr)
library(stringr)
library(sf)
library(ggplot2)
library(colorspace)
# life expectancy ----
file <-
    paste0("./data-raw/ihme_life_exp//IHME_USA_COD_COUNTY_RACE_",
           "ETHN_2000_2019_LT_2019_ALL_BOTH_Y2023M06D12.CSV")
df <- vroom::vroom(file = file,
                   col_types = paste0(rep("c", 17), collapse = "")
                   ) %>%
    filter(!is.na(fips)) %>%
    filter(race_name %in% c("Total")) %>%
    filter(sex_name %in% c("Both")) %>%
    filter(age_name %in% c("<1 year")) %>%
    mutate(fips_length = nchar(fips)) %>%
    filter(fips_length > 2) %>%
    select(year, fips, location_name, age_name, val) %>%
    mutate(life_exp = as.numeric(val) %>% round(3)) %>%
    select(!val) %>%
    mutate(fips = stringr::str_pad(fips,
                                   width = 5,
                                   side = "left",
                                   pad = "0")) %>%
    mutate(state_fips = substr(fips, start = 1, stop = 2),
           .before = fips) %>%
    mutate(state_name = str_extract(location_name,
                               pattern = "(?<=\\().*?(?=\\))"),
                               .before = fips) %>%
    filter(!is.na(life_exp))

# shape files ----
counties <- sf::st_read(dsn = "./data-raw/cb_2018_us_county_20m",
                        layer = "cb_2018_us_county_20m") %>%
            select(GEOID, geometry) %>%
            rename(fips = GEOID)

# merge ----
le <- dplyr::left_join(counties, df, by = "fips") %>%
    filter(!state_name %in% c("Alaska", "Hawaii")) %>%
    filter(!is.na(state_name))
le <- sf::st_transform(le, crs = st_crs(2163))
saveRDS(le, file = "./data/2024-07-22_us_life_expectancy.rds")

