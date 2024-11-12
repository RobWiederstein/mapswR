# sf, the table (data.frame) with feature attributes and feature geometries, which contains
# sfc, the list-column with the geometries for each feature (record), which is composed of
# sfg, the feature geometry of an individual simple feature.
# 1. create simple features
# 2. convert to sfc
# 3. set CRS
# 4. add attributes / convert to sf
# 5. plot
# 6. add basemap
# 7. decide layers (countries, water features, cities, shipwrecks, etc)
# 8. add/create attributes data (sometimes called "feature creation" which is confusing
# when dealing with the simple features package)
# 9. add annotations
# 10. add compass rosette
# 11. add distance scale
# 12. add labels
# 13. set theme
#
# We'll start in the make-believe world of "Square-uh-stan"

# insert image from Geocomputation with R

library(sf)
#load world map
afrc <- rnaturalearth::ne_countries(continent = "Africa")

# create simple features
land_1 <- st_polygon(list(rbind(c(-10, -10), c(-10, -15), c(-15, -15), c(-15, -10), c(-10, -10))))
land_2 <- land_1 * .75 + 7
lake <- land_1 * .25
mountain <- st_centroid(land_1 - 1)
pm <- st_linestring(matrix(c(0, -20, 0, 20), ncol = 2, byrow = T))
eq <- st_linestring(matrix(c(-20, 0, 20, 0), ncol = 2, byrow = T))

# sfc
land_sfc = st_sfc(list(land_1, land_2))
lake_sfc = st_sfc(lake)
mountain_sfc <- st_sfc(mountain)
pm_sfc <- st_sfc(pm)
eq_sfc <- st_sfc(eq)

# set CRS
land_sfc_wgs = st_sfc(land_sfc, crs = "OGC:CRS84")
lake_sfc_wgs = st_sfc(lake_sfc, crs = "OGC:CRS84")
mountain_sfc_wgs <- st_sfc(mountain_sfc, crs = "OGC:CRS84")
pm_sfc_wgs <- st_sfc(pm_sfc, crs = "OGC:CRS84")
eq_sfc_wgs <- st_sfc(eq_sfc, crs = "OGC:CRS84")

# add attributes
country <- c("A", "B")
land_sfc_wgs_df = st_sf(country = country, land_sfc_wgs)
name <- "Mt. High"
mountain_sfc_wgs_df = st_sf(name = name, mountain_sfc_wgs)
name <- "Lake Clear"
lake_sfc_wgs_df <- st_sf(name = name, lake_sfc_wgs)
name <- "Equator"
eq_sfc_wgs_df <- st_sf(name = name, eq_sfc_wgs)
name <- "Prime Meridian"
pm_sfc_wgs_df <- st_sf(name = name, pm_sfc_wgs)

# plot ggplot2
library(ggplot2)
library(ggspatial)
library(ggrepel)
ggplot() +
# add layers
geom_sf(data = afrc, fill = "antiquewhite") +
geom_sf(data = land_sfc_wgs_df, fill = "antiquewhite") +
geom_sf(data = lake_sfc_wgs_df, fill = "lightblue") +
geom_sf(data = mountain_sfc_wgs_df, color = "red", shape = 17, size = 3) +
geom_sf(data = pm_sfc_wgs_df, linetype = "dashed") +
geom_sf(data = eq_sfc_wgs_df, linetype = "dashed") +
# add annotations
geom_sf_text(data = land_sfc_wgs_df,
             aes(label = country),
             nudge_y = 1) +
geom_sf_text(data = mountain_sfc_wgs_df,
             aes(label = name),
             nudge_y = -.75,
             nudge_x = .75) +
geom_sf_text(data = lake_sfc_wgs_df,
             aes(label = name),
             nudge_y = -1) +
geom_sf_text(data = eq_sfc_wgs_df,
             aes(label = name),
             nudge_y = .75,
             nudge_x = 2.5,
             color = "gray50",
             fontface = "italic") +
