#Corer el shiny
source("global.R")

shinyServer(function(input, output,session) {
  
##---- Construimos la data reactiva: #----
  
  DataDepa <- reactive({
    DataGR%>%
    filter(G_Regional %in% input$region,
      between(Year,input$date_Range_input[1],
                     input$date_Range_input[2]))
           # Year >= input$date_Range_input[1],
           # Year <= input$date_Range_input[2])
    })
  
  #Grafica de barras
  #Mejorar la gráfica:https://stackoverflow.com/questions/30018187/changing-tick-intervals-when-x-axis-values-are-dates/30020683
  #https://slcladal.github.io/motion.html
  #https://shiny.rstudio.com/gallery/nz-trade-dash.html
  
  ##---- Valores de cajas ##----
  
  dash_metric_boxes <- reactive({
    dat <- DataDepa()
  #   dash_metric_input <- input$dash_metric

    dat <- dat %>%
      summarise(meanPIA = mean(PIA),
                meanPIM = mean(PIM),
                meanDevengado = mean(Devengado),
                meanAvance = mean(`Avance%`)
               # n=n()
                )
  #   
  #   if (dash_metric_input == "severity") {
  #     dat <- dat %>%
  #       mutate(paid = paid / n,
  #              case = case / n,
  #              reported = reported / n)
  #   }
  #   
  #   titles <- switch(
  #     dash_metric_input,
  #     "total" = c("Paid Loss & ALAE", "Case Reserve", "Reported Loss & ALAE"),
  #     "severity" = c("Paid Severity", "Case Reserve Severity", "Reported Severity"),
  #     "claims" = c("Closed Claim Counts", "Open Claim Counts", "Reported Claim Counts")
  #   )
  #   
  #   list(
  #     "dat" = dat,
  #     "titles" = titles
  #   )
  })
  
  output$PIA_box <- renderValueBox({
      Valores <- dash_metric_boxes()
    valueBox2(
      format(round(as.numeric(Valores$meanPIA), 0), big.mark = ","),
      # subtitle = out$titles[1],
      subtitle = "Promedio de PIA",
      icon = icon("money"),
      backgroundColor = "#434348"
    )
  })
  
  output$PIM_box <- renderValueBox({
    Valores <- dash_metric_boxes()
    valueBox2(
      format(round(as.numeric(Valores$meanPIM, 0)), big.mark = ","),
      # subtitle = out$titles[2],
      subtitle = "Promedio de PIM",
      icon = icon("university"),
      backgroundColor = "#7cb5ec"
    )
  })
  
  output$Deven_box <- renderValueBox({
    Valores <- dash_metric_boxes()
    valueBox2(
      format(round(as.numeric(Valores$meanDevengado), 0), big.mark = ","),
      # subtitle = out$titles[3],
      subtitle = "Promedio de devengado",
      icon = icon("clipboard"),
      backgroundColor = "#f7a35c"
    )
  })
  
  output$Avan_box <- renderValueBox({
    Valores <- dash_metric_boxes()
    valueBox2(
      format(round(as.numeric(Valores$meanAvance, 0)), big.mark = ","),
      # subtitle = out$titles[3],
      subtitle = "Promedio de ejecución",
      icon = icon("clipboard"),
      backgroundColor = "#f7a35c"
    )
  })
  
  ##---- Gráfico de barras #----
  
  output$boxplot1 <- renderPlot({
    
    ggplot(DataDepa(),aes(x = as.factor(year(Year)),y = Devengado,fill=G_Regional))+
      geom_bar(stat = "identity",position="dodge")+
      geom_text(aes(label = round(Devengado, 1)),
                position = position_dodge(1),
                hjust =-0.1,angle=90,show.legend = FALSE)+ #,vjust -=0.5,hjust =-0.5
      labs(y= "",x= "",colour = "")+
      theme_bw() + 
      theme(panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank(),
            legend.title = element_blank(),
            legend.position = "top")+
      scale_y_continuous(limits = c(0,max(DataDepa()$Devengado)+1000))
  })
  
##---- Gráfico de linea #----
  
  output$Lineplot1 <- renderPlotly({
    validate(need(input$region, "Debe seleccionar al menos una región"))
    ggplotly(ggplot(DataDepa(),
                    aes(x = as.factor(year(Year)),y =`Avance%`))+
               geom_line(aes(color=G_Regional,group=G_Regional))+
               geom_text(aes(label =`Avance%` ),
                         #position = position_dodge(0.5),
                         vjust =-0.5 ,show.legend = FALSE)+
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
  
##---- Mostrar la data #----
  #Ajustar columna:https://stackoverflow.com/questions/25205410/r-shiny-set-datatable-column-width
  
  ##Data region
  output$DataRegion <- DT::renderDT({
    datatable(
      DataDepa(), #Conjunto de datos
      rownames = FALSE,
      #container = col_headers,
      class = "stripe cell-border",
      extensions = "Buttons",
      options = list(
        dom = 'Brtip',
        scrollX = TRUE,
        buttons = list( 
          list(
            extend = 'collection',
            buttons = c('csv', 'excel'), #'pdf'
            text = 'Descargar'))
        )
      )
  }, server = FALSE)
  
  # output$DataRegion <- renderDataTable(
  #   DataDepa(),extensions = "Buttons",
  #   options = list(dom = "Brtip",buttons = "excel"),
  #   server = FALSE)
  ##Data general
  #output$DataRegiones <- renderDataTable(DataGR)
  output$DataRegiones <- DT::renderDT({
    
    datatable(
      DataGR,
      rownames = FALSE,
      class = "cell-border stripe compact",
      #colnames = show_names(names(DataGR)),
      extensions = "Buttons",
      #filter = 'top',
      options = list(
        dom = 'Bfrtip',
        scrollX = TRUE,
        buttons = list(
          'colvis', 
          list(
            extend = 'collection',
            buttons = c('csv', 'excel'), #'pdf'
            text = 'Descargar') #Download
        ),
        pageLength = 10
      ))
    # %>%
    #   formatCurrency(
    #     columns = 7:9,
    #     currency = "",
    #     digits = 0
    #   )
  }, server = FALSE)
  # Downloadable csv of selected dataset ----
  # output$downloadData2 <- downloadHandler(
  #   filename = function() {
  #     paste("DataR", ".xlsx")},
  #   content = function(file) {
  #     write.xlsx(DataGR, file)})
})