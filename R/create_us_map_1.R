library(sf)
library(spData)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(colorspace)
library(ggplot2)
library(ggspatial)
# world
wrld <- ne_countries(scale = "medium", returnclass = "sf")
plot(wrld$geometry)
st_crs(wrld)[[1]]
st_bbox(wrld, crs = st_crs(4326))
# us
us <-
    ne_states(country = 'united states of america') |>
    select(name, postal, geometry) |>
    st_as_sf()
# plot
plot(us$geometry)
# see coordinate reference system
st_crs(us)[[1]]
# find bbox
st_bbox(us, crs = st_crs(4326))

# great lakes
lk_spr <- st_read(dsn = "./data/hydro_p_LakeSuperior", layer = "hydro_p_LakeSuperior")
lk_spr_4326 <- st_transform(lk_spr, crs = "OGC:CRS84")
lk_mchgn <- st_read(dsn = "./data/hydro_p_LakeMichigan/", layer = "hydro_p_LakeMichigan")
lk_mchgn_4326 <- st_transform(lk_mchgn, crs = "OGC:CRS84")
lk_ontr <- st_read(dsn = "./data/hydro_p_LakeOntario/", layer = "hydro_p_LakeOntario")
lk_ontr_4326 <- st_transform(lk_ontr, crs = "OGC:CRS84")
lk_hrn <- st_read(dsn = "./data/hydro_p_LakeHuron/", layer = "hydro_p_LakeHuron")
lk_hrn_4326 <- st_transform(lk_hrn, crs = "OGC:CRS84")
lk_erie <- st_read(dsn = "./data/hydro_p_LakeErie/", layer = "hydro_p_LakeErie")
lk_erie_4326 <- st_transform(lk_erie, crs = "OGC:CRS84")
# states
#state_points <- st_centroid(us)
state_points <- cbind(us, st_coordinates(st_centroid(us$geometry)))

plot_us <- function(xlim, ylim, title){
    wrld |>
        ggplot() +
        geom_sf(fill= "antiquewhite") +
        geom_sf(data = lk_spr_4326, fill = "aliceblue") +
        geom_sf(data = lk_mchgn_4326, fill = "aliceblue") +
        geom_sf(data = lk_ontr_4326, fill = "aliceblue") +
        geom_sf(data = lk_hrn_4326, fill = "aliceblue") +
        geom_sf(data = lk_erie_4326, fill = "aliceblue") +
        geom_sf(data = us, aes(geometry = geometry, fill = name), show.legend = F) +
        scale_fill_discrete_qualitative(palette = "pastel1") +
        geom_text(data = state_points,
                  aes(x = X, y = Y,label = postal),
                  size = 2.5,
                  color = "black",
                  check_overlap = TRUE) +
        coord_sf(xlim = xlim, ylim = ylim, default_crs = sf::st_crs(4326)) +
        annotation_north_arrow(location = "br",
                               which_north = "true",
                               height = unit(.75, "cm"),
                               width = unit(.75, "cm")) +
        labs(title = "") +
        theme_void() +
        theme(panel.grid.major = element_line(
            color = gray(.5),
            linetype = "dotted",
            size = 0.25),
            panel.background = element_rect(
                fill = "aliceblue")
            )
}
main_us <-  plot_us(xlim = c(-145, -70), ylim = c(25, 50), title = "U.S.")
main_us
inset_hi <-
    us |>
    filter(name == "Hawaii") |>
    ggplot() +
    geom_sf(aes(fill = name), show.legend = F) +
    scale_fill_discrete_qualitative(palette = "pastel1") +
    geom_text(data = state_points |> filter(name == "Hawaii"),
              aes(x = X, y = Y,label = postal),
              size = 2.5,
              color = "black",
              check_overlap = TRUE) +
    coord_sf(xlim = c(-161.5, -154.5),
             ylim = c(18, 23),
             default_crs = sf::st_crs(4326),
             datum = NA,
             expand = F) +
    scale_x_continuous(name = "") +
    scale_y_continuous(name = "") +
    theme(panel.background = element_rect(fill = 'transparent'),
          plot.background = element_rect(fill = 'transparent', color = NA),
          panel.border = element_rect(colour = "black", fill = NA, size = 1)
          )
inset_ak <-
    us |>
    filter(name == "Alaska") |>
    ggplot() +
    geom_sf(aes(fill = name), show.legend = F) +
    scale_fill_discrete_qualitative(palette = "pastel1") +
    geom_text(data = state_points |> filter(name == "Alaska"),
              aes(x = X, y = Y,label = postal),
              size = 2.5,
              color = "black",
              check_overlap = TRUE) +
    coord_sf(xlim = c(-185, -128),
             ylim = c(50, 72),
             default_crs = sf::st_crs(4326),
             datum = NA,
             expand = F) +
    scale_x_continuous(name = "") +
    scale_y_continuous(name = "") +
    theme(panel.background = element_rect(fill = 'transparent'),
          plot.background = element_rect(fill = 'transparent', color = NA),
          panel.border = element_rect(colour = "black", fill = NA, size = 1)
    )
main_us +
    annotation_custom(
        grob = ggplotGrob(inset_hi),
        xmin = -145,
        xmax = -125,
        ymin = 25,
        ymax = 35
    ) +
    annotation_custom(
        grob = ggplotGrob(inset_ak),
        xmin = -145,
        xmax = -125,
        ymin = 35,
        ymax = 50
    ) +
    theme_bw() +
    labs(title = "United States",
         caption = "Warning: Insets not to scale") +
    scale_x_continuous(name = "") +
    scale_y_continuous(name = "") +
    theme(panel.grid.major = element_line(
        color = gray(.5),
        linetype = "dotted",
        size = 0.2),
        panel.background = element_rect(
            fill = "aliceblue")
    )
ggsave(filename = "./us_map_second.jpg",
       height = 4,
       width = 6,
       units = "in",
       dpi = 600)
