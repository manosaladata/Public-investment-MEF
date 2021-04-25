library(shiny)

# Creating a fake data frame
categories <- c("A", "B", "c")
values <- c(12, 15, 20)
data <- merge(categories, values)
sapply(data, class)
# Define UI for application 
ui <- shinyUI(fluidPage(
  
  # Title panel
  titlePanel(title = h1("Title", align = "center")),
  sidebarLayout(
    
    # Sidebar panel 
    sidebarPanel(
      
      # Options
      selectInput(inputId = "xcol", label = "Select", choices = levels(data$x)),
      br(),
      #Colours histogram
      radioButtons(inputId = "colour", label = strong("Select the colour of 
                                                      histogram"), choices = c("Yellow", "Red"), selected = "Yellow"),
      br(),
      #Bins for histogram
      sliderInput(inputId = "bins", label = "Select the number of Bins for the 
                  histogram", min=5, max = 25, value = 15),
      br(),
      #Density curve
      checkboxInput(inputId = "density", label = strong("Show Density Curve"), 
                    value = FALSE),
      
      # Display this only if the density is shown
      conditionalPanel(condition = "input.density ==true",
                       sliderInput(inputId = "bw_adjust",
                                   label = "Bandwidth adjustment:",
                                   min = 0.2, max = 3, value = 1, step = 0.2))
      
      
    ),
    
    # Main Panel
    mainPanel(
      #plot histogram
      plotOutput("plot"),
      
      # Output: Verbatim text for data summary
      verbatimTextOutput("summary"))
    
  )))

# Define server logic 
server <- shinyServer(function(input, output) {
  data2 <- reactive({data[as.character(data$x)==input$xcol, "y"]})
  
  output$plot <-renderPlot({
    hist(data2(), breaks = seq(0, max(c(1, data2()), na.rm=TRUE), l= input$bins+1), col = input$colour, 
         probability = TRUE, xlab = "Values", main = "")
    abline(v = mean(data2()), col = "red", lty = 2)
    title(main = input$xcol)
    
    if (input$density) {
      dens <- density(data2(), adjust = input$bw_adjust, na.rm = TRUE)
      lines(dens, col = "blue", lwd = 1)
    }
    if(input$colour=="Red"){
      abline(v=20)}else{abline(v=15)}
    # Generate the summary
    output$summary <- renderPrint({
      #xcol <- xcolInput()
      summary(data2())
    })
  })
})

# Run the application 
shinyApp(ui = ui, server = server)

