get_country_replacements <- function() {
  
  c(".*Bahamas.*" = "Bahamas",
    ".*Bolivia.*" = "Bolivia (Plurinational State of)",
    ".*Brunei.*"= "Brunei Darussalam",
    ".*Bosnia And Herzegovina.*" = "Bosnia and Herzegovina",
    
    ".*Congo.*(Brazzaville).*" = "Congo",
    ".*Congo, Rep.*" = "Congo",
    
    ## Congo
    "Congo.*(Democratic Republic of the).*" = "Democratic Republic of the Congo",
    ".*Congo.*(Kinshasa).*" = "Democratic Republic of the Congo", 
    "Congo, Dem. Rep." = "Democratic Republic of the Congo",
    "Democratic Republic of Congo" = "Democratic Republic of the Congo", 
    
    ".*Ivoire" = "Côte d'Ivoire",
    "Czechia" = "Czech Republic",
    
    "Eswatini.*" = "Eswatini",
    "Egypt, Arab Rep."= "Egypt",
    "Guinea Bissau" = "Guinea-Bissau",
    ".*Iran.*"= "Iran (Islamic Republic of)",
    
    ## Democratic People's Republic of Korea
    ".*Korea.*(Democratic People's Rep. of).*" = "Democratic People's Republic of Korea",
    ".*Korea, Dem. People's Rep.*" = "Democratic People's Republic of Korea",
    ".*Korea, North.*" = "Democratic People's Republic of Korea",
    
    ## Republic of Korea
    ".*Korea.*(Republic of).*" = "Republic of Korea",
    ".*Korea, Rep.*" = "Republic of Korea",
    ".*Korea, South.*" = "Republic of Korea",
    
    "Kyrgyz Republic" = "Kyrgyzstan",
    
    ".*Lao.*"= "Lao People's Democratic Republic",
    ".*Micronesia.*" = "Micronesia (Federated States of)",
    ".*Moldova.*" = "Republic of Moldova",
    ".*Netherlands.*" = "Netherlands (Kingdom of the)",
    ".*Palestine.*" = "State of Palestine",
    "Saint" = "St.",
    ".*Syria.*" = "Syrian Arab Republic",
    ".*Tanzania.*" = "United Republic of Tanzania",
    ".*Gambia.*" = "Gambia",
    ".*Trinidad And Tobago.*" = "Trinidad and Tobago",
    ".*Turkiye.*" = "Türkiye",
    ".*Türkiye.*" = "Türkiye",
    ".*United States of America.*" = "United States of America",
    ".*United Kingdom.*" = "United Kingdom of Great Britain and Northern Ireland",
    ".*Venezuela.*" = "Venezuela (Bolivarian Republic of)",
    ".*Viet Nam.*" = "Viet Nam",
    ".*Yemen.*" = "Yemen")
}