#
# This is the server logic of a Shiny web application. You can run the
# application by clicking "Run App" above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinyjs)
library(leaflet)
library(sf)
library(stringr)
library(rmapshaper)
library(here)
library(plotly) 
library(tidyverse)
library(ggplot2)
library(mosaic)

source("utils.R")

MAX_KMEANS_SIZE <- 10

CURRENT_RENDERING = -1 # 0 for national, int+ for a state, -1 before init
CURRENT_RENDERING_P2 = -1 # 0 for national, int+ for a state, -1 before init
TAB2_INIT = FALSE # Whether page 2 has been initiated (clicked)
# Data displayed in the page, updated when render_map is called
DATA_ON_DISPLAY = NULL
# Data displayed in the page, updated when render_map_p2 is called
DATA_ON_DISPLAY_P2 = NULL
# Whether we currently have a cluster assignment based on the data
CLUSTER_READY = FALSE
CLUSTER_RESULT = NULL # Cluster designation

# Render the map with id = map_id
render_map <- function(session, map_id="map1"){
  color = "blue"
  
  # Render the choropleth map on page "variable"
  if (map_id=="map1"){
    loc <- session$input$location_select # Name of location
    
    concept <- session$input$concept_select
    
    CURRENT_RENDERING <<- state2id(loc)
    data <- generate_data(loc, concept)
    DATA_ON_DISPLAY <<- data
    if (("estimate" %in% names(data)) && !all(is.na(data$estimate))){
      color_palette <- colorNumeric(
        "YlOrRd",
        domain = data$estimate,
        na.color = "#808080")
      color <- ~color_palette(data$estimate)
      values <- ~data$estimate
      session$output$info_p1 <- renderText({
        ''
      })
    }
    else{
      color_palette <- colorNumeric(
        "YlOrRd",
        domain = c(0,1),
        na.color = "#808080")
      color <- "grey"
      values <- c(0,1)
      session$output$info_p1 <- renderText({
        HTML('<span style="color: red;">Selected concept not available at this level.</span>')
      })
      # return()
    }
    data$vis_value <- round(data$estimate, 4)
    legend_title = "Range"
    
  } else if (map_id=="map2") { # Visualize cluster map on page 2
    loc <- session$input$location_select_p2 # Name of location
    loc_id <- state2id(loc)
    # concept <- session$input$concept_select_p2
    CURRENT_RENDERING_P2 <<- loc_id
    if (loc_id==0){
      data <- states
    } else {
      data <- counties[as.numeric(counties$STATEFP)==loc_id,]
    }
    if (CLUSTER_READY){
      data <- left_join(
        data,
        CLUSTER_RESULT,
        by="GEOID")
      
    } else {
      data$cluster = 1
    }
    data$vis_value=data$cluster
    # Color polygons by cluster
    color_palette <- colorFactor(
      palette = "Set1",
      domain = data$cluster
    )
    color <- ~color_palette(data$cluster)
    values <- ~data$cluster
    DATA_ON_DISPLAY_P2 <<- data
    
    legend_title = "Cluster"
  }
  
  loc_id <- state2id(loc)
  bv <- best_view(loc_id) # A list of lng, lat, zoom for viewing the map
  
  leafletProxy(map_id) %>%
    clearShapes() %>%
    clearControls() %>% 
    addPolygons(
      data = data,
      layerId = ~ as.numeric(GEOID),
      color = color,
      weight = 1,
      fillOpacity = 0.5,
      options = pathOptions(
        interactive = TRUE,
        bubblingMouseEvents = FALSE),
      label = ~paste(NAME, ", original value:", vis_value),
      labelOptions = labelOptions(
        style = list("color" = "black"),
        textsize = "12px",
        direction = "auto"
      ),
      highlightOptions = highlightOptions(
        weight = 3,
        color = "red",
        bringToFront = TRUE
      )
    ) %>%
    addLegend(
      data = data,
      "bottomright",
      pal = color_palette,
      values = values,
      title = legend_title) %>%
    setView(
      lng = bv$lng,
      lat = bv$lat,
      zoom = bv$zoom)
}

