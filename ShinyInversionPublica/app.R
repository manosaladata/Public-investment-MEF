library(shiny)
library(shinydashboard)
#DataGR[,11] <- sapply(DataGR[,11],function(x) as.numeric(x))
#sapply(DataGR, class)
#table(DataGR$G_Regional)
#?icon()

# Define UI for application 
#skin = "blue", Ã³ theme = "slate",

ui <- dashboardPage(
    dashboardHeader(title = "Inversión pública",color = "blue",inverted = TRUE),
    dashboardSidebar(side = "left", size = "thin", color = "teal",
        sidebarMenu(
            menuItem("Dashboard", tabName = "dashboard",icon = icon("dashboard")),
            menuItem("Data", tabName = "data",icon = icon("table")))),
    dashboardBody(
        tabItems(
            #selected = 1,
            tabItem(
                tabName = "dashboard",
                fluidRow(
                    box(width = 4,color = "sky blue",ribbon = TRUE,
                        numericRangeInput("numeric_Range_input","seleccione rango de año:",
                                          value = c(2010:2020), 
                                          separator = "a")),
                    box(width = 3,color = "sky blue",ribbon = TRUE,
                    selectInput("region","Región:",
                                choices = c(unique(DataGR$G_Regional)),
                                selected = unique(DataGR[,"G_Regional"])[1])),
                    box(width = 3,color = "sky blue",ribbon = TRUE,
                        submitButton("Ejecutar"))),
                fluidRow(
                    box(width = 8,
                            title = "Graph 1",
                            color = "green",ribbon = TRUE,title_side = "Top right",
                            column(width = 8,
                                   plotOutput("boxplot1"))),
                    box(width = 8,
                            title = "Graph 2",
                            color = "red",ribbon = TRUE,title_side = "Top right",
                            column(width = 8,
                                   plotlyOutput("dotplot1"))))),
            tabItem(
                tabName = "data",
                fluidRow(
                    dataTableOutput("DataRegion"),
                    downloadButton("downloadData", "Download"))))
        )
)

#sapply(DataGR, class)
# 
server <- shinyServer(function(input, output,session) {
    colscale <- c(semantic_palette[["red"]],semantic_palette[["green"]],semantic_palette[["blue"]])
   
   # datasub <- reactive({
    #    DataGR[DataGR$G_Regional == input$region,]
    #}) 
    
#Hacemos la grafica
    output$boxplot1 <- renderPlot({
        ggplot(DataGR[DataGR$G_Regional == input$region,],aes(x = Year,y = Devengado))+
            geom_bar(stat = "identity",fill="sky blue")+
            geom_text(aes(label = round(Devengado, 1)),
                      position = position_dodge(0.5),
                      vjust =-0.3 ,show.legend = FALSE)+
            labs(y= "",colour = "")+
            theme_bw() + 
            theme(panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.border = element_blank(),
                  axis.text.y = element_blank(),
                  axis.ticks.y = element_blank())
    })
    output$dotplot1 <- renderPlotly({
        ggplotly(ggplot(DataGR[DataGR$G_Regional == input$region,],aes(x = Year,y = Devengado))+
                     geom_point(aes(color=G_Regional,size=Devengado))
                 )
    })
    output$DataRegion <- renderDataTable(DataGR)
    # Downloadable csv of selected dataset ----
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("DataR", ".xlsx")},
        content = function(file) {
            write.xlsx(DataGR, file)})
})


# Run the application 
shinyApp(ui = ui, server = server)


