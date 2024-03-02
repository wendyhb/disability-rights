dat <- read_rds("data/dat.rds")

# -------------------------------------------------------------------------

## Add features
dat <- dat |>
  mutate(
    convention_signed = if_else(!is.na(date_signed_convention), TRUE, FALSE),
    convention_ratified = if_else(!is.na(date_ratified_convention),TRUE, FALSE),
    protocol_signed = if_else(!is.na(date_signed_protocol), TRUE, FALSE),
    protocol_ratified = if_else (!is.na(date_ratified_protocol), TRUE, FALSE),
    category = case_when(
      convention_ratified & protocol_ratified ~ "ratified both convention and protocol",
      convention_ratified & !protocol_ratified ~ "ratified protocol",
      convention_signed & protocol_signed ~ "signed both convention and protocol",
      convention_signed & !protocol_signed  ~ "only signed convention"
      ),
    category_n = case_match(
      category,
      "ratified both convention and protocol" ~ 4,
      "ratified protocol" ~ 3,
      "signed both convention and protocol" ~ 2,
      "only signed convention" ~ 1,
      )
  ) 

## Filter Years
dat <- dat  |> 
  select(- matches("^(convention|protocol)")) |> 
  relocate(c(category, category_n), .after = country) |> 
  filter(
    ## Cook Islands has no year (it has no QoL data)
    year %in% (2017:2023) | (country == "Cook Islands" & is.na(year))
    )

## Fill the variables which don't change much by year, 
## Make a note in the table/paper
dat_filled <- dat |> 
  fill(
    democracy_cat,
    life_expectancy, 
    expected_years_of_schooling, 
    mean_years_of_schooling,
    .direction = "updown"
    )

# -------------------------------------------------------------------------

fs::dir_create("output")
write_xlsx(dat_filled, "output/dat_filled.xlsx", na.strings = "") 
write_rds(dat_filled, "output/dat_filled.rds")
