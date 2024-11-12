# intro ----
# just dealing with vector

# Import GIS ----
#
dsn <- "./data/cb_2023_us_state_20m"
layer <- "cb_2023_us_state_20m"
us <- sf::st_read(dsn = dsn, layer = layer)

plot(us$bou)
# Export GIS ----


# Get Info ----
## Versions ----
sf_extSoftVersion()[1:3]

## Get CRS ----
st_crs()

# Sanity-Check ----
## Valid Geometries ----
## st_is_valid()
## Plot object ----
## plot(data$geometry, axes = T)

# create geometries


# convert lat lng to sf
flcities <-
    data.frame(
        state = rep("Florida", 5),
        city = c("Miami", "Tampa", "Orlando", "Jacksonville", "Sarasota"),
        lat = c(25.7616798, 27.950575, 28.5383355, 30.3321838, 27.3364347),
        lng = c(-80.1917902, -82.4571776, -81.3792365, -81.655651, -82.5306527)
    )
(flcities <- st_as_sf(flcities, coords = c("lng", "lat"), remove = FALSE,
                      crs = 4326))
