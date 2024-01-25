# GDP ---------------------------------------------------------------------

path_gdp <- "data-raw/renamed/GDP_1960-2022_2023-10-30.csv"
gdp_table <- read_csv(path_gdp, col_names = TRUE, skip = 4)
names(gdp_table)
head(gdp_table)
gdp_table <- gdp_table |> 
  janitor::clean_names() |> 
  rename_with(~ str_replace(., "x(\\d+)", "year_\\1"), starts_with("x"))  

gdp_long <- gdp_table |> 
  pivot_longer(
    cols = c(year_1960:year_2022),
    names_to = "year",
    values_to = "dgp_per_capita") |> 
  mutate(country = country_name, dgp_per_capita = dgp_per_capita, year, .keep = "none") |> 
  relocate(country)

gdp_long <- gdp_long |>  
  mutate(dgp_per_capita = round(dgp_per_capita, 2), 
         year = str_remove(year, "year_")) |> 
  mutate(year= year |> as.integer())

write_rds(gdp_long,"data/clean-raw/gdp.rds")
gdp<-read_rds("data/clean-raw/gdp.rds")

