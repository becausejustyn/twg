library(shiny)
library(tidyverse)

source("~/Documents/Github/twg/card_pack/cards.R")

# Define UI for dataset viewer app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Title"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a dataset ----
      selectInput("packs", "Choose a dataset:",
                  choices = c("bronze", "silver", "gold")),
      
      # Input: Specify the number of observations to view ----
      numericInput("n_packs", "Number of observations to view:", 1),
      
      # Include clarifying text ----
      helpText("Note: while the data view will show only the specified",
               "number of observations, the summary will still be based",
               "on the full packs"),
      
      # Input: actionButton() to defer the rendering of output ----
      # until the user explicitly clicks the button (rather than
      # doing it immediately when inputs change). This is useful if
      # the computations required to render output are inordinately
      # time-consuming.
      actionButton("update", "Update View")
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Header + summary of distribution ----
      h4("Summary"),
      verbatimTextOutput("summary"),
      
      # Output: Header + table of distribution ----
      h4("Observations"),
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
           "bronze" = bronze,
           "silver" = silver,
           "gold" = gold)
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