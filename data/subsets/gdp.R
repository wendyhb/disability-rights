path <- "data-raw/renamed/gdp_1960-2022_2023-10-30.csv"
gdp <- read_csv(path, col_names = TRUE, skip = 4)

gdp <- gdp |> 
  janitor::clean_names() |> 
  rename_with(~ str_replace(., "x(\\d+)", "year_\\1"), starts_with("x"))  

gdp_long <- gdp |> 
  pivot_longer(
    cols = c(year_1960:year_2022),
    names_to = "year",
    values_to = "gdp_per_capita"
    ) |> 
  mutate(
    country = country_name, 
    gdp_per_capita = gdp_per_capita |> round(2), 
    year = str_remove(year, "year_") |> as.integer(),
    .keep = "none"
    ) |> 
  relocate(country)

write_rds(gdp_long, "data/subsets/gdp.rds")

