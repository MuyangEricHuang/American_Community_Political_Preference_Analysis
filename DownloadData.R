library(tidycensus)
library(here)
source("concepts.R")

# Download ACS data and compute variables of interest according to the concepts 
# listed in "concepts.R"

# Set up api key
# census_api_key("51fb009b9f413b9ce64f902dee19cea4789018c5", install = TRUE)

# Use ACS5 for 2022
ACS = "acs5"
year = 2022

output <- data.frame(GEOID=character(),
                     NAME=character(),
                     label=character(),
                     estimate=numeric())

# Concepts record variables of interest and how to compute them from ACS tables
for (concept in concepts){
  label <- concept$label # E.g., "Proportion of Married-couple family (B05)"
  # Source, e.g., c("B05001_006", "B05001_001")
  selected_variables <- concept$variables
  expression = concept$expression # How to compute, e.g., "B11001_003 / B11001_001"
  
  # Download state-level data
  data_state <- get_acs(geography = "state",
                        variables = selected_variables, 
                        year = year, 
                        survey = ACS)
  
  for (variable in selected_variables){
    assign(paste0(variable), data_state[data_state$variable==variable, ]$estimate)
  }
  estimate <- eval(parse(text=expression)) # E.g., "B11001_003 / B11001_001"
  
  # Download county-level data
  output <- rbind(
    output,
    data.frame(
      GEOID=data_state[
        data_state$variable==variable, ]$GEOID,
        NAME=factor(data_state[data_state$variable==variable, ]$NAME),
        label=label,
      estimate=estimate)
  )
  
  data_county <- get_acs(
    geography = "county",
    variables = selected_variables, 
    year = year, 
    survey = ACS)
  
  for (variable in selected_variables){
    assign(
      paste0(variable),
      data_county[data_county$variable == variable, ]$estimate)
  }
  estimate <- eval(parse(text=expression)) # E.g., "B11001_003 / B11001_001"
  
  output <- rbind(
    output,
    data.frame(
      GEOID=data_county[data_county$variable==variable, ]$GEOID,
      NAME=factor(data_county[data_county$variable==variable, ]$NAME),
      label=label,
      estimate=estimate)
  )
}

data_all <- output

# Save to "data" folder
save(data_all, file = here("data/data.RData"))
