library(shiny)
library(tidyverse)
library(shinythemes)

source("~/Documents/Github/twg/card_pack/cards.R")

# Define UI for dataset viewer app ----
ui <- fluidPage(
  
  theme = shinytheme("slate"),
  # App title ----
  titlePanel("Simulation of Opening Card Packs"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a dataset ----
      selectInput("packs", "Choose a pack:",
                  choices = c("bronze")),
      
      # Input: Specify the number of observations to view ----
      numericInput("n_packs", "Number of packs to open:", 1),
      
      # Include clarifying text ----
      helpText("Note: drop rates are based on the assumption that", 
               "each card is equally likely.",
               "I plan on adding the other packs eventually."),
      
      # Input: actionButton() to defer the rendering of output ----
      # until the user explicitly clicks the button (rather than
      # doing it immediately when inputs change). This is useful if
      # the computations required to render output are inordinately
      # time-consuming.
      actionButton("update", "Open Pack")
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Header + summary of distribution ----
      #h4("Summary"),
      #verbatimTextOutput("summary"),
      
      # Output: Header + table of distribution ----
      #h4("Observations"),
      tableOutput("view")
    )
    
  )
)

# Define server logic to summarize and view selected packs ----
server <- function(input, output) {
  
  # Return the requested packs ----
  # Note that we use eventReactive() here, which depends on
  # input$update (the action button), so that the output is only
  # updated when the user clicks the button
  datasetInput <- eventReactive(input$update, {
    switch(input$packs,
           "bronze" = bronze)
  }, ignoreNULL = FALSE)
  
  # Generate a summary of the dataset ----
  #output$summary <- renderPrint({
  #  packs <- datasetInput()
  #  summary(packs)
  #})
  
  # Show the first "n" observations ----
  # The use of isolate() is necessary because we don't want the table
  # to update whenever input$obs changes (only when the user clicks
  # the action button)
  output$view <- renderTable({
    slice_sample(datasetInput(), n = isolate(input$n_packs * 3), replace = TRUE)
  }, digits = 0, width = "500px")
  
}

# Create Shiny app ----
shinyApp(ui, server)

#runGitHub("becausejustyn/twg/card_pack")

#https://github.com/becausejustyn/twg/tree/main/card_pack