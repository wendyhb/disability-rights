# corruption perceptions index ---------------------------------------------

path_cpi<-"data-raw/corruption_index_2012-2022_2023-11-8.xlsx"
excel_sheets(path_cpi)
cpi_table<- read_xlsx(path_cpi, sheet = 2, col_names = TRUE, skip = 2)
names(cpi_table)
head(cpi_table)
cpi <- cpi_table |> 
  janitor::clean_names() |> 
  select(country = country_territory, starts_with("cpi"))|> 
  pivot_longer(
    cols = c(cpi_score_2022:cpi_score_2012),
    names_to = "year",
    values_to = "cpi_score") |> 
  mutate(year = (year |> str_extract(".{0,4}$") |> as.integer()))
head(cpi)
write_rds(cpi,"data/cpi.rds")
cpi$country |> unique()
