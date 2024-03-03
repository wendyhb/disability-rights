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
      country = country |> str_remove_all("\\d")
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
