#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking "Run App" above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinyjs)
library(leaflet)
library(plotly) 

source("concepts.R")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("American Community Political Preference Analysis"),
  tabsetPanel(
    id="tabs",
    tabPanel("Variables",
      sidebarLayout(
        sidebarPanel(
          
          selectInput(
            inputId = "location_select",
            label = "Region:",
            choices = c(
              "U.S.", "Alabama", "Alaska", "Arizona", "Arkansas", "California", 
              "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
              "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", 
              "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", 
              "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", 
              "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico",
              "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma",
              "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
              "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia",
              "Washington", "West Virginia", "Wisconsin", "Wyoming",
              "District of Columbia"),
            selected = "U.S."
          ),
          
          selectInput(
            inputId = "concept_select",
            label = "Concept:",
            choices = NULL
          ),
          tags$div(
            style = "margin-top: 20px;",
            tags$h4("Concept Description", style = "font-weight: bold;"),
          ),
          textOutput("hint_p1"),
          htmlOutput("info_p1"),
          tags$div(
            style = "margin-top: 20px;",
            tags$h4("Summary", style = "font-weight: bold;"),
          ),
          tableOutput("summary_table"),
          
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
          leafletOutput("map1", height = "40vh"),
          plotlyOutput("plot_hist")
        )
      )
    ),
    tabPanel(
      "Unsupervised Learning", 
      sidebarLayout(
      sidebarPanel(
        selectInput(
          inputId = "location_select_p2",
          label = "Region:",
          choices = c(
            "U.S.", "Alabama", "Alaska", "Arizona", "Arkansas", "California",
            "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii",
            "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
            "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
            "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
            "New Hampshire", "New Jersey", "New Mexico", "New York",
            "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
            "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
            "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
            "West Virginia", "Wisconsin", "Wyoming", "District of Columbia"),
          selected = "U.S."
          ),
        selectInput(
          inputId = "concept_select_p2",
          label = "Cluster By Concepts:",
          choices = NULL
          ),
        
        selectInput(
          inputId = "k_means_size",
          label = "Select Cluster Size:",
          choices = NULL
          ),
        actionButton(
          "generate_elbow",
          "Generate Elbow Plot",
          style = "width: 100%;"),
        actionButton(
          "kmeans",
          "Run K-means Clustering",
          style = "width: 100%; background-color: black; color: white; margin-bottom: 5%;"),
        selectInput(
          inputId = "check_concept_p2",
          label = "Check Concept",
          choices = NULL
          ),
        htmlOutput("info_p2"),
        tags$div(
          style = "margin-top: 20px;",
          tags$h4("Conclusion", style = "font-weight: bold;"),
          tags$p(HTML("From the elbow plot for all the variables, 
                      we found that there is an obvious bend at k = 2. 
                      Thus, we conduct a k-means clustering with k = 2 to these variables. 
                      Based on the clustering results, the two clusters closely align with 
                      the 2024 U.S. elections results. The red and green clusters indicate 
                      the states that tend to support Republicans and Democrats, respectively. 
                      Only the results of Pennsylvania, Florida, and New Mexico differ from 
                      the actual 2024 U.S. elections presidential results. So, we can conclude that the 
                      variables are well chosen to refrain the political 
                      preferences in the U.S.. It can be found from the bar charts of variables’ 
                      distributions that the proportion of the voting-age population (B01), 
                      the proportion of the population married more than three or more times (B12), 
                      the proportion of current residence (over 1 yr) as a non-U.S. 
                      citizen who moved from abroad (B07), and proportion of 
                      non-institutionalized civilian with health insurance (B27) 
                      highly reflect the political preferences in each state, 
                      and median household income level (B19), the proportion of 
                      employed civilians with blue-collar occupations (C24), 
                      proportion of the voting-age population with a bachelor's 
                      degree or higher (B29), and proportion of unmarried women 
                      under 20 who gave birth in the past 12 months (B13) are 
                      consistent with the clustering results. Also, if we choose 
                      k = 3 to cluster, the results will condense only Washington 
                      D.C. to the additional cluster, with only Wisconsin changing 
                      its cluster to the other from the results of k = 2 clustering."),
                 style = "margin-top: 10px;")
        ),
        
      ),
      mainPanel(
        leafletOutput("map2", height = "40vh"),
        # Elbow plot for k-means
        plotlyOutput("plot_elbow", height = "40vh")
        )
      )
      ),
    tabPanel(
      "Dictionary",
      htmlOutput("p3_html_content")),
    tabPanel(
      "Reference",
      htmlOutput("p4_html_content")),
    ),
  
  
))
