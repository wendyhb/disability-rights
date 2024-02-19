get_country_replacements <- function() {
  
  c(".*Bahamas.*" = "Bahamas",
    ".*Bolivia.*" = "Bolivia",
    ".*Brunei.*"= "Brunei",
    ".*Bosnia And Herzegovina.*" = "Bosnia and Herzegovina",
    ".*Congo.*(Brazzaville).*" = "Congo",
    ".*Congo, Rep.*" = "Congo",
    
    ## Congo
    "Congo.*(Democratic Republic of the).*" = "Democratic Republic of the Congo",
    ".*Congo.*(Kinshasa).*" = "Democratic Republic of the Congo", 
    "Congo, Dem. Rep." = "Democratic Republic of the Congo",
    "Democratic Republic of Congo" = "Democratic Republic of the Congo", 
    
    "Cote d'Ivoire" = "Côte d'Ivoire",
    "Czechia" = "Czech Republic",
    
    "Eswatini.*" = "Eswatini",
    "Egypt, Arab Rep."= "Egypt",
    "Guinea Bissau" = "Guinea-Bissau",
    ".*Iran.*"= "Iran",
    
    ## North Korea
    ".*Korea.*(Democratic People's Rep. of).*" = "North Korea",
    ".*Korea, Dem. People's Rep.*" = "North Korea",
    ".*Korea, North.*" = "North Korea",
    
    ## South Korea
    ".*Korea.*(Republic of).*" = "South Korea",
    ".*Korea, Rep.*" = "South Korea",
    ".*Korea, South.*" = "South Korea",
    
    "Kyrgyz Republic" = "Kyrgyzstan",
    
    ".*Lao.*"= "Laos",
    ".*Micronesia.*" = "Micronesia",
    ".*Moldova.*"= "Moldova",
    ".*Palestine.*"= "Palestine",
    "Russian Federation" = "Russia",
    ".*Syria.*"= "Syria",
    "Sao Tome and Principe" = "São Tomé and Príncipe",
    ".*Tanzania.*"= "Tanzania",
    ".*Gambia.*"= "Gambia",
    "Trinidad And Tobago" = "Trinidad and Tobago",
    ".*Turkiye.*" = "Turkey",
    ".*Türkiye.*" = "Turkey",
    ".*United States of America.*" = "United States",
    ".*Venezuela.*" = "Venezuela",
    ".*Viet Nam.*" = "Vietnam",
    ".*Yemen.*" = "Yemen")
}