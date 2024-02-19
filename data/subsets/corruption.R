path <- "data-raw/renamed/corruption_2012-2022_2023-11-8.xlsx"
corruption <- read_xlsx(path, sheet = 2, col_names = TRUE, start_row = 3)

corruption <- corruption |> 
  clean_names() |> 
  select(country = country_territory, starts_with("cpi"))|> 
  pivot_longer(
    cols = c(cpi_score_2022:cpi_score_2012),
    names_to = "year",
    values_to = "corruption_score"
    
    ) |> 
  mutate(year = (year |> str_extract(".{0,4}$") |> as.integer()))

write_rds(corruption,"data/subsets/corruption.rds")

