library(tidyverse)
library(readxl)
load("data/data.RData")

shapefile_path <- here("shapefiles/county_simple.shp")
counties <- st_read(shapefile_path)
counties <- st_transform(counties, crs = 4326)

shapefile_path <- here("shapefiles/state_simple.shp")
states <- st_read(shapefile_path)
states <- st_transform(states, crs = 4326)

# Map state to geoid or geoid to state
loc_mapping <- data.frame(
  loc = c(
    "U.S.", "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
    "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois",
    "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
    "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", 
    "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York",
    "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
    "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", 
    "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming",
    "District of Columbia"),
  id = c(
    0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 
    25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
    35, 36, 37, 38, 39, 40, 41, 42, 44, 45, 
    46, 47, 48, 49, 50, 51, 53, 54, 55, 56, 
    11)
)

Table_Shells <- read_xlsx("rawdata/ACS2022_Table_Shells.xlsx")
DataProductList <- read_xlsx("rawdata/2022_DataProductList.xlsx")

state2id <- function(state){
  # "California" -> 6
  # "U.S." -> 0
  sapply(state, function(x){loc_mapping[loc_mapping$loc == x, "id"]})
}

id2state <- function(id){
  # Counvert the id for state OR COUNTY to the name of the state
  # "California" -> 6
  # "Los Angeles" -> 6
  sapply(id, function(x){loc_mapping[loc_mapping$id == if_else(
    x >= 1000,
    x%%1000,
    x),
    "loc"]})
}

get_data <- function(GEOID, concept = NULL){
  # Get data for GOEID's child nodes
  # GEOID in definition: 01~56 for states, 100+ for counties
  # GEOID=0, then child nodes are states
  # GEOID!=0, childe nodes are counties
  
  if (!is.null(concept)){
    # Specify a concept
    output <- data_all[data_all$label == concept, c("GEOID", "estimate")]
    if (GEOID == 0){
      # U.S. data, return data for states
      output[as.numeric(output$GEOID) <= 99,]
    } else{
      # Counties whose GEOID %/% 100 = input_GEOID
      output[
        as.numeric(output$GEOID)%/%1000 == as.numeric(GEOID),
        c("GEOID", "estimate")]
    }
  } else{
    # Get estimates for all concepts, used for clustering
    if (GEOID == 0){
      # U.S. data, return data for states
      output <- data_all[
        as.numeric(data_all$GEOID) <= 99,
        c("GEOID", "label", "estimate")]
      output %>% pivot_wider(names_from = label, values_from = estimate)
    } else{
      # Counties whose GEOID %/% 100 = input_GEOID
      output <- data_all[
        as.numeric(data_all$GEOID)%/%1000 == as.numeric(GEOID),
        c("GEOID", "label", "estimate")]
      output %>% pivot_wider(names_from=label, values_from=estimate)
    }
  }
  
}

best_view <- function(loc_id){
  # Best lng, lat, zoom for region with GEOID = loc_id
  if (loc_id > 0){
    # focusing on a state
    lat <- states[as.numeric(states$STATEFP) == loc_id,]$INTPTLAT 
    lng <- states[as.numeric(states$STATEFP) == loc_id,]$INTPTLON
    state_aland <- states[as.numeric(states$STATEFP) == loc_id,]$ALAND
    # Empirical formula for a good perspective
    zoom <- -0.55 * log(state_aland) + 20.6
  } else{
    # Focusing on U.S.
    lng <- -98.5795
    lat <- 39.8283
    zoom <- 4
  }
  return(list(lng=lng, lat=lat, zoom = zoom))
}
