#!/usr/bin/env Rscript
# Plot MSLP pressure difference (LAX − DAG) from TSV using base R graphics.
#
# Usage:
#   Rscript plot_pressure_diff_base.R                   # reads hrrr_pressure_diff.tsv
#   Rscript plot_pressure_diff_base.R path/to/file.tsv

args     <- commandArgs(trailingOnly = TRUE)
tsv_path <- if (length(args) > 0) args[1] else "hrrr_pressure_diff.tsv"

df <- read.delim(tsv_path, stringsAsFactors = FALSE)
df$valid_time_pt <- as.POSIXct(df$valid_time_pt, format = "%Y-%m-%d %H:%M", tz = "Etc/GMT+7")

GREEN      <- "#43A047"
RED        <- "#E53935"
GREEN_FILL <- adjustcolor(GREEN, alpha.f = 0.25)
RED_FILL   <- adjustcolor(RED,   alpha.f = 0.25)

out <- sub("\\.tsv$", ".base.png", tsv_path)
png(out, width = 1300, height = 500, res = 150)

par(mar = c(4, 4, 3, 1))

times <- df$valid_time_pt
diff  <- df$diff_hpa

plot(times, diff,
     type = "n",
     ylim = c(-12, 12),
     xlab = "",
     ylab = "LAX \u2212 DAG (hPa)",
     main = paste("MSLP Difference (LAX \u2212 DAG) \u2014", basename(tsv_path)),
     xaxt = "n",
     panel.first = grid(col = "grey90", lty = 1)
)

# Daily x-axis ticks
day_breaks <- seq(
  as.POSIXct(format(min(times), "%Y-%m-%d"), tz = "Etc/GMT+7"),
  max(times),
  by = "day"
)
axis.POSIXct(1, at = day_breaks, format = "%m-%d")

# Shaded fill — positive (onshore)
pos <- ifelse(diff >= 0, diff, 0)
neg <- ifelse(diff <  0, diff, 0)
polygon(c(times, rev(times)), c(pos, rep(0, length(times))),
        col = GREEN_FILL, border = NA)
polygon(c(times, rev(times)), c(neg, rep(0, length(times))),
        col = RED_FILL, border = NA)

# Lines
abline(h = 0, lty = 2, lwd = 0.8)
lines(times[diff >= 0], diff[diff >= 0], col = GREEN, lwd = 2)
lines(times[diff <  0], diff[diff <  0], col = RED,   lwd = 2)

# Labels
if (length(times) >= 5) {
  text(times[5],  5.3, "Onshore",  col = GREEN, cex = 1.6, adj = c(0, 1))
  text(times[5], -5.3, "Offshore", col = RED,   cex = 1.6, adj = c(0, 0))
}

dev.off()
cat(sprintf("Saved \u2192 %s\n", out))
