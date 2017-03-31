using DataFrames
using Plots
using StatsBase
activity_symbols=(:sleep,:work,:tv,:edu,:household,:relax,:carehh,:eat,:travel,:personalcare,:sport,:buy,:religion,:telephone,:carenhh,:volunteer)

include("make_dataset.jl")
include("analyze.jl")
include("visualize.jl")

function main(;recreate=false)
  if !isfile("../data/processed/processed.csv") || recreate
    print("Pre-processing data files... ")
    preprocess_datafiles()
    print("done. ")
  end

  print("Reading data file... ")
  data=readtable("../data/processed/processed.csv", nrows=-1)
  println("done")

  print("Analyzing... ")
  work_df, nwork_df =aggregate_by_age(data)
  println("done")

  print("Plotting... ")
  create_plot_workvsfree(work_df,nwork_df)
  create_plot_diff(work_df,nwork_df)
  println("done")
end

#cd to src directory
cd(dirname(@__FILE__))

recreate=false
if(length(ARGS) > 0)
  if(ARGS[1] == "--recreate")
    recreate=true
  end
end

main(recreate=recreate)
