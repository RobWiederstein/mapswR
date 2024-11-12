library(sf)
library(spData)
library(maps)
library(ggplot2)
st_crs(world)
world_proj = st_transform(world, "+proj=eck4")
world_cents = st_centroid(world_proj, of_largest_polygon = TRUE)
par(mar = c(0, 0, 0, 0))
plot(world_proj["continent"], reset = FALSE, main = "", key.pos = NULL)
g = st_graticule()
g = st_transform(g, crs = "+proj=eck4")
plot(g$geometry, add = TRUE, col = "lightgrey")
data(world)
cex = sqrt(world$pop) / 10000
plot(st_geometry(world_cents), add = TRUE, cex = cex, lwd = 2, graticule = TRUE)

library(s2)
g <- as_s2_geography(TRUE) # Earth
co <- s2_data_countries()
oc <- s2_difference(g, s2_union_agg(co)) # oceans
b <- s2_buffer_cells(as_s2_geography("POINT(-30 -10)"), 9800000) # visible half
i <- s2_intersection(b, oc) # visible ocean
co <- s2_intersection(b, co)

png(filename = "./img/globe.png",
     width = 480,
     height = 480,
     units = "px",
     pointsize = 12,
     bg = "white",
     res = NA,
     type = "cairo")
plot(st_transform(st_as_sfc(i), "+proj=ortho +lat_0=-10 +lon_0=-30"), col = 'lightblue')
plot(st_transform(st_as_sfc(co), "+proj=ortho +lat_0=-10 +lon_0=-30"), col = NA, add = TRUE)
dev.off()

library(sf)
library(ggplot2)
library(mapview)
library(lwgeom)
library(rnaturalearth)
library(dplyr)

# world data
world <- rnaturalearth::ne_countries(scale = 'small', returnclass = 'sf')
plot(world$geometry)
# Fix polygons so they don't get cut in ortho projection
world  <- st_cast(world, 'MULTILINESTRING') %>%
    st_cast('LINESTRING', do_split=TRUE) %>%
    mutate(npts = npts(geometry, by_feature = TRUE)) %>%
    st_cast('POLYGON')

# map
ggplot() +
    geom_sf(data=world, color="gray80", fill="antiquewhite") +
    coord_sf(crs= "+proj=ortho +lat_0=20 +lon_0=-75")  +
    theme_void() +
    theme(panel.background = element_rect(
        fill = "lightblue"),
        )

ggplot() +
    geom_sf(data=world, color="gray80", aes(fill=continent)) +
    coord_sf( crs= "+proj=ortho +lat_0=-20 +lon_0=0", expand = F)  +
    theme_bw()
