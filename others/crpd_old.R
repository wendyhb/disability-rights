#country list for treaty CRPD
source("R/my-packages.R")
html_crpd <- read_html("https://tbinternet.ohchr.org/_layouts/15/TreatyBodyExternal/Treaty.aspx?Treaty=CRPD")
crpd_table <- html_crpd |>
  html_elements(".rgMasterTable") |> 
  html_table() 
crpd_table <- crpd_table[[1]] 

crpd_table <- crpd_table |> 
  janitor::clean_names() 

crpd_table <- crpd_table |>  
  slice(-(1:3)) |> 
  select(country, 
         crpd_signature_date = signature_date , 
         crpd_ratification_date = ratification_date_accession_a_succession_d_date,
         crpd_entry_into_force_date = entry_into_force_date ) 

crpd_table <- crpd_table |> 
  mutate(crpd_ratification_date = str_remove(crpd_ratification_date, "\\(a\\)")) 

crpd_table <- crpd_table |> 
  mutate(
    across(
      c(crpc_signature_date, crpc_ratification_date,crpc_entry_into_force_date), 
       ~ as.Date(., format = "%d %b %Y")
      # \(x) as_date(x, format = "%d %b %Y")
      )
    )

# CRPD - Convention on the Rights of Persons with Disabilities, 195 countries in total ------------
# file_path <- paste("data/",i, sep = "")

my_list_1 <- list()
for(i in 1:195){
    file_path <- paste("https://tbinternet.ohchr.org/_layouts/15/TreatyBodyExternal/Treaty.aspx?CountryID=",i,"&Lang=en", sep = "")
    html_crpd <- read_html(file_path)
    crpd_table_2 <- html_crpd |>
    html_elements("#ContentPlaceHolder1_JurisGrid") |>
    html_table()
    my_list_1[[i]] <- crpd_table_2
    Sys.sleep(5)
}

# clean the list and make it into one table for country_opt_protocol------------------------------------------------------------------

ex <- my_list_1[[11]] |> _[[1]]
exp <- my_list_1[[12]] |> _[[1]]

clean_and_mutate <- function(df) {
  
  df %>%  
    janitor::clean_names() %>%
    slice(-c(1:3)) %>%
    filter(treaty_name == "CRPD-OP") |>
    select(country, optional_protocol_date = date_of_acceptance_non_acceptance)
}

cleaned_list <- my_list_1 |> map(\(x) x |> _[[1]] |> clean_and_mutate())
country_opt_protocol <- cleaned_list |> bind_rows()

write_rds(country_opt_protocol,"data/crpd_webscraped.rds")
opt_protocol <- read_rds("data/intermediate/crpd_webscraped.rds")


# combine crpd_table and country_opt_protocol -------------------------------------
crpd_final <- full_join(crpd_table, country_opt_protocol, by = "country") 
crpd_final <- crpd_final %>%
  mutate_all(~na_if(.x, "")) |> 
  mutate(crpd_category = NA)

crpd_final <- crpd_final |> 
  mutate(signed = if_else(!is.na(crpd_signature_date), TRUE, FALSE),
         ratified = if_else(!is.na(crpd_ratification_date),TRUE, FALSE),
         protocol = if_else(!is.na(optional_protocol_date),TRUE, FALSE)
  )

crpd_final <- crpd_final |> 
  mutate(crpd_category = case_when(
    signed == TRUE & ratified == TRUE & protocol == TRUE ~ "signed & ratified & protocol",
    signed == TRUE & ratified == TRUE ~ "signed & ratified",
    signed == TRUE & ratified == FALSE & protocol == TRUE ~ "signed & protocol",
    signed == TRUE ~ "signed",
    ratified == TRUE & protocol == TRUE ~ "ratified & protocol",
    ratified == TRUE ~ "ratified",
    .default = "none"
    )
  )

## NB For the map, if a country Ratified, it is dark blue, period.
## followed this map but it was made in 2014 so the map is out-dated
# https://abilitymagazine.com/images/enablemap.jpg

crpd_final <- crpd_final |> 
  mutate(crpd_category_value = case_match(
    crpd_category, 
     "none" ~ 1,
     "signed" ~ 2,
     "signed & protocol" ~ 3,
     "signed & ratified" ~ 4,
     "ratified" ~ 4,
     "ratified & protocol" ~ 5,
     "signed & ratified & protocol" ~ 5
  ))

# only select relevant columns for the research

crpd_final <- crpd_final |> 
  select(country, crpd_signature_date, crpd_ratification_date,optional_protocol_date,crpd_category, crpd_category_value)

# write_rds(crpd_final,"data/crpd.rds")
crpd_tidy <- read_rds("data/clean-raw/crpd.rds")
crpd_tidy <- crpd_tidy |> 
  select(- c("optional_protocol_date","crpd_category", "crpd_category_value")) |> 
  mutate(country = country, 
         crpd_sign = crpd_signature_date, 
         crpd_ratif = crpd_ratification_date,.keep = "none")

write_rds(crpd_tidy,"data/crpd_tidy.rds")

crpd_1 <- read_rds("data/crpd_tidy.rds")


# remeber that the country name has not been cleaned yet.
# 198 countries in total(European Union is not removed yet)
