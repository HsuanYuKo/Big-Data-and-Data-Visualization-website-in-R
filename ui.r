library(shiny)
library(plotly)
library(leaflet)

shinyUI(fluidPage(  
  titlePanel("地區性別統計表-嚴重特殊傳染性肺炎"),  
  sidebarLayout(
    sidebarPanel(
      selectInput("dist", "Choose Location:", 
                  choices =c("all",unique(Input[,3]))),
      selectInput("date", "Choose Date:", 
                  choices =c("all",unique(Input[,2]))),
      
      radioButtons("Choices", label = "圖表",
                   choices = list("Pie Charts (各地區個案比例)" = 1,
                                  "Bar Charts (地區總數分析)" = 2,
                                  "Line Plots (時間和人數折線圖)" = 3
                    )),
      radioButtons("Type", label = "列表",
                   choices = list("個案列表" = 1,
                                  "縣市總數列表" = 2
                   )),
      
      numericInput("Case", "Number of Case to view:", 10),
      submitButton("Submit"),
      br(),br(),
      downloadButton("download", "資料下載")
    ),    
    mainPanel(
      #textOutput("caption"),
      #br(),br(),
      #plotlyOutput("plotly"),
      #tableOutput("table"),
      #plotOutput("distPlot")
      tabsetPanel(type = "tabs",
                  tabPanel("列表圖表分析",textOutput("caption"),br(),br(),plotlyOutput("plotly"), tableOutput("table")),
                  tabPanel("地圖展示",leafletOutput("map"))
      )
    )
  )
))
