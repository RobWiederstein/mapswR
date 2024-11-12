# show various choropleth strateges

# United States of America
wrld <- rnaturalearth::ne_states(country = "United States of America") |>
    dplyr::select(postal, geometry) |>
    dplyr::filter(!(postal == "DC")) |>
    dplyr::mutate(rname = sample(1:5, size = 50, replace = T))
wrld_aeqd <- st_transform(wrld, crs = "+proj=aeqd +lon_0=-156 +lat_0=31 +datum=WGS84 +units=m +no_defs")

values <- colorspace::qualitative_hcl(n = 5, palette = "pastel1")
ggplot() +
    geom_sf(data = wrld_aeqd, mapping = aes(fill = factor(rname))) +
    scale_fill_manual(values = values) +
    coord_sf() +
    theme_bw()
