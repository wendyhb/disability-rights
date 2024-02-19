path <- "data-raw/renamed/freedom_2013-2023_2023-10-30.xlsx"
excel_sheets(path)
freedom <- read_xlsx(path, sheet = 2, col_names = TRUE, start_row = 2)
freedom <- freedom |> 
  janitor::clean_names() |> 
  mutate(
    country = country_territory, year = edition |> as.integer(),
    freedom_index = total, 
    .keep = "none"
    )

write_rds(freedom, "data/freedom.rds")