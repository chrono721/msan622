
library(shiny)
library(ggplot2)
library(scales)
library(wordcloud)
library(reshape)
library(gridExtra)
library(igraph)

#### PLOTTING FUNCTIONS ####

getInfo <- function(countFrame, tfidfFrame, basicFrame, AcountFrame, AtfidfFrame, AbasicFrame, frametype, itemHAM, itemMAD, itemUNK){
  
  if(frametype == T){
    myData_count <- AcountFrame
    myData_tfidf <- AtfidfFrame
    myData_basic <- AbasicFrame
  }
  else{
    myData_count <- countFrame
    myData_tfidf <- tfidfFrame
    myData_basic <- basicFrame
  }
  
  if(length(itemHAM) == 0){HAM <- which(myData_basic$AUTHOR == "HAMILTON")}
  else{HAM <- which(myData_basic$PAPER_NAME %in% itemHAM)}
  if(length(itemMAD) == 0){MAD <- which(myData_basic$AUTHOR == "MADISON")}
  else{MAD <- which(myData_basic$PAPER_NAME %in% itemMAD)}
  if(length(itemUNK) == 0){UNK <- which(myData_basic$AUTHOR == "UNKNOWN")}
  else{UNK <- which(myData_basic$PAPER_NAME %in% itemUNK)}
  N_papers <- sort(c(HAM, MAD, UNK))
  
  myData_basic <- myData_basic[N_papers,]
  
  BASIC <- data.frame("Paper_No" = myData_basic$PAPER_NAME, 
                      "Title" = myData_basic$TITLE, 
                      "Author" = myData_basic$AUTHOR, 
                      "Published" = myData_basic$DATE, 
                      "Word_Count" = myData_basic$COUNT) 
  return(BASIC)
}

