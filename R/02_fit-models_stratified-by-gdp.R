source("R/my-packages.R")
source("R/02_functions.R")

dat <- read_rds("output/dat_2022.rds")
stopifnot(cols %in% names(dat))

dat <- dat |>
  pivot_longer(cols = all_of(cols),
               names_to = "vars",
               values_to = "value" )

# -------------------------------------------------------------------------

dat <- dat |> 
  group_by(vars, gdp_cat)

# -------------------------------------------------------------------------

dat <- dat |>  
  select(- democracy_cat, - year) |> 
  nest_complete_data_per_lm()

# -------------------------------------------------------------------------
## NEED FIX
models <- dat |> 
  filter(sample_size > 10) |>
  model_tidy() 

# |> 
# filter(!is.na(gdp_cat))


models_ov <- models |> model_overview()

write_xlsx(models_ov, "output/fit-models_stratified-by-income.xlsx", na.strings = "")


# -------------------------------------------------------------------------

## check assumptions


sig_models <- models |> 
  filter(vars == "unemployment_rate" & gdp_cat == "High income")
plot(sig_models$model[[1]])

sig_models <- models |> 
  filter(vars == "life_expectancy" & gdp_cat == "High income")
plot(sig_models$model[[1]])

sig_models <- models |> 
  filter(vars == "freedom_index" & gdp_cat == "High income")
plot(sig_models$model[[1]])

models_ov$vars |> head(10)
sig_models <- models |> 
  filter(vars == "expected_years_of_schooling" & gdp_cat == "High income")
plot(sig_models$model[[1]])

sig_models <- models |> 
  filter(vars == "human_development_index" & gdp_cat == "High income")
plot(sig_models$model[[1]])


sig_models <- models |> 
  filter(vars == "uncertainty_avoidance" & gdp_cat == "middle income")
plot(sig_models$model[[1]])


sig_models <- models |> 
  filter(vars == "democracy" & gdp_cat == "High income")
plot(sig_models$model[[1]])

sig_models <- models |> 
  filter(vars == "individualism" & gdp_cat == "High income")
plot(sig_models$model[[1]])

sig_models <- models |> 
  filter(vars == "life_expectancy" & gdp_cat == "middle income")
plot(sig_models$model[[1]])

sig_models <- models |> 
  filter(vars == "human_development_index" & gdp_cat == "Low income")
plot(sig_models$model[[1]])


#library(easystats)
# sig_models$model[[1]] |> check_model()

# -------------------------------------------------------------------------



















# models <- models |> 
#   mutate(
#     p.value= glance |> map_dbl("p.value"),
#     ## need a function in map() below in order to handle the <tibble> inside
#     ## the tidy column of <list> type
#     coef   = tidy |> 
#       map_dbl(
#         \(x) x |> 
#           pull(estimate) |> 
#           pluck(2)
#           ),
#     augment= model |> map(broom::augment)
#   ) 
# 
# modles <- models |> 
#   select(- data, - data_complete, - augment, - glance, -tidy ) 



# unnest(rsq, keep_empty = TRUE) |> 
# unnest(tidy, keep_empty = TRUE)


# models <- models |> arrange(p.value)
# 
# plot_mod <- models |>
#   filter(!is.na(r.squared)) |>
#   ggplot(aes(r.squared,reorder(vars, r.squared)))+
#   geom_point()
# 
# 
# plot_mod_2 <- plot_mod +
#   labs(x = "R^2",
#        y = "variables")
# plot_mod_2