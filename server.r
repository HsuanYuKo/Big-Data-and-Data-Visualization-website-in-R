#p19
library(shiny)
library(dplyr)
library(datasets)
library(ggplot2)
library(leaflet)
library(plotly)

shinyServer(function(input, output) {
  output$caption <- renderText({
    paste(input$dist,"/",input$date,"///","肥皂勤洗手,外出戴口罩,如有接觸病例且有相關症狀請撥打1922","///","(資料中的「
空值」係指境外移入)")
  })
  
  datasetInput <- reactive({
    if(input$date != "all"){
      if(input$dist != "all")
        Data = Input %>% filter(個案研判日 == input$date)%>% filter(縣市 == input$dist)
      else
      Data = Input %>% filter(個案研判日 == input$date)
    }
    else if(input$dist != "all"){
        Data = Input %>% filter(縣市 == input$dist)
    }
    else
      Data = Input
    Data
  })
  
  output$plotly <- renderPlotly({
    #x = datasetInput()
    if(input$Choices == 1) {
      p = plot_ly(data = datasetInput(), labels = ~縣市, values = ~確定病例數,type = "pie") %>%
        layout(xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
               yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    }
    else if(input$Choices == 2){
      #p = plot_ly( data = datasetInput(),x = ~縣市,y = ~確定病例數,name = "cov19",type = "bar")
      Data = datasetInput()
      Total = unique(Data[,3])
      Total = data.frame(縣市 = Total,男性 = c(0),女性 = c(0))
      for (i in 1:nrow(Total)) {
        county = Data %>% filter(縣市 == Total[i,1])
        boy = county %>% filter(性別 == "男")
        Total[i,2] = sum(boy[,7])
        girl = county %>% filter(性別 == "女")
        Total[i,3] = sum(girl[,7])
      }
      p = plot_ly( x = Total[,1], y = Total[,2], name = "男性", type = "bar")
      p = p %>% add_trace( y = Total[,3], name = "女性") %>% layout(yaxis = list(title = 'Count'), barmode = 'group')
      
    }
    else if(input$Choices == 3)
      p = plot_ly( data = datasetInput(), x = ~個案研判日, y = ~確定病例數, name = 'cov_19', type = 'scatter', mode = 'lines')
    p
  })
  
  output$table <- renderTable({
    Data = datasetInput()
    if(input$Type == 1)
      head(datasetInput(), n = input$Case)
    else if(input$Type == 2) {
      Total = unique(Data[,3])
      Total = data.frame(縣市 = Total,男性 = c(0),女性 = c(0))
      for (i in 1:nrow(Total)) {
        county = Data %>% filter(縣市 == Total[i,1])
        boy = county %>% filter(性別 == "男")
        Total[i,2] = sum(boy[,7])
        girl = county %>% filter(性別 == "女")
        Total[i,3] = sum(girl[,7])
      }
      head(Total, n = input$Case)
    }
  })
  
  output$map <- renderLeaflet({
    m = leaflet() %>% addTiles() %>% setView(lng=121.4580,lat=25.01186,zoom=10)
    Data = datasetInput()
    Total = unique(Data[,3])
    Total = data.frame("縣市" = Total,People = c(0))
    for (i in 1:nrow(Total)) {
      county = Data %>% filter(縣市 == Total[i,1])
      Total[i,2] = sum(county[,7])
    }
    Total = merge(x = Total,y = Site, by="縣市",all=FALSE)
    for(i in 1:nrow(Total)) {
      m = addMarkers(m, lng=Total[i,3], lat=Total[i,4],
                     popup=paste(Total[i,1],"人數:",Total[i,2]))
      m = m%>%addCircles(lng =Total[i,3],lat = Total[i,4],
                     radius = Total[i,2]*30,
                     fill=TRUE)
    }
    m
  })
  
  output$download <- downloadHandler(
    filename = "cov_19.csv",
    content = function(file) {
      write.csv(datasetInput(), file, row.names = TRUE,fileEncoding = "UTF-8")
    }
  )
  
})
