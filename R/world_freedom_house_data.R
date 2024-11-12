# freedom house data ----
fh <- readr::read_csv(file = "./data/2024-06-28_freedom_house_data.csv",
                      name_repair = ~janitor::make_clean_names(.x)) %>%
    dplyr::select(country_territory, pr_rating) %>%
    dplyr::rename(admin = country_territory) %>%
    dplyr::mutate(admin = gsub("United States", "United States of America", admin))
## ordered factor ----
levels <- as.character(1:7)
fh$pr_rating_fct <-  factor(fh$pr_rating, levels = levels, ordered = T)

# boundary ----
wrld <- rnaturalearth::ne_countries() %>%
    dplyr::select(admin, sov_a3, geometry)

# join ----
wrld_fh <- dplyr::left_join(wrld, fh, by = "admin")

# projection ----
wrld_fh_mw <- st_transform(wrld_fh, crs = "+proj=moll +lon_0=0 +datum=WGS84 +units=m +no_defs")

# plot ----
ggplot() +
geom_sf(data = wrld_fh_mw, aes(fill = pr_rating_fct) )+
coord_sf(expand = T) +
scale_fill_manual(values = colorspace::sequential_hcl(7, palette = "YlGnBu")) +
theme_bw() +
guides(fill=guide_legend(title="Political Rights\nScore")) +
labs(title = "2024 Political Rights by Country",
     caption = "Source: Freedom House")

