path <- "data/subsets/"
files <- list.files(path, pattern = "\\.rds$") |> as.vector()

library(dm)
ls_data <- list()
for (i in files){q
  file_path <- paste(path,i, sep = "")
  temp_data <- readRDS(file_path)
  name <- str_extract(i,".*(?=\\.rds)")
  ls_data[[name]] <- temp_data
}

list2env(ls_data, envir = .GlobalEnv)

un <- full_join(un_convention, un_protocol, by = join_by(country))

# One ---------------------------------------------------------------------

dm_one <- dm(
  corruption, 
  democracy,
  freedom,
  gdp,
  life_exp,
  safety,
  unemployment,
  
  culture,
  masculinity,
  un
)

dm_one |> 
  dm_add_pk(un, country) |> 
  dm_add_fk(corruption, country, un) |>
  dm_add_fk(democracy, country, un) |>
  dm_add_fk(gdp, country, un) |>
  dm_add_fk(life_exp, country, un) |>
  dm_add_fk(safety, country, un) |>
  dm_add_fk(unemployment, country, un) |>
  dm_add_fk(culture, country, un) |>
  dm_add_fk(masculinity, country, un) |>
  dm_add_fk(freedom, country, un) |>
  dm_set_colors(
    darkred = corruption,
    blue = freedom,
    gold = gdp,
    yellow = life_exp,
    darkgreen = safety, 
    brown = unemployment,
    
    whitesmoke = culture,
    orange = masculinity,
    pink = un
    ) |> 
  dm_draw(view_type = "all", rankdir = "BT")



# Final -------------------------------------------------------------------

un_disability <- full_join(un_convention, un_protocol, by = join_by(country))

culture_and_masculinity <- full_join(culture, masculinity, by = join_by(country))

positive_qol <- Reduce(
  \(x,y) full_join(x, y, by = join_by(country, year)),
  list(freedom, democracy, gdp, life_exp, safety)
)

negative_qol <- full_join(corruption, unemployment,
                          by = join_by(country, year))

project_dm <- dm(
  positive_qol, 
  negative_qol,
  culture_and_masculinity,
  un_disability
)

project_dm |> 
  dm_add_pk(un_disability, country) |> 
  dm_add_fk(negative_qol, country, un_disability) |>
  dm_add_fk(positive_qol, country, un_disability) |>
  dm_add_fk(culture_and_masculinity, country, un_disability) |>
  dm_set_colors(
    darkred = negative_qol,
    blue = positive_qol,
    gold = culture_and_masculinity,
    darkgreen = un_disability
  ) |> 
  dm_draw(view_type = "all", rankdir = "BT")

