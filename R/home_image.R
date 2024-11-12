
library(dplyr)
wrld <- rnaturalearth::ne_countries(scale = "large", returnclass = "sf") %>% 
    select(admin, geometry) %>% 
    rmapshaper::ms_filter_islands(min_area = 1e8) %>% 
    mutate(category = sample(1:5, nrow(.), replace = T) )

st_crs(wrld)
wrld1 <- st_transform(wrld, crs = "+proj=moll +lon_0=0 +datum=WGS84 +units=m +no_defs")
plot(wrld1, graticule = T)

library(ggplot2)
library(colorspace)
colors <- colorspace::qualitative_hcl(n = 5, palette = "Set3")

ggplot() +
geom_sf(wrld, mapping =  aes(fill = factor(category)), show.legend = F) +
coord_sf(xlim = c(-120, 60), expand = F, label_axes = "----") +
scale_fill_manual(values = colors) +
theme_bw() +
theme(
    panel.border = element_rect(colour = "black", fill=NA, linewidth = 1),
    panel.background = element_blank(),
    plot.background = element_rect(fill='transparent', color=NA)
)

world_sf <- ne_countries(returnclass = "sf")

# Themed with minimal grid from cowplot

world <- ggplot() +
    geom_sf(data = world_sf )  +
    ggtitle("van der Grinten IV")+
    theme_minimal_grid()+
    coord_sf(crs= "+proj=vandg4")
world

