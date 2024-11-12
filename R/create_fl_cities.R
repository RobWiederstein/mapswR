flcities <-
    data.frame(
        state = rep("Florida", 5),
        city = c("Miami", "Tampa", "Orlando", "Jacksonville", "Sarasota"),
        lat = c(25.7616798, 27.950575, 28.5383355, 30.3321838, 27.3364347),
        lng = c(-80.1917902, -82.4571776, -81.3792365, -81.655651, -82.5306527)
    )
(flcities <- st_as_sf(flcities, coords = c("lng", "lat"), remove = FALSE,
                      crs = 4326))

ggplot() +
    geom_sf(data = flcities) +
    # geom_text(data = flcities, aes(x = lng, y = lat, label = city),
    #           size = 3.9, col = "black", fontface = "bold") +
    geom_text_repel(data = flcities,
                    aes(x = lng, y = lat, label = city),
                    fontface = "bold",
                    nudge_x = c(1, -1.5, 2, 2, -1),
                    nudge_y = c(0.25,  -0.25, 0.5, 0.5, -0.5)
                    ) +
    coord_sf(xlim = c(-88, -78), ylim = c(24.5, 33), expand = FALSE)
