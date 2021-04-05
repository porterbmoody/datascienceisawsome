set.seed(1014)
options(digits = 3)

library(reticulate)
library(ggplot2)

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = TRUE,
  out.width = "70%",
  fig.align = 'center',
  fig.width = 6,
  fig.asp = 0.618,  # 1 / phi
  fig.show = "hold",
  cache = FALSE,
  engine.path = '/usr/local/bin/python3.8',
  python.reticulate = TRUE
)

options(dplyr.print_min = 6, dplyr.print_max = 6)

