library(shiny)
source("helpers.R")

# Define UI for application that plots random distributions 
ui <- fluidPage(
  titlePanel("Toronto's Neighbourhoods"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create demographic maps with 
        information from the 2010 US Census."),
      
      selectInput("var_top", 
                  label = "Choose a variable to display",
                  choices = c("COVID Case Rate", "Low Income Rate", "Visible Minority Rate"),
                  selected = "COVID Case Rate"),
      
      selectInput("var_bottom", 
                  label = "Choose another variable to compare",
                  choices = c("COVID Case Rate", "Low Income Rate", "Visible Minority Rate"),
                  selected = "Low Income Rate")
  
    ),
    
    mainPanel(plotOutput("map_top"),
              plotOutput("map_bottom"))
  )
)
