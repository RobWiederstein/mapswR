library(classInt)
library(cowplot)
library(dplyr)
library(stringr)
library(sf)
library(ggplot2)
library(colorspace)
library(magrittr)
file <- "./data/2024-07-22_us_life_expectancy.rds"
df <- readRDS(file = file)
# distribution ----
df %>%
    ggplot() +
    aes(life_exp) +
    geom_histogram(color = "gray20", fill = "gray80") +
    theme_minimal() +
    labs(title = "2019 U.S. Life Expectancy by County") +
    xlab("years") +
    ylab("counties")
# add interval columns ----
map_life_expectancy <- function(cut_method){
    # read ----
    file <- "./data/2024-07-22_us_life_expectancy.rds"
    df <- readRDS(file = file) %>%
        mutate(
            life_exp_f = cut(
                life_exp,
                breaks = classIntervals(
                            life_exp,
                            n = 5,
                            style = "quantile"
                            )[[2]],
                include.lowest = T))
    # map ----
    ggplot() +
    geom_sf(df, mapping = aes(fill = life_exp_f), show.legend = F) +
    coord_sf(xlim = c(-2036902.7, 5e6)) +
    scale_fill_discrete_diverging(palette = "Blue-Red2", rev = T) +
    theme_map() +
    labs(title = "2019 U.S. Life Expectancy") -> map
    map
    # define breaks ----
    breaks <- classIntervals(df$life_exp,
                             n = 5,
                             style = "quantile",
                             include.lowest = T)$brks

    # bar plot ----
    ggplot(df, aes(x = life_exp_f,
                    fill = life_exp_f)) +
        geom_bar(aes(y = (..count..)/sum(..count..)), show.legend = F) +
        scale_fill_discrete_diverging(palette = "Blue-Red2", rev = T) +
        scale_y_continuous(
            labels = scales::label_percent(),
            expand = expansion(mult = c(0, 0.05))) +
        labs(title = "cut_method", x = "", y = "") +
        coord_flip() +
        theme_half_open() -> bar
    bar
    # assemble ----
    map +
        annotation_custom(
            grob = ggplotGrob(bar),
            xmin = 4.8e6,
            xmax = 2e6,
            ymin = -2.25e6,
            #ymax = 1.5e4
            ymax = .25e6
        )
}

map_life_expectancy(cut_method = "quantile")


