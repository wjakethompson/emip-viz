# Setup ------------------------------------------------------------------------
library(tidyverse)
library(here)

library(ggraph)
library(colorblindr)

network <- read_rds(here("2020-edmeas-network", "data", "network.rds"))


# Make plot --------------------------------------------------------------------
plot <- ggraph(network, layout = "linear", circular = TRUE) +
  geom_edge_arc2(aes(alpha = weight, edge_color = node.louvain),
                 width = 1, show.legend = FALSE) +
  geom_node_point(aes(color = louvain, size = betweenness)) +
  scale_edge_alpha_continuous(range = c(0.2, 0.8)) +
  scale_color_OkabeIto() +
  scale_edge_color_manual(values = palette_OkabeIto[1:7]) +
  scale_size_area() +
  coord_fixed() +
  labs(color = NULL) +
  theme_graph() +
  theme(legend.position = "right",
        text = element_text(family = "Arial Narrow")) +
  guides(size = FALSE,
         color = guide_legend(byrow = FALSE, ncol = 1,
                              override.aes = list(size = 3)))

ggsave(filename = "network.png", plot = plot, path = here("2020-edmeas-network"),
       width = 8, height = 6, units = "in", dpi = "retina")
