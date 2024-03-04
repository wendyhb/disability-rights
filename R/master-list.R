url <- "https://www.un.org/en/about-us/member-states"

df_ls <- url |> 
  read_html() |> 
  html_elements("h2") |> 
  html_text() 

un_countries <- df_ls |> 
  str_subset("Search the United Nations", negate = TRUE) |> 
  str_replace_all(get_country_replacements())

dplyr::symdiff(df_2022$country, un_countries)



# Countries that participated in the CRPD ---------------------------------

## All in un_convention and un_protocol except "European Union"