getBar <- function(countFrame, tfidfFrame, basicFrame, AcountFrame, AtfidfFrame, AbasicFrame, frametype, itemHAM, itemMAD, itemUNK, barType, barFreq){
  
  if(frametype == T){
    myData_count <- AcountFrame
    myData_tfidf <- AtfidfFrame
    myData_basic <- AbasicFrame
  }
  else{
    myData_count <- countFrame
    myData_tfidf <- tfidfFrame
    myData_basic <- basicFrame
  }
  
  N_words <- barFreq
  
  if(length(itemHAM) == 0){HAM <- which(myData_basic$AUTHOR == "HAMILTON")}
  else{HAM <- which(myData_basic$PAPER_NAME %in% itemHAM)}
  if(length(itemMAD) == 0){MAD <- which(myData_basic$AUTHOR == "MADISON")}
  else{MAD <- which(myData_basic$PAPER_NAME %in% itemMAD)}
  if(length(itemUNK) == 0){UNK <- which(myData_basic$AUTHOR == "UNKNOWN")}
  else{UNK <- which(myData_basic$PAPER_NAME %in% itemUNK)}

  N_papers <- sort(c(HAM, MAD, UNK))
  if (length(N_papers) > 25){
    N_papers <- sort(sample(N_papers, 25))
  }
  
  titles <- myData_basic$PAPER_NAME[N_papers]
  authors <- myData_basic$AUTHOR[N_papers]
  title_author <- paste(titles,' (',authors,')', sep="")
  
  if(barType == "Most Frequent"){
    common_words <- names(sort(colSums(myData_count), decreasing=T)[1:N_words])
    common_words_counts <- as.vector(sort(colSums(myData_count), decreasing=T)[1:N_words])
    word_df <- myData_count[titles,common_words]
  }
  else if(barType == "Highest TF-IDF"){
    temp<- apply(myData_tfidf, 2, max)
    common_words <- names(sort(temp, decreasing=T)[1:N_words])
    common_words_counts <- as.vector(sort(temp, decreasing=T)[1:N_words])
    word_df <- myData_tfidf[titles,common_words]
  }
  
  word_df$papers <- title_author
  bar_df <- melt(word_df, id="papers")
  bar_df$papers <- factor(bar_df$papers, levels = title_author)

  plt1 <- ggplot(bar_df, aes(x="i", y=value))
  plt1 <- plt1 +  geom_bar(aes(fill=variable),position ="dodge",
                           stat="identity", width=.25)
  plt1 <- plt1 + theme(panel.grid.major = element_blank(),
                       panel.grid.minor = element_blank(),
                       panel.background = element_rect(fill="white"),
                       plot.background = element_blank(),
                       axis.ticks = element_blank(),
                       axis.text.x = element_blank(),
                       axis.title.x = element_blank(),
                       axis.title.y = element_blank(),
                       legend.title = element_blank(),
                       legend.text = element_text(size=14, face="bold"))
  plt1 <- plt1 + facet_wrap( ~ papers, ncol=ceiling(sqrt(length(N_papers))))
  plt1 <- plt1 + theme(strip.background = element_rect(fill = "tan"), 
                       strip.text = element_text(size = 10, face="italic")) 
  
  #BASED ON CHOICE
  if(barType == "Most Frequent"){
    mytable <- tableGrob(cbind(words=common_words,total_counts = common_words_counts), 
                       gpar.rowfill = gpar(fill = "grey90", col = "white"))
    plt1 <- plt1 + ggtitle("Most Frequent Words in the Federalist Papers\n")
  }
  else if(barType == "Highest TF-IDF"){
    mytable <- tableGrob(cbind(words=common_words, max_tfidf = common_words_counts), 
                         gpar.rowfill = gpar(fill = "grey90", col = "white"))
    plt1 <- plt1 + ggtitle("Words with Highest TF-IDF in the Federalist Papers\n")
  }
  
  
  #Extract Legend
  g_legend <- function(a.gplot){
    tmp <- ggplot_gtable(ggplot_build(a.gplot))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    return(legend)}
  
  legend <- g_legend(plt1)
  
  grid.newpage()
  vp1 <- viewport(width = 0.75, height = 1, x = 0.375, y = .5)
  vpleg <- viewport(width = 0.25, height = 0.5, x = 0.85, y = 0.75)
  subvp <- viewport(width = 0.3, height = 0.3, x = 0.85, y = 0.25)
  plt1 <- plt1 + theme(legend.position = "none")
  print(plt1, vp = vp1)
  
  upViewport(0)
  pushViewport(vpleg)
  grid.draw(legend)
  
  #Make the new viewport active and draw
  upViewport(0)
  pushViewport(subvp)
  grid.draw(mytable)
  
}

getCloud <- function(countFrame, tfidfFrame, basicFrame, AcountFrame, AtfidfFrame, AbasicFrame, frametype, itemHAM, itemMAD, itemUNK, cloudAuthor, cloudType, option){
  
  if(frametype == T){
    myData_count <- AcountFrame
    myData_tfidf <- AtfidfFrame
    myData_basic <- AbasicFrame
  }
  else{
    myData_count <- countFrame
    myData_tfidf <- tfidfFrame
    myData_basic <- basicFrame
  }
  
  if(length(itemHAM) == 0){HAM <- which(myData_basic$AUTHOR == "HAMILTON")}
  else{HAM <- which(myData_basic$PAPER_NAME %in% itemHAM)}
  if(length(itemMAD) == 0){MAD <- which(myData_basic$AUTHOR == "MADISON")}
  else{MAD <- which(myData_basic$PAPER_NAME %in% itemMAD)}
  if(length(itemUNK) == 0){UNK <- which(myData_basic$AUTHOR == "UNKNOWN")}
  else{UNK <- which(myData_basic$PAPER_NAME %in% itemUNK)}
  
  N_papers <- sort(c(HAM, MAD, UNK))
  titles <- myData_basic$PAPER_NAME[N_papers]
  
  authors <- c("MADISON","HAMILTON","UNKNOWN")
  
  if(cloudAuthor ==  "ALL"){authors <- c("MADISON","HAMILTON","UNKNOWN")}
  else if(cloudAuthor ==  "HAMILTON & MADISON"){authors <- c("MADISON","HAMILTON")}
  else if(cloudAuthor ==  "HAMILTON & UNKNOWN"){authors <- c("HAMILTON","UNKNOWN")}
  else if(cloudAuthor ==  "MADISON & UNKNOWN"){authors <- c("MADISON","UNKNOWN")}
  
  word_group <- data.frame(WORDS = names(myData_count))
  
  if(cloudType == "Word Count"){
    for (author in authors){
      papers <- myData_basic$PAPER_NAME[which(myData_basic$AUTHOR==author & myData_basic$PAPER_NAME %in% titles)]
      word_group[,author] <- t(t(colSums(myData_count[papers,])))
    }
  }
  else if(cloudType == "TF-IDF"){
    for (author in authors){
      papers <- myData_basic$PAPER_NAME[which(myData_basic$AUTHOR==author & myData_basic$PAPER_NAME %in% titles)]
      word_group[,author] <- t(t(apply(myData_tfidf[papers,], 2, max)))
    }
  }

  rownames(word_group)<- word_group$WORDS
  word_group$WORDS <- NULL
  word_group <- as.matrix(word_group)
  
  if(option == "Overall"){
      wordcloud(rownames(word_group),apply(word_group,1,max),max.words = 75)
  }
  else{
      comparison.cloud(word_group, scale=c(3,.6), max.words=75, title.size=2)
  } 
}

