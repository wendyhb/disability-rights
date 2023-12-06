# freedom -----------------------------------------------------------------

path_freedom <- "data-raw/freedom_index_2013-2023_2023-10-30.xlsx"
excel_sheets(path_freedom)
freedom_table<- read_xlsx(path_freedom, sheet = 2, col_names = TRUE, skip = 1)
names(freedom_table)
head(freedom_table)
freedom <- freedom_table |> 
  janitor::clean_names() |> 
  mutate(country = country_territory, year = edition |> as.integer(), freedom_index = total,.keep = "none")
write_rds(freedom, "data/freedom.rds")
freedom <- read_rds("data/clean-raw/freedom.rds")