# Plot histogram for the selected concept on page 1
render_hist <- function(session) {
  if (is.null(DATA_ON_DISPLAY) || !"estimate" %in% names(DATA_ON_DISPLAY)){
    # Empty
    session$output$plot_hist <- renderPlotly({
      ggplot_plot <- ggplot()
      ggplotly(ggplot_plot)
    })
    return()
  }
    
  data <- DATA_ON_DISPLAY[!is.na(DATA_ON_DISPLAY$estimate), ]
  if (nrow(data)<2){
    # Empty
    session$output$plot_hist <- renderPlotly({
      ggplot_plot <- ggplot()
      ggplotly(ggplot_plot)
    })
    return()
  }
  density_data <- density(data$estimate)
  df <- data.frame(
    x = density_data$x,
    y = density_data$y)
  session$output$plot_hist <- renderPlotly({
    ggplot_plot <- data %>%
      ggplot(aes(x = estimate)) + # Compute histogram based on estimate
      geom_histogram(aes(y = after_stat(density))) + 
      geom_line(
        aes(
          x = x,
          y = y),
        data=df,
        color="red") + 
      theme_minimal() +
      labs(
        x = "Estimate Value",
        y = "Frequency",
        title = "Distribution of Estimates")
    ggplotly(ggplot_plot)
  })
}

# Barplot to visualize cluster on page 2
render_hist_p2 <- function(session){
  if (!CLUSTER_READY) 
    return()
  concept_check <- session$input$check_concept_p2
  loc <- session$input$location_select_p2
  loc_id <- state2id(loc)
  
  # B12 doesn't have county-level data
  if ((loc_id > 0) && concept_check == "Proportion Population Married More Than Three or More Times (B12)"){
    session$output$plot_elbow <- renderPlotly({
      ggplot_plot <- ggplot()
      ggplotly(ggplot_plot)
    })
    session$output$info_p2 <- renderText({
      HTML('<span style="color: red;">Selected concept not available at this level.</span>')
    })
    return()
  }
  
  session$output$info_p2 <- renderText({
    ''
  })
  
  data <- get_data(
    loc_id,
    concept=concept_check)
  
  # Get clear whether we are visualizing whole U.S. or a state
  if (loc_id == 0){
    region_show <- states
  } else {
    region_show <- counties[as.numeric(counties$STATEFP) == loc_id,]
  }
  
  data <- left_join(region_show, data, by = "GEOID")[c("GEOID", "NAME", "estimate")]
  data <- left_join(data, CLUSTER_RESULT, by="GEOID") %>% na.omit()
  data <- data %>% arrange(estimate)
  data$region <- paste0(data$GEOID, "-", data$NAME)
  data$region <- reorder(data$region, 1:nrow(data))
  
  # Color the bars based on cluster designation
  color_palette <- colorFactor(
    palette = "Set1",
    domain = data$cluster
  )
  colors <- color_palette(data$cluster)
  names(colors) <- data$cluster
  scale_color_spell <- scale_color_manual(values = color_palette(data$cluster))
  
  session$output$plot_elbow <- renderPlotly({
    ggplot_plot <- data %>%
      ggplot(
        aes(
          x = region, # Plot by GEOID to avoid problems caused by duplicate names
          y = estimate),
        ) + 
      geom_bar(
        aes(fill=cluster),
        stat = "identity") +
      scale_fill_manual(values = colors) +
      scale_x_discrete(
        labels = data$NAME # Relabel x-axis with region name
      ) +
      theme(axis.text.x = element_text(
        angle = 90,
        hjust = 1,
        vjust = 0.5,
        size=6)) +
      labs(
        x = "Region",
        y = "Estimates",
        title = "Estimates Values in Each Region",
        fill = "Cluster"
      )
    ggplotly(ggplot_plot)
  })
}

