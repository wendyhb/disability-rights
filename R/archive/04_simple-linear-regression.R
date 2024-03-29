source("R/my-packages.R")

df_2022 <- read_rds("output/data-report_2017-2023_filled.rds")
df_2022 <-df_2022 |> 
  filter(year == 2022) |> 
  select(-c(democracy_cat,year, crpd_category))


# Create income groups based on gdp ---------------------------------------
# df_2022 <- df_2022 |> 
#   mutate(income_group = case_when(
#     gdp < 1085 ~ "Low income",
#     gdp < 4256 ~ "Lower-middle income",
#     gdp < 13206~ "Upper-middle income",
#     gdp > 13205~ "High income",
#     .default = NA
#   )) |> 
#   relocate(income_group, .after = "country")




# Create Model ------------------------------------------------------------


df_2022 <- df_2022 |>
  pivot_longer(cols = (power_distance:unemployment_rate),
               names_to = "vars",
               values_to = "value" )



df_2022 <- df_2022 |> 
   group_by(vars) |> 
  nest() 


df_2022 <- df_2022 |> 
  mutate(
    data_complete = map(data, \(x) drop_na(x)),
    sample_size = map_int(data_complete, \(x) nrow(x))
  )


var_model <- function(df){
  lm(value ~ crpd_category_v, data = df)
} 

safe_model <- var_model|> safely()

models <- df_2022 |> 
  mutate(
    model = map(data, safe_model)) |> 
 mutate(
   model = map(model, \(x)x[[1]])
 )

models <- models |> 
  mutate(
    glance = model |> map(broom::glance),
    rsq    = glance |> map(safely("r.squared")) |> map("result"),
    tidy   = model |> map(broom::tidy),
    augment= model |> map(broom::augment)
  ) |> 
  unnest(rsq, keep_empty = TRUE)

models <- models |> arrange(desc(rsq))

models <- models |> unnest (tidy) |> 
  select(-c(term, estimate, std.error, statistic)) |> 
  relocate(p.value, rsq, .after = vars) |> 
  janitor::clean_names()
models |> View()


var_plot <- p_value
# var_plot <- rsq
plot_mod <- models |>
  filter(!is.na(var_plot)) |>
  ggplot(aes(var_plot,reorder(vars, var_plot)))+
  geom_point()


plot_mod_2 <- plot_mod_2 +
  labs(x = "R^2",
       y = "variables")

# Broom -------------------------------------------------------------------




# mutate(
#   data = pmap(
#     list(f, x, y),
#     \(f, x, y) f |> 
#       select(country, !!y, !!x) |> 
#       drop_na()
# )