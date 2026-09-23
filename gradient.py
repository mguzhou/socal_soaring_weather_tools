"""The sea-level pressure gradient panel: LAX − DAG against time.

The Santa Ana index. A positive gradient (coastal pressure above desert)
drives onshore flow; negative means the desert is higher and air drains
offshore through the passes, which is the Santa Ana setup. Sustained
negative periods matter more than the peak value -- a gradient that
stays offshore through a diurnal cycle is the signal, where a couple of
hours either side of dawn is just the usual nocturnal drainage.
"""

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import numpy as np

ONSHORE_COLOR = "#43A047"
OFFSHORE_COLOR = "#E53935"


def render_gradient_panel(valid_times_pt, diff, title, ylim=12):
    """Draw the gradient time series and return the figure.

    valid_times_pt is timezone-converted for display; diff is the
    pressure difference in hPa. Positive and negative are drawn as
    separate traces so the sign reads at a glance rather than having to
    be traced against the zero line."""
    fig, ax = plt.subplots(figsize=(13, 5))

    ax.fill_between(valid_times_pt, diff, 0, where=(diff >= 0),
                    interpolate=True, alpha=0.25, color=ONSHORE_COLOR)
    ax.fill_between(valid_times_pt, diff, 0, where=(diff < 0),
                    interpolate=True, alpha=0.25, color=OFFSHORE_COLOR)
    # np.where rather than masking: a plain masked trace would join
    # across the sign change and draw a line through zero that isn't
    # there in the data.
    ax.plot(valid_times_pt, np.where(diff >= 0, diff, np.nan),
            color=ONSHORE_COLOR, linewidth=2)
    ax.plot(valid_times_pt, np.where(diff < 0, diff, np.nan),
            color=OFFSHORE_COLOR, linewidth=2)
    ax.axhline(0, color="k", linewidth=0.8, linestyle="--")

    ax.text(valid_times_pt[4], ylim * 0.61, "Onshore",
            color=ONSHORE_COLOR, fontsize=24, va="top")
    ax.text(valid_times_pt[4], -ylim * 0.61, "Offshore",
            color=OFFSHORE_COLOR, fontsize=24, va="bottom")

    ax.set_ylim(-ylim, ylim)
    ax.set_ylabel("LAX \N{MINUS SIGN} DAG (hPa)")
    ax.set_title(title)
    ax.grid(True, alpha=0.3)

    ax.xaxis.set_major_formatter(mdates.DateFormatter("%m-%d"))
    ax.xaxis.set_major_locator(mdates.HourLocator(byhour=[0]))
    plt.setp(ax.xaxis.get_majorticklabels(), rotation=0, ha="center")

    fig.tight_layout()
    return fig
