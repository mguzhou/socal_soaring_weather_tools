"""
Plot MSLP pressure difference (LAX − DAG) from a TSV produced by hrrr_pressure_diff.py.

Usage:
  julia plot_pressure_diff.jl                          # reads hrrr_pressure_diff.tsv
  julia plot_pressure_diff.jl path/to/file.tsv
"""

using CSV, DataFrames, Dates, CairoMakie

tsv_path = length(ARGS) > 0 ? ARGS[1] : "hrrr_pressure_diff.tsv"
df = CSV.read(tsv_path, DataFrame)

times = DateTime.(df.valid_time_pt, dateformat"yyyy-mm-dd HH:MM")
diff  = df.diff_hpa

# Makie requires numeric x-axis — convert DateTime to Float64 (ms since epoch)
t_num = Float64.(Dates.value.(times))

GREEN = RGBf(0.263, 0.627, 0.278)   # #43A047
RED   = RGBf(0.898, 0.224, 0.208)   # #E53935

# Build daily x-axis ticks
tick_times  = filter(t -> hour(t) == 0, times)
tick_vals   = Float64.(Dates.value.(tick_times))
tick_labels = Dates.format.(tick_times, "mm-dd")

struct AppendTicks 
    extra::Vector{Float64}
end
function Makie.get_ticks(t::AppendTicks, scale, formatter, vmin, vmax)
    vals, labels = Makie.get_ticks(Makie.WilkinsonTicks(5; k_min = 4), scale, formatter, vmin, vmax)
    extra = filter(v -> vmin ≤ v ≤ vmax, t.extra)
    all_vals = sort(unique(vcat(vals, extra)))
    all_labels = Makie.get_ticklabels(formatter, all_vals)
    return all_vals, all_labels
end

fig = Figure(size = (1300, 500))
ax  = Axis(fig[1, 1],
    ylabel = "LAX − DAG (hPa)",
    title  = "MSLP Difference (LAX − DAG)",
    limits = (nothing, (-9, 9)),
    xticks = (tick_vals, tick_labels),
    #yticks = AppendTicks([-5.0, -3.0, -1.0]),
)

# Shade positive (onshore) and negative (offshore) regions
band!(ax, t_num, fill(0.0, length(diff)), diff;
    color = [d >= 0 ? (GREEN, 0.25f0) : (RED, 0.25f0) for d in diff])

# Green line for onshore (diff >= 0), red for offshore (diff < 0)
pos_mask = diff .>= 0
neg_mask = diff .<  0

lines!(ax, t_num[pos_mask], diff[pos_mask]; color = GREEN, linewidth = 2)
lines!(ax, t_num[neg_mask], diff[neg_mask]; color = RED,   linewidth = 2)

hlines!(ax, [0];       color = :black, linewidth = 0.8, linestyle = :dash)
hlines!(ax, [-3, -5]; color = RED,   linewidth = 1.2, linestyle = :dot)

# Labels
if length(t_num) > 4
    text!(ax, t_num[5], 7.3;  text = "Onshore",  color = GREEN, fontsize = 24, align = (:left, :top))
    text!(ax, t_num[5], -7.3; text = "Offshore", color = RED,   fontsize = 24, align = (:left, :bottom))
end

out = replace(tsv_path, r"\.tsv$" => ".makie.png")
save(out, fig, px_per_unit = 1.5)
println("Saved → $out")
