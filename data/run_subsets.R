scripts <- fs::dir_ls("data/subsets", type = "file", glob = "*.R")
map(scripts, source)
