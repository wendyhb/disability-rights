# use loops and map to get different years
# after that add year columns to every table
years <- 2012:2023
table_ls <- list()
base_url <- "https://www.numbeo.com/crime/rankings_by_country.jsp"

for (i in seq_along(years)){
  
  suffix <- if (years[i] %in% c(2012, 2013)) "-Q1" else ""
  url <- glue("{base_url}?title={years[i]}{suffix}")
  table <- url |> 
    read_html() |>  
    html_element("#t2") |>
    html_table()
  table$year <- years[i]
  table_ls[[i]] <- table
}

## Combine 12 tables into 1
safety <- do.call(rbind, table_ls) |> 
  rename_with(snakecase::to_snake_case) |>
  select(- rank)

stopifnot(identical(unique(safety$year), years))

write_rds(safety, "data/safety.rds")
