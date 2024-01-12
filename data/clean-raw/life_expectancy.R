# life_expectancy ---------------------------------------------------------

html_life_exp <-"data-raw/renamed/life_expectancy_2021_2023-10-30.xlsx"
life_exp_table <- read_xlsx(html_life_exp, col_names = FALSE)

names(life_exp_table) <- glue::glue(
  "{life_exp_table |> slice(5)} {life_exp_table |> slice(6)}",
  .na = ""
)
life_exp_table <- life_exp_table |> janitor::clean_names()
life_exp_table <- life_exp_table |> 
  ## Warning is due to "HDI rank" string under hd_rank
  filter(
    !is.na(as.numeric(hdi_rank)) | human_development_index_hdi_value == ".."
  )
names(life_exp_table)
life_exp_table <- life_exp_table |> 
  select(- matches("hdi_rank|na_na|^x")) |>  
  ## Warnings are due to ".." for non HDI ranked countries
  mutate(
    across(
      - country, 
      \(x) round(as.numeric(x), 2)
    ),
    year = 2021
  )

life_exp_table |> names()
life_exp_table  <- life_exp_table |> 
  select(-gross_national_income_gni_per_capita_2017_ppp) |> 
         rename(
        human_development_index = human_development_index_hdi_value,
         life_expectancy = life_expectancy_at_birth_years,
         expected_years_of_schooling = expected_years_of_schooling_years,
         mean_years_of_schooling = mean_years_of_schooling_years) |> 
         mutate(year = year |> as.integer())
  
life_exp_table |> names()
write_rds(life_exp_table, "data/life_exp.rds")