# Print stats table on page 1
print_summary_table <- function(session){
  if (is.null(DATA_ON_DISPLAY) || !"estimate" %in% names(DATA_ON_DISPLAY)){
    
    return()
  } 
  
  data <- DATA_ON_DISPLAY[!is.na(DATA_ON_DISPLAY$estimate), ]$estimate
  data_s <- favstats(data)
  session$output$summary_table <- renderTable({
    data.frame(Statistics=str_to_title(names(data_s)), Value=c(
      data_s$min,
      data_s$Q1,
      data_s$median,
      data_s$Q3,
      data_s$max,
      data_s$mean,
      data_s$sd,
      data_s$n,
      data_s$missing))
  })
}

# Elbow plot for selected region and concept group on page 2
plot_elbow <- function(session){
  if (!TAB2_INIT){
    return()
  }
  loc <- session$input$location_select_p2
  loc_id <- state2id(loc)
  data4clus <- generate_data_p2(session) %>% na.omit()
  if (length(data4clus)<=1){
    # Data has not been initiated
    return()
  }
  
  wss <- function(k, data){
    kmeans(scale(data), k, nstart=50)$tot.withinss
  }
  
  k <- 1:min(MAX_KMEANS_SIZE, nrow(data4clus) - 1) # Avoid k being too much
  set.seed(666)
  
  # Compute wss for k from 1 to MAX_KMEANS_SIZE
  if (nrow(data4clus) == 1){
    session$output$plot_elbow <- renderPlotly({
      ggplotly(ggplot())
    })
    return()
  }
  wss.s <- map_dbl(k, wss, data=scale(data4clus[-1]))
  wss.vs.k <- data.frame(wss = wss.s, k = k)
  
  # Generate elbow plot
  session$output$plot_elbow <- renderPlotly({
    
    ggplot_plot <- wss.vs.k %>% ggplot(
      aes(
        x=k,
        y=wss.s))+
      geom_point()+
      geom_line() +
      scale_x_continuous(
        breaks = 1:length(k),
        labels = 1:length(k)    # make sure only integer for x label
      ) +
      labs(
        x="Cluster Size",
        y="Total Sum of Within-group Variance",
        title="Elbow Plot: WSS vs K")
    
    ggplotly(ggplot_plot)
  })
}

# In utils.R
# Subset data_all to data within the location and concept
# get_data <- function(loc, concept)

# Get data and join with location name
generate_data <- function(loc, concept = NULL){
  # loc: e.g., "U.S." / "California"
  # Concept: e.g., "Proportion of Married-couple family (B05)"
  loc_id <- state2id(loc)
  
  if ((loc_id == 0) && !is.null(concept)){
      # Get the estimates on this concept for each state in U.S.
      data <- get_data(loc_id, concept) # Data: GEOID - estimate
      return(left_join(states, data, by = "GEOID"))
    
  } else if ((loc_id > 0) && !is.null(concept)){
    # Get the estimates on this concept for each county in the state "loc_id"
    counties_show <- counties[as.numeric(counties$STATEFP) == loc_id,]
    data <- get_data(loc_id, concept) # Data: GEOID - estimate
    return(left_join(counties_show, data, by="GEOID"))
    
  } else if ((loc_id == 0) && is.null(concept)){
    # Get the estimates on all concept for each state in U.S.
    data <- get_data(loc_id, concept) # Data: GEOID - estimate1 - ...
    return(left_join(states, data, by = "GEOID"))
    
  } else if ((loc_id > 0) && is.null(concept)){
    # Get the estimates on all concept for each counties in the state
    counties_show <- counties[as.numeric(counties$STATEFP) == loc_id,]
    data <- get_data(loc_id, concept) # Data: GEOID - estimate1 - ...
    return(left_join(counties_show, data, by = "GEOID"))
  }
}

