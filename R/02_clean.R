
source("R/my-packages.R")
library(stringdist)

# clean the country names for the combined variables
df_no_conv_prot <- read_rds("data/data_no_convention_protocol.rds")

# country list from the convention website --------------------------------------------------------------------

# the cleaning process above the filter line is to ensure that the later after the amatch(), the matched country names are perfectly matched wit no errors.
convention <- read_rds("data/clean-raw/convention.rds")
# 193 countries in total

# Compare the country list -----------------------------------------------------------------
# convention countries vs countries from other varibles
messy_country <- unique(df_no_conv_prot$country)
tidy_country <- unique(convention$country)
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

# now try to apply the code to the combined data set

# clean vars_exclude_convention_protocol -------------------------------------------------
data_clean_no_convention_protocol <- df_no_conv_prot|> 
   mutate(country = str_replace_all(
     country, 
     regexes
   ))
   
write_rds(data_clean_no_convention_protocol,
          "data/data_clean_no_convention_protocol.rds")

data_clean_no_convention_protocol  <- read_rds("data/data_clean_no_convention_protocol.rds")
data_clean_no_convention_protocol $country |> unique()

# join convention,  protocol, data_exclude_conven_proto_clean_country_name
protocol <- read_rds("data/clean-raw/protocol.rds") 
data_combined <- convention |> 
   left_join(data_clean_no_convention_protocol, by = join_by(country)) |> 
   left_join(protocol, by = join_by(country))

data_combined <- data_combined |> 
  group_by(country, year) |> 
  fill(everything(), .direction = "updown") |> 
  distinct(country, year, .keep_all = TRUE)

data_combined <- data_combined |> 
  relocate(protocol_sign,protocol_ratif, .after = "crpd_ratif")

write_csv(data_combined, "output/data-report.csv")
write_rds(data_combined, "output/data-report.rds")
data_combined <- read_rds("output/data-report.rds")
data_combined$country |> unique()
# 193 countries

# check if there are any empty strings
data_combined|> 
  filter(if_any(everything(), \(x) x == ""))

# convention |> 
#   filter(country == "Cook Islands") |> 
#   view()

# Stuart's email
# 1 Didn’t sign
# 2 Signed protocol
# 3 Signed and ratified protocol
# 4 Signed and ratified protocol and additional optional protocol

# filter for your 2022 and make crpd_catogory

# Do not need these lines
data_combined <- data_combined |>
  mutate(crpd_signed = if_else(!is.na(crpd_sign), TRUE, FALSE),
         crpd_ratified = if_else(!is.na(crpd_ratif),TRUE, FALSE),
         protocol_signed = if_else(!is.na(protocol_sign), TRUE, FALSE),
         protocol_ratified = if_else (!is.na(protocol_ratif), TRUE, FALSE)
  )

data_combined  <- data_combined  |> 
  mutate(crpd_category = case_when(
    crpd_ratified & protocol_ratified ~ "ratified both crpd and protocol",
    crpd_ratified & !protocol_ratified ~ "ratified protocol",
    crpd_signed & protocol_signed ~ "signed both crpd and protocol",
    crpd_signed & !protocol_signed  ~ "only signed crpd",
  )) |> 
  mutate(crpd_category_v = case_match(crpd_category,
    "ratified both crpd and protocol" ~ 4,
    "ratified protocol" ~ 3,
    "signed both crpd and protocol" ~ 2,
    "only signed crpd" ~ 1,
  )) 

# crpd_study |> filter(year == 2022|is.na(year)) |> view()
drop_cols <- c("crpd_sign", "crpd_ratif", "protocol_sign", "protocol_ratif",
               "crpd_signed","crpd_ratified", "protocol_signed","protocol_ratified")

data_combined |> names()
data_combined  <- data_combined  |> 
  select(-all_of(drop_cols)) |> 
  select(country, crpd_category, crpd_category_v, year, 
         power_distance, individualism, motivation,
         uncertainty_avoidance, long_term_orientation,
         indulgence, 
         democracy_index, democracy_cat, 
         masculinity_index,
         everything())
  # relocate(crpd_category, .after = country) |> 
  # relocate(crpd_category_v, .after = crpd_category ) |> 
  # relocate(corruption_score, .after = indulgence) |> 
  # relocate(masculinity_index, .after = democracy_cat)

write_rds(data_combined, "output/data_combined.rds")

data_report_2017_2023 <- data_combined  |> 
  filter (year %in% (2017:2023) | (
    country == "Cook Islands" & is.na(year)))


write_rds(data_report_2017_2023,"output/data-report_2017-2023.rds")
write_csv(data_report_2017_2023,"output/data-report_2017-2023.csv")



# fill the variables which are not year-based, make a note in the table/paper -------------------------
data_report_2017_2023 |> names()

data_report_2017_2023_filled <- data_report_2017_2023 |> 
  group_by(country) |> 
  fill(
    power_distance,
    individualism,
    motivation,
    uncertainty_avoidance,
    long_term_orientation,
    indulgence,
    masculinity_index,
    .direction = "down"
  )

data_report_2017_2023_filled <- data_report_2017_2023_filled |> 
  fill(democracy_cat,
       .direction = "up")

data_report_2017_2023_filled <- data_report_2017_2023_filled |> 
  fill(life_expectancy, expected_years_of_schooling, mean_years_of_schooling,
       .direction = "updown")


# output ------------------------------------------------------------------

path <- "output/data-report_booklet.xlsx"
openxlsx2::write_xlsx(
  list(data_2017_2023_filled = data_report_2017_2023_filled,
       data_2017_2023 = data_report_2017_2023),
  path,
  na.strings = ""
  ) 

  
write_rds(data_report_2017_2023_filled,"output/data-report_2017-2023_filled.rds")
write_csv(data_report_2017_2023_filled,"output/data-report_2017-2023_filled.csv")
