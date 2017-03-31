### Data analysis ###

# this helper function works like
# aggregate(df, by_sym, mean)
# but uses column "weight_sym" as weights
function aggregate_wmean(df,by_sym,weight_sym)
  function wmean(df, by_sym, weight_sym)
    ndf=DataFrame()
    for sym in names(df)
      if sym==by_sym || sym==weight_sym continue end
      ndf[Symbol(sym,"_mean")]=mean(df[sym],WeightVec(df[weight_sym]))
    end
    return ndf
  end
  by(df,by_sym,d->wmean(d,by_sym,weight_sym))
end

function aggregate_by_age(data)
  workminutes_cutoff = 60
  # this would work in principle but cannot take the weights into account
  # work_df = aggregate(data[data[:work].>= workminutes_cutoff,:], :age, mean)
  # nwork_df = aggregate(data[data[:work].< workminutes_cutoff,:], :age, mean)

  work_df = aggregate_wmean(data[(data[:work].>= workminutes_cutoff) & (data[:employment] .== 1),:], :age, :weight)
  nwork_df = aggregate_wmean(data[(data[:work].< workminutes_cutoff) & (data[:employment] .== 1),:], :age, :weight)


  # save data for reproducibility
  mkpath("../data/processed")
  writetable("../data/processed/_work.csv",work_df)
  writetable("../data/processed/_nwork.csv",nwork_df)

  #remove "_mean" suffix from column names
  names_df = names(work_df)
  for sym in names_df
    if sym==:age continue end
    nsym = Symbol(replace(string(sym), "_mean", ""))
    rename!(work_df, sym, nsym)
    rename!(nwork_df, sym, nsym)
  end
  return work_df, nwork_df
end
