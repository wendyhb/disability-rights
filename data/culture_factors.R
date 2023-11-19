# culture factor: power distance, individualism, motivation, unce --------

url <- "https://www.hofstede-insights.com/country-comparison-tool"
html_2023 <- read_html(url)
country <- html_2023 |>
  html_elements("div") |>
  html_elements(".c-overview") |> 
  html_attr("data-country")      

vars <- c("power-distance",
          "individualism",
          "motivation",
          "uncertainty-avoidance",
          "long-term-orientation", 
          "indulgence")
list_of_tibbles <- list()

## FOR LOOP

for (i in vars) {
  text <- html_2023 |>
    html_elements("span") |>
    html_elements(paste0(".", i)) |> 
    html_text2()
  #remove every second element and leave only the numbers
  value <- text[c(TRUE, FALSE)] |> as.numeric()
  list_of_tibbles[[i]]<- tibble(country, value, variable = i)
}
culture_factors <- list_of_tibbles |> 
  bind_rows() |> 
  pivot_wider(names_from = variable, values_from = value) |> 
  janitor::clean_names()

culture_factors <- culture_factors |> 
  mutate(country = country |> 
          str_to_title() |> 
           str_replace("\\sAnd"," and"), year = as.integer(2023))


culture_factors
write_rds(culture_factors,"data/culture_factors.rds")
