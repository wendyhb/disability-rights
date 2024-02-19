## The latest update on our website was on October 16, 2023 (IDV and LTO).

url <- "https://www.hofstede-insights.com/country-comparison-tool"
html <- read_html(url)

vars <- c("power-distance",
          "individualism",
          "motivation",
          "uncertainty-avoidance",
          "long-term-orientation", 
          "indulgence")

list_of_tibbles <- list()

for (i in vars) {
  text <- html |>
    html_elements("span") |>
    html_elements(paste0(".", i)) |> 
    html_text2()
  
  ## Remove every second element and leave only the numbers
  value <- text[c(TRUE, FALSE)] |> as.numeric()
  list_of_tibbles[[i]]<- tibble(country, value, variable = i)
}

culture <- list_of_tibbles |> 
  bind_rows() |> 
  pivot_wider(names_from = variable, values_from = value) |> 
  janitor::clean_names()

culture <- culture |> 
  mutate(
    country = country |> 
      str_to_title() |> 
      str_replace("\\sAnd"," and")
    )

write_rds(culture,"data/subsets/culture.rds")
