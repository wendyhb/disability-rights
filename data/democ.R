# democracy index and categories -----------------------------------------

path_democ<-"data-raw/democracy_index_2006-2022_2023-11-8.csv"
democ_table<- read_csv(path_democ)
head(democ_table)
democ_table

cat_info <- data.frame(
  cat_a = "Full Democracy",
  cat_b = "Flawed Democracy",
  cat_c = "Hybrid Regime",
  cat_d = "Authoritarian Regime",
  cat_e = "No Data")

# filter out regions in the country column, create democracy categories
democ <- democ_table |>
  janitor::clean_names() |> 
  filter(!is.na(code)) |> 
  mutate(democracy_index = round(democracy_eiu,2), year = year |> as.integer()) |> 
  select(country = entity, democracy_index, year) |> 
  mutate(democracy_cat = case_when (democracy_index >= 8.01 ~ "Full Democracy",
                                    democracy_index >= 6.01 & democracy_index < 8.01 ~ "Flawed Democracy",
                                    democracy_index >= 4.01 & democracy_index < 6.01 ~ "Hybrid Regime",
                                    democracy_index >= 0 & democracy_index < 4.01 ~ "Authoritarian Regime",
                                    is.na(democracy_index) ~ "Not Available"))
democ

write_rds(democ, "data/democ.rds")
# decmoc category reference: https://en.wikipedia.org/wiki/The_Economist_Democracy_Index

