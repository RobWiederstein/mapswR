# libraries ----
library(colorspace)
library(cowplot)
library(dplyr)
library(ggplot2)
library(ggspatial)
library(rmapshaper)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)

# base ----
ne_states(country = 'united states of america') %>%
select(name, postal, geometry) %>%
filter(postal != "DC") %>%
mutate(cont_var = rnorm(n = 50), .before = geometry) %>%
mutate(
    fact_var = cut_interval(
        cont_var,
        n = 5,
        labels = c("very low", "low", "average",
                   "high", "very high" )
    ),
    ordered_result = T
) %>%
rmapshaper::ms_simplify(method = "vis", weighting = .05) %>%
st_transform(2163) -> us
us %>% mutate(fact_var = forcats::fct_rev(fact_var)) -> us
#create mainland ----

ggplot() +
geom_sf(us, mapping = aes(geometry = geometry,
                      fill = fact_var),
        linewidth = .4,
        color = "gray80") +
scale_fill_discrete_sequential(palette = "Emrld", rev = F) +
geom_sf_text(us, mapping = aes(label = postal), size = 3, check_overlap = T) +
coord_sf(crs = st_crs(2163),
         xlim = c(-2500000, 2500000),
         ylim = c(-2300000, 730000)) +
theme_nothing() -> main
main
# create alaska ----
ggplot(data = us) +
geom_sf(mapping = aes(fill = fact_var), show.legend = F) +
coord_sf(
    crs = st_crs(3467),
    xlim = c(-2400000, 1600000),
    ylim = c(200000, 2500000),
    expand = FALSE,
    datum = NA) +
#scale_fill_continuous_sequential(palette = "Emrld") +
scale_fill_discrete_sequential(palette = "Emrld", rev = F) +
geom_sf_text(data = us, mapping = aes(label = postal), size = 3) +
theme_nothing() -> ak
# create hawaii ----
ggplot(data = us) +
geom_sf(mapping = aes(fill = fact_var), show.legend = F) +
coord_sf(crs = st_crs(4135),
         xlim = c(-161, -154),
         ylim = c(18, 23),
         expand = FALSE,
         datum = NA) +
#scale_fill_continuous_sequential(palette = "Emrld") +
scale_fill_discrete_sequential(palette = "Emrld", rev = F) +
geom_sf_text(data = us,
             mapping = aes(label = postal),
             size = 3,
             check_overlap = T) +
theme_nothing() -> hi
# assemble plots
main +
annotation_custom(
    grob = ggplotGrob(hi),
    xmin = -1250000,
    xmax = -1250000 + (-154 - (-161)) * 120000,
    ymin = -2450000,
    ymax = -2450000 + (23 - 18) * 120000
) +
annotation_custom(
    grob = ggplotGrob(ak),
    xmin = -2750000,
    xmax = -2750000 + (1600000 - (-2400000))/2.5,
    ymin = -2450000,
    ymax = -2450000 + (2500000 - 200000)/2.5
) +
theme_nothing() +
theme(
      legend.position = "right",
      legend.key.spacing.y = unit(2, units = "points")
      )

# save ----
final
ggsave("./img/us_map_fourth.jpg",
       height = 5,
       width = 8,
       unit = "in",
       dpi = 600)
