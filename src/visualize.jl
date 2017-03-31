# mapping symbols to Human-readable label
activities_h = (
                (:work,         "Work"),
                (:sleep,        "Sleep"),
                (:tv,           "TV/Radio/Computer"),
                (:relax,        "Socalizing, Relaxing, Leisure"),
                (:household,    "Household chores"),
                (:sport,        "Sports, Exercise, Recreation"),
                (:edu,          "Education"),
                (:religion,     "Religious & Spiritual activities"),
                (:buy,          "Consumer Purchases"),
                (:travel,       "Travelling"),
                (:eat,          "Eating and drinking"),
                (:personalcare, "Personal Care"),
                (:carehh,       "Caring for household members"),
                (:carenhh,      "Caring for non HH members"),
                (:volunteer,    "Volunteering"),
                (:telephone,    "Telephone"));


# Formatter for y-axis
function timeformatter(x)
  if abs(x)<=60
    minutes=round(Int,x)
    return string(minutes)*"m"
  else
    hours, minutes = fldmod(round(Int,x),60)
    if minutes == 0
      return string(hours)*"h:00m"
    else
      return string(hours)*"h:"*string(minutes)*"m"
    end
  end
end

# Tick selection helper function
import PlotUtils
function optimize_minutes_ticks(mmin,mmax,k_min=2,k_max=4)
  msec_per_min=60000
  return PlotUtils.optimize_datetime_ticks(mmin*msec_per_min-1, mmax*msec_per_min, k_min=k_min,k_max=k_max)[1]/msec_per_min
end

# Annotation overlay
# usage:
# overlay = add_annotation_overlay!(p)
# annotate!(overlay, [(0.95, 0.15,"annotation")])
function add_annotation_overlay!(p)
  overlay=plot!(inset = (bbox(0.0,0.0,1,1, :bottom,:right)), ticks=nothing, subplot=length(p)+1, bg_inside=nothing,grid=false,border=nothing,leg=false)
  return p[end]
end


# Apply loess smoothing to (x,y)
import Loess
function loess_filter(x,y)
  model=Loess.loess(Float64.(x),Float64.(y))
  return Loess.predict(model,Float64.(x))
end


function create_plot_workvsfree(work_df, nwork_df)

    # a list of available fonts: PyPlot.matplotlib[:font_manager][:findSystemFonts]()
    # or in python:
    # import matplotlib.font_manager
    # set([f.name for f in matplotlib.font_manager.fontManager.ttflist])
    # I picked Arial as the closest Helvetica alternative available
    tickfont = Plots.font("Arial", 18)
    titlefont = Plots.font("Arial", 20)
    annotation_font = Plots.font("Arial", 16, :left)
    default(xtickfont=tickfont, ytickfont=tickfont, titlefont=titlefont)
    #gr()
    #4x4 plot layout plus an extended plot to create space for annotations
    l = @layout  [grid(4,4);b{0.01h} ]
    p=plot(layout=l,axis=true,size=(2400,2000),left_margin=50px, bottom_margin=50px,top_margin=50px, right_margin=50px)
    overlay=add_annotation_overlay!(p)

    #add actual plots
    for i in 1:size(activities_h,1)
      sym=activities_h[i][1]
      title_txt=activities_h[i][2]

      #non workdays
      x=convert(Array,nwork_df[:age])
      y=convert(Array,nwork_df[sym])
      y_smooth = loess_filter(x,y)
      scatter!(p[i], x, y, leg=false, label="", title=title_txt, color=:orange, marker=:rect, markersize=3,markerstrokewidth=0)
      plot!(p[i], x, y_smooth, leg=false, label="Non-workday", title=title_txt, lw=4, color=:orange)

      #workdays
      x=convert(Array,work_df[:age])
      y=convert(Array,work_df[sym])
      y_smooth = loess_filter(x,y)
      scatter!(p[i], x, y, leg=false, label="", title=title_txt, color=:green, marker=:circle, markersize=3,markerstrokewidth=0)
      plot!(p[i], x, y_smooth, leg=false, label="Workday", title=title_txt,ls=:dash, color=:green, lw=4)

      #adjust y-limits and optimize tick marks for minutes/hours
      ylims!(p[i], 0, Inf)
      expand_factor=1.2
      upper_y=ylims(p[i])[2]*expand_factor
      ylims!(p[i],0,upper_y)
      ticks=optimize_minutes_ticks(0,upper_y)
      yticks!(p[i], ticks, formatter=timeformatter)
      xticks!(p[i], 20:20:80 ,string.(20:20:80).*"yrs",grid=false)
      # this also applies to xaxis in PyPlot, probably a bug
      yaxis!(p[i],foreground_color_border=:white)
    end

    # put legend in a selected subplot
    plot!(p[4], leg=true,legendfont=tickfont)

    # add data source information in plot "17"
    plot!(p[17],axis=false)
    annotate!(overlay, [(0.75, 0.03, text("\nData source: American Time Use Survey (ATUS) 2003-2015\nBureau of Labor Statistics\nhttps://www.bls.gov/tus/datafiles_0315.htm\nWorkdays are days with more than 1 hour of work.",annotation_font))])

    # save file using Plots interface
    savefig("../figures/workfvsfree.pdf")

    # PyPlot fine-tuning by working on Plots.o
    p=current()

    # remove top and right ticksmarks, add x-spine, change titlefont weight to "bold"
    for i in 1:16
      ax=p.o[:axes][i]
      ax[:xaxis][:set_ticks_position]("bottom")
      ax[:yaxis][:set_ticks_position]("left")
      ax[:spines]["bottom"][:set_color]("grey")
      ax[:spines]["bottom"][:set_linewidth](1.5)
      title_text=ax[:get_title]()
      ax[:set_title](title_text, fontweight="bold", fontsize=titlefont.pointsize)
    end

    # save figure -- use PyPlot.savefig because we have modified the PyPlot object
    p.o[:set_size_inches](610/25.4, 508/25.4)
    PyPlot.savefig("../figures/workfvsfree.pdf")
