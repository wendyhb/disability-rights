library("factoextra")
library(tidyverse)
# Enhanced k-means clustering
library(Amelia)
adata <- data_combined |> filter(year == 2022) 
missmap(adata)

missing_cases <- adata |> 
  ungroup() |> 
  summarize(
    across(everything(), \(x) sum(is.na(x)))
  ) |> 
  pivot_longer(
    cols = everything()
  ) |> 
  filter(value > 60)

missing_vars <- missing_cases |> 
  pull(name)

adata <- adata |>
  select(- all_of(missing_vars)) |> 
  drop_na()

# Prep ----------------------------------------------------------------

# All numeric

df <- adata |> 
  column_to_rownames("country") |> 
  select(- c(year, crpd_category, democracy_cat)) |> 
  scale()

# df <- scale(adata |> select(gdp, crpd_category_v) |> drop_na())

# Clustering --------------------------------------------------------------

# # Compute dissimilarity matrix
# res.dist <- dist(df, method = "euclidean")
# 
# # Compute hierarchical clustering
# res.hc <- hclust(res.dist, method = "ward.D2")
# 
# # Visualize
# plot(res.hc, cex = 0.5)

## HIERARCHICAL
res.hc <- eclust(df, "hclust") # compute hclust
fviz_dend(res.hc, rect = TRUE) # dendrogam
fviz_cluster(res.hc) # scatter plot

