simple_country_names <- function(dat) {
  dat |> 
    mutate(
      # Remove parentheses and anything between them
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
      )
    )
}