## Acronyms
## - QoL: Quality of Life
## - UN: United Nations

## Steps:
## 1. Focus of study is on UN rights of persons with disabilities, 
##    so treat UN list of countries as the master list
## 2. Compare all countries from data on QoL factors (not UN data) to the UN 
##    master list
## 3. Apply patterns and replacements to clean the QoL data's countries
## 4. Join QoL data by country and year, 
##    clean country names,
##    fill values by country and year,
##    and get distinct country and year

source("R/my-packages.R")

path <- "data/subsets/"
files <- list.files(path, pattern = "\\.rds$") |> as.vector()

un_files <- c("un_convention.rds","un_protocol.rds")
files <- files[!files %in% un_files]

ls_non_un <- list()
for (i in files){q
  file_path <- paste(path,i, sep = "")
  temp_data <- readRDS(file_path)
  name <- str_extract(i,".*(?=\\.rds)")
  ls_non_un[[name]] <- temp_data
}

## Get all unique countries
countries_qol <- ls_non_un |> 
  map(\(x) unique(x$country)) |> 
  unlist() |> 
  unique() |> 
  str_sort()

source("R/get_country_replacements.R")
regexes <- get_country_replacements()
  
# -------------------------------------------------------------------------

## Manually check that countries that do not match the UN list
## are in fact not part of the UN list

# countries_qol <- countries_qol |> str_replace_all(regexes)
countries_un <- c(
  read_rds("data/subsets/un_protocol.rds") |> pull(country),
  read_rds("data/subsets/un_convention.rds") |> pull(country)
) |>
  unique() |> 
  sort()
# un <- tibble(country = countries_un, in_un_list = "yes") 
# tibble(country = countries_qol) |>
#   left_join(un, by = "country") |>
#   filter(is.na(in_un_list)) |>
#   View()

## Check passed

# -------------------------------------------------------------------------

## Let each df in ls_non_un exist in the global environment
## This is needed for Reduce()
list2env(ls_non_un, envir = .GlobalEnv)

un_convention <- read_rds("data/subsets/un_convention.rds")
un_protocol <- read_rds("data/subsets/un_protocol.rds") 

dat <- Reduce(
  \(x,y) full_join(x, y, by = join_by(country, year)),
  ls_non_un[!names(ls_non_un) %in% c("culture", "masculinity")]
  ) |> 
  full_join(ls_non_un$culture, by = join_by(country)) |> 
  full_join(ls_non_un$masculinity, by = join_by(country)) |> 
  ## Join UN data
  full_join(un_protocol, by = join_by(country)) |> 
  full_join(un_convention, by = join_by(country))

dat <- dat |> 
  mutate(country = str_squish(country) |> str_replace_all(regexes)) |> 
  arrange(country, desc(year)) |> 
  group_by(country, year) |> 
  fill(everything(), .direction = "updown") |> 
  distinct(country, year, .keep_all = TRUE)

dat <- dat |> filter(country %in% !!countries_un)
write_rds(dat, "data/dat.rds")
