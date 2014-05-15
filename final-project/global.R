
library(shiny)

######LOAD DATA######
loadCountData <- function(type) {
  if(type == "all"){
    myData <- read.csv("./network/all_counts.csv")
  }
  else{
    myData <- read.csv("./network/stop_counts.csv")
    myData$ha <- NULL
  }
  basic <- read.csv("./network/basic.csv")
  basic$PAPER_NAME <- as.character(basic$PAPER_NAME)
  rownames(myData) <- basic$PAPER_NAME
  return(myData)
}

loadTfidfData <- function(type) {
  if(type == "all"){
    myData <- read.csv("./network/all_tfidf.csv")
  }
  else{
    myData <- read.csv("./network/stop_tfidf.csv")
    myData$ha <- NULL
  }
  basic <- read.csv("./network/basic.csv")
  basic$PAPER_NAME <- as.character(basic$PAPER_NAME)
  rownames(myData) <- basic$PAPER_NAME
  return(myData)
}

loadBasic <- function(type) {
  if(type == "all"){
    myData_count <- read.csv("./network/all_counts.csv")
    myData_POS <- read.csv("./network/all_POS.csv")
  }
  else{
    myData_count <- read.csv("./network/stop_counts.csv")
    myData_POS <- read.csv("./network/stop_POS.csv")
  }
  myData_basic <- read.csv("./network/basic.csv")
  myData_basic$PAPER_NAME <- as.character(myData_basic$PAPER_NAME)
  myData_basic$DATE <- as.Date(myData_basic$DATE, format = "%m/%d/%Y")
  myData_basic$WC_TOTAL <- rowSums(myData_count)
  myData_basic$WC_NOUN <- rowSums(myData_count[,subset(myData_POS, POS=="noun")$Word])
  myData_basic$WC_ADVERB <- rowSums(myData_count[,subset(myData_POS, POS=="adverb")$Word]) 
  myData_basic$WC_ADJECTIVE <- rowSums(myData_count[,subset(myData_POS, POS=="adjective")$Word])
  myData_basic$WC_VERB <- rowSums(myData_count[,subset(myData_POS, POS=="verb")$Word])
  myData_basic$WC_OTHER <- rowSums(myData_count[,subset(myData_POS, POS %in% c("CD", "modal","PRP", "RBR"))$Word])
  
  myData_basic$AUTHOR <- as.character(myData_basic$AUTHOR)
  myData_basic$AUTHOR[which(myData_basic$AUTHOR == "HAMILTON OR MADISON")] <- "UNKNOWN"
  myData_basic$AUTHOR <- as.factor(myData_basic$AUTHOR)
  
  return(myData_basic)
}

loadNetwork <- function(type, author) {
  filename <- paste('./network/network', type, author, sep='_')
  filename <- paste(filename,'.csv',sep="")
  network_data <- read.csv(filename)
  rownames(network_data) <- names(network_data)
  return(network_data)
}

#####GLOBAL DATA#####
setwd(getwd())
countFrame <- loadCountData('other')
basicFrame <- loadBasic('other')
tfidfFrame <- loadTfidfData('other')
ALL_countFrame <- loadCountData('all')
ALL_basicFrame <- loadBasic('all')
ALL_tfidfFrame <- loadTfidfData('all')
HAM_Paper_List <- basicFrame$PAPER[which(basicFrame$AUTHOR == "HAMILTON")]
MAD_Paper_List <- basicFrame$PAPER[which(basicFrame$AUTHOR == "MADISON")]
UNK_Paper_List <- basicFrame$PAPER[which(basicFrame$AUTHOR == "UNKNOWN")]

