#
# Observatorio de Inversión Pública-SIAF-MEF
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(shinyWidgets) #numericRangeInput()
#library(shinydashboard)
library(semantic.dashboard)
library(plotly)
library(DT)
#library(lubridate)
library(tidyverse)


server <- shinyServer(function(input, output,session) {
    colscale <- c(semantic_palette[["red"]],semantic_palette[["green"]],semantic_palette[["blue"]])
   
   datasub <- reactive({
      # DataGR[DataGR$G_Regional == input$region,]
       DataGR %>% filter(G_Regional == input$region)
   })
    
#Hacemos la grafica
    output$boxplot1 <- renderPlot({
        df1 <- datasub()
        ggplot(DataGR[DataGR$G_Regional == input$region,],aes(x = Year,y = Devengado))+
            geom_bar(stat = "identity",fill="gray")+
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
        df1 <- datasub()
        ggplotly(ggplot(df1,aes(x = Year,y = Devengado))+
                     geom_point(aes(color=G_Regional,size=Devengado))
                 )
    })
    output$DataRegion <- renderDataTable(df1)
    # Downloadable csv of selected dataset ----
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("DataR", ".xlsx")},
        content = function(file) {
            write.xlsx(df1, file)})
    
})




