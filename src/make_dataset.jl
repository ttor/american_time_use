function preprocess_datafiles()
  # read unprocessed datafiles
  data = readtable("../data/raw/atussum.csv")

  # define activity-to-columns matching
  # format:
  # symbol for building dataframe, array of symbols corresponding to activity in original data
  headers=string.(names(data))
  activities = ((:sleep,         Symbol.(["t010101"])),
                (:work,          Symbol.(["t050101", "t050102"])),
                (:tv,            Symbol.(["t120305", "t120303", "t120304", "t120308"])),
                (:edu,           Symbol.(filter(x->ismatch(r"t06",x),headers))),
                (:household,     Symbol.(filter(x->ismatch(r"t02",x),headers))),
                (:relax,         Symbol.(filter(x->ismatch(r"t12",x),headers))),
                (:carehh,        Symbol.(filter(x->ismatch(r"t03",x),headers))),
                (:eat,           Symbol.(filter(x->ismatch(r"t11",x),headers))),
                (:travel,        Symbol.(filter(x->ismatch(r"t18",x),headers))),
                (:personalcare,  Symbol.(filter(x->ismatch(r"t01.[^1]",x),headers))),
                (:sport,         Symbol.(filter(x->ismatch(r"t13",x),headers))),
                (:buy,           Symbol.(filter(x->ismatch(r"t07",x),headers))),
                (:religion,      Symbol.(filter(x->ismatch(r"t14",x),headers))),
                (:telephone,     Symbol.(filter(x->ismatch(r"t16",x),headers))),
                (:carenhh,       Symbol.(filter(x->ismatch(r"t04",x),headers))),
                (:volunteer,     Symbol.(filter(x->ismatch(r"t15",x),headers)))
            );
  # build new dataframe
  data2=DataFrame()
  data2[:weight] = data[:tufnwgtp]
  data2[:age] = data[:teage]
  data2[:employment] = data[:trdpftpt]
  for act in activities
    sym = act[1]
    data2[sym] = 0
    for origsym in act[2]
      data2[sym] += data[origsym]
    end
  end

  #write processed data
  mkpath("../data/processed")
  writetable("../data/processed/processed.csv",data2)
end
