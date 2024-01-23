source("R/my-packages.R")

df_2022 <- read_rds("output/data-report_2017-2023_filled.rds")
df_2022 <-df_2022 |> 
  filter(year == 2022) |> 
  select(-c(democracy_cat,year, crpd_category))


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

models<- models |> arrange(desc(rsq))

# Create a vector of 20 colors from the "Set3" palette
colorblind_light <- c("#ff99cc", "#33a02c", "#8B2500", "#006400", "#6a3d9a",
                      "#a6cee3", "#cc33ff", "lightsteelblue4", "#66ff66","#0000FF",
                      "burlywood4", "darkslategray4", "#3498db", "#bcbd22", "#ffcc00",
                      "#66ffff", "#e67e22", "#473C8B", "#292929", "#e74c3c")



# Print the vector of colors

models |> 
  ggplot(aes(rsq, reorder(vars, rsq)))+
  geom_point(aes(colour = vars))+
  scale_colour_manual(values = colorblind_light)



#note: the map() above can be written as below
# models <- models |> 
#   mutate(
#     tidy   = model |> map(\(x) broom::tidy (x)),
#     glance = model |> map(\(x)broom::glance (x)),
#     augment= model |> map(model,\(x)broom::augment (x))
#   )

models |> head(1) |> View()

# Broom -------------------------------------------------------------------




# mutate(
#   data = pmap(
#     list(f, x, y),
#     \(f, x, y) f |> 
#       select(country, !!y, !!x) |> 
#       drop_na()
# )