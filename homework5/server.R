library(shiny)
library(ggplot2)
library(scales)

######LOAD DATA######
loadData <- function() {
  
  Seat_df <- data.frame(time = as.Date(c(time(Seatbelts)), origin = "1970-01-01"),
                        DriversKilled = c(Seatbelts[1:192]), 
                        drivers = c(Seatbelts[(192*1+1):(192*2)]),
                        front =c(Seatbelts[(192*2+1):(192*3)]),
                        rear = c(Seatbelts[(192*3+1):(192*4)]),
                        kms = c(Seatbelts[(192*4+1):(192*5)]),
                        PetrolPrice = c(Seatbelts[(192*5+1):(192*6)]),
                        VanKilled = c(Seatbelts[(192*6+1):(192*7)]),
                        law = c(Seatbelts[(192*7+1):(192*8)])
  )
  return(Seat_df)
}


#### PLOTTING FUNCTIONS ####
getLinePlot <- function(localFrame, XzoomStart, XzoomEnd, law, petrolSlide){
  
  Seat_df <- localFrame

  date <- as.numeric(as.Date(XzoomEnd) - as.Date(XzoomStart))
  text <- ""
  if(date <= 0 ){
    XzoomStart <- "1975-05-24"
    XzoomEnd <- "1975-06-08"
    text <- "Invalid dates Selected, Reverting to default dates."
  }
  
  petrol_over = Seat_df[which(Seat_df$PetrolPrice > petrolSlide),]
  
  plt1 <- ggplot()
  plt1 <- plt1 + geom_line(data = Seat_df, aes(x=time, y=kms))
  plt1 <- plt1 + geom_point(data = petrol_over, aes(x=time, y=kms, color="kms",size=2))
  if(law){
    plt1 <- plt1 + geom_vline(xintercept = as.numeric(Seat_df$time[170]), color = "Red", size = 1.2)
  }
  plt1 <- plt1 + ggtitle("Total Kilometers Driven in 1975")
  plt1 <- plt1 + xlab("Time (1975)") +  ylab("Kilometers")
  plt1 <- plt1 + guides(color=FALSE, size=FALSE)
  plt1 <- plt1 + theme(axis.title=element_text(size=12,face="bold"), title = element_text(size=18))
  plt1 <- plt1 + scale_x_date(limits = c(as.Date(XzoomStart), as.Date(XzoomEnd)), 
                              breaks = date_breaks("2 days"), labels = date_format("%d-%b"), expand = c(0,0))
  plt1 <- plt1 + annotate("text", x=(as.Date(XzoomStart)+5), y=5, label=text)  
  return(plt1)
}

getStackedArea <- function(localFrame, XzoomStart, XzoomEnd, law, areaType){
  
  Seat_df <- localFrame
  
  date <- as.numeric(as.Date(XzoomEnd) - as.Date(XzoomStart))
  text <- ""
  if(date <= 0 ){
    XzoomStart <- "1975-05-24"
    XzoomEnd <- "1975-06-08"
    text <- "Invalid dates Selected, Reverting to default dates."
  }
  
  Seat_killed <- data.frame(time=Seat_df$time,
                            Driver=Seat_df$drivers,
                            Front=Seat_df$front,
                            Rear=Seat_df$rear)
  Seat_melt <- melt(Seat_killed, id="time")
  
  TOTALS <- Seat_df$drivers+Seat_df$front+Seat_df$rear
  Seat_killed_P <- data.frame(time=Seat_df$time,
                              Driver=Seat_df$drivers/TOTALS,
                              Front=Seat_df$front/TOTALS,
                              Rear=Seat_df$rear/TOTALS)
  Seat_melt_P <- melt(Seat_killed_P, id="time")
  
  if(areaType == "Area"){
    plt2 <- ggplot(Seat_melt, aes(x=time, y=value, group=variable, fill=variable))
    plt2 <- plt2 + geom_area(position="stack")
    plt2 <- plt2 + ggtitle("Number of Car Injuries/Deaths in the UK")
    plt2 <- plt2 + xlab("Time (1975)") +  ylab("Death/Serious Injury Counts")
    plt2 <- plt2 + scale_y_continuous(limits = c(0,5000), expand = c(0,0))
    plt2 <- plt2 + annotate("text", x=(as.Date(XzoomStart)+5), y=500, label=text)
  }
  else if (areaType == "Percent"){
    plt2 <- ggplot(Seat_melt_P, aes(x=time, y=value, group=variable, fill=variable))
    plt2 <- plt2 + geom_area(position="stack")
    plt2 <- plt2 + ggtitle("Percent of Car Injuries/Deaths in the UK")
    plt2 <- plt2 + xlab("Time (1975)") +  ylab("Death/Serious Injury")
    plt2 <- plt2 + ylim(0,1)
    plt2 <- plt2 + scale_y_continuous(breaks=seq(0,1,0.1), labels=percent, expand = c(0,0))
    plt2 <- plt2 + annotate("text", x=(as.Date(XzoomStart)+5), y=0.1, label=text)
  }
  
  if(law){
    plt2 <- plt2 + geom_vline(xintercept = as.numeric(Seat_df$time[170]), color = "Red", size = 1.2)
  }
  
  plt2 <- plt2 + scale_x_date(limits = c(as.Date(XzoomStart), as.Date(XzoomEnd)), 
                              breaks = date_breaks("2 days"), labels = date_format("%d-%b"), expand = c(0,0))
  plt2 <- plt2 + labs(fill = "Victim Location")
  plt2 <- plt2 + theme(axis.title=element_text(size=12,face="bold"), 
                       title = element_text(size=18),
                       panel.background = element_rect(fill="grey95"))
  return(plt2)
}

