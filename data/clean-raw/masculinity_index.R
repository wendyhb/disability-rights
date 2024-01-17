
source("R/my-packages.R")
url <- "https://clearlycultural.com/geert-hofstede-cultural-dimensions/masculinity/"
html_masculinity <- read_html(url)
masculinity_df <- html_masculinity |>
  html_elements("table") |> 
  html_table()
masculinity_index <- masculinity_df[[2]] |> 
  slice(-2) |> 
  janitor::clean_names() |> 
  select(x1,x4) |> 
  slice(-1) |> 
  rename(country = x1, masculinity_index = x4) |> 
  mutate(year = 2023) |> 
  filter(!country %in% c("Taiwan","Hong Kong"))
write_rds(masculinity_index, "data/clean-raw/masculinity_index.rds")
# 64 countries in total



