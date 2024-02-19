read_treaty_url <- function(url) {
  df_ls <- url |> 
    read_html() |> 
    html_elements("table") |> 
    html_table() 
  
  df <- df_ls[[12]] |> 
    row_to_names(row_number = 1) |> 
    clean_names() |>
    rename(country = participant) |> 
    mutate(
      date_signed = str_remove_all(signature, "\\t"),
      date_ratified = formal_confirmation_c_accession_a_ratification |> 
        str_remove_all("\\t") |> 
        str_remove_all("a$"),
      ## Remove parentheses and anything between them
      country = country |> 
        str_replace_all("\\(.*?\\)", "") |> 
        str_remove_all("\\d+$"),
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
        "Sao Tome and Principe" ~ "São Tomé and Príncipe",
        .default = country
      ),
    ) |> 
    select(- formal_confirmation_c_accession_a_ratification, - signature)
  
  df <- df |> 
    mutate(
      across(where(is.character), ~ na_if(., "")),
      across(
        c(country, date_signed, date_ratified),
        \(x) str_squish(x)
      ),
      across(
        c(date_signed, date_ratified),
        \(x) as.Date(x, format = "%d %b %Y")
      )
    )
}