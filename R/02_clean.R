
source("R/my-packages.R")
library(stringdist)


all_but_crpd <- read_rds("data/all_but_crpd.rds") |> 
    mutate(country = str_replace_all(
    country,
    c("Bosnia And Herzegovina" = "Bosnia and Herzegovina",
      "Côte d'Ivoire" = "Cote d'Ivoire",
      "Guinea Bissau" = "Guinea-Bissau",
      "Trinidad And Tobago" = "Trinidad and Tobago")
  )) |>
  filter(year > 2007)

# crpd --------------------------------------------------------------------

# the cleaning process above the filter line is to ensure that the later after the amatch(), the matched country names are perfectly matched wit no errors.
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

write_rds(crpd, "data/crpd_clean-country.rds")

# Compare -----------------------------------------------------------------

crpd_clean <- read_rds("data/crpd_clean-country.rds")
crpd_clean$country
# after cleaning, there are still 197 countries in crpd


messy_country <- unique(all_but_crpd$country)
tidy_country <- unique(crpd_clean$country)
# messy_country |> view()
# 339 ?
# tidy_country |> view()
# 197?


indexes <- amatch(messy_country, tidy_country, maxDist = 1)

compare_df <- tibble(messy_country = messy_country,
                     tidy_country = tidy_country[indexes]) 


# double check all matched the values
compare_df_matched <- compare_df |> 
  filter(!is.na(tidy_country))
to_be_fixed <- subset(compare_df_matched, tidy_country != messy_country)

# all the matched countries are perfectly matched with no typos. 
# apply this reference code to the full_data set later


# now fix all unmatched country names manually
compare_df_unmatched <- compare_df |> 
  filter(is.na(tidy_country)) 



datatable(compare_df_unmatched)
compare_df_unmatched$messy_country |> str_subset("Congo")

# [1] "Congo (Brazzaville)"               
# [2] "Congo (Democratic Republic of the)"
# [3] "Congo (Kinshasa)"                  
# [4] "Congo, Dem. Rep."                  
# [5] "Congo, Rep."                       
# [6] "Democratic Republic of Congo"  

regexes <- c(".*Bahamas.*" = "Bahamas",
           ".*Bolivia.*" = "Bolivia",
           ".*Brunei.*"= "Brunei",
           ".*Bosnia And Herzegovina.*" = "Bosnia And Herzegovina",
           ".*Congo.*(Brazzaville).*" = "Congo",
           ".*Congo, Rep.*" = "Congo",
           
           ## DEM. REP. OF CONGO
           
           "Congo.*(Democratic Republic of the).*" = "Democratic Republic of the Congo",
           ".*Congo.*(Kinshasa).*" = "Democratic Republic of the Congo", 
           "Congo, Dem. Rep." = "Democratic Republic of the Congo",
           "Democratic Republic of Congo" = "Democratic Republic of the Congo", 
           
           ##
           
           "Czechia" = "Czech Republic",
           "Egypt, Arab Rep."= "Egypt",
           ".*Iran.*"= "Iran",
           ".*Korea.*(Democratic People's Rep. of).*" = "North Korea",
           ".*Korea.*(Republic of).*" = "South Korea",
           ".*Korea, Dem. People's Rep.*" = "North Korea",
           ".*Korea, North.*" = "North korea",
           ".*Korea, Rep.*" = "South Korea",
           ".*Korea, South.*" = "South Korea",
           ".*Lao.*"= "Laos",
           ".*Micronesia.*" = "Micronesia",
           ".*Moldova.*"= "Moldova",
           ".*Palestine.*"= "Pakestine",
           "Russian Federation" = "Russia",
           ".*Syria.*"= "Syria",
           ".*Tanzania.*"= "Tanzania",
           ".*Gambia.*"= "Gambia",
           ".*Turkiye.*" = "Turkey",
           ".*Türkiye.*" = "Turkey",
           ".*United States of America.*" = "United States",
           ".*Venezuela.*" = "Venezuela",
           ".*Viet Nam.*" = "Vietnam",
           ".*Yemen.*" = "Yemen")

clean_compare_df_unmatched <- compare_df_unmatched |>
  mutate(messy_country = str_replace_all(
    messy_country, 
    regexes
  ))

# unmatched countries are cleaned

# now try to apply the code to the real data set

# clean non_crpd -------------------------------------------------
 non_crpd <- non_crpd |> 
   mutate(country = str_replace_all(
     country, 
     regexes
   ))
   
write_rds(non_crpd_clean, "data/non_crpd_clean.rds")

non_crpd_clean <- read_rds("data/non_crpd_clean.rds")

full_data <- crpd_clean |> 
   left_join(non_crpd_clean, by = join_by(country == country))

full_data |> names()
