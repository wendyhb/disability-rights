# unemployment rate -------------------------------------------------------

path_unemploy<- "data-raw/unemployment_rate_2023-10-31.csv"
unemploy_table <- read_csv(path_unemploy, col_names = TRUE, skip = 4)
names(unemploy_table)
head(unemploy_table)
unemploy_table <- unemploy_table |> 
  pivot_longer(
  cols = as.character(c(1960:2022)) ,
  names_to = "year",
  values_to = "unemployment_rate"
)
names(unemploy_table)
unemployment <- unemploy_table |> 
  janitor::clean_names() |> 
  mutate(country = country_name, unemployment_rate, year = year |> as.integer(), .keep = "none") |> 
  relocate(country)
write_rds(unemployment, "data/unemployment.rds")
