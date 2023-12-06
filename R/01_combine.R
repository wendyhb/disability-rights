source("R/my-packages.R")
path <- "data/clean-raw/"
files <- list.files(path, pattern = "\\.rds$") |> 
  as.vector()


# crpd and protocol have no year column, so its excluded for full_join()

# [1] "cpi.rds"            
# [2] "crpd.rds"           
# [3] "culture_factors.rds"
# [4] "democ.rds"          
# [5] "freedom.rds"        
# [6] "gdp.rds"            
# [7] "life_exp.rds"       
# [8] "protocol.rds"       
# [9] "safety.rds"         
# [10] "unemployment.rds"   


files <- files[!files %in% c("crpd.rds","protocol.rds")]

  
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

non_crpd <- Reduce(
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

# non_crpd <- full_join(cpi, democ, by = c("country","year")) |> 
#   full_join(gdp, by = c("country", "year")) |>
#   full_join(safety, by = c("country", "year"))|>
#   full_join(culture_factors, by = c("country", "year")) |>
#   full_join(life_exp, by = c("country", "year"))|>
#   full_join(unemployment, by = c("country", "year"))

non_crpd <- non_crpd |> 
  mutate(country = str_replace_all(
    country,
    c("Bosnia And Herzegovina" = "Bosnia and Herzegovina",
      "Côte d'Ivoire" = "Cote d'Ivoire",
      "Guinea Bissau" = "Guinea-Bissau",
      "Trinidad And Tobago" = "Trinidad and Tobago")) |> 
      str_squish()
  ) 

non_crpd_raw <- non_crpd |> 
  filter(year > 2007) |> 
  arrange(country, desc(year))

write_rds(non_crpd, "data/non_crpd_raw.rds")


