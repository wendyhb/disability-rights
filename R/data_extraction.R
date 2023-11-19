
# freedom -----------------------------------------------------------------

path_freedom <- "data-raw/freedom_index_2013-2023_2023-10-30.xlsx"
excel_sheets(path_freedom)
freedom_table<- read_xlsx(path_freedom, sheet = 2, col_names = TRUE, skip = 1)
names(freedom_table)
head(freedom_table)
freedom <- freedom_table |> 
  mutate(country = `Country/Territory`, year = Edition, freedom_index = Total,.keep = "none")
freedom $ year |> unique()
freedom
write_rds(freedom, "data/freedom.rds")
freedom |> view()
# GDP ---------------------------------------------------------------------

path_gdp <- "data-raw/GDP_1960-2022_2023-10-30.csv"
gdp_table <- read_csv(path_gdp, col_names = TRUE, skip = 4)
names(gdp_table)
head(gdp_table)
gdp_table <- gdp_table |> 
  janitor::clean_names() |> 
  rename_with(~ str_replace(., "x(\\d+)", "year_\\1"), starts_with("x"))  

gdp_long <- gdp_table |> 
  pivot_longer(
    cols = c(year_1960:year_2022),
    names_to = "year",
    values_to = "gdp"
    ) |> 
  mutate(country = country_name, gdp, year, .keep = "none") |> 
  relocate(country)

gdp_long <- gdp_long |>  mutate(gdp = round(gdp, 2), year = str_remove(year, "year_"))

write_rds(gdp_long, "data/gdp.rds")

# life_expectancy ---------------------------------------------------------

html_life_exp <-"data-raw/life_expectancy_2021_2023-10-30.xlsx"
life_exp_table <- read_xlsx(html_life_exp, col_names = FALSE)

names(life_exp_table) <- glue::glue(
  "{life_exp_table |> slice(5)} {life_exp_table |> slice(6)}",
  .na = ""
)
life_exp_table <- life_exp_table |> janitor::clean_names()
life_exp_table <- life_exp_table |> 
  ## Warning is due to "HDI rank" string under hd_rank
  filter(
    !is.na(as.numeric(hdi_rank)) | human_development_index_hdi_value == ".."
    )
names(life_exp_table)
life_exp_table <- life_exp_table |> 
  select(- matches("hdi_rank|na_na|^x")) |>  
  ## Warnings are due to ".." for non HDI ranked countries
  mutate(
    across(
      - country, 
      \(x) round(as.numeric(x), 2)
    ),
    year = 2021
    )

view(life_exp_table)
write_rds(life_exp_table, "data/life_exp.rds")



# Safety Index ------------------------------------------------------------
html_2023 <- read_html("https://www.numbeo.com/crime/rankings_by_country.jsp?title=2023")
html_2023|> html_element("#t2") |> 
  html_table()
results_list <- list()

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



# unemployment rate -------------------------------------------------------

path_unemploy<- "data-raw/unemployment_rate_2023-10-31.csv"
unemploy_table <- read_csv(path_unemploy, col_names = TRUE, skip = 4)
names(unemploy_table)
head(unemploy_table)
unemploy_table <- unemploy_table |> pivot_longer(
  cols = as.character(c(1960:2022)) ,
  names_to = "year",
  values_to = "unemployment_rate"
)
names(unemploy_table)
unemployment <- unemploy_table |> 
  mutate(country = `Country Name`, unemployment_rate, year, .keep = "none") |> 
  relocate(country)

write_rds(unemployment, "data/unemployment.rds")



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
  pivot_wider(names_from = variable, values_from = value)
write_rds(culture_factors, "data/culture_factors.rds")

# examples to try
# cultural_factors |> 
#   filter(country == "armenia") |> 
#   view()
# my_data <- readRDS("data/culture_factors.rds")
# print(my_data)
# view(my_data)


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
  mutate(year = (year |> str_extract(".{0,4}$") |> as.numeric()))
head(cpi)
write_rds(cpi,"data/cpi.rds")


# democracy index and categories -----------------------------------------

path_democ<-"data-raw/democracy_index_2006-2022_2023-11-8.csv"
democ_table<- read_csv(path_democ)
head(democ_table)
democ_table

cat_info <- data.frame(
  cat_a = "Full Democracy",
  cat_b = "Flawed Democracy",
  cat_c = "Hybrid Regime",
  cat_d = "Authoritarian Regime",
  cat_e = "No Data")

# filter out regions in the country column, create democracy categories
democ <- democ_table |>
  janitor::clean_names() |> 
  filter(!is.na(code)) |> 
  mutate(democracy_index = round(democracy_eiu,2)) |> 
  select(country = entity, democracy_index, year) |> 
  mutate(democracy_cat = case_when (democracy_index >= 8.01 ~ "Full Democracy",
                                    democracy_index >= 6.01 & democracy_index < 8.01 ~ "Flawed Democracy",
                                    democracy_index >= 4.01 & democracy_index < 6.01 ~ "Hybrid Regime",
                                    democracy_index >= 0 & democracy_index < 4.01 ~ "Authoritarian Regime",
                                    is.na(democracy_index) ~ "Not Available"))
   

write_rds(democ, "data/democ.rds")
# decmoc category reference: https://en.wikipedia.org/wiki/The_Economist_Democracy_Index

