# Safety Index ------------------------------------------------------------
 

# use loops and map to get different years
# after that add year columns to every table
years <- 2012:2023
for (i in seq_along(years)){
  ## 2012 and 2013 URLs are written YYYY-Q1
  q <- if (years[i] %in% c(2012, 2013)) "-Q1" else ""
  url <- glue::glue("https://www.numbeo.com/crime/rankings_by_country.jsp?title={years[i]}{q}")
  html_content <- read_html(url)
  table_data <- html_content %>% html_element("#t2") %>% html_table()
  results_list[[i]] <- table_data |> 
    mutate (year = !!years[i]) 
}

# combine 12 tables into 1

safety_index <- do.call(rbind, results_list)

safety_index <- safety_index |> 
  rename_with(snakecase::to_snake_case) |>
  select(- rank)

stopifnot(identical(safety_index $ year |> unique(), years))
write_rds(safety_index, "data/safety.rds")