end



function create_plot_diff(work_df, nwork_df)

  # a list of available fonts: PyPlot.matplotlib[:font_manager][:findSystemFonts]()
  # or in python:
  # import matplotlib.font_manager
  # set([f.name for f in matplotlib.font_manager.fontManager.ttflist])
  # I picked Arial as the closest Helvetica alternative available
  tickfont = Plots.font("Arial", 18)
  titlefont = Plots.font("Arial", 20)
  annotation_font = Plots.font("Arial", 16, :left)
  default(xtickfont=tickfont, ytickfont=tickfont, titlefont=titlefont)
  #gr()
  #4x4 plot layout plus an extended plot to create space for annotations
  l = @layout  [grid(4,4);b{0.01h} ]
  p=plot(layout=l,axis=true,size=(2400,2000),left_margin=50px, bottom_margin=50px,top_margin=50px, right_margin=50px)
  overlay=add_annotation_overlay!(p)

  #add actual plots
  for i in 1:size(activities_h,1)
    sym=activities_h[i][1]
    title_txt=activities_h[i][2]

    # don't plot work
    if sym==:work
      plot!(p[i],ticks=nothing, bg_inside=nothing,grid=false,border=nothing,leg=false)
      continue
    end;

    #non workdays
    x=convert(Array,nwork_df[:age])
    y1=convert(Array,nwork_df[sym])
    y1_smooth = loess_filter(x,y1)
    y2=convert(Array,work_df[sym])
    y2_smooth = loess_filter(x,y2)
    y=y1-y2
    y_smooth=y1_smooth-y2_smooth
    scatter!(p[i], x, y, leg=false, label="", title=title_txt, color=:orange, marker=:rect, markersize=3,markerstrokewidth=0)
    plot!(p[i], x, y_smooth, leg=false, label="additional time spent\non days off", title=title_txt, lw=4, color=:orange)

    #adjust y-limits and optimize tick marks for minutes/hours
    #ylims!(p[i], 0, Inf)
    expand_factor=1.2
    upper_y=ylims(p[i])[2]*expand_factor
    lower_y=ylims(p[i])[1]*expand_factor
    #ylims!(p[i],0,upper_y)
    ticks=optimize_minutes_ticks(lower_y,upper_y)
    yticks!(p[i], ticks, formatter=timeformatter)
    xticks!(p[i], 20:20:80 ,string.(20:20:80).*"yrs",grid=false)
    # this also applies to xaxis in PyPlot, probably a bug
    yaxis!(p[i],foreground_color_border=:white)
  end

  # put legend in a selected subplot
  plot!(p[4], leg=true,legendfont=tickfont)

  # add data source information in plot "17"
  plot!(p[17],axis=false)
  annotate!(overlay, [(0.75, 0.03, text("\nData source: American Time Use Survey (ATUS) 2003-2015\nBureau of Labor Statistics\nhttps://www.bls.gov/tus/datafiles_0315.htm\nWorkdays are days with more than 1 hour of work.",annotation_font))])

  # save file using Plots interface
  savefig("../figures/difference.pdf")

  # PyPlot fine-tuning by working on Plots.o
  p=current()

  # remove top and right ticksmarks, add x-spine, change titlefont weight to "bold"
  for i in 2:16
    ax=p.o[:axes][i]
    ax[:xaxis][:set_ticks_position]("bottom")
    ax[:yaxis][:set_ticks_position]("left")
    ax[:spines]["bottom"][:set_color]("grey")
    ax[:spines]["bottom"][:set_linewidth](1.5)
    title_text=ax[:get_title]()
    ax[:set_title](title_text, fontweight="bold", fontsize=titlefont.pointsize)
  end

  # save figure -- use PyPlot.savefig because we have modified the PyPlot object
  p.o[:set_size_inches](610/25.4, 508/25.4)
  PyPlot.savefig("../figures/difference.pdf")
end