annotate(geom = "text", x = -.75, y = -15, label = "Prime Meridian",
         fontface = "italic", color = "grey50", angle = 90) +
coord_sf(xlim = c(-20, 15),
         ylim = c(-20, 10),
         expand = F) +
# add direction
annotation_north_arrow(
    which_north = "grid",
    height = unit(.75, "cm"),
    width = unit(.75, "cm"),
    location = "br",
    pad_x = unit(3.2, "cm"),
    pad_y = unit(1, "cm")
    ) +
# add scale
    annotation_scale(pad_x = unit(3.5, "in")) +
# add labels
labs(title = "Square-uh-stan",
     subtitle = "ggplot2",
     x = "longitude",
     y = "latitude",
     caption = "Source: My Data Source") +
# add theme
theme_bw() +
theme(panel.grid.major = element_line(
    color = gray(.5),
    linetype = "dotted",
    linewidth = 0.25),
    panel.background = element_rect(
        fill = "lightblue")
)
ggsave(filename = "./img/square-uh-stan_ggplot.jpg",
       height = 6,
       width = 6.5,
       unit = "in",
       dpi = 600)

# identify bb in narrative
library(tmap)
library(tmaptools)
tmap_options_reset()
box <- tmaptools::bb(afrc, xlim = c(-20, 15), ylim = c(-20, 10))
tm <-
tm_shape(afrc, bb = box) +
    tm_borders("gray50", lwd = .25) +
    tm_polygons(fill = "antiquewhite") +
tm_shape(land_sfc_wgs_df) +
    tm_borders("gray50", lwd = .25) +
    tm_polygons("country", fill = "antiquewhite") +
    tm_text("country", ymod = 1) +
tm_shape(lake_sfc_wgs) +
    tm_polygons(fill = "lightblue") +
    tm_text("Lake Clear", ymod = -1.3, xmod =-1) +
tm_shape(mountain_sfc_wgs_df) +
    tm_symbols(size = 1, fill = "red", shape = 17) +
    tm_text("Mt. High", ymod = -.75, xmod = 1) +
tm_shape(eq_sfc_wgs_df) +
    tm_lines(lty = "dotted") +
    tm_text("Equator", xmod = -18, ymod = .5, fontface = "italic", alpha = .5, size = .75) +
tm_shape(pm_sfc_wgs_df) +
    tm_lines(lty = "dotted") +
    tm_text("Prime Meridian", ymod = -17, xmod = -.5, fontface = "italic",
            alpha = .5, size = .75, angle = 90) +
    tm_xlab("Longitude") +
    tm_ylab("Latitude", rotation = 90) +
    tm_grid(labels.show = T,  alpha = .5) +
    tm_compass(position = c(.75, .25)) +
    tm_scalebar() +
    tm_title_in("Square-uh-stan",
                size = 1.4,
                padding = c(.5, 1, .5, 1),
                position = tm_pos_in("left", "top"),
                bg.color = "white",
                frame = "black",
                frame.lwd = 2) +
    tm_layout(
              bg.color = "lightblue",
              inner.margins = 0,
              frame = "grey50",
              frame.lwd = 3,
              frame.double.line = F,
              outer.bg.color = "#00000000"
              )
tm
tmap_save(tm,
          "./img/square-uh-stan_tmap.png",
          width = 6,
          height = 6.5,
          dpi = 600,
          units = "in")
st_crs(afrc)
afrc1 <- sf::st_transform(afrc, crs = 4087)
tm_shape(afrc1) +
    tm_grid(
        lwd = .5,
        crs = 4087,
        labels.show = T,
        labels.size = .8,
        labels.rot = c(-45, 45),
        labels.cardinal = T,
        labels.margin.x = 1,
        labels.margin.y = 1,
        labels.format = list(fun = function(x) formatC(x, digits = 0, big.mark = ".", format = "f")),
        ticks = FALSE,
        alpha = .5) +
    tm_borders("gray50", lwd = .25) +
    tm_polygons(fill = "antiquewhite")

