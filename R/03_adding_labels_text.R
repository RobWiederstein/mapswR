# libraries ----
library(colorspace)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(magrittr)
library(sfheaders)
library(sf)
library(tibble)
library(tidyr)
library(tmap)
# functions ----
## create polygons ----
create_polys <- function(n_obs = 5, side_length = 5){
    lat_range <- seq(-85, 85, by = 5)
    lng_range <- seq(-175, 175, by = 5)
    y_origin <- sample(lat_range, n_obs, replace = F)
    x_origin <- sample(lng_range, n_obs, replace = F)
    df <- tibble()
    for(i in 1:length(x_origin)){
        p <-
            tibble(
                id = i,
                x_1 = x_origin[i],
                y_1 = y_origin[i],
                x_2 = x_origin[i],
                y_2 = y_origin[i] + side_length,
                x_3 = x_origin[i] + side_length,
                y_3 = y_origin[i] + side_length,
                x_4 = x_origin[i] + side_length,
                y_4 = y_origin[i],
                x_5 = x_origin[i],
                y_5 = y_origin[i]
                )
        p_xy <-
            p |>
            pivot_longer(cols = x_1:y_5) |>
            separate(name, into = c("axis", "call"), sep = "_") |>
            select(id, call, everything()) |>
            pivot_wider(names_from = axis, values_from = value) |>
            select(-call)
        df <- dplyr::bind_rows(df, p_xy)
    }

    sf <- sfheaders::sf_polygon(
        obj = df,
        , x = "x"
        , y = "y"
        , polygon_id = "id"
    )
    sf::st_crs(sf) <- "WGS84"
    sf$var_cont <- rnorm(n_obs)
    sf$var_fact <- ggplot2::cut_interval(sf$var_cont, n = 5, labels = c(letters[1:5]))
    sf$id <- as.character(sf$id)
    sf
}
## save ggplot ----
rw_ggsave <- function(filename){
    ggsave(
        filename = filename,
        height = 5,
        width = 8,
        units = "in",
        dpi = 600
    )
}
rw_tmap_save <- function(filename, ...){
    tmap_save(tm1,
              filename = filename,
              width = 8,
              height = 5,
              units = "in",
              dpi = 600)
}
# build ----
polys <- create_polys(n_obs = 25, side_length = 5)
# add centroids ----
poly_ctr <-
    polys %>%
    sf::st_centroid() %>%
    dplyr::mutate(lon = sf::st_coordinates(.)[, 1],
                  lat = sf::st_coordinates(.)[, 2])

# plot base ----
st_crs(polys)
plot(polys["id"],
     #pal = sf.colors(8, categorical = TRUE),
     axes = T,
     border = "grey20",
     bg = "aliceblue",
     main = "Variable Factor",
     key.pos = 4,
     key.length = .75,
     key.width = lcm(1.5),
     graticule = T
     )

st_crs(poly_ctr)
plot(poly_ctr,
     pch = 3,
     col = "red",
     axes = T,
     add = T)
dev.off()


# ggplot ----
## label factor ----
library(ggplot2)
library(ggrepel)
colors <- colorspace::qualitative_hcl(n = 5, palette = "pastel1") |> dput()
    ggplot() +
    geom_sf(data = polys, mapping = aes(fill = var_fact), show.legend = T) +
    scale_fill_manual("Factor", values = colors) +
    geom_sf(data = poly_ctr, size = .75, show.legend = F) +
    geom_label_repel(data = poly_ctr,
                    aes(x = lon, y = lat, label = id),
                    nudge_y = 10,
                    nudge_x = 10,
                    min.segment.length = 0
    ) +
    coord_sf(expand = F) +
    theme_bw() +
    theme(
        panel.grid.major = element_line(
            color = gray(.5),
            linetype = "dotted",
            linewidth = 0.25
            ),
        panel.background = element_rect(
            fill = "lightskyblue1"
            )
    ) +
    labs(title = "Square Land - Factor Variable",
         subtitle = "ggrepel - geom_label_repel",
         caption = "Source: My data") +
    xlab("Longitude") +
    ylab("Latitude")

