# Rely on the 'WorldPhones' dataset in the datasets
# package (which generally comes preloaded).
library(datasets)

# Define a server for the Shiny app
function(input, output) {
  
  # Fill in the spot we created for a plot
  
  output$phonePlot <- renderPlot({
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
}