getHeatMap <- function(localFrame, XzoomStart, XzoomEnd, law, colorScheme, heatType){
  
  Seat_df <- localFrame
  
  date <- as.numeric(as.Date(XzoomEnd) - as.Date(XzoomStart))
  text <- ""
  if(date <= 0 ){
    XzoomStart <- "1975-05-24"
    XzoomEnd <- "1975-06-08"
    text <- "Invalid dates Selected, Reverting to default dates."
  }
  
  Seat_killed_P2 <- data.frame(time=Seat_df$time,
                               Driver=Seat_df$drivers/sum(Seat_df$drivers),
                               Front=Seat_df$front/sum(Seat_df$front),
                               Rear=Seat_df$rear/sum(Seat_df$rear))
  Seat_melt_P2 <- melt(Seat_killed_P2, id="time")
  
  #Single COlors
  if(heatType == "Single Color"){
    colorval <- c(0,0.5,1)
    if(colorScheme == "ColorScheme1"){palette <- c("#e5f5e0", "#a1d99b", "#31a354")} #Greens
    if(colorScheme == "ColorScheme2"){palette <- c("#fee6ce", "#fdae6b", "#e6550d")} #Orange
    if(colorScheme == "ColorScheme3"){palette <- c("#efedf5", "#bcbddc", "#756bb1")} #Purple
    if(colorScheme == "ColorScheme4"){palette <- c("#deebf7", "#9ecae1", "#3182bd")} #Blues
  }
  #Contrasting Colors
  else{
    colorval <- c(0,0.4,0.6,1)
    if(colorScheme == "ColorScheme1"){palette <- c("#ef8a62", "#f7f7f7", "#f7f7f7", "#67a9cf")} #Red/Blue
    if(colorScheme == "ColorScheme2"){palette <- c("#f1a340", "#f7f7f7", "#f7f7f7", "#998ec3")} #Purple/Orange
    if(colorScheme == "ColorScheme3"){palette <- c("#7fbf7b", "#f7f7f7", "#f7f7f7", "#af8dc3")} #Green/Purple
    if(colorScheme == "ColorScheme4"){palette <- c("#d8b365", "#f5f5f5", "#f5f5f5", "#5ab4ac")} #Brown/Blue
  }
  
  plt3 <- ggplot(Seat_melt_P2, aes(x=time, y=variable, fill=value))
  plt3 <- plt3 + geom_tile()
  plt3 <- plt3 + theme_minimal()
  plt3 <- plt3 + theme(panel.grid = element_blank())
  
  if(law){
    plt3 <- plt3 + geom_vline(xintercept = as.numeric(Seat_df$time[170]), color = "Red", size = 1.2)
  }
  
  plt3 <- plt3 + ggtitle("Percent of Car Injuries/Death (UK)")
  plt3 <- plt3 + xlab("Time (1975)") +  ylab("Location of Death in Car")
  plt3 <- plt3 + labs(fill = "Percent")
  plt3 <- plt3 + scale_x_date(limits = c(as.Date(XzoomStart), as.Date(XzoomEnd)-1),expand = c(0,0))
  plt3 <- plt3 + scale_fill_gradientn(colours = palette, values = colorval, breaks = seq(0.003, 0.008, 0.001), labels = paste(seq(0.3, 0.8, 0.1), "%"))
  plt3 <- plt3 + scale_y_discrete(expand = c(0,0))
  plt3 <- plt3 + theme(axis.title=element_text(size=12,face="bold"), title = element_text(size=18))

  return(plt3)
}


#### GLOBAL OBJECTS ####
globalData <- loadData()


#CREATE SERVER
shinyServer(function(input, output) {
  
  localFrame <- globalData
  
  output$LinePlot <- renderPlot({
    LinePlot <- getLinePlot(
      localFrame, input$XzoomStart, input$XzoomEnd, input$law,
      input$petrolSlide
    )
    print(LinePlot)
  })
  
  output$StackedArea <- renderPlot({
    StackedArea <- getStackedArea(
      localFrame, input$XzoomStart, input$XzoomEnd, input$law,
      input$areaType
    )
    print(StackedArea)
  })
  
  output$HeatMap <- renderPlot({
    HeatMap <- getHeatMap(
      localFrame, input$XzoomStart, input$XzoomEnd, input$law,
      input$colorScheme, input$heatType
    )
    print(HeatMap)
  })
  
})
  
