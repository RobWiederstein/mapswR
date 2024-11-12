library(tidyr)
library(dplyr)
library(magrittr)
library(sf)

#boundaries
nz <- rnaturalearth::ne_states(country = "New Zealand") %>%
    select(name, region, geometry) %>%
    filter(!grepl("Outlying Islands|Chatham", region)) %>%
    filter(!is.na(region)) %>%
    mutate(name = gsub(" District| City", "", name)) %>%
    mutate(name = gsub("Wanganui", "Whanganui", name)) %>%
    mutate(lng = st_coordinates(st_centroid(.))[, 1],
           lat = st_coordinates(st_centroid(.))[, 2])


# Business Counts
nz_bi <- readr::read_csv(
    file = "./data/2024-06-28_nz_stats_bus_count_indic.csv",
    col_names = F,
    skip = 2,
    n_max = 2
)

nz_bi_1 <- tibble(
    name = as.character(nz_bi[1, ]),
    value = as.numeric(nz_bi[2, ])
    ) %>%
    filter(!is.na(name)) %>%
    filter(!grepl("Total", name)) %>%
    mutate(total = sum(value)) %>%
    mutate(pct_val = divide_by(value, total),
                  pct_val = pct_val * 100) %>%
    mutate(pct_val_f = cut_interval(pct_val, n = 4)) %>%
    select(!c(value, total))

# left join
nz <- left_join(nz, nz_bi_1, by = "name")

# cities
nz_cities <- readr::read_csv(
    file = "./data/2024-06-29_nz_cities.csv",
    col_select = c(city, lat, lng, population)
) %>%
    mutate(pop_m = population/1e6) %>%
    mutate(pop_m_f = cut_number(pop_m, n = 4)) %>%
    mutate(size = case_when(
        pop_m_f == "[0.0762,0.115]" ~ 3,
        pop_m_f == "(0.115,0.191]" ~ 3.75,
        pop_m_f == "(0.191,0.336]" ~ 4.5,
        pop_m_f == "(0.336,1.35]" ~ 5.25
    )) %>%
    st_as_sf(., coords = c("lng", "lat"), remove = FALSE, crs = "WGS84")

library(ggplot2)
library(ggrepel)

values = colorspace::sequential_hcl(3, palette = "TealGrn")
ggplot() +
geom_sf(data = nz, mapping = aes(fill = pct_val_f), lwd = .5, col = "gray70") +
scale_fill_manual(name = "Pct.Total\nBusinesses", values = values) +
geom_label_repel(data = nz,
                mapping = aes(x = lng, y = lat, label = name),
                force = 10,
                fill = alpha(c("white"),0.75),
                label.padding = .2,
                box.padding = .6,
                min.segment.length = 1.2,
                arrow = arrow(length = unit(0.01, "npc"),
                              type = "open"),
                size = 5) +
theme_void() +
theme(
    text = element_text(size = 13),
    legend.position = "inside",
    legend.position.inside =  c(.90, .2)
)