rw_ggsave(filename = "./img/squared_world_ggplot_label_factor.jpg")
## label continuous -----
colors <- diverge_hcl(n = 5, palette = "tropic")
ggplot() +
    geom_sf(data = polys, mapping = aes(fill = var_cont), show.legend = T) +
    scale_fill_gradientn("Continuous", colours = colors) +
    geom_sf(data = poly_ctr, size = .75, show.legend = F) +
    geom_label_repel(data = poly_ctr,
                     aes(x = lon, y = lat, label = id),
                     nudge_y = 10,
                     nudge_x = 10,
                     min.segment.length = 0
    ) +
    coord_sf(expand = F) +
    theme_bw() +
    theme(
        panel.grid.major = element_line(
            color = gray(.5),
            linetype = "dotted",
            linewidth = 0.25
        ),
        panel.background = element_rect(
            fill = "lightskyblue1"
        )
    ) +
    labs(title = "Square Land - Continuous Variable",
         subtitle = "ggrepel - geom_label_repel",
         caption = "Source: My data") +
    xlab("Longitude") +
    ylab("Latitude")

rw_ggsave(filename = "./img/squared_world_ggplot_label_cont.jpg")
## text factor ----
colors <- colorspace::qualitative_hcl(n = 5, palette = "pastel1") |> dput()
ggplot() +
    geom_sf(data = polys, mapping = aes(fill = var_fact), show.legend = T) +
    scale_fill_manual("Factor", values = colors) +
    geom_sf(data = poly_ctr, size = .75, show.legend = F) +
    geom_text_repel(data = poly_ctr,
                     aes(x = lon, y = lat, label = id),
                     nudge_y = 10,
                     nudge_x = 10,
                     min.segment.length = 0
    ) +
    coord_sf(expand = F) +
    theme_bw() +
    theme(
        panel.grid.major = element_line(
            color = gray(.5),
            linetype = "dotted",
            linewidth = 0.25
        ),
        panel.background = element_rect(
            fill = "lightskyblue1"
        )
    ) +
    labs(title = "Squared World - Factor Variable",
         subtitle = "ggrepel - geom_text_repel",
         caption = "Source: My data") +
    xlab("Longitude") +
    ylab("Latitude")

rw_ggsave(filename = "./img/squared_world_ggplot_text_factor.jpg")
## text continuous ----
colors <- diverge_hcl(n = 5, palette = "green-orange")
ggplot() +
    geom_sf(data = polys, mapping = aes(fill = var_cont), show.legend = T) +
    scale_fill_gradientn("Continuous", colours = colors) +
    geom_sf(data = poly_ctr, size = .75, show.legend = F) +
    geom_text_repel(data = poly_ctr,
                     aes(x = lon, y = lat, label = id),
                     nudge_y = 10,
                     nudge_x = 10,
                     min.segment.length = 0
    ) +
    coord_sf(expand = F) +
    theme_bw() +
    theme(
        panel.grid.major = element_line(
            color = gray(.5),
            linetype = "dotted",
            linewidth = 0.25
        ),
        panel.background = element_rect(
            fill = "lightskyblue1"
        )
    ) +
    labs(title = "Squared World - Continuous Variable",
         subtitle = "ggrepel - geom_text_repel",
         caption = "Source: My data") +
    xlab("Longitude") +
    ylab("Latitude")
rw_ggsave(filename = "./img/squared_world_ggplot_text_cont.jpg")
# tmap ----
## label factor ----
values <- qualitative_hcl(n = 5, palette = "pastel1")
tm1 <-
tm_shape(polys) +
    tm_borders("gray50", lwd = .25) +
    tm_polygons(fill = "var_fact",
                fill.scale = tm_scale_categorical(values = values),
                fill.legend = tm_legend("Factor")) +
    tm_labels(text = "id",
              bgcol = "white",
              col = "black",
              size = .8,
              angle = 0,
              dots.just = "top",
              options = opt_tm_labels(point.label = T,
                                      point.label.gap = 1,
                                      remove.overlap = F,
                                      point.label.method = "SANN")) +
