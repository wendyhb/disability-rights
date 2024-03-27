source("R/my-packages.R")

dat <- read_rds("data/dat.rds")

# -------------------------------------------------------------------------

## Add features
dat <- dat |>
  mutate(
    convention_signed = if_else(!is.na(date_signed_convention), TRUE, FALSE),
    convention_ratified = if_else(!is.na(date_ratified_convention), TRUE, FALSE),
    protocol_signed = if_else(!is.na(date_signed_protocol), TRUE, FALSE),
    protocol_ratified = if_else (!is.na(date_ratified_protocol), TRUE, FALSE),
    crpd_cat = case_when(
      convention_ratified & protocol_ratified ~ "ratified both convention and protocol",
      convention_ratified & !protocol_ratified ~ "ratified convention",
      convention_signed & protocol_signed ~ "signed both convention and protocol",
      convention_signed & !protocol_signed  ~ "only signed convention"
      ),
    crpd = case_match(
      crpd_cat,
      "ratified both convention and protocol" ~ 4,
      "ratified convention" ~ 3,
      "signed both convention and protocol" ~ 2,
      "only signed convention" ~ 1,
      )
  ) 

# Create income groups based on gdp ---------------------------------------
dat <- dat |>
  mutate(
    gdp_cat = case_when(
      gdp_per_capita < 1085 ~ "Low income",
      ##gdp_per_capita < 4256 ~ "Lower-middle income",
      ##gdp_per_capita < 13206~ "Upper-middle income",
      gdp_per_capita < 13206~ "middle income",
      gdp_per_capita > 13205~ "High income",
      .default = NA
    )
  ) |>
  relocate(gdp_cat, .after = "country")

## Filter Years
dat <- dat |> 
  select(- matches("^(convention|protocol)")) |> 
  relocate(c(crpd_cat, crpd), .after = country) |> 
  filter(
    ## Cook Islands has no year (it has no QoL data)
    year %in% (2017:2023) | (country == "Cook Islands" & is.na(year))
    )

## Fill the variables which don't change much by year, 
## Make a note in the table/paper
dat_filled <- dat |> 
  group_by(country) |> 
  fill(
    human_development_index,
    democracy_cat,
    life_expectancy, 
    expected_years_of_schooling, 
    mean_years_of_schooling,
    .direction = "updown"
    )

source("R/rename_country_simple.R")

dat_2022 <- dat_filled |> 
  filter((year == 2022 | country == "Cook Islands")
         & country != "European Union") |> 
  rename_country_simple() |> 
  select( - starts_with("date_"))

# -------------------------------------------------------------------------

fs::dir_create("output")
write_xlsx(dat_filled, "output/dat_filled.xlsx", na.strings = "") 
write_xlsx(dat, "output/dat.xlsx", na.strings = "")
write_xlsx(dat_2022, "output/dat_2022.xlsx", na.strings = "")

write_rds(dat_filled, "output/dat_filled.rds")
write_rds(dat_2022, "output/dat_2022.rds")
