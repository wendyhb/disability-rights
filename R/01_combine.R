source("R/my-packages.R")
my_path <- getwd()
files <- list.files("data", pattern = "\\.rds$") |> 
  as.vector()
my_list <- list()

for (i in files){
  file_path <- paste("data/",i, sep = "")
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
  culture_factors |> view()
head(freedom)
head(life_exp)
head(unemployment)
head(crpd)

# join the data together

my_list <- my_list[names(my_list) != "crpd"]

# Reduce will apply the function to the first two elements of the list
# then the result with the third element of the list
# and so on

full_data <- Reduce(
  \(x,y) full_join(x, y, by = join_by(country, year)), 
  my_list
  )
library(fuzzyjoin)

fuzz <- Reduce(
  \(x,y) stringdist_join(
    x, y, by = c("country", "year"),
    mode='left', #use left join
    method = "jw", #use jw distance metric
    max_dist=99, 
    distance_col='dist'
    ), 
  my_list
)


full_data$country |> unique()

# It mimics:

# full_data <- full_join(cpi, democ, by = c("country","year")) |> 
#   full_join(gdp, by = c("country", "year")) |>
#   full_join(safety, by = c("country", "year"))|>
#   full_join(culture_factors, by = c("country", "year")) |>
#   full_join(life_exp, by = c("country", "year"))|>
#   full_join(unemployment, by = c("country", "year"))

full_data <- full_data |> arrange(country, desc(year))

write_rds(full_data, "data/full_data.rds")
