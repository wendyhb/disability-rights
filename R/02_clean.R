library(reticulate)
path_to_python <- "C://Users/cyn64/AppData/Local/Microsoft/WindowsApps/python"
use_python(path_to_python)
reticulate::py_config()
# load Python modules
DIFFLIB <-reticulate::import("difflib")
POLYFUZZ <- reticulate::import("polyfuzz")
full_data <- read_rds("data/full_data.rds")
full_data |> names()
full_data <- full_data |> 
  filter(year > 2007)
crpd <- read_rds("data/crpd.rds")
from_vec <- unique(full_data$country)
to_vec <- unique(crpd$country)


