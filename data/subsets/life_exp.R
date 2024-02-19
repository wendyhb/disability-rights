path <- "data-raw/renamed/life-expect_2021_2023-10-30.xlsx"
life_exp <- read_xlsx(path, col_names = FALSE)

## Names are in 5th and 6th rows
names(life_exp) <- glue::glue(
  "{life_exp |> slice(5)} {life_exp |> slice(6)}",
  .na = ""
)

life_exp <- life_exp |>
  janitor::clean_names() |> 
  ## Warning is due to "HDI rank" string under hd_rank
  filter(
    !is.na(as.numeric(hdi_rank)) | human_development_index_hdi_value == ".."
  ) |> 
  select(- matches("hdi_rank|na_na|^x")) |>  
  ## Warnings are due to ".." for non HDI ranked countries
  mutate(
    across(
      - country, 
      \(x) round(as.numeric(x), 2)
    ),
    year = 2021
  ) |> 
  select(- gross_national_income_gni_per_capita_2017_ppp) |> 
   rename(
    human_development_index = human_development_index_hdi_value,
    life_expectancy = life_expectancy_at_birth_years,
    expected_years_of_schooling = expected_years_of_schooling_years,
    mean_years_of_schooling = mean_years_of_schooling_years
    ) |> 
  suppressWarnings()
  
write_rds(life_exp, "data/life_exp.rds")

