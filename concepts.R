# Concepts subtracted from each selected tables for visualization and analysis
# And the expression to compute them

concepts = list(
  
  # B01
  # B01001: Sex by Age
  # B01001_001: Total:
  # B01001_003: Male under 5 years
  # B01001_004: Male 5 to 9 years
  # B01001_005: Male 10 to 14 years
  # B01001_006: Male 15 to 17 years
  # B01001_027: Female under 5 years
  # B01001_028: Female 5 to 9 years
  # B01001_029: Female 10 to 14 years
  # B01001_030: Female 15 to 17 years
  # Concept of interest: Proportion of Voting-Age Population
  list(label="Proportion of Voting-Age Population (B01)", 
       variables=c("B01001_001", "B01001_003", "B01001_004", "B01001_005", "B01001_006", "B01001_027", "B01001_028", "B01001_029", "B01001_030"), 
       expression="1 - (B01001_003 + B01001_004 + B01001_005 + B01001_006 + B01001_027 + B01001_028 + B01001_029 + B01001_030) / B01001_001",
       hint="The proportion of the voting-age population not only directly influences voter participation rates but also reflects the age distribution within a region. Generally, younger voters are less likely to align with traditional conservative policies and are more inclined to support Democrats, while older voters tend to favor Republicans."),
  
  # B11
  # B11001: Household Type (Including Living Alone)
  # B11001_001: Total:
  # B11001_003: Family households: Married-couple family
  # Concept of interest: Proportion of Married-Couple Family
  list(label="Proportion of Married-Couple Family (B11)", 
       variables=c("B11001_003", "B11001_001"), 
       expression="B11001_003 / B11001_001",
       hint="This variable represents the family structures within a region and reflects certain traditional values of the society, influencing party preferences of voters. Historically, Republicans gained more support from the areas with higher proportion of married-couple family, especially in rural areas. This traditional family structure tends to closely align with Republican values. "),
  
  # B09
  # B09019: Household Type (Including Living Alone) by Relationship
  # B09019_001: Total:
  # B09019_011: Same-sex spouse
  # B09019_012: Opposite-sex unmarried partner
  # B09019_013: Same-sex unmarried partner
  # Concept of interest: Proportion of Households Not Classified as Traditional Relationships
  list(label="Proportion of Households Not Classified as Traditional Relationships (B09)", 
       variables=c("B09019_001", "B09019_011", "B09019_012", "B09019_013"), 
       expression="(B09019_011 + B09019_012 + B09019_013) / B09019_001",
       hint="policies of Democrats. Republicans, on the other hand, are often struggled to gain support from these households, partially due to the religious differences."),
  
  # B12
  # B12505: Number of Times Married by Sex by Marital Status for the Population 15 Years and Over
  # B12505_001: Total:
  # B12505_007: Male married three or more times
  # B12505_013: Female married three or more times
  # Concept of interest: Proportion of Population Married More than Three or More Times
  list(label="Proportion Population Married More Than Three or More Times (B12)", 
       variables=c("B12505_001", "B12505_007", "B12505_013"), 
       expression="(B12505_007 + B12505_013) / B12505_001",
       hint="Individuals who have been married multiple times are more likely to support traditional views and religious faiths on marriages, aligning with Republican values. Rural areas in the South and Midwest tend to have a higher proportion of population married multiple times, and thus we can observe political differences geographically based on this variable."),
  
  # B02
  # B02001: Race  
  # B02001_001: Total:
  # B02001_002: White alone  
  # Concept of interest: Proportion of Non-White Population 
  list(label="Proportion of Non-White Population (B02)", 
       variables=c("B02001_002", "B02001_001"), 
       expression="1 - B02001_002 / B02001_001",
       hint="Race and ethnicity, while heavily influencing the culture of a community, play a significant role in analyzing political preferences. A community with a high proportion of non-white population is more likely to support Democrats, due to its emphasis on civil rights, social justice, and perhaps immigration policies. "),
  
  # B07
  # B07007: Geographical Mobility in the Past Year by Citizenship Status for Current Residence in the United States 
  # B07007_001: Total:
  # B07007_030: Moved from abroad: Foreign born: Not a U.S. citizen
  # Concept of interest: Proportion of Current Residence (over 1 yr) Who Moved from Abroad as Non U.S. Citizen 
  list(label="Proportion of Current Residence (over 1 yr) Who Moved from Abroad as Non U.S. Citizen (B07)",
       variables=c("B07007_001", "B07007_030"), 
       expression="B07007_030 / B07007_001",
       hint="Many current residents who were not U.S. citizens when they moved from abroad may not yet be voters, but they are the potential voters and can reflect the political preferences of their communities in which they reside, particularly in urban areas. Historically, this population has favored Democrats due to its emphasis on inclusiveness and immigration reform."),
  
  # B25
  # B25003: Tenure   
  # B25003_001: Total:
  # B25003_002: Owner occupied  
  # Concept of interest: Proportion of Occupied Housing Units That are Owner-Occupied 
  list(label="Proportion of Occupied Housing Units That are Owner-Occupied (B25)", 
       variables=c("B25003_002", "B25003_001"), 
       expression="B25003_002 / B25003_001",
       hint="Studies show that individuals who own housing units tend to prioritize policies such as lower taxes and property rights, which aligns with support for Republicans. In urban areas, homeownership rates are lower and people tend to rent for living, so residents in these areas typically favor Democratic policies that focus on affordable housing, highlighting a geographic political difference."),
  
  # B19
  # B19013: Median Household Income in the Past 12 Months (in 2022 Inflation-Adjusted Dollars)    
  # B19013_001: Median household income in the past 12 months (in 2022 inflation-adjusted dollars)
  # Concept of interest: Median Household Income Level 
  list(label="Median Household Income Level (B19)", 
       variables="B19013_001", 
       expression="B19013_001",
       hint="Income levels vary significantly in urban, suburban, and rural areas, and we use median household income as the representative measure. Historically, lower-income households tend to support Democrats that advocating for big government, social equity, and public services, while higher-income households tend to support Republicans that advocating for small government, deregulation, and tax cuts."),
  
  # C24
  # C24010: Sex by Occupation for the Civilian Employed Population 16 Years and Over
  # C24010_001: Total:
  # C24010_030: Males: Natural resources, construction, and maintenance occupations:
  # C24010_034: Males: Production, transportation, and material moving occupations:
  # C24010_066: Females: Natural resources, construction, and maintenance occupations:
  # C24010_070: Females: Production, transportation, and material moving occupations:
  # Concept of interest: Proportion of Employed Civilians with Blue-Collar Occupations
  list(label="Proportion of Employed Civilians with Blue-Collar Occupations (C24)", 
       variables=c("C24010_030", "C24010_034", "C24010_066", "C24010_070", "C24010_001"), 
       expression="(C24010_030 + C24010_034 + C24010_066 + C24010_070) / C24010_001",
       hint="In this variable, blue-collar occupations stand for natural resources, construction, maintenance, production, transportation, and material moving occupations. These blue-collar workers tend to align with Republican values emphasizing on as tax cuts, job creation, and deregulation, although Democrats have historically been a party of labor unions. "),
  
  # B29
  # B29002: Citizen, Voting-Age Population by Educational Attainment   
  # B29002_001: Total:
  # B29002_007: Bachelor's degree
  # B29002_008: Graduate or professional degree
  # Concept of interest: Proportion of Voting-Age Population with a Bachelor's Degree or Higher
  list(label="Proportion of Voting-Age Population with a Bachelor's Degree or Higher (B29)", 
       variables=c("B29002_007", "B29002_008", "B25003_001"), 
       expression="(B29002_007 + B29002_008) / B25003_001",
       hint="Political preferences have been found to be closely associated with education levels. College students tend to focus on broader issues such as climate change mitigation, diversity, and civil rights. Geographically, people in urban areas have higher level of educational attainment on average, and individuals with higher education tend to support Democrats due to the party's emphasis on broader issues."),
  
  # B13
  # B13002: Women 15 to 50 Years Who Had a Birth in the Past 12 Months by Marital Status and Age
  # B13002_008: Women who had a birth in the past 12 months: Unmarried (never married, widowed, and divorced): 15 to 19 years old
  # B13002_017: Women who did not have a birth in the past 12 months: Unmarried (never married, widowed, and divorced): 15 to 19 years old
  # Concept of interest: Proportion of Unmarried Women Under 20 Who Gave Birth in the Past 12 Months
  list(label="Proportion of Unmarried Women Under 20 Who Gave Birth in the Past 12 Months (B13)", 
       variables=c("B13002_008", "B13002_017"), 
       expression="B13002_008 / (B13002_008 + B13002_017)",
       hint="The variable is designed to represent the culture of a community, specifically the extent of its open-mindedness. It also reflects the economic disadvantage of a community and its access to healthcare. Democrats is known for advocating for emphasize social welfare, affordable healthcare, and sex education to support young mothers. This variable can potentially identify communities that are more likely to support Democrats."),
  
  # B27
  # B27001: Health Insurance Coverage Status by Sex by Age     
  # B27001_001: Total:
  # B27001_004: Males: Under 6 years: With health insurance coverage
  # B27001_007: Males: 6 to 18 years: With health insurance coverage
  # B27001_010: Males: 19 to 25 years: With health insurance coverage
  # B27001_013: Males: 26 to 34 years: With health insurance coverage
  # B27001_016: Males: 35 to 44 years: With health insurance coverage
  # B27001_019: Males: 45 to 54 years: With health insurance coverage
  # B27001_022: Males: 55 to 64 years: With health insurance coverage
  # B27001_025: Males: 65 to 74 years: With health insurance coverage
  # B27001_028: Males: 75 years and over: With health insurance coverage
  # B27001_032: Females: Under 6 years: With health insurance coverage
  # B27001_035: Females: 6 to 18 years: With health insurance coverage
  # B27001_038: Females: 19 to 25 years: With health insurance coverage
  # B27001_041: Females: 26 to 34 years: With health insurance coverage
  # B27001_044: Females: 35 to 44 years: With health insurance coverage
  # B27001_047: Females: 45 to 54 years: With health insurance coverage
  # B27001_050: Females: 55 to 64 years: With health insurance coverage
  # B27001_053: Females: 65 to 74 years: With health insurance coverage
  # B27001_056: Females: 75 years and over: With health insurance coverage
  # Concept of interest: Proportion of Non-Institutionalized Civilian with Health Insurance 
  list(label="Proportion of Non-Institutionalized Civilian with Health Insurance (B27)", 
       variables=c("B27001_004", "B27001_007", "B27001_010", "B27001_013", "B27001_016", "B27001_019",
                   "B27001_022", "B27001_025", "B27001_028", "B27001_032", "B27001_035", "B27001_038",
                   "B27001_041", "B27001_044", "B27001_047", "B27001_050", "B27001_053", "B27001_056", "B27001_001"), 
       expression="(B27001_004 + B27001_007 + B27001_010 + B27001_013 + B27001_016 + B27001_019 + B27001_022 + B27001_025 + B27001_028 + B27001_032 + B27001_035 + B27001_038 + B27001_041 + B27001_044 + B27001_047 + B27001_050 + B27001_053 + B27001_056) / B27001_001",
       hint="High health insurance coverage rates suggest progressive values within communities. These communities prioritize social welfare and equity, aligning with Democratic policies, particularly in urban areas. Communities with low health insurance coverage rates, often found in rural areas, tend to prefer less government intervention. Residents in these areas may prioritize reducing healthcare costs rather than expanding health insurance coverage, aligning with Republican policies.
")
  
)

get_concept_by_group <- function(group){
  if (group=="Demographic Structure"){
    return (c(
      "Proportion of Voting-Age Population (B01)",
      "Proportion of Married-Couple Family (B11)",
      "Proportion of Households Not Classified as Traditional Relationships (B09)",
      "Proportion Population Married More Than Three or More Times (B12)"))
  }
  if (group=="Ethnicity and Culture"){
    return (c(
      "Proportion of Non-White Population (B02)",
      "Proportion of Current Residence (over 1 yr) Who Moved from Abroad as Non U.S. Citizen (B07)",
      "Proportion of Occupied Housing Units That are Owner-Occupied (B25)"))
  }
  if (group=="Socioeconomy"){
    return (c(
      "Median Household Income Level (B19)",
      "Proportion of Employed Civilians with Blue-Collar Occupations (C24)",
      "Proportion of Voting-Age Population with a Bachelor's Degree or Higher (B29)"))
  }
  if (group=="Health and Fertility"){
    return (c(
      "Proportion of Unmarried Women Under 20 Who Gave Birth in the Past 12 Months (B13)",
      "Proportion of Non-Institutionalized Civilian with Health Insurance (B27)"))
  }
  if (group=="All"){
    return (sapply(concepts, function(x){x$label}))
  }
}