getLine <- function(countFrame, tfidfFrame, basicFrame, AcountFrame, AtfidfFrame, AbasicFrame, frametype, lineDates, lineFreq, lineAuthor){
  
  if(frametype == T){
    myData_linecount <- AcountFrame
    myData_tfidf <- AtfidfFrame
    myData_basic <- AbasicFrame
  }
  else{
    myData_linecount <- countFrame
    myData_tfidf <- tfidfFrame
    myData_basic <- basicFrame
  }
  
  authors <- c("MADISON","HAMILTON","UNKNOWN")
  if(lineAuthor ==  "ALL"){authors <- c("MADISON","HAMILTON","UNKNOWN")}
  else if(lineAuthor ==  "HAMILTON"){authors <- c("HAMILTON")}
  else if(lineAuthor ==  "MADISON"){authors <- c("MADISON")}
  else if(lineAuthor ==  "UNKNOWN"){authors <- c("UNKNOWN")}
  papers <- myData_basic$PAPER_NAME[which(myData_basic$AUTHOR %in% authors)]
  myData_linecount <- myData_linecount[papers,]
  N_years <- length(rownames(myData_linecount))
  
  #Analysis
  lower_range <- 1:floor(N_years/3)
  upper_range <- (floor(N_years)/3 + floor(N_years)/3):N_years

  analysis <- data.frame(colSums(myData_linecount[lower_range,]))
  analysis$upper <- colSums(myData_linecount[upper_range,])
  names(analysis) <- c("lower", "upper")
  analysis$diff <- analysis$lower - analysis$upper
  analysis <- analysis[with(analysis, order(-diff)),]
  #1 = high-low, 2=no change, 3=low to high use
  low <- floor(length(analysis$diff)/3)
  high <- length(analysis$diff)-2*low
  analysis$TYPE <- c(rep("Decreased Usage",low), rep("No Change", low), rep("Increased Usage", high))
  analysis_1 <- subset(analysis,TYPE=="Decreased Usage")
  analysis_2 <- subset(analysis,TYPE=="No Change")
  analysis_2$diff <- abs(analysis_2$diff)
  analysis_2 <- analysis_2[with(analysis_2, order(diff)),]
  analysis_3 <- subset(analysis,TYPE=="Increased Usage")
  analysis_3 <- analysis_3[with(analysis_3, order(diff)),]
  
  words_to_plot_type1 <- rownames(analysis_1)[1:lineFreq]
  words_to_plot_type2 <- rownames(analysis_2)[1:lineFreq]
  words_to_plot_type3 <- rownames(analysis_3)[1:lineFreq]
  
  #SUBSET FOR ZOOMING and NUMBER OF WORDS
  startdate <- lineDates[1]
  enddate <- lineDates[2]
  date_daterange <- as.Date(myData_basic$DATE[which(myData_basic$DATE >= startdate & myData_basic$DATE <= enddate)])
  titles <- myData_basic$PAPER[which(myData_basic$DATE >= startdate & myData_basic$DATE <= enddate & myData_basic$PAPER_NAME %in% papers)]
  
  lines <- myData_linecount[titles,words_to_plot_type1]
  lines$date <- myData_basic$DATE[which(myData_basic$PAPER_NAME %in% titles)]
  lines_melted <- melt(lines, id="date")  # convert to long format
  lines_melted$TYPE <- rep("Decreased Usage",length(lines_melted$date))
  
  lines <- myData_linecount[titles,words_to_plot_type3]
  lines$date <- myData_basic$DATE[which(myData_basic$PAPER_NAME %in% titles)]
  lines_melted_new <- melt(lines, id="date")  # convert to long format
  lines_melted_new$TYPE <- rep("Increased Usage",length(lines_melted_new$date))
  lines_melted <- rbind(lines_melted, lines_melted_new)
   
  plt3 <- ggplot(data = lines_melted, aes(x=date, y=value))
  plt3 <- plt3 + geom_line(aes(group = variable, color = variable))
  plt3 <- plt3 + facet_wrap(~TYPE, nrow = 2)
  
  text=""
  for(author in authors){text <- paste(text, author)}
  
  plt3 <- plt3 + ggtitle(paste("Word Usage of", text))
  plt3 <- plt3 + xlab("Date of Publish (1787 - 1788)") +  ylab("Count of Word Usage")
  plt3 <- plt3 + labs(color="Word Used")
  plt3 <- plt3 + scale_x_date(limits = c(startdate, enddate), breaks = date_breaks(width = "1 month"), labels = date_format("%m/%Y"), expand = c(0,0))
  plt3 <- plt3 + theme(axis.title=element_text(size=12,face="bold"), title = element_text(size=18))
  plt3 <- plt3 +theme(panel.background = element_rect(fill="grey100"))
  
  return(plt3)  
}

