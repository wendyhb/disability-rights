source("R/my-packages.R")
my_path <- getwd()
files <- list.files("C:/Users/cyn64/OneDrive - University of Guelph/r/disability-rights/data", pattern = "\\.rds$") |> 
  as.vector()
# [1] "cpi.rds"             "crpd.rds"           
# [3] "crpd_web-scrapt.rds" "culture_factors.rds"
# [5] "democ.rds"           "freedom.rds"        
# [7] "gdp.rds"             "life_exp.rds"       
# [9] "safety.rds"          "unemployment.rds"  
my_list <- list()

for (i in files){
  file_path <- paste("C:/Users/cyn64/OneDrive - University of Guelph/r/disability-rights/data/",i, sep = "")
  temp_data <- readRDS(file_path)
  name <- str_extract(i,".*(?=\\.rds)")
  my_list[[name]] <- temp_data
}
my_list
names(my_list)
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
full_data <- full_join(cpi, democ, by = c("country","year")) |> 
  full_join(gdp, by = c("country", "year")) |>
  full_join(safety, by = c("country", "year"))|>
  full_join(culture_factors, by = c("country", "year")) |>
  full_join(life_exp, by = c("country", "year"))|>
  full_join(unemployment, by = c("country", "year")) |> 
  full_join(crpd, by = c("country"))

full_data <- full_data |> arrange(country, desc(year))

write_rds(full_data, "data/full_data.rds")