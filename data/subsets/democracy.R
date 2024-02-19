path <-"data-raw/renamed/democracy_2006-2022_2023-11-8.csv"
democracy <- read_csv(path)

democracy <- democracy |>
  janitor::clean_names() |> 
  filter(!is.na(code)) |> 
  mutate(democracy = round(democracy_eiu, 2)) |> 
  select(country = entity, democracy, year) |> 
  mutate(
    democracy_cat = case_when(
      democracy >= 8.01 ~ "Full Democracy",
      democracy >= 6.01 & democracy < 8.01 ~ "Flawed Democracy",
      democracy >= 4.01 & democracy < 6.01 ~ "Hybrid Regime",
      democracy >= 0 & democracy < 4.01 ~ "Authoritarian Regime",
      is.na(democracy) ~ "Not Available"
      )
    )

write_rds(democracy, "data/subsets/democracy.rds")
