library(sf)
library(spData)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(colorspace)
library(ggplot2)
library(ggspatial)

mdgscr <- ne_countries(scale = "medium", country = "Madagascar")
st_crs(mdgscr)
mdgscr |>
    ggplot() +
    geom_sf() +
    coord_sf(datum = sf::st_crs(4326)) +
    theme_bw() +
    labs(title = "Madagascar",
         subtitle = "Geographic EPG 4326")
mdgscr |>
    ggplot() +
    geom_sf() +
    coord_sf(datum = sf::st_crs(3395)) +
    theme_bw() +
    #scale_x_continuous(labels = scales::label_comma()) +
    labs(title = "Madagascar",
         subtitle = "Projected EPG 3395")

albn <- ne_countries(scale = "large", country = "Albania")
st_crs(albn)
albn |>
    ggplot() +
    geom_sf() +
    coord_sf(datum = sf::st_crs(4326)) +
    theme_bw()
albn |>
    ggplot() +
    geom_sf() +
    coord_sf(datum = sf::st_crs(3395)) +
    theme_bw()
albn |>
    ggplot() +
    geom_sf() +
    coord_sf(datum = sf::st_crs(2462)) +
    theme_bw()
albn |>
    ggplot() +
    geom_sf() +
    coord_sf(datum = sf::st_crs(4191)) +
    theme_bw()


data(nz)
st_crs(nz)
# plot 2193 - New Zealand Transverse Mercator 2000
nz |>
    ggplot() +
    geom_sf(expand = F)

#WGS 84
nz |>
    ggplot() +
    geom_sf() +
    coord_sf(crs = st_crs(4326))

# hadley
library(ozmaps)
oz_states <- ozmaps::ozmap_states %>% filter(NAME != "Other Territories")
oz_votes <- rmapshaper::ms_simplify(ozmaps::abs_ced)
ggplot(ozmap_states) + geom_sf()
ozmap_states |>
    ggplot() +
    geom_sf() +
    coord_sf(crs = st_crs(3112))

#next ----
ggplot() +
    geom_sf(data = oz_states, mapping = aes(fill = NAME), show.legend = FALSE) +
    geom_sf(data = oz_votes, fill = NA) +
    coord_sf()
