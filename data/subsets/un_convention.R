url <- "https://treaties.un.org/Pages/ViewDetails.aspx?src=TREATY&mtdsg_no=IV-15&chapter=4&clang=_en"
un_convention <- url |> 
  read_treaty_url() |> 
  rename_with(
    \(x) glue("{x}_convention"),
    starts_with("date")
  )
  
write_rds(un_convention, "data/subsets/un_convention.rds") 
