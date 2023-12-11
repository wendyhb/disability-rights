
source("R/my-packages.R")
library(stringdist)

# clean the country names in non_crpd_raw 
non_crpd_raw <- read_rds("data/non_crpd_raw.rds")

# crpd --------------------------------------------------------------------

# the cleaning process above the filter line is to ensure that the later after the amatch(), the matched country names are perfectly matched wit no errors.
crpd <- read_rds("data/clean-raw/crpd.rds")
# 193 countries in total

# Compare -----------------------------------------------------------------
# both non_crpd and crpd 
messy_country <- unique(non_crpd_raw$country)
tidy_country <- unique(crpd$country)
# messy_country |> view()
# 335
# tidy_country |> view()
# 193

indexes <- amatch(messy_country, tidy_country, maxDist = 1)

compare_df <- tibble(messy_country = messy_country,
                     tidy_country = tidy_country[indexes]) 


# double check all matched the values
compare_df_matched <- compare_df |> 
  filter(!is.na(tidy_country))
to_be_fixed <- subset(compare_df_matched, tidy_country != messy_country)

# to_be_fixed should be an empty tibble

# now fix all unmatched country names manually, take "Congo for an example"
compare_df_unmatched <- compare_df |> 
  filter(is.na(tidy_country)) 

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
           ".*Palestine.*"= "Palestine",
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

# clean non_crpd_raw -------------------------------------------------
 non_crpd <- non_crpd_raw |> 
   mutate(country = str_replace_all(
     country, 
     regexes
   ))
   
write_rds(non_crpd, "data/non_crpd.rds")

non_crpd <- read_rds("data/non_crpd.rds")
non_crpd$country |> unique()

# join crpd, non_crpd, protocol
protocol <- read_rds("data/clean-raw/protocol.rds") 
full_data <- crpd |> 
   left_join(non_crpd, by = join_by(country)) |> 
   left_join(protocol, by = join_by(country))

full_data <- full_data |> 
  group_by(country, year) |> 
  fill(everything(), .direction = "updown") |> 
  distinct(country, year, .keep_all = TRUE)

full_data <- full_data |> 
  relocate(protocol_sign,aces_or_ratif, .after = "crpd_ratif")

write_csv(full_data, "data/crpd_study.csv")
write_rds(full_data, "data/crpd_study.rds")
crpd_study <- read_rds("data/crpd_study.rds")
crpd_study$country |> unique()
# 193 countries

# check if there are any empty strings
crpd_study |> 
  filter(if_any(everything(), \(x) x == ""))

# crpd_study |> 
#   filter(country == "Cook Islands") |> 
#   view()

# Stuart's email
# 1 Didn’t sign
# 2 Signed protocol
# 3 Signed and ratified protocol
# 4 Signed and ratified protocol and additional optional protocol

# filter for your 2022 and make crpd_catogory

crpd_study <- crpd_study |> 
  mutate(signed = if_else(!is.na(crpd_sign), TRUE, FALSE),
         ratified = if_else(!is.na(crpd_ratif),TRUE, FALSE),
         protocol = if_else((!is.na(protocol_sign)|!is.na(aces_or_ratif)), TRUE, FALSE)
  )
# continue here
crpd_study <- crpd_study |> 
  mutate(crpd_category = case_when(
    !signed & !ratified & !protocol ~ "none",
    signed & ratified & protocol ~ "signed and ratified convention with protocol",
    signed & ratified & !protocol ~ "signed and ratified convention",
    (signed | ratified) & !protocol ~ "signed or ratified convention",
    (signed | ratified) & protocol ~ "signed or ratified convention with protocol",
  )) |> 
  mutate(crpd_category_v = case_match(crpd_category,
    "none" ~ 1,
    "signed and ratified convention with protocol" ~ 5,
    "signed and ratified convention" ~ 3,
    "signed or ratified convention with protocol" ~ 4,
     "signed or ratified convention" ~ 2,
  )) 


drop_cols <- c("crpd_sign", "crpd_ratif", "protocol_sign", "aces_or_ratif")
crpd_study <- crpd_study |> 
  select(-all_of(drop_cols)) |> 
  relocate(crpd_category, .after = country) |> 
  relocate(crpd_category_v, .after = crpd_category )

crpd_study_2017_2022 <- crpd_study |> 
  filter (year %in% (2017:2022) | (country == "Cook Islands" & is.na(year)))


write_rds(crpd_study_2017_2022,"output/crpd_study_2017-2022.rds")
write_csv(crpd_study_2017_2022,"output/crpd_study_2017_2022.csv")


crpd_study_2022 <- crpd_study |> 
  filter (year == 2022 | (country == "Cook Islands" & is.na(year)))

write_rds(crpd_study_2022,"output/crpd_study_2022.rds")
write_csv(crpd_study_2022,"output/crpd_study_2022.csv")

getwd()
path <- "C:/Users/cyn64/repo/disability-rights/output/crpd_data.xlsx"
openxlsx2::write_xlsx(
  list(data_2022 = crpd_study_2022, 
       data_2017_2022 = crpd_study_2017_2022),
  path)
  
