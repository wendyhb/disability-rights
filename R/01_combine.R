source("R/my-packages.R")
path <- "data/clean-raw/"
files <- list.files(path, pattern = "\\.rds$") |> 
  as.vector()
my_list <- list()

for (i in files){
  file_path <- paste(path,i, sep = "")
  temp_data <- readRDS(file_path)
  name <- str_extract(i,".*(?=\\.rds)")
  my_list[[name]] <- temp_data
}
# the data frames in the list my_list will be unlisted into individual data frames in the global environment.
list2env(my_list, envir = .GlobalEnv)
head(cpi)
head(democ)
head(gdp)
head(safety)
head(culture_factors)
head(freedom)
head(life_exp)
head(unemployment)
head(crpd)

# join the data together

my_list <- my_list[names(my_list) != "crpd"]

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

non_crpd <- non_crpd |> arrange(country, desc(year))
write_rds(non_crpd, "data/non_crpd.rds")