# Get data and select certain concept groups for clustering
generate_data_p2 <- function(session){
  # loc: e.g., "U.S." / "California"
  loc <- session$input$location_select_p2
  
  # Concept_group: All, (other groups)
  concept_group <- session$input$concept_select_p2
  loc_id <- state2id(loc)
  covered_concepts <- get_concept_by_group(concept_group)
  
  if ((loc_id == 0)){
    # Get the estimates on all concept for each state in U.S.
    data <- get_data(loc_id, concept = NULL) # Data: GEOID - estimate1 - ...
    data <- data %>% select(c("GEOID", covered_concepts))
    
  } else if ((loc_id > 0)){
    # Get the estimates on all concept for each counties in the state
    counties_show <- counties[as.numeric(counties$STATEFP) == loc_id,]
    data <- get_data(loc_id, concept = NULL) # Data: GEOID - estimate1 - ...
    covered_concepts <- setdiff(
      covered_concepts,
      "Proportion Population Married More Than Three or More Times (B12)")
    
    data <- data %>% select(c("GEOID", covered_concepts))
  }
  return(data)
}

# Define server logic required to draw a histogram
function(input, output, session) {
  output$map1 <- renderLeaflet({
    # Initiate map on page 1
    leaflet(data = states) %>%
      addTiles() %>%
      setView(lng = - 98.5795, lat = 39.8283, zoom = 4)
  })
  
  output$map2 <- renderLeaflet({
    # Initiate map on page 2
    leaflet(data = states) %>%
      addTiles() %>%
      setView(lng = - 98.5795, lat = 39.8283, zoom = 4)
  })
  
  # Initialization
  observe({
    concepts <- unique(data_all$label)
    updateSelectInput(
      session, "concept_select",
      choices = concepts,
      selected = concepts[1]
    )
    updateSelectInput(
      session, "check_concept_p2",
      choices = concepts,
      selected = concepts[1]
    )
    updateSelectInput(
      session, "concept_select_p2",
      choices = c("All", "Demographic Structure", "Ethnicity and Culture", 
                  "Socioeconomy", "Health and Fertility"), 
      selected = "All"
    )
    updateSelectInput(
      session, "k_means_size",
      choices = 1:MAX_KMEANS_SIZE,
      selected = 1
    )
    output$p3_html_content <- renderUI({
      includeHTML("./www/Dict.html")
    })
    output$p4_html_content <- renderUI({
      includeHTML("./www/Reference.html")
    })
  })
  
  # On location select, focus on the selected location
  observeEvent(input$location_select, {
    if (input$location_select == "Connecticut"){
      updateSelectInput(
        session, "location_select",
        selected = "U.S."
      )
      showModal(
        modalDialog(
          title = "Ooops",
          "Data within Connecticut are collected by planning regions, which is imcompatible with our county-based geographic data. Returning to U.S. level page",
          easyClose = TRUE,
          footer = tagList(
            modalButton("Fine...")
          )
        )
      )
      return()
    }
    
    render_map(session) # Update map
    render_hist(session) # Update histogram
    print_summary_table(session) # Update stat table
    
  })
  
  # On location select (page 2), focus on the selected location
  observeEvent(input$location_select_p2, {
    if (input$location_select_p2 == "Connecticut"){
      showModal(
        modalDialog(
          title = "Ooops",
          "Data within Connecticut are collected by planning regions, which is imcompatible with our county-based geographic data. Returning to U.S. level page",
          easyClose = TRUE,
          footer = tagList(
            modalButton("Fine...")
          )
        )
      )
      updateSelectInput(
        session, "location_select_p2",
        selected = "U.S."
      )
      return()
    }
    # Current cluster will be outdated due to location shift
    CLUSTER_READY <<- FALSE
    CLUSTER_RESULT <<- NULL
    
    render_map(session, map_id = "map2")
    plot_elbow(session)
    
  })
  
  # Select concept, re-render by new values
  observeEvent(input$concept_select, {
    # Check validity by str length
    if (str_length(input$concept_select) > 5){
      render_map(session)
      render_hist(session)
      print_summary_table(session)
      
      hint <- Filter(function(x) x$label==input$concept_select, concepts)[[1]]$hint
      output$hint_p1 <- renderText({
        hint
      })
      
    }
  })
  
  # Select concept group (p2), update concept options
  observeEvent(input$concept_select_p2, {
    if (!TAB2_INIT){
      # Do nothing if page 2 is not initiated
      return()
    }
    concept_groups <- get_concept_by_group(input$concept_select_p2)
    # Delete NA column when visualizing within a state
    if (CURRENT_RENDERING_P2 != 0){
      concept_groups <- setdiff(
        concept_groups,
        "Proportion Population Married More Than Three or More Times (B12)")
    }
    CLUSTER_READY <<- FALSE
    CLUSTER_RESULT <<- NULL
    updateSelectInput(
      session, "check_concept_p2",
      choices = concept_groups,
      selected = concept_groups[1]
    )
    plot_elbow(session)
    render_map(session, map_id = "map2")
  })
  
  # Select concept (p2), plot bar-chart by new values
  observeEvent(input$check_concept_p2, {
    render_hist_p2(session)
  })
  
  # Click on a state polygon
  observeEvent(input$map1_shape_click, {
    click <- input$map1_shape_click
    if (!is.null(click)) {
      # Change location focus if click on state.
      # Do nothing if click on county
      if (click$id < 100){
        updateSelectInput(
          session, "location_select",
          selected = id2state(click$id)
        )
      }
    }
  })
  
  # Click on a state polygon (p2)
  observeEvent(input$map2_shape_click, {
    click <- input$map2_shape_click
    if (!is.null(click)) {
      # Change focues if click on state.
      # Do nothing if click on county
      if (click$id < 100){
        updateSelectInput(
          session, "location_select_p2",
          selected = id2state(click$id)
        )
      }
    }
  })
  
  # Click on blank area, switch to U.S. perspective
  observeEvent(input$map1_click, {
    # Triggered only when not rendering U.S.
    if (CURRENT_RENDERING!=0){
      
      # Update location select
      updateSelectInput(
        session, "location_select",
        selected = "U.S."
      )
      DATA_ON_DISPLAY <<- states
    }
  })
  
  # Click on blank area, switch to U.S. perspective (p2)
  observeEvent(input$map2_click, {
    # Triggered only when not rendering U.S.
    if (CURRENT_RENDERING_P2!=0){
      updateSelectInput(
        session, "location_select_p2",
        selected = "U.S."
      )
      DATA_ON_DISPLAY <<- states
      
    }
  })
  
  # Generate elbow plot
  observeEvent(input$generate_elbow, {
    plot_elbow(session)
  })
  
  # Run k-means
  observeEvent(input$kmeans, {
    set.seed(666)
    loc <- session$input$location_select_p2
    data4clus <- generate_data_p2(session) %>% na.omit()
    k <- as.numeric(session$input$k_means_size)
    k <- min(k, nrow(data4clus)-1)
    
    if ((k >= 1) && (k < nrow(data4clus))){
      clus.res <- kmeans(scale(data4clus[-1]), k, nstart = 50, iter.max = 50)
      Cluster <- clus.res$cluster
      
      # Update to global variables to be used by other functions
      CLUSTER_READY <<- TRUE
      CLUSTER_RESULT <<- data.frame(
        GEOID=data4clus$GEOID,
        cluster=as.factor(Cluster))
      render_map(session, map_id = "map2")
      render_hist_p2(session)
    }
    
  })
  
  # Monitor wheter tab2 is initiated
  observeEvent(input$tabs, {
    current_tab <- input$tabs
    if (current_tab == "Unsupervised Learning"){
      if (!TAB2_INIT && (CURRENT_RENDERING != - 1)) {
        render_map(session, map_id = "map2")
        
        TAB2_INIT <<- TRUE
        plot_elbow(session)
      }
    }
  })
  
}