getNetwork <- function(networkType, author, networkNodes, networkDraw){
  
  networkFrame <- loadNetwork(networkType, author)
  rownames(networkFrame) <- names(networkFrame)
  
  m=as.matrix(networkFrame)
  
  if(networkDraw == "Highest Edge Counts"){
    #ORGANIZE BY MAX NODES
    Max_nodes <- sort(networkFrame[networkFrame > 0], decreasing=T)[1:networkNodes]
    names_MAX_NODES <- data.frame()
    for (node in Max_nodes){
      names_MAX_NODES <- rbind(names_MAX_NODES, which(m==node, arr.ind=TRUE))
    }
    names_MAX_NODES <- unique(names_MAX_NODES)
    row_names_max <- rownames(networkFrame)[names_MAX_NODES$row]
    col_names_max <- names(networkFrame)[names_MAX_NODES$col]
    all_names <- unique(c(row_names_max, col_names_max)) 
  }
  else if(networkDraw == "Highest Overall Degree"){
    Degree <- sort(rowSums(networkFrame) + colSums(networkFrame), decreasing = T)[1:networkNodes]
    DegreeValue <- as.vector(Degree)
    all_names <- names(Degree)
  }

  m <- m[all_names, all_names]
  
  net=graph.adjacency(m,mode="directed",weighted=TRUE,diag=F) 
  
  plot.igraph(net,vertex.label=V(net)$name,layout=layout.fruchterman.reingold, 
              vertex.label.color="black",edge.color="black",
              edge.width=E(net)$weight/5, edge.arrow.size=0.5,edge.curved=TRUE)

}

