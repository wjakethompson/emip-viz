# Setup ------------------------------------------------------------------------
library(tidyverse)
library(here)


# Functions --------------------------------------------------------------------
logit <- function(x) {
  exp(x) / (1 + exp(x))
}
comp <- function(x, y, a1 = 1, a2 = 1, d = 0, c = 0) {
  lin_comb <- (a1 * x) + (a2 * y)
  c + (1 - c) * logit(lin_comb - d)
}
noncomp <- function(x, y, a1 = 1, a2 = 1, d1 = 0, d2 = 0, c = 0) {
  c + (1 - c) * prod(logit((a1 * x) - d1), logit((a2 * y) - d2))
}
partcomp <- function(x, y, a1 = 1, a2 = 1, a3 = 0.3, d = 0, c = 0) {
  c + (1 - c) * logit((a1 * x) + (a2 * y) + (a3 * x * y) - d)
}

# Simulation data --------------------------------------------------------------
theta_1 <- seq(-3, 3, 0.01)
theta_2 <- seq(-3, 3, 0.01)

pl1 <- crossing(theta_1, theta_2) %>%
  mutate(
    Model = "1PL",
    Compensatory = map2_dbl(.x = theta_1, .y = theta_2, .f = comp),
    Noncompensatory = map2_dbl(.x = theta_1, .y = theta_2, .f = noncomp),
    Partial = map2_dbl(.x = theta_1, .y = theta_2, .f = partcomp, a3 = 0.3)
  )

pl2 <- crossing(theta_1, theta_2) %>%
  mutate(
    Model = "2PL",
    Compensatory = map2_dbl(.x = theta_1, .y = theta_2, .f = comp,
                            a1 = 0.8, a2 = 1.8),
    Noncompensatory = map2_dbl(.x = theta_1, .y = theta_2, .f = noncomp,
                               a1 = 0.8, a2 = 1.8),
    Partial = map2_dbl(.x = theta_1, .y = theta_2, .f = partcomp,
                       a1 = 0.8, a2 = 1.8, a3 = 0.3)
  )

pl3 <- crossing(theta_1, theta_2) %>%
  mutate(
    Model = "3PL",
    Compensatory = map2_dbl(.x = theta_1, .y = theta_2, .f = comp,
                            a1 = 0.8, a2 = 1.8, c = 0.2),
    Noncompensatory = map2_dbl(.x = theta_1, .y = theta_2, .f = noncomp,
                               a1 = 0.8, a2 = 1.8, c = 0.2),
    Partial = map2_dbl(.x = theta_1, .y = theta_2, .f = partcomp,
                       a1 = 0.8, a2 = 1.8, a3 = 0.3, c = 0.2)
  )


# Make plot --------------------------------------------------------------------
bind_rows(pl1, pl2, pl3) %>%
  gather(Method, Probability, Compensatory:Partial) %>%
  mutate(Method = factor(Method, levels = c("Compensatory", "Partial",
                                            "Noncompensatory"),
                         labels = c("Compensatory", "Partially Compensatory",
                                    "Noncompensatory"))) %>%
  ggplot(mapping = aes(x = theta_1, y = theta_2)) +
  facet_grid(Model ~ Method) +
  geom_raster(aes(fill = Probability), interpolate = TRUE) +
  geom_contour(aes(z = Probability), color = "black", binwidth = 0.1) +
  scale_x_continuous(breaks = seq(-10, 10, 1)) +
  scale_y_continuous(breaks = seq(-10, 10, 1)) +
  scale_fill_distiller(name = "Probability of Correct Response",
                       palette = "Spectral", direction = -1, limits = c(0, 1),
                       breaks = seq(0, 1, 0.1)) +
  labs(x = expression(paste(theta[1])), y = expression(paste(theta[2]))) +
  theme_minimal() +
  theme(
    aspect.ratio = 1,
    legend.position = "bottom",
    legend.title = element_text(vjust = 0.5, size = 14),
    legend.text = element_text(size = 12),
    axis.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    strip.text = element_text(face = "bold", size = 14),
    legend.key.width = unit(1, "inches")
  ) +
  guides(fill = guide_colorbar(title.position = "top", title.hjust = 0.5)) -> p

ggsave("mirt-visualization.png", plot = p, path = here("2017-mirt-models"),
       width = 10, height = 11, units = "in", dpi = "retina", bg = "white")
