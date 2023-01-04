ggplot() +
  geom_line(aes(x = AllPatterns$TestletNum, y = AllPatterns$LL,
                group = AllPatterns$line_id,
                color = factor(AllPatterns$final_LL)),
            stat = "smooth", method = "loess", alpha = 0.009, size = 1) +
  geom_point(aes(x = PlotData$TestletNum, y = PlotData$LL_Numeric,
                 size = PlotData$NumStu),
             color = "black", alpha = 0.4) +
  scale_x_continuous(limits = c(1, num_testlets),
                     breaks = seq(1, num_testlets, 1)) +
  scale_y_continuous(limits = c(0,6), breaks = seq(0,6,1),
                     labels = c(0, "Initial\nPrecursor", "Distal\nPrecursor",
                                "Proximal\nPrecursor", "Target", "Successor",
                                6)) +
  coord_cartesian(ylim = c(0.75, 5.25),
                  xlim = c(0.75,
                           max(AllPatterns$TestletNum, na.rm = TRUE) + 0.25)) +
  labs(x = "Testlet Number", y = "Linkage Level") +
  scale_size_area(name = "Number of\nStudents",
                  limits = c(0, num_stu),
                  max_size = 15,
                  breaks = c(100, 250, seq(500, num_stu, 500))) +
  scale_color_manual(name = "Ending\nLinkage Level",
                     values = c("firebrick", "darkorange2", "deepskyblue",
                                "blue", "green"),
                     labels = c("Initial\nPrecursor", "Distal\nPrecursor",
                                "Proximal\nPrecursor", "Target", "Successor")) +
  theme(legend.position = "bottom",
        legend.box = "vertical",
        legend.title = element_text(face = "bold")) +
  guides(
    color = guide_legend(nrow = 1, order = 1, override.aes = list(alpha = 1)),
    size = guide_legend(nrow = 1, order = 2)
  ) -> img

ggsave("emip-2016.png", plot = img, path = "~/Desktop/", width = 12, height = 8,
  units = "in", dpi = "retina")