getNetworkTable <- function(networkType, author, networkNodes, networkDraw){
  
  networkFrame <- loadNetwork(networkType, author)
  rownames(networkFrame) <- names(networkFrame)
  
  m=as.matrix(networkFrame)
  
  if(networkDraw == "Highest Edge Counts"){
    #ORGANIZE BY MAX NODES
    Max_nodes <- sort(networkFrame[networkFrame > 0], decreasing=T)[1:networkNodes]
    names_MAX_NODES <- data.frame()
    for (node in Max_nodes){
      names_MAX_NODES <- rbind(names_MAX_NODES, which(m==node, arr.ind=TRUE))
    }
    names_MAX_NODES <- unique(names_MAX_NODES)
    row_names_max <- rownames(networkFrame)[names_MAX_NODES$row]
    col_names_max <- names(networkFrame)[names_MAX_NODES$col]
    all_names <- unique(c(row_names_max, col_names_max)) 
  }
  else if(networkDraw == "Highest Overall Degree"){
    Degree <- sort(rowSums(networkFrame) + colSums(networkFrame), decreasing = T)[1:networkNodes]
    DegreeValue <- as.vector(Degree)
    all_names <- names(Degree)
  }
  
  m <- m[all_names, all_names]
  
  if(networkDraw == "Highest Edge Counts"){
    WORD_1 <- character(0)
    WORD_2 <- character(0)
    Edge <- numeric(0)
    for(x_name in all_names){
      for(y_name in all_names){
        WORD_1 <- c(WORD_1, x_name)
        WORD_2 <- c(WORD_2, y_name)
        Edge <- c(Edge, m[x_name, y_name])
      }
    }
    table_data <- data.frame(WORD_1, WORD_2, Edge)
    table_data <- table_data[order(-table_data[,3]),]
    table_data <- table_data[1:15,]
    rownames(table_data) <- 1:15
  }
  else if(networkDraw == "Highest Overall Degree"){
    table_data <- data.frame(Node = all_names, Degree = DegreeValue)
    table_data <- table_data[1:15,]
    rownames(table_data) <- 1:15
  }
  
  return(table_data)
}


#CREATE SERVER
shinyServer(function(input, output) {
  
  output$infoTable <- renderDataTable({
    Information <- getInfo(
      countFrame, tfidfFrame, basicFrame,
      ALL_countFrame, ALL_tfidfFrame, ALL_basicFrame, input$frametype,
      input$itemHAM, input$itemMAD, input$itemUNK
      )
  }, options = list(aLengthMenu = c(5, 10, 20), iDisplayLength = 10))
  
  output$Bar <- renderPlot({
    BarPlot <- getBar(
      countFrame, tfidfFrame, basicFrame,
      ALL_countFrame, ALL_tfidfFrame, ALL_basicFrame, input$frametype,
      input$itemHAM, input$itemMAD, input$itemUNK,
      input$barType, input$barFreq 
      )
  })
  
  output$Cloud <- renderPlot({
    CloudPlot <- getCloud(
      countFrame, tfidfFrame, basicFrame,
      ALL_countFrame, ALL_tfidfFrame, ALL_basicFrame, input$frametype,
      input$itemHAM, input$itemMAD, input$itemUNK,
      input$cloudAuthor, input$cloudType, input$cloudOption
    )
  })
  
  output$Line <- renderPlot({
    LinePlot <- getLine(
      countFrame, tfidfFrame, basicFrame,
      ALL_countFrame, ALL_tfidfFrame, ALL_basicFrame, input$frametype,
      input$lineDates, input$lineFreq, input$lineAuthor
    )
    print(LinePlot)
  })
  
  output$Network <- renderPlot({
    NetworkPlot <- getNetwork(
      input$networkLink, input$networkAuthor,
      input$networkNodes, input$networkDraw
    )
  }, width = 700, height = 500)
  
  output$NetworkTable <- renderTable({
    NetworkTable <- getNetworkTable(
      input$networkLink, input$networkAuthor,
      input$networkNodes, input$networkDraw
    )
    NetworkTable
  })
  
})










