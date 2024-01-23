source("R/03_tables.R")
# gt_tb <- summ_categ_year_loc |> 
#   gt() |> 
#   tab_header(
#     title = md("**Family Housing Community Development**"),
#     subtitle = md("Programs by *type*") ) |> 
#   tab_source_note (
#     source_note = "Source: Starez")
# 
# gt_tb <- gt_tb |> 
#   tab_spanner(
#     label = "year",
#     columns = c("2021", "2022", "2023")
#   )
# write_rds(gt_tb, "output/tb_categ_y_loc.rds")
# gtsave(gt_tb, "output/tb_categ_y_loc.html")

