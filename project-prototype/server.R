
library(shiny)
library(ggplot2)
library(scales)
library(wordcloud)

######LOAD DATA######
loadData <- function() {
  
}


#### PLOTTING FUNCTIONS ####
getBar <- function(localFrame){
  
  Seat_df <- localFrame
  
}

getCloud <- function(localFrame){
  
  Seat_df <- localFrame
  
}

getLine <- function(localFrame){
  
  Seat_df <- localFrame
  
}

getNetwork <- function(localFrame){
  
  Seat_df <- localFrame
  
}


#### GLOBAL OBJECTS ####
globalData <- loadData()


#CREATE SERVER

shinyServer(function(input, output) {
  
  localFrame <- globalData
  
  output$Bar <- renderPlot({
    BarPlot <- getBar(
      localFrame
      )
    print(BarPlot)
  })
  
  output$Cloud <- renderPlot({
    CloudPlot <- getCloud(
      localFrame
    )
    print(BarPlot)
  })
  
  output$Line <- renderPlot({
    LinePlot <- getLine(
      localFrame
    )
    print(LinePlot)
  })
  
  output$Network <- renderPlot({
    NetworkPlot <- getNetwork(
      localFrame
    )
    print(NetworkPlot)
  })
  
})










