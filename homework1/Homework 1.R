
library(ggplot2)
library(scales)

dir <- getwd()
  
#Load Data
data(movies)
data(EuStockMarkets)

#Transformations
movies <- movies[!is.na(movies$budget),]
movies <- movies[movies$budget > 0,]

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
freq <- data.frame(table(genre))
freq$Percent <- paste(as.character(round(100*freq$Freq/sum(freq$Freq),digits=2)), "%", sep="")

eu <- transform(data.frame(EuStockMarkets), time = time(EuStockMarkets))


#########################
#Plot 1 - Scatterplot
#########################

plot1 <- ggplot(data = movies, aes(x=budget/1000000, y=rating)) +
         ggtitle("Scatterplot: Ratings due to Movie Budget") +
         geom_point(na.rm = TRUE) +  xlab("Budget (in Millions)") +  ylab("Rating") +
         scale_x_continuous(labels = dollar) + 
         scale_y_continuous(breaks = seq(1,10,1)) + 
         theme(axis.title=element_text(size=14,face="bold"), title = element_text(size=18))
#print(plot1)

plot1_save <- paste(dir, "hw1-scatter.png", sep = "/")
ggsave(filename = plot1_save, plot = plot1, dpi = 72)


#########################
#Plot 2 - Bar Chart
#########################

plot2 <- ggplot(data = movies, aes(x=factor(genre), fill = genre)) + 
         ggtitle("Number of Genres in Movies Dataset") + scale_y_continuous(breaks = seq(0,2000,100))+
         geom_text(data=freq,aes(x=genre, y = Freq, label = Percent), vjust=-0.5) +
         geom_bar(na.rm = TRUE) +  xlab("Genre") +  ylab("Counts") +
         guides(fill=FALSE) + 
         theme(axis.title=element_text(size=14,face="bold"), title = element_text(size=18))
#print(plot2)

plot2_save <- paste(dir, "hw1-bar.png", sep = "/")
ggsave(filename = plot2_save, plot = plot2, dpi = 72)


#########################
#Plot 3 - Small Multiples
#########################

plot3 <- ggplot(data = movies, aes(x=budget/1000000, y=rating, color = factor(genre), group=factor(genre))) + 
         ggtitle("Rating due to Movie Budget by Genre") + 
         geom_point(na.rm = TRUE) +  xlab("Budget (in Millions)") +  ylab("Rating") + 
         facet_wrap(~ genre, ncol = 3) + guides(color=FALSE) +
         scale_x_continuous(labels = dollar) + 
         scale_y_continuous(breaks = seq(1,10,1)) + 
         theme(axis.title=element_text(size=14,face="bold"), title = element_text(size=18))
#print(plot3)

plot3_save <- paste(dir, "hw1-multiples.png", sep = "/")
ggsave(filename = plot3_save, plot = plot3, dpi = 72)

#########################
#Plot 4 - Multi-Line Chart
#########################

plot4 <- ggplot(data = eu, aes(x=time)) + 
         geom_line(aes(y=DAX, color = "DAX")) + 
         geom_line(aes(y=SMI, color = "SMI")) + 
         geom_line(aes(y=CAC, color = "CAC")) + 
         geom_line(aes(y=FTSE, color = "FTSE")) + 
         ggtitle("EU Stock Indexes over The Years") +  
         xlab("Time (Year)") +  ylab("Stock Index") +
         labs(color="Stock Index") + 
         scale_x_continuous(breaks = seq(1991,1999,1), limits=c(1991, 1999)) + 
         scale_y_continuous(breaks = seq(1000,9000,1000), limits=c(1000, 9000)) + 
         guides(size=FALSE, color=guide_legend(override.aes=list(size=c(2,2,2,2)))) + 
         theme(axis.title=element_text(size=14,face="bold"), title = element_text(size=18))
#print(plot4)

plot4_save <- paste(dir, "hw1-multiline.png", sep = "/")
ggsave(filename = plot4_save, plot = plot4, dpi = 72)




