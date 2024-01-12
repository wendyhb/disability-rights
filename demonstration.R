
file_to_move <-fs::dir_ls("data-raw", glob = "*.csv|*.xlsx") 
fs::dir_create("data-raw/renamed")
fs::file_move(file_to_move, "data-raw/renamed")

fs::file_move("C:/Users/cyn64/repo/disability-rights/others", "C:/Users/cyn64/repo/disability-rights/prose")
file.rename("C:/Users/cyn64/repo/disability-rights/others","C:/Users/cyn64/repo/disability-rights/prose")
