# https://mgimond.github.io/Spatial/mapping-data-in-r.html

# load ----
library(terra)
library(sf)

# import ----
## spatRaster ----
z <- gzcon(url("https://github.com/mgimond/Spatial/raw/main/Data/elev.RDS"))
elev_r <- unwrap(readRDS(z))
plot(elev_r)
## sf ----
z <- gzcon(url("https://github.com/mgimond/Spatial/raw/main/Data/s_sf.RDS"))
s_sf <- readRDS(z)
plot(s_sf$geometry)
rm(z)
# about ----
## dependencies ----
sf_extSoftVersion()[1:3]

## CRS ----
cat(st_crs(s_sf)[[1]]) #EPSG / Proj4 string
cat(st_crs(s_sf)[[2]]) #WKT -- well known text

# set ----
## sf - Proj4 string ----
(s_sf <- st_set_crs(s_sf, "+proj=utm +zone=19 +ellps=GRS80 +datum=NAD83"))

## sf - EPSG code ----
(s_sf <- st_set_crs(s_sf, 26919))


## raster proj4 string ----
crs(elev_r) <- "+proj=utm +zone=19 +ellps=GRS80 +datum=NAD83"
st_crs(elev_r)
## raster epsg code ----
crs(elev_r) <- "+init=EPSG:26919"
st_crs(elev_r)[[1]]

# transform ----
(s_sf_gcs <- st_transform(s_sf, "+proj=longlat +datum=WGS84"))
(s_sf_gcs <- st_transform(s_sf, 4326))

# sanity - check ----
library(leaflet)
leaflet(s_sf_gcs) |>
    addTiles() |>
    addPolygons()

# World ----

## load ----
library(tmap)
data(World) # The dataset is stored as an sf object
World
## Check CRS ----
st_crs(World)
## transform ----
### world aeqd----
World_ae <- st_transform(World, "+proj=aeqd +lat_0=0 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
tm_shape(World_ae) + tm_fill()
### maine aeqd ----
World_ae_maine <- st_transform(World, "+proj=aeqd +lat_0=44.5 +lon_0=-69.8 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
## new plot maine
tm_shape(World_ae_maine) + tm_fill()
### world robinson ----
World_robin <- st_transform(World,"+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
tm_shape(World_robin) + tm_fill()
### world sinusoidal  ----
World_sin <- st_transform(World,"+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
tm_shape(World_sin) + tm_fill()
### world mercator ----
World_mercator <- st_transform(World,"+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
tm_shape(World_mercator) + tm_fill()
## reproject ----
### problem (note new lon!) ----
World_mercator2 <- st_transform(World, "+proj=merc +lon_0=-69 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
tm_shape(World_mercator2) + tm_borders()
### fix ----
#### Define new meridian ----
meridian2 <- -69

#### Split world at new meridian ----
wld_new <- st_break_antimeridian(World, lon_0 = meridian2)

#### Now reproject to Mercator using new meridian center ----
wld_merc2 <- st_transform(wld_new,
                          paste("+proj=merc +lon_0=", meridian2 ,
                                "+k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs") )

tm_shape(wld_merc2) + tm_borders()

#### robinson ----
wld_rob_sf <-  st_transform(wld_new,
                            paste("+proj=robin +lon_0=", meridian2 ,
                                  "+k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs") )
tm_shape(wld_rob_sf) + tm_borders()
