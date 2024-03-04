source("R/my-packages.R")
source("R/02_functions.R")

dat_2022 <- read_rds("output/dat_2022.rds")
stopifnot(cols %in% names(dat_2022))

dat_2022 <- dat_2022 |>
  pivot_longer(cols = all_of(cols),
               names_to = "vars",
               values_to = "value" )


# -------------------------------------------------------------------------

dat_2022 <- dat_2022 |> 
  group_by(vars, gdp_cat)

# -------------------------------------------------------------------------

dat_2022 <- dat_2022 |>
  nest_model_data()

safe_model <- var_model|> safely()

# -------------------------------------------------------------------------
## NEED FIX

models <- dat_2022 |> 
  describe_model()

models_ov <- models |> model_overview()

# -------------------------------------------------------------------------

## check assumptions

library(easystats)
sig_models <- models |> 
  filter(vars == "gdp_per_capita")

sig_models$model[[1]] |> check_model()

plot(sig_models$model[[1]])



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