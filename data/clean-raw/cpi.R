# corruption perceptions index ---------------------------------------------
library(openxlsx2)
path_corruption_index <-"data-raw/renamed/corruption_index_2012-2022_2023-11-8.xlsx"
excel_sheets(path_corruption_index)
corruption_index_table<- read_xlsx(
  path_corruption_index, sheet = 2, col_names = TRUE, start_row = 3)

names(corruption_index_table)
head(corruption_index_table)
corruption_index <- corruption_index_table |> 
  janitor::clean_names() |> 
  select(country = country_territory, starts_with("cpi"))|> 
  pivot_longer(
    cols = c(cpi_score_2022:cpi_score_2012),
    names_to = "year",
    values_to = "cpi_score") |> 
  mutate(year = (year |> str_extract(".{0,4}$") |> as.integer()))
head(corruption_index)
write_rds(corruption_index,"data/clean-raw/corruption_index.rds")

