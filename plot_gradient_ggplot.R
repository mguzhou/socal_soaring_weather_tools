#!/usr/bin/env Rscript
# Plot MSLP pressure difference (LAX − DAG) from TSV using ggplot2.
#
# Usage:
#   Rscript plot_pressure_diff_ggplot.R                   # reads hrrr_pressure_diff.tsv
#   Rscript plot_pressure_diff_ggplot.R path/to/file.tsv

library(ggplot2)

args     <- commandArgs(trailingOnly = TRUE)
tsv_path <- if (length(args) > 0) args[1] else "hrrr_pressure_diff.tsv"

df <- read.delim(tsv_path, stringsAsFactors = FALSE)
df$valid_time_pt <- as.POSIXct(df$valid_time_pt, format = "%Y-%m-%d %H:%M", tz = "Etc/GMT+7")
df$fill_color    <- ifelse(df$diff_hpa >= 0, "onshore", "offshore")

GREEN <- "#43A047"
RED   <- "#E53935"

p <- ggplot(df, aes(x = valid_time_pt, y = diff_hpa)) +
  geom_ribbon(
    aes(ymin = pmin(diff_hpa, 0), ymax = pmax(diff_hpa, 0), fill = fill_color),
    alpha = 0.25
  ) +
  geom_line(
    data = df[df$diff_hpa >= 0, ],
    color = GREEN, linewidth = 0.8
  ) +
  geom_line(
    data = df[df$diff_hpa < 0, ],
    color = RED, linewidth = 0.8
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.5) +
  annotate("text", x = df$valid_time_pt[5], y =  11.3, label = "Onshore",
           color = GREEN, size = 8, vjust = "top") +
  annotate("text", x = df$valid_time_pt[5], y = -11.3, label = "Offshore",
           color = RED,   size = 8, vjust = "bottom") +
  scale_fill_manual(values = c("onshore" = GREEN, "offshore" = RED), guide = "none") +
  scale_x_datetime(date_breaks = "1 day", date_labels = "%m-%d") +
  coord_cartesian(ylim = c(-12, 12)) +
  labs(
    x     = NULL,
    y     = "LAX \u2212 DAG (hPa)",
    title = paste("MSLP Difference (LAX \u2212 DAG) \u2014",Sys.Date() )
  ) +
  theme_minimal(base_size = 13) +
  theme(panel.grid.minor = element_blank())

out <- sub("\\.tsv$", ".ggplot.png", tsv_path)
ggsave(out, p, width = 13, height = 5, dpi = 150)
cat(sprintf("Saved \u2192 %s\n", out))
