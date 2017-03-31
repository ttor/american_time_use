american_time_use
==============================

# How do we spend our extra times on days off? 

#### Author: ttor

An analysis of the way employees spend their days off based on the American Time Use Survey (ATUS). 

#### How to use

Run `get_data.sh` to obtain raw data from Bureau of Labor Statistics.
Run `run.jl` to run analysis and create graphs. 


Project Organization
------------

    ├── LICENSE
    ├── README.md          <- The top-level README 
    ├── data
    │   ├── processed      <- Processed data files, ready to plot. 
    │   └── raw            <- The original ATUS data files used.
    │
    ├── references         <- Data dictionaries, manuals, and all other explanatory materials.
    │
    ├── figures            <- Generated graphics and figures
    │
    ├── src                <- Source code for use in this project.
    │   ├── get_data.sh    <- get raw data from Bureau of Labor statistics
    │   │
    │   ├── run.jl         <- run preprocessing, analysis, and plotting, use `--recreate` to 
    │   │                     re-run preprocessing
    │   │
    │   ├── make_dataset.jl<- preprocessing (creates processed.dat)
    │   │
    │   ├── analyze.jl     <- analysis (creates _work.dat, _nwork.dat)
    │   │
    │   ├── visualize.jl   <- create visualizations
    │   │
    │   └── convert.sh     <- convert PDF figures to PNG 

--------

