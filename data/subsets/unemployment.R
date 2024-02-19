path <- "data-raw/renamed/unemployment_2023-10-31.csv"
unemploy <- read_csv(path, col_names = TRUE, skip = 4)

unemploy <- unemploy |> 
  pivot_longer(
  cols = as.character(c(1960:2022)),
  names_to = "year",
  values_to = "unemployment_rate"
  ) |> 
  clean_names() |> 
  mutate(
    country = country_name, 
    unemployment_rate, 
    year = as.integer(year),
    .keep = "none"
    ) |> 
  relocate(country)

write_rds(unemploy, "data/subsets/unemployment.rds")

