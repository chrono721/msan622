
library(RColorBrewer)
library(ggplot2)
library(shiny)
library(scales)
library(datasets)
library(GGally)

######LOAD DATA######
loadData <- function() {
  data(state)
  df <- data.frame(state.x77,
                   State = state.name,
                   Abbrev = state.abb,
                   Region = state.region,
                   Division = state.division)
  df$Area <- df$Area/1000
  df$Illiteracy <-  df$Illiteracy/100
  df$Murder <-  df$Murder/100
  df$HS.Grad <-  df$HS.Grad/100
  names(df) <-c("Population", "Income", "Illiteracy", "Life Expectancy","Murder Rate","HS Grad Rate","Frost",    
                "Area","State", "Abbrev","Region","Division" )
  return(df)
}

loadLimits <- function(localFrame){
  Limits <- data.frame(Minimum = apply(localFrame[,1:8], 2, min))
  Limits$Labels <- c(
    "Population (July 1, 1975)",
    "Income per capita (1974)",
    "Illiteracy Rate (1970)",
    "Life Expectancy in Years (1969-71)",
    "Murder Rate per 100,000 (1976)",
    "Percent of High-School Graduates (1970)",
    "Mean Days of Temperature below Freezing (1931-1960)",
    "Area in 1000's of Square Miles")
  Limits$Minimum <- c(0,3000,0,65,0.01,0.35,0,0)
  Limits$Maximum <- c(25000,6500,0.03,75,0.16,0.70,200,600)
  Limits$Breaks <- c(2500,1000,0.0025,2,0.02,0.05,20,50)
  Limits$Breaks2 <- c(7500,2000,0.005,2,0.03,0.1,50,100)
  return(Limits)
}

#### PLOTTING FUNCTIONS ####
getBubbleMap <- function(localFrame,localLimits, pointShape, dotalpha, dotsize, groupLocation, grouping,
                         intensityvar, xplotvar, yplotvar, colorScheme){
  #SUBSET BY LOCATION
  location_truth <- as.numeric(groupLocation)
  division_names <- c("New England","Middle Atlantic",
                      "East North Central","West North Central", 
                      "South Atlantic","East South Central","West South Central",
                      "Mountain","Pacific")
  if (sum(location_truth) > 0){df <- subset(localFrame, Division %in% division_names[location_truth])}
  else{df <- localFrame}
  
  if (pointShape == "Circle"){shape <- 20}
  else if (pointShape == "Triangle"){shape <- 17}
  else if (pointShape == "Diamond"){shape <- 18}
  else if (pointShape == "Square"){shape <- 15}
  else {shape <- 20}
  
  # Plot Points based on sliders
  if (dotalpha > 1){dotalpha <- 1}
  if (dotalpha < 0){dotalpha <- 0}

  #SORT BY CHOICE OF PLOT SO BIG BUBBLES ARE UNDER SMALLER ONES
  df <- df[with(df, order(-df[,intensityvar])), ]
  if(grouping != "None"){
    df <- data.frame(X=df[,xplotvar], Y=df[,yplotvar], size = df[,intensityvar], color = df[,grouping])
  }
  else{
    df <- data.frame(X=df[,xplotvar], Y=df[,yplotvar], size = df[,intensityvar], color = rep(1, length(df[,1])))
  }

  plt <- ggplot(df, aes(x=X, y=Y, size = size, color = color))
  plt <- plt + geom_point(shape = shape, alpha = dotalpha)
  plt <- plt + scale_size_area(max_size = dotsize)
  plt <- plt + theme(panel.border = element_rect(fill=NA, color = "grey"))
  
  if (colorScheme != "None" && colorScheme != "Default" && grouping != "None") {plt <- plt + scale_colour_brewer(palette=colorScheme, limits = levels(localFrame[,grouping]))}
  else if (colorScheme == "Default" && grouping != "None") {plt <- plt + scale_colour_brewer(limits = levels(localFrame[,grouping]))}

  if (xplotvar %in% c("Illiteracy", "HS.Grad", "Murder")){
    plt <- plt + scale_x_continuous(breaks = seq(localLimits[xplotvar,"Minimum"],localLimits[xplotvar,"Maximum"],localLimits[xplotvar,"Breaks"]),labels = percent, limits = c(localLimits[xplotvar,"Minimum"], localLimits[xplotvar,"Maximum"]))}
  else{plt <- plt + scale_x_continuous(breaks = seq(localLimits[xplotvar,"Minimum"],localLimits[xplotvar,"Maximum"],localLimits[xplotvar,"Breaks"]),limits = c(localLimits[xplotvar,"Minimum"], localLimits[xplotvar,"Maximum"]))}
  
  if (yplotvar %in% c("Illiteracy", "HS.Grad", "Murder")){
    plt <- plt + scale_y_continuous(breaks = seq(localLimits[yplotvar,"Minimum"],localLimits[yplotvar,"Maximum"],localLimits[yplotvar,"Breaks"]),labels = percent,limits = c(localLimits[yplotvar,"Minimum"], localLimits[yplotvar,"Maximum"]))
  }
  else{plt <- plt + scale_y_continuous(breaks = seq(localLimits[yplotvar,"Minimum"],localLimits[yplotvar,"Maximum"],localLimits[yplotvar,"Breaks"]),limits = c(localLimits[yplotvar,"Minimum"], localLimits[yplotvar,"Maximum"]))}
  
  plt <- plt + xlab(localLimits[xplotvar,"Labels"])
  plt <- plt + ylab(localLimits[yplotvar,"Labels"])
  plt <- plt + guides(colour = guide_legend(grouping), size = guide_legend(intensityvar))
  return(plt)
}

