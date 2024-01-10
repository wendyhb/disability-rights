source("R/my-packages.R")
files <- list.files(path, pattern = "\\.rds$") |> 
  as.vector()


# crpd and protocol have no year column, so its excluded for full_join()

# [1] "corruption_index.rds"               
# [2] "convention.rds"    
# [3] "culture.rds"   
# [4] "democracy.rds"             
# [5] "freedom.rds"           
# [6] "gdp.rds"               
# [7] "life_exp.rds"          
# [8] "protocol.rds"
# [9] "safety.rds"            
# [10] "unemployment.rds"   

path <- "data/clean-raw/"
files <- files[!files %in% c("convention.rds","protocol.rds")]

  
my_list <- list()

for (i in files){
  file_path <- paste(path,i, sep = "")
  temp_data <- readRDS(file_path)
  name <- str_extract(i,".*(?=\\.rds)")
  my_list[[name]] <- temp_data
}

# the data frames in the list my_list will be unlisted into individual data frames in the global environment.
list2env(my_list, envir = .GlobalEnv)
my_list <- my_list[names(my_list)]

# Reduce will apply the function to the first two elements of the list
# then the result with the third element of the list
# and so on

data_no_convention_protocol <- Reduce(
  \(x,y) full_join(x, y, by = join_by(country, year)),
  my_list
  )

# library(fuzzyjoin)
# 
# fuzz <- Reduce(
#   \(x,y) stringdist_join(
#     x, y, by = c("country", "year"),
#     mode='left', #use left join
#     method = "jw", #use jw distance metric
#     max_dist=99, 
#     distance_col='dist'
#     ), 
#   my_list
# )

# It mimics:

# non_crpd <- full_join(corruption_index, democracy, by = c("country","year")) |> 
#   full_join(gdp, by = c("country", "year")) |>
#   full_join(safety, by = c("country", "year"))|>
#   full_join(culture, by = c("country", "year")) |>
#   full_join(life_exp, by = c("country", "year"))|>
#   full_join(unemployment, by = c("country", "year"))

data_no_convention_protocol <- data_no_convention_protocol |> 
  mutate(country = str_replace_all(
    country,
    c("Bosnia And Herzegovina" = "Bosnia and Herzegovina",
      "Côte d'Ivoire" = "Cote d'Ivoire",
      "Guinea Bissau" = "Guinea-Bissau",
      "Trinidad And Tobago" = "Trinidad and Tobago")) |> 
      str_squish()
  ) 

data_no_convention_protocol <- data_no_convention_protocol |> 
  filter(year > 2007) |> 
  arrange(country, desc(year))

write_rds(data_no_convention_protocol, "data/data_no_convention_protocol.rds")


