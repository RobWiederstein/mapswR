library(purrr)
library(sf)

# squares ----
## create ----
square <- sf::st_polygon(list(rbind(c(-.5,-.5), c(-.5, .5), c(.5, .5), c(.5, -.5), c(-.5, -.5))))

add_lng <- function(lng, lat){
    (square * 5) + c(lng, lat)
}

sq_all <-
    c(
        seq(-170, 170, by = 10) %>% map(add_lng, lat = -80),
        seq(-170, 170, by = 10) %>% map(add_lng, lat = -60),
        seq(-170, 170, by = 10) %>% map(add_lng, lat = -40),
        seq(-170, 170, by = 10) %>% map(add_lng, lat = -20),
        seq(-170, 170, by = 10) %>% map(add_lng, lat = 0),
        seq(-170, 170, by = 10) %>% map(add_lng, lat = 20),
        seq(-170, 170, by = 10) %>% map(add_lng, lat = 40),
        seq(-170, 170, by = 10) %>% map(add_lng, lat = 60),
        seq(-170, 170, by = 10) %>% map(add_lng, lat = 80)
)

sq_sfc <- st_sfc(sq_all, crs = 4326)
sq_sf <- st_sf(data.frame(names = 1:315), geometry =  sq_sfc)

rep_letter <- function(letter){rep(letter, 35)}
sq_sf %>%
    dplyr::mutate(group = (
        letters[1:9] %>%
        map(rep_letter) %>%
        unlist())) %>%
    st_centroid(.) %>%
    st_coordinates(.) %>%
    tibble::as_tibble(.) %>%
    dplyr::rename(lng = X, lat = Y) %>%
    dplyr::bind_cols(sq_sf, .) -> sq


sq |> dplyr::mutate(lat_abs = abs(lat), .before = geometry) -> sq

## plot squares ----
library(ggplot2)
p_sq <-
    ggplot() +
    geom_sf(data = sq, mapping = aes(fill = lat_abs)) +
    scale_fill_gradient("Equator \nProximity", low = "#A93154", high = "#AEB6E5") +
    coord_sf(xlim = c(-180, 180),
             ylim = c(-90, 90),
             expand = FALSE) +
    scale_x_continuous(breaks = seq(-180, 180, by = 30)) +
    scale_y_continuous(breaks = seq(-90, 90, by = 30)) +
    guides(fill = "none") +
    theme_bw() +
    theme(rect = element_rect(fill = "transparent"),
          panel.background = element_rect(fill = "transparent"),
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank())
p_sq
## plot aeqd ----
sq_aeqd <- st_transform(sq, crs = "+proj=aeqd +lon_0=0 +lat_0=90 +datum=WGS84 +units=m +no_defs")
p_sq_aeqd <-
    ggplot() +
    geom_sf(data = sq_aeqd, mapping = aes(fill = -lat_abs)) +
    coord_sf() +
    scale_fill_gradient("Polar \nProximity", low = "#A93154", high = "#AEB6E5") +
    scale_x_continuous(breaks = seq(-180, 180, by = 30)) +
    scale_y_continuous(breaks = seq(-90, 90, by = 30)) +
    guides(fill = "none") +
    theme_bw() +
    theme(rect = element_rect(fill = "transparent"),
          panel.background = element_rect(fill = "transparent"),
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank())
p_sq_aeqd
# world ----
## create ----
library(sf)
library(dplyr)
library(ggplot2)
wrld_in <- rnaturalearth::ne_countries(scale = 'large', type = 'countries') |>
    rmapshaper::ms_simplify(method = "vis", .01) |>
    dplyr::select(admin, geometry)

wrld_in %>%
    st_centroid(.) %>%
    st_coordinates(.) %>%
    tibble::as_tibble(.) %>%
    dplyr::rename(lng = X, lat = Y) %>%
    mutate(abs_lat = abs(lat)) %>%
    dplyr::bind_cols(wrld_in, .) -> wrld
## plot world ----
p_wrld <-
    ggplot(wrld) +
    geom_sf(mapping = aes(fill = abs_lat)) +
    coord_sf(expand = FALSE) +
    scale_fill_gradient("Polar \nProximity", low = "#A93154", high = "#AEB6E5") +
    scale_x_continuous(breaks = seq(-180, 180, by = 30)) +
    scale_y_continuous(breaks = seq(-90, 90, by = 30)) +
    guides(fill = "none") +
    theme_bw() +
    theme(rect = element_rect(fill = "transparent"),
          panel.background = element_rect(fill = "transparent"),
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank())
p_wrld
## plot aeqd ----
wrld_aeqd <- st_transform(wrld, crs = "+proj=aeqd +lon_0=0 +lat_0=90 +datum=WGS84 +units=m +no_defs")
p_wrld_aeqd <-
    ggplot(wrld_aeqd) +
    geom_sf(mapping = aes(fill = abs_lat)) +
    coord_sf(expand = FALSE) +
    scale_fill_gradient("Polar \nProximity", low = "#A93154", high = "#AEB6E5") +
    scale_x_continuous(breaks = seq(-180, 180, by = 30)) +
    scale_y_continuous(breaks = seq(-90, 90, by = 30)) +
    guides(fill = "none") +
    theme_bw() +
    theme(rect = element_rect(fill = "transparent"),
          panel.background = element_rect(fill = "transparent"),
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank())
p_wrld_aeqd
# grobs ----
library(patchwork)
filename <- "./images/cover_photo.png"

png(filename = filename,
    height = 4,
    width = 5,
    bg = "white",
    units = "in",
    res = 300)
p_sq + p_wrld + p_wrld_aeqd + p_sq_aeqd +
    theme(plot.margin = unit(c(0,0,0,0), "cm")) +
    plot_annotation(theme = theme(plot.background = element_rect(fill ="transparent")))
dev.off()