getScatterPlotMatrix <- function(localFrame,localLimits, pointShape, dotalpha, dotsize, groupLocation, grouping,
                                 xplotvar, yplotvar, colorScheme){
  
  location_truth <- as.numeric(groupLocation)
  division_names <- c("New England","Middle Atlantic",
                      "East North Central","West North Central", 
                      "South Atlantic","East South Central","West South Central",
                      "Mountain","Pacific")
  if (sum(location_truth) > 0){
    df <- subset(localFrame, Division %in% division_names[location_truth])
  }
  else{df <- localFrame}
  
  #Grouping
  if(grouping == "Region"){
    df <- data.frame(X=df[,xplotvar], Y=df[,yplotvar], color = df[,"Division"], location = df[,"Region"])
  }
  else if(grouping == "Division"){
    df <- data.frame(X=df[,xplotvar], Y=df[,yplotvar], color = df[,"Division"], location = df[,"Division"])
  }
  else{
    df <- data.frame(X=df[,xplotvar], Y=df[,yplotvar], color = df[,"Division"], location = rep("All", length(df[,xplotvar])))
  }
  
  #Choose Which
  plot_scatter <- ggplot(df, aes(group = color, colour = color))
  plot_scatter <- plot_scatter + geom_point(aes(x=X, y=Y))
  
  if (xplotvar %in% c("Illiteracy", "HS.Grad", "Murder")){
    plot_scatter <- plot_scatter + scale_x_continuous(breaks = seq(localLimits[xplotvar,"Minimum"],localLimits[xplotvar,"Maximum"],localLimits[xplotvar,"Breaks2"]),labels = percent, limits = c(localLimits[xplotvar,"Minimum"], localLimits[xplotvar,"Maximum"]))}
  else{plot_scatter <- plot_scatter + scale_x_continuous(breaks = seq(localLimits[xplotvar,"Minimum"],localLimits[xplotvar,"Maximum"],localLimits[xplotvar,"Breaks2"]),limits = c(localLimits[xplotvar,"Minimum"], localLimits[xplotvar,"Maximum"]))}
  
  if (yplotvar %in% c("Illiteracy", "HS.Grad", "Murder")){
    plot_scatter <- plot_scatter + scale_y_continuous(breaks = seq(localLimits[yplotvar,"Minimum"],localLimits[yplotvar,"Maximum"],localLimits[yplotvar,"Breaks2"]),labels = percent,limits = c(localLimits[yplotvar,"Minimum"], localLimits[yplotvar,"Maximum"]))
  }
  else{plot_scatter <- plot_scatter + scale_y_continuous(breaks = seq(localLimits[yplotvar,"Minimum"],localLimits[yplotvar,"Maximum"],localLimits[yplotvar,"Breaks2"]),limits = c(localLimits[yplotvar,"Minimum"], localLimits[yplotvar,"Maximum"]))}
  
  plot_scatter <- plot_scatter + xlab(localLimits[xplotvar,"Labels"])
  plot_scatter <- plot_scatter + ylab(localLimits[yplotvar,"Labels"])
  plot_scatter <- plot_scatter + guides(colour = guide_legend(grouping))
  
  plot_scatter <- plot_scatter + facet_wrap(~ location, nrow = ceiling(sqrt(length(unique(df$location)))), ncol=ceiling(sqrt(length(unique(df$location)))))
  return(plot_scatter)
}

