cols <- c("corruption_score", "democracy", "freedom_index", 
          "gdp_per_capita", "human_development_index", "life_expectancy", 
          "expected_years_of_schooling", "mean_years_of_schooling", "crime_index", 
          "safety_index", "unemployment_rate", "power_distance", "individualism", 
          "motivation", "uncertainty_avoidance", "long_term_orientation", 
          "indulgence", "masculinity")

non_model_cols <- c("democracy_cat", "year", "crpd_cat")

nest_complete_data_per_lm <- function(dat) {
  dat |> 
    nest() |> 
    mutate(
      data_complete = map(data, \(x) drop_na(x)),
      sample_size = map_int(data_complete, \(x) nrow(x)),
      data = map(
        data, 
        \(x) if (vars == "gdp_per_capita") {
          x |> mutate(value = log(value))
        } else x
      )
    )
}

var_model <- function(df){
  lm(value ~ crpd, data = df)
} 

safe_model <- var_model |> safely()

model_tidy <- function(dat) {
  dat |> 
    mutate(
      model = map(data, safe_model),
      model = map(model, \(x)x[[1]]),
      tidy   = model |> map(broom::tidy),
      glance = model |> map(broom::glance),
      ## glance is <list> type column
      ## map over it, and extract out the "r.squared" column
      r.squared = glance |> map_dbl("r.squared"),
    )
}

safe_model_tidy <- model_tidy |> safely()

    
model_overview <- function(dat) {
  dat |> 
    select(vars, sample_size, r.squared, tidy) |> 
    unnest(tidy, keep_empty = TRUE) |> 
    group_by(term) |> 
    arrange(p.value) |> 
    mutate(
      across(where(is.numeric), \(x) round(x, 3))
    ) |> 
    pivot_wider(
      values_from = c(p.value, estimate, std.error, statistic),
      names_from = term,
      names_vary = "slowest"
    ) |> 
    relocate(matches("Intercept"), .after = statistic_crpd) |> 
    arrange(p.value_crpd)
}