tm_grid(labels.show = T,  alpha = .5) +
tm_title_out("Square World") +
tm_credits("Source: My Data", position = c(.75, .1)) +
tm_xlab("Longitude") +
tm_ylab("Latitude", rotation = 90) +
tm_layout(
    bg.color = "lightskyblue1",
    inner.margins = 0,
    frame = "grey50",
    frame.lwd = 3,
    frame.double.line = F,
    outer.bg.color = "#00000000"
)
tm1
rw_tmap_save(tm1, filename = "./img/squared_world_tmap_label_factor.jpg")

## label continuous ----
values <- colorspace::diverge_hcl(n = 5, palette = "Purple-Brown")
tm2 <-
    tm_shape(polys) +
    tm_borders("gray50", lwd = .25) +
    tm_polygons(fill = "var_cont",
                fill.scale = tm_scale_continuous(values = values),
                fill.legend = tm_legend("Continuous", bg.color = "white")) +
    tm_labels(text = "id",
              bgcol = "white",
              col = "black",
              size = .8,
              angle = 0,
              dots.just = "top",
              options = opt_tm_labels(point.label = T,
                                      point.label.gap = 1,
                                      remove.overlap = F,
                                      point.label.method = "SANN")) +
    tm_grid(labels.show = T,  alpha = .5) +
    tm_title_out("Square World") +
    tm_xlab("Longitude") +
    tm_ylab("Latitude", rotation = 90) +
    tm_credits("Source: My Data", position = c(.75, .1)) +
    tm_layout(
        bg.color = "lightskyblue1",
        inner.margins = 0,
        frame = "grey50",
        frame.lwd = 3,
        frame.double.line = F,
        outer.bg.color = "#00000000"
    )
tm2
rw_tmap_save(tm2, filename = "./img/squared_world_tmap_label_cont.jpg")
## text factor ----
values <- qualitative_hcl(n = 5, palette = "pastel1")
tm3 <-
    tm_shape(polys) +
    tm_borders("gray50", lwd = .25) +
    tm_polygons(fill = "var_fact",
                fill.scale = tm_scale_categorical(values = values),
                fill.legend = tm_legend("Factor")) +
    tm_text(text = "id",
              col = "black",
              size = .8,
              angle = 0,
              dots.just = "top",
              options = opt_tm_labels(point.label = T,
                                      point.label.gap = .8,
                                      remove.overlap = F,
                                      point.label.method = "SANN")) +
    tm_grid(labels.show = T,  alpha = .5) +
    tm_title_out("Square World") +
    tm_credits("Source: My Data", position = c(.75, .1)) +
    tm_xlab("Longitude") +
    tm_ylab("Latitude", rotation = 90) +
    tm_layout(
        bg.color = "lightskyblue1",
        inner.margins = 0,
        frame = "grey50",
        frame.lwd = 3,
        frame.double.line = F,
        outer.bg.color = "#00000000"
    )
tm3
rw_tmap_save(tm3, filename = "./img/squared_world_tmap_text_factor.jpg")
## text cont -----
values <- colorspace::diverge_hcl(n = 5, palette = "Purple-Brown")
tm4 <-
    tm_shape(polys) +
    tm_borders("gray50", lwd = .25) +
    tm_polygons(fill = "var_cont",
                fill.scale = tm_scale_continuous(values = values),
                fill.legend = tm_legend("Continuous", bg.color = "white")) +
    tm_text(text = "id",
              col = "black",
              size = .8,
              angle = 0,
              dots.just = "top",
              options = opt_tm_labels(point.label = T,
                                      point.label.gap = 1,
                                      remove.overlap = F,
                                      point.label.method = "SANN")) +
    tm_grid(labels.show = T,  alpha = .5) +
    tm_title_out("Square World") +
    tm_xlab("Longitude") +
    tm_ylab("Latitude", rotation = 90) +
    tm_credits("Source: My Data", position = c(.75, .1)) +
    tm_layout(
        bg.color = "lightskyblue1",
        inner.margins = 0,
        frame = "grey50",
        frame.lwd = 3,
        frame.double.line = F,
        outer.bg.color = "#00000000"
    )
tm4
rw_tmap_save(tm4, filename = "./img/squared_world_tmap_text_cont.jpg")
