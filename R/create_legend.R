library(ggplot2)
library(cowplot)
library(classInt)
library(colorspace)
data(diamonds)
head(diamonds)

breaks <- classIntervals(diamonds$depth, n = 5, style = "fisher")$brks
breaks
breaks_tbl <- data.frame(
    ymin = breaks[1:length(breaks) - 1],
    ymax = breaks[2:length(breaks)],
    xmin = -Inf,
    xmax = Inf,
    fill = letters[1:length(breaks) - 1]
)
breaks_tbl


p1 <- ggplot() +
    geom_rect(breaks_tbl, mapping = aes(xmin = xmin, xmax = xmax,
                       ymin = ymin, ymax = ymax, fill = fill),
              show.legend = F) +
    scale_fill_discrete_diverging(n = 5, palette = "Tropic") +
    geom_histogram(data = diamonds,
                   binwidth = .5,
                   aes(y = depth,
                       x = after_stat(count / sum(count))),
                   fill = "gray80", alpha = .5, color = "black") +
    scale_y_continuous(breaks = breaks,
                       expand = expansion(mult = 0)) +
    scale_x_continuous(expand = expansion(mult = c(0, 0.01)),
                       labels = scales::label_percent()) +
    labs(x = "", y = "") +
    #coord_flip() +
    theme_cowplot()
p1
p2 <- ggplot() +
    geom_boxplot(diamonds, mapping = aes(y = depth)) +
    stat_boxplot(diamonds, mapping = aes(y = depth), geom ='errorbar', width = .25) +
    scale_y_continuous(expand = expansion(mult = c(.01, .01))) +
    #coord_flip() +
    cowplot::theme_nothing()
p2
cowplot::plot_grid(p1, p2,
                   ncol = 2, rel_widths =  c(5, 1),
                   align = 'h', axis = 'lr')
