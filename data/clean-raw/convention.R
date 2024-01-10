source("R/my-packages.R")
html_raw <- read_html("https://treaties.un.org/Pages/ViewDetails.aspx?src=TREATY&mtdsg_no=IV-15&chapter=4&clang=_en")
raw_table <- html_raw |>
  html_elements("table") |> 
  html_table() 
raw_table <- raw_table[[12]]
raw_table <- raw_table |> 
  janitor::row_to_names(row_number = 1) |> 
  janitor::clean_names()
raw <- raw_table 
raw |> names()
#[1] "participant"                                   
#[2] "signature"                                     
#[3] "formal_confirmation_c_accession_a_ratification"

#  For character columns only, replace any blank strings with NA values
raw <- raw |> 
  mutate(across(where(is.character), ~ na_if(.,""))) |> 
  mutate(crpd_sign = signature |> 
           str_remove_all("\\t"), .keep = "unused")
raw <- raw |> 
  mutate(
    crpd_ratif = 
      formal_confirmation_c_accession_a_ratification |> 
      str_remove_all("\\t") |> 
      str_remove_all("a$"), .keep = "unused") 


#  delete space at the end of the strings 
raw <- raw |> 
  mutate(
    participant = str_squish(participant),
    crpd_sign = str_squish(crpd_sign),
    crpd_ratif = str_squish(crpd_ratif)
  )
  
raw_clean <- raw |> 
  mutate(
    across(
      c(crpd_sign, crpd_ratif),
      ~as.Date(., format = "%d %b %Y"))
  )

# clean the country names
crpd <- raw_clean |> 
  mutate(country = if_else(
    str_detect(participant, "\\(.*?\\)"),
    str_replace_all(participant, "\\(.*?\\)", ""),
    participant
  ), .keep = "unused"
  )

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

crpd <- crpd |>  
  mutate(country = 
           str_remove_all(country, "\\d+$") |> 
           str_squish())

crpd <- crpd |> select(country, everything()) |> 
           filter(country != "European Union")

write_rds(crpd, "data/clean-raw/convention.rds") 