getParallelCoord <- function(localFrame, titles_selected, groupLocation, grouping){
  
  df <- localFrame
  
  if(grouping != "None"){df$color <- df[,grouping]}
  else{df$color <- rep(1, length(df[,1]))}
  
  location_truth <- as.numeric(groupLocation)
  division_names <- c("New England","Middle Atlantic",
                      "East North Central","West North Central", 
                      "South Atlantic","East South Central","West South Central",
                      "Mountain","Pacific")
  if (sum(location_truth) > 0){df <- subset(df, Division %in% division_names[location_truth])}
  else{df <- df}
  
  titles_truth <- as.numeric(c(titles_selected,length(df)))
  if(length(titles_truth) > 2){df <- df[,titles_truth]}
  else(df <- df[,c(seq(1,8,1),length(df))])
  
  plot_pcp <- ggparcoord(df,columns = c(1:length(df)-1), groupColumn = length(df), title = "Parallel Coordinates Plot")
  plot_pcp <- plot_pcp + geom_line()
  #plot_pcp <- plot_pcp + scale_colour_continuous()
  plot_pcp <- plot_pcp + xlab(NULL)
  plot_pcp <- plot_pcp + ylab("Scaled Values")
  plot_pcp <- plot_pcp + guides(colour = guide_legend(grouping))
  
  return(plot_pcp)
}

getHeatMap <- function(localFrame,localLimits, pointShape, dotalpha, dotsize, groupLocation, grouping,
                       intensityvar, xplotvar, yplotvar, colorScheme2){
  
  states <- map_data("state")
  
  location_truth <- as.numeric(groupLocation)
  division_names <- c("New England","Middle Atlantic",
                      "East North Central","West North Central", 
                      "South Atlantic","East South Central","West South Central",
                      "Mountain","Pacific")
  
  if (sum(location_truth) > 0){df <- subset(localFrame, Division %in% division_names[location_truth])}
  else{df <- localFrame}
  
  df$State <- tolower(as.character(df$State))
  states <- subset(states, region %in% df$State)
  states_heat <- df
  states_heat$fill <- cut(df[,intensityvar], dig.lab = 5,breaks = seq(localLimits[intensityvar,"Minimum"],localLimits[intensityvar,"Maximum"],localLimits[intensityvar,"Breaks"]))
  
  states <- merge(states, states_heat, by.x = "region", by.y = "State", all.x = TRUE)
  
  heat <- ggplot()
  heat <- heat + geom_polygon(data=states, aes(x=long, y=lat, group = group, fill=fill),colour="white")
  
  if (colorScheme2 != "None" && colorScheme2 != "Default") {heat <- heat + scale_fill_brewer(palette = colorScheme2)}
  else if (colorScheme2 == "Default") {heat <- heat + scale_fill_brewer()}
  
  heat <- heat + xlab(element_blank())
  heat <- heat + ylab(element_blank())
  heat <- heat + guides(fill = guide_legend(intensityvar))
  
  
  return(heat)
}

#### GLOBAL OBJECTS ####
globalData <- loadData()
globalLimits <- loadLimits(globalData)

#CREATE SERVER
shinyServer(function(input, output) {
  
  localFrame <- globalData
  localLimits <- globalLimits
  
  output$bubblePlot <- renderPlot({
    bubblePlot <- getBubbleMap(
      localFrame,localLimits, input$pointShape, input$dotalpha, input$dotsize, 
      input$groupLocation, input$grouping, input$intensityvar, input$xplotvar, 
      input$yplotvar, input$colorScheme
    )
    print(bubblePlot)
  })
  
  output$scatterMatrix <- renderPlot({
    scatterMatrix <- getScatterPlotMatrix(
      localFrame,localLimits, input$pointShape, input$dotalpha, input$dotsize, 
      input$groupLocation, input$grouping, input$xplotvar, 
      input$yplotvar, input$colorScheme
    )
    print(scatterMatrix)
  })
  
  output$parCoords <- renderPlot({
    parCoords <- getParallelCoord(
      localFrame, input$titles_selected, input$groupLocation, input$grouping
    )
    print(parCoords)
  })
  
  output$heatMap <- renderPlot({
    heatMap <- getHeatMap(
      localFrame,localLimits, input$pointShape, input$dotalpha, input$dotsize, 
      input$groupLocation, input$grouping, input$intensityvar, input$xplotvar, 
      input$yplotvar, input$colorScheme2
    )
    print(heatMap)
  },width = 800, height = 400)
  
})







