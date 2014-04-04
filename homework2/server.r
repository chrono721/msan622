library(ggplot2)
library(shiny)
library(scales)

#LOAD DATA
loadData <- function() {
  data("movies", package = "ggplot2")
  genre <- rep(NA, nrow(movies))
  count <- rowSums(movies[, 18:24])
  genre[which(count > 1)] = "Mixed"
  genre[which(count < 1)] = "None"
  genre[which(count == 1 & movies$Action == 1)] = "Action"
  genre[which(count == 1 & movies$Animation == 1)] = "Animation"
  genre[which(count == 1 & movies$Comedy == 1)] = "Comedy"
  genre[which(count == 1 & movies$Drama == 1)] = "Drama"
  genre[which(count == 1 & movies$Documentary == 1)] = "Documentary"
  genre[which(count == 1 & movies$Romance == 1)] = "Romance"
  genre[which(count == 1 & movies$Short == 1)] = "Short"
  movies$genre <- genre
  movies$mpaa <- as.character(movies$mpaa)
  movies$mpaa[movies$mpaa == ""] <- "No Rating"
  movies$mpaa <- factor(movies$mpaa)
  return(movies)
}

#Define Format Functions

#### PLOTTING FUNCTION ####
getPlot <- function(localFrame, groupMPAA, GroupGenre, colorScheme = "None", dotsize, dotalpha,
                    xaxis_lim,yaxis_lim, pointShape) {

  # SUBSET BASED ON RATING
  if (groupMPAA != "All"){
    movies_sub <- subset(localFrame, mpaa == groupMPAA)
  }
  else{movies_sub <- localFrame}
  
  # SUBSET BASED ON GENRE
  genre_names <- c("Action", "Animation", "Comedy", "Drama",
                   "Documentary", "Romance", "Short")
  genre_truth <- as.numeric(GroupGenre)
  if (sum(as.numeric(genre_truth)) > 0){
    movies_sub <- subset(movies_sub, genre %in% genre_names[genre_truth])
  }
  
  #CREATE THE PLOT
  plt <- ggplot(data = movies_sub, aes(x=budget/1000000, y=rating, color = mpaa)) 
  
  # Get shape of the points
  if (pointShape == "Circle"){shape <- 20}
  else if (pointShape == "Triangle"){shape <- 17}
  else if (pointShape == "Diamond"){shape <- 18}
  else if (pointShape == "Square"){shape <- 15}
  else if (pointShape == "X"){shape <- 4}
  else if (pointShape == "Star"){shape <- 8}
  else if (pointShape == "Target"){shape <- 10}
  else if (pointShape == "Plus"){shape <- 43}
  else {shape <- 20}
  
  # Plot Points based on sliders
  if (dotalpha > 1){dotalpha <- 1}
  if (dotalpha < 0){dotalpha <- 0}
  plt <- plt + geom_point(shape = shape,size=dotsize, alpha=dotalpha, na.rm=TRUE)
  
  if (xaxis_lim[2] - xaxis_lim[1] <= 100 && xaxis_lim[2] - xaxis_lim[1] > 50){xsep <- 10}
  else if (xaxis_lim[2] - xaxis_lim[1] <= 50){xsep <- 5}
  else{xsep <- 20}

  # Plot Attributes
  plt <- plt + ggtitle("Ratings Due to Movie Budget") + 
    xlab("Budget (in Millions)") + 
    ylab("Rating") +  
    scale_x_continuous(breaks = seq(0,200,xsep), labels = dollar, limits = xaxis_lim) + 
    scale_y_continuous(breaks = c(seq(1,10,1)), limits = yaxis_lim) + 
    theme(axis.title=element_text(size=14,face="bold")) + 
    theme(title = element_text(size=18)) +  
    theme(legend.position="bottom")

  #Define Color Scheme
  if (colorScheme != "None" && colorScheme != "Default") {plt <- plt + scale_colour_brewer(palette=colorScheme, limits = levels(localFrame$mpaa))}
  else if (colorScheme == "Default") {plt <- plt + scale_colour_brewer(limits = levels(localFrame$mpaa))}
  else {plt <- plt + scale_colour_grey(start = 0.5, end = 0.5, limits = levels(localFrame$mpaa))}
  
  return(plt)
}

#### CREATING DATA TABLE ####
createDataTable <- function(localFrame, groupMPAA, GroupGenre, xaxis_lim, yaxis_lim){
  #subset based on MPAA rating
  if (groupMPAA != "All"){
    movies_sub <- subset(localFrame, mpaa == groupMPAA)
  }
  else{movies_sub <- localFrame}
  
  #subset based on genre
  genre_names <- c("Action", "Animation", "Comedy", "Drama",
                   "Documentary", "Romance", "Short")
  genre_truth <- as.numeric(GroupGenre)
  if (sum(as.numeric(genre_truth)) > 0){
    movies_sub <- subset(movies_sub, genre %in% genre_names[genre_truth])
  }
  
  #subset based on limits
  movies_sub <- subset(movies_sub, budget/1000000 >= xaxis_lim[1] & budget/1000000 <= xaxis_lim[2])
  movies_sub <- subset(movies_sub, rating >= yaxis_lim[1] & rating <= yaxis_lim[2])
  
  summary_ntable <- data.frame(movies_sub$length, movies_sub$budget/1000000, movies_sub$rating, movies_sub$votes)
  summary_ftable <- data.frame(movies_sub$mpaa, movies_sub$genre)
  names(summary_ntable) <- c("Length", "Budget(Millions)", "Rating", "Votes")
  names(summary_ftable) <- c("MPAA Rating", "Genre")
  summary_ntable <- summary(summary_ntable, maxsum = 10)
  summary_ftable <- summary(summary_ftable, maxsum = 10)
  summary_list <- list(summary_ntable, summary_ftable)
  return(summary_list)
}

##### GLOBAL OBJECTS #####

# Shared data
globalData <- loadData()

palette1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
              "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

##### SHINY SERVER #####

#CREATE SERVER
shinyServer(function(input, output) {
  
  localFrame <- globalData
  
  output$scatterPlot <- renderPlot({
      scatterPlot <- getPlot(
        localFrame, input$groupMPAA, input$GroupGenre, 
        input$colorScheme, input$dotsize, input$dotalpha, 
        input$xaxis_lim, input$yaxis_lim, input$pointShape
        )
      print(scatterPlot)
    })
  
  output$table_numeric <- renderTable({
    datatable <- createDataTable(
      localFrame, input$groupMPAA, input$GroupGenre,
      input$xaxis_lim, input$yaxis_lim
      )
    return(datatable[[1]])
  }, include.rownames = FALSE)
  
  output$table_factor <- renderTable({
    datatable <- createDataTable(
      localFrame, input$groupMPAA, input$GroupGenre,
      input$xaxis_lim, input$yaxis_lim
    )
    return(datatable[[2]])
  }, include.rownames = FALSE)
  
})



