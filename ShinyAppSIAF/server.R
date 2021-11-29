#Corer el shiny
source("global.R")

shinyServer(function(input, output,session) {
  colscale <- c(semantic_palette[["red"]],semantic_palette[["green"]],semantic_palette[["blue"]])
  
  # datasub <- reactive({
  #    DataGR[DataGR$G_Regional == input$region,]
  #}) 
  
  #Grafica de barras
  #Mejorar la gráfica:https://stackoverflow.com/questions/30018187/changing-tick-intervals-when-x-axis-values-are-dates/30020683
  #https://slcladal.github.io/motion.html
  #https://shiny.rstudio.com/gallery/nz-trade-dash.html
  
  output$boxplot1 <- renderPlot({
    ggplot(DataGR%>%
             filter(G_Regional%in%input$region),
           aes(x = as.factor(Year),y = Devengado,fill=input$region))+
      geom_bar(stat = "identity",position="dodge")+
      geom_text(aes(label = round(Devengado, 1)),
                position = position_dodge(0.5),
                vjust =-0.3 ,show.legend = FALSE)+
      labs(y= "",x= "",colour = "")+
      theme_bw() + 
      theme(panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank(),
            legend.title = element_blank(),
            legend.position = "top")
  })
  
  #Grafico de linea
  output$Lineplot1 <- renderPlotly({
    validate(need(input$region, "Debe seleccionar al menos una región"))
    ggplotly(ggplot(DataGR%>%
                      filter(G_Regional%in%input$region),
                    aes(x = Year,y =`Avance%`))+
               geom_line(aes(color=input$region,group=input$region))+
               geom_text(aes(label =`Avance%` ),
                         position = position_dodge(0.5),
                         vjust =-0.3 ,show.legend = FALSE)+
               labs(y= "",x= "",colour = "")+
               theme_bw() + 
               theme(panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(),
                     panel.border = element_blank(),
                     axis.text.y = element_blank(),
                     axis.ticks.y = element_blank(),
                     legend.title = element_blank(),
                     legend.position = "top")
    )
  })
  
  #Construimos la data reactiva
  DataDepa <- reactive({
    filter(DataGR, G_Regional%in%input$region)
  })
  
  #Mostrar la data
  #Ajustar columna:https://stackoverflow.com/questions/25205410/r-shiny-set-datatable-column-width
  
  #Data region
  output$DataRegion <- renderDataTable(DataDepa(),extensions = "Buttons", 
                                       options = list(dom = "Brtip",buttons = "excel"),
                                       server = FALSE)
  #Desacargar la data
  output$downloadData1 <- downloadHandler(
    filename = function() {
      paste("DataRegion", ".xlsx")},
    content = function(file) {
      write.xlsx(DataDepa(), file)})
  #Data general
  output$DataRegiones <- renderDataTable(DataGR)
  # Downloadable csv of selected dataset ----
  output$downloadData2 <- downloadHandler(
    filename = function() {
      paste("DataR", ".xlsx")},
    content = function(file) {
      write.xlsx(DataGR, file)})
})