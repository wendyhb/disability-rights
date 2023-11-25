# library(reticulate)
# # path_to_python <- "C:/Users/cyn64/AppData/Local/Microsoft/WindowsApps/python"
# # use_python(path_to_python)
# reticulate::py_config()
# DIFFLIB <-reticulate::import("difflib")
# POLYFUZZ <- reticulate::import("polyfuzz")
#   
# full_data <- read_rds("data/full_data.rds")
# full_data |> names()
# full_data <- full_data |> 
#   filter(year > 2007)
# crpd <- read_rds("data/crpd.rds")
# from_vec <- unique(full_data$country)
# to_vec <- unique(crpd$country)
# 
# # Test
source("R/my-packages.R")
library(stringdist)

full_data <- read_rds("data/full_data.rds")
full_data <- full_data |>
  filter(year > 2007)
crpd <- read_rds("data/crpd.rds")


#clean crpd$country
crpd <- crpd %>%
  filter(country != "European Union" )

# crpd$country |> view()
# 197 countries in total

# remove the () in country names
crpd <- crpd %>%
  mutate(
    country = if_else(
      str_detect(country, "\\(.*?\\)"),
      str_replace_all(country, "\\(.*?\\)", ""),
      country
    )
  )
crpd$country

# manually clean some country names to make a standard country name list
crpd <- crpd %>%
  mutate(
    # see ?case_match example similarity to case_when()
    country = case_match(
      country,
      "Democratic People's Republic of Korea" ~ "North Korea",
      "Republic of Korea" ~ "South Korea",
      "Syrian Arab Republic" ~ "Syria",
      "Brunei Darussalam" ~ "Brunei", 
      "Lao People's Democratic Republic" ~ "Laos",
      "Republic of Moldova" ~ "Moldova",
      "Viet Nam" ~ "Vietnam",
      "Russian Federation" ~ "Russia",
      "State of Palestine" ~ "Palestine",
      "Türkiye" ~ "Turkey",
      "United Kingdom of Great Britain and Northern Ireland" ~ "United Kingdom",
      "United Republic of Tanzania" ~ "Tanzania",
      "United States of America" ~ "United States",
      "Côte d'Ivoire" ~ "Cote d'Ivoire",
      .default = country
    )
  )

# remove the space after some country names

crpd <- crpd %>%
  mutate(country = str_trim(country,side = "right"))

  


write_rds(crpd, "data/crpd_name-cleaned.rds")

crpd_clean_name <- read_rds("data/crpd_name-cleaned.rds")
crpd_clean_name$country
# after cleaning, there are still 197 countries in crpd


messy_country <- unique(full_data$country)
tidy_country <- unique(crpd$country)
# messy_country |> view()
# 339 
tidy_country |> view()
# 197


indexes <- amatch(messy_country, tidy_country, maxDist = 1)

compare_df <- tibble(messy_country = messy_country,
                 tidy_country = tidy_country[indexes])

# double check all matched the values
compare_df_matched <- compare_df |> 
  filter(!is.na(tidy_country))
result <- subset(compare_df_matched, tidy_country != messy_country)

result <- compare_df_matched |>
  filter(tidy_country != messy_country)

# Print the result
result
### continue working here


# now all unmatched
compare_df |> 
  filter(is.na(tidy_country))

### MANUAL CLEANING?
# ? 
#? 


# THEN FIX TIDY COUNTRY??

## THEN JOIN 

full_data |> 
  left_join(compare_df_matched, by = join_by(country == messy_country)) |> view()





















dupli <- compare_df_matched 




compare_df_unmatched <- compare_df |> 
  filter(is.na(tidy_country))

datatable(compare_df)

compare_df <- compare_df |>
  mutate(messy_country = str_replace_all(
    messy_country, 
    c(".*Bahamas.*" = "Bahamas",
      ".*Bolivia.*" = "Bolivia",
      ".*Brunei.*"= "Brunei",
      ".*Congo.*" = "Congo",
      ".*Iran.*" = "Iran",
      ".*Lao.*" = "Lao",
      ".*Korea.*Dem.*" = "North Korea",
      "Korea, North" = "North Korea",
      "Korea, Rep.*" = "South korea",
      "Korea, South" = "South korea",
      "Korea (Republic of)" = "South Korea",
      "Russian Federation" = "Russia",
      "Palestine, State of" = "Palestine",
      "Gambia, The" = "Gambia",
      "Egypt, Arab Rep."= "Egypt",
      "Czechia" = "Czech Republic",
      ".*Micronesia.*" = "Micronesia")
      
  ))
datatable(compare_df)
  
  
