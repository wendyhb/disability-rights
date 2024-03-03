url <- "https://treaties.un.org/Pages/ViewDetails.aspx?src=TREATY&mtdsg_no=IV-15-a&chapter=4&clang=_en"
un_protocol <- url |> 
  read_treaty_url() |> 
  rename_with(
    \(x) glue("{x}_protocol"),
    starts_with("date")
  )

write_rds(un_protocol, "data/subsets/un_protocol.rds") 
