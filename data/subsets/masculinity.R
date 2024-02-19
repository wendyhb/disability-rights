masculinity_ls <- "https://clearlycultural.com/geert-hofstede-cultural-dimensions/masculinity/" |> 
  read_html() |>
  html_elements("table") |> 
  html_table()

masculinity <- masculinity_ls[[2]] |> 
  slice(-2) |> 
  janitor::clean_names() |> 
  select(x1, x4) |> 
  slice(-1) |> 
  rename(country = x1, masculinity = x4) |> 
  mutate(masculinity = as.numeric(masculinity)) |> 
  ## Remove non-UN countries
  filter(!country %in% c("Taiwan", "Hong Kong"))

write_rds(masculinity, "data/subsets/masculinity.rds")



