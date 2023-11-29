source("R/my-packages.R")
html_raw <- read_html("https://treaties.un.org/Pages/ViewDetails.aspx?src=TREATY&mtdsg_no=IV-15-a&chapter=4&clang=_en")
raw_table <- html_protocol |>
  html_elements("table") |> 
  html_table() 
raw_table <- raw_table[[12]]
raw_table <- raw_table |> 
 janitor::row_to_names(row_number = 1) |> 
 janitor::clean_names()
raw <- raw_table 
raw |> names()
# [1] "participant"                                   
# [2] "signature"                                     
# [3] "formal_confirmation_c_accession_a_ratification"

#  For character columns only, replace any blank strings with NA values
raw <- raw |> 
 mutate(across(where(is.character), ~ na_if(.,""))) |> 
 mutate(signature = signature |> 
          str_remove_all("\\t"))
raw <- raw |> 
 mutate(
   acession_or_ratification = 
     formal_confirmation_c_accession_a_ratification |> 
          str_remove_all("\\t") |> 
          str_remove_all("a$")
 )
#  delete space at the end of the strings 
raw <- raw |> 
  mutate(
    participant = str_squish(participant),
    signature = str_squish(signature),
    acession_or_ratification = str_squish(acession_or_ratification,
    formal_confirmation_c_accession_a_ratification = str_squish(
      formal_confirmation_c_accession_a_ratification
      )                                      )
     )
raw_clean <- raw |> 
  select(-formal_confirmation_c_accession_a_ratification)
raw_clean <- raw_clean |> 
  mutate(
    across(
      c(signature, acession_or_ratification),
      ~as.Date(., format = "%d %b %Y"))
  )

# clean the country names
protocol <- raw_clean |> 
  mutate(country = if_else(
          str_detect(participant, "\\(.*?\\)"),
          str_replace_all(participant, "\\(.*?\\)", ""),
          participant
         )
  )

protocol <- protocol %>%
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

protocol <- protocol |>  
  mutate(country = 
           str_remove_all(country, "\\d+$"))


protocol <- protocol |> 
  select(-participant)
protocol |> view()



# 
# #clean crpd$country
# crpd <- crpd %>%
#   filter(country != "European Union" )
# 
# # crpd$country |> view()
# # 197 countries in total
# 
# # remove the () in country names
# crpd <- crpd %>%
#   mutate(
#     country = if_else(
#       str_detect(country, "\\(.*?\\)"),
#       str_replace_all(country, "\\(.*?\\)", ""),
#       country
#     )
#   )
# crpd$country
# 
# # manually clean some country names to make a standard country name list
# crpd <- crpd %>%
#   mutate(
#     # see ?case_match example similarity to case_when()
#     country = case_match(
#       country,
#       "Democratic People's Republic of Korea" ~ "North Korea",
#       "Republic of Korea" ~ "South Korea",
#       "Syrian Arab Republic" ~ "Syria",
#       "Brunei Darussalam" ~ "Brunei", 
#       "Lao People's Democratic Republic" ~ "Laos",
#       "Republic of Moldova" ~ "Moldova",
#       "Viet Nam" ~ "Vietnam",
#       "Russian Federation" ~ "Russia",
#       "State of Palestine" ~ "Palestine",
#       "Türkiye" ~ "Turkey",
#       "United Kingdom of Great Britain and Northern Ireland" ~ "United Kingdom",
#       "United Republic of Tanzania" ~ "Tanzania",
#       "United States of America" ~ "United States",
#       "Côte d'Ivoire" ~ "Cote d'Ivoire",
#       .default = country
#     )
#   )
