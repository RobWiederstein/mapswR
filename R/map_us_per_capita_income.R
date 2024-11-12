library(magrittr)
library(dplyr)
library(ggplot2)
library(cowplot)
library(classInt)
library(colorspace)
library(units)
file <- "./data-raw/bea_personal_income_2019/table.csv"
df <- readr::read_csv(file = file,
                   skip = 3,
                   col_names = T,
                   name_repair = ~janitor::make_clean_names(.x),
                   show_col_types = F) %>%
    mutate(year = 2019, .before = everything()) %>%
    select(!line_code) %>%
    tidyr::pivot_wider(names_from = description,
                values_from = x2019) %>%
    rename(personal_inc_tot = `Personal income (thousands of dollars)`,
           population = `Population (persons) 1`,
           per_capita_inc = `Per capita personal income (dollars) 2`) %>%
    select(!`NA`) %>%
    mutate(across(personal_inc_tot:per_capita_inc, ~as.integer(.x))) %>%
    mutate(geo_name = gsub("\\*", "", geo_name)) %>%
    #filter(!grepl("\\*", geo_name)) %>%
    tidyr::separate(col = geo_name, into = c("county", "state"), sep = ", ") %>%
    tidyr::drop_na()
names(df)
df %>%
    ggplot(aes(population)) +
    geom_histogram(fill = "gray80",
                   color = "black",
                   bins = 100,
                   binwidth = 2.5e4) +
    scale_x_continuous(name = "persons",
                       limits = c(0, 1e6),
                       expand = expansion(mult = c(0, .05)),
                       labels = c("0", "250k", "500k", "750k", "1,000k")) +
    scale_y_continuous(name = "counties",
                       expand = expansion(mult = c(0, .05))
                       )+
    theme_cowplot()
#
# shape files ----
counties <- sf::st_read(dsn = "./data-raw/cb_2018_us_county_20m",
                        layer = "cb_2018_us_county_20m") %>%
    select(GEOID, geometry) %>%
    rename(geo_fips = GEOID)

#merge
# merge ----
pop <- dplyr::left_join(counties, df, by = "geo_fips") %>%
    tidyr::drop_na() %>%
    filter(!grepl("AK|HI|PR", state))
sf::st_crs(pop)
pop <- sf::st_transform(pop, crs = sf::st_crs(2163))
plot(pop$geometry)

pop %>% mutate(
    area = (sf::st_area(geometry) / 1e6),
    pop_density = (population/area),
    pop_density_f = cut(
        pop_density,
        breaks = classIntervals(
            pop_density,
            #n = 7,
            style = "headtails",
            thr = .1,
        )[[2]],
        include.lowest = T))-> pop1

library(ggplot2)
ggplot() +
    geom_sf(pop1, mapping = aes(fill = pop_density_f), show.legend = T) +
    coord_sf(xlim = c(-2036902.7, 5e6)) +
    scale_fill_discrete_sequential(palette = "Viridis", rev = T) +
    theme_map() +
    labs(title = "2019 U.S. Population")
