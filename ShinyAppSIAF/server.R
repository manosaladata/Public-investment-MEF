#
source("global.R")

shinyServer(function(input, output,session) {
    colscale <- c(semantic_palette[["red"]],semantic_palette[["green"]],semantic_palette[["blue"]])
    
    # datasub <- reactive({
    #    DataGR[DataGR$G_Regional == input$region,]
    #}) 
    
    #Grafica de barras
    
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
    
    #Grafico de linea
    output$Lineplot1 <- renderPlotly({
        ggplotly(ggplot(DataGR[DataGR$G_Regional == input$region,],
                        aes(x = Year,y =`Avance%`))+
                     geom_line()
        )
    })

    #Construimos la data reactiva
    DataDepa <- reactive({
        filter(DataGR, G_Regional == input$region)
    })
    
    #Mostrar la data
    #Data region
    output$DataRegion <- renderDataTable(DataDepa())
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
