library(shiny)
source("helpers.R")
library(maps)
library(mapproj)

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
   
  # Expression that generates a plot of the distribution. The expression
  # is wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically 
  #     re-executed when inputs change
  #  2) Its output type is a plot 
  #
  output$map_top <- renderPlot({
    data <- switch(input$var_top, 
                   "COVID Case Rate" = nbhoods_final$rate_per_100000,
                   "Low Income Rate" = nbhoods_final$low_income_pt_18_64,
                   "Visible Minority Rate" = nbhoods_final$visible_minority_rate)
    color <- switch(input$var_top, 
                   "COVID Case Rate" = "darkorange",
                   "Low Income Rate" = "darkgreen",
                   "Visible Minority Rate" = "royalblue1")
    title <-switch(input$var_top, 
                   "COVID Case Rate" = "COVID-19 cases per 100,000, by neighbourhood in Toronto, Canada",
                   "Low Income Rate" = "Percentage of 18 to 64 year olds living in a low income family (2015)",
                   "Visible Minority Rate" = "Percentage of visible minority population (2015)")
    legend <-switch(input$var_bottom, 
                    "COVID Case Rate" = "Cases per 100,000 people",
                    "Low Income Rate" = "%",
                    "Visible Minority Rate" = "%")
    present_map(column = data, color, title, legend)
  })
  
  output$map_bottom <- renderPlot({
    data <- switch(input$var_bottom, 
                   "COVID Case Rate" = nbhoods_final$rate_per_100000,
                   "Low Income Rate" = nbhoods_final$low_income_pt_18_64,
                   "Visible Minority Rate" = nbhoods_final$visible_minority_rate)
    color <- switch(input$var_bottom, 
                    "COVID Case Rate" = "darkorange",
                    "Low Income Rate" = "darkgreen",
                    "Visible Minority Rate" = "royalblue1")
    title <-switch(input$var_bottom, 
                   "COVID Case Rate" = "COVID-19 cases per 100,000, by neighbourhood in Toronto, Canada",
                   "Low Income Rate" = "Percentage of 18 to 64 year olds living in a low income family (2015)",
                   "Visible Minority Rate" = "Percentage of visible minority population (2015)")
    legend <-switch(input$var_bottom, 
                   "COVID Case Rate" = "Cases per 100,000 people",
                   "Low Income Rate" = "%",
                   "Visible Minority Rate" = "%")
    present_map(column = data, color, title, legend)
  })
  
})
