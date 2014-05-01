
library(ggplot2)
library(scales)
library(reshape)
library(wordcloud)
library(network)
library(gridExtra)

curr_dir <- getwd()
myData_count <- read.csv("counts.csv")
myData_POS <- read.csv("POS.csv")
myData_basic <- read.csv("basic.csv")

#TRANSFORM BASIC DATA
myData_basic$PAPER_NAME <- as.character(myData_basic$PAPER_NAME)
myData_basic$DATE <- as.Date(myData_basic$DATE, format = "%m/%d/%Y")
myData_basic$WC_TOTAL <- rowSums(myData_count)
myData_basic$WC_NOUN <- rowSums(myData_count[,subset(myData_POS, POS=="noun")$Word])
myData_basic$WC_ADVERB <- rowSums(myData_count[,subset(myData_POS, POS=="adverb")$Word]) 
myData_basic$WC_ADJECTIVE <- rowSums(myData_count[,subset(myData_POS, POS=="adjective")$Word])
myData_basic$WC_VERB <- rowSums(myData_count[,subset(myData_POS, POS=="verb")$Word])
myData_basic$WC_OTHER <- rowSums(myData_count[,subset(myData_POS, POS %in% c("CD", "modal","PRP", "RBR"))$Word])

#TRANSFOEM MYDATA_COUNTS
rownames(myData_count) <- myData_basic$PAPER_NAME


#Plot1: Bar Multiples

common_words <- names(sort(colSums(myData_count), decreasing=T)[1:5])
common_words_counts <- as.vector(sort(colSums(myData_count), decreasing=T)[1:5])
titles <- myData_basic$PAPER_NAME[5:13]
authors <- myData_basic$AUTHOR[5:13]
title_author <- paste(titles,' (',authors,')', sep="")
word_df <- myData_count[titles,common_words]
word_df$papers <- title_author
bar_df <- melt(word_df, id="papers")
bar_df$papers <- factor(bar_df$papers, levels = title_author)

mytable <- tableGrob(cbind(words=common_words,total_counts = common_words_counts), 
                     gpar.rowfill = gpar(fill = "grey90", col = "white"))

plt1 <- ggplot(bar_df, aes(x="i", y=value))
plt1 <- plt1 +  geom_bar(aes(fill=variable),position ="dodge",
           stat="identity", width=.25)
plt1 <- plt1 + theme(panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(),
                     panel.background = element_rect(fill="white"),
                     plot.background = element_blank(),
                     axis.ticks = element_blank(),
                     axis.text.x = element_blank(),
                     axis.text.y = element_blank(),
                     axis.title.x = element_blank(),
                     axis.title.y = element_blank(),
                     legend.title = element_blank(),
                     legend.text = element_text(size=14, face="bold"))
plt1 <- plt1 + ggtitle("Top 5 Most Frequent Words in the Federalist Papers\n")
#plt1 <- plt1 + scale_fill_manual(values=palette[1:3])
plt1 <- plt1 + facet_wrap( ~ papers, ncol=3)
plt1 <- plt1 + theme(strip.background = element_rect(fill = "tan"), 
                     strip.text = element_text(size = 10, face="italic")) 
#plt1 <- plt1 + annotation_custom(tableGrob(mytable, gpar.rowfill = gpar(fill = "grey90", col = "white")), 
#                                 xmin=0, xmax=0,ymin=0, ymax=0)

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
print(plt1 + opts(legend.position = "none"), vp = vp1)
upViewport(0)
pushViewport(vpleg)
grid.draw(legend)
#Make the new viewport active and draw
upViewport(0)
pushViewport(subvp)
grid.draw(mytable)

#print(plt1)

#Plot2: Wordcloud
#WORD_TOTALS<- apply(counts, 2, function(x) info$Year[which(x == max(x))[1]])
#TOTALS$YEARS <- t(t(WORD_TOTALS))[,1]
authors <- c("HAMILTON", "JAY", "MADISON")
word_group <- data.frame(WORDS = names(myData_count))
for (author in authors){
  papers <- myData_basic$PAPER_NAME[which(myData_basic$AUTHOR==author)]
  word_group[,author] <- t(t(colSums(myData_count[papers,])))
}
rownames(word_group)<- word_group$WORDS
word_group$WORDS <- NULL
word_group <- as.matrix(word_group)
comparison.cloud(word_group, scale=c(4,.5), title.size=2)

###################################
#Not Done

#Plot3: Lines Plot
lines <- data.frame(state=counts[,1695], power=counts[,1333],constitution=counts[,385],
                    world=counts[,1943], america=counts[,97], new=counts[,1207])
lines$Year <- info$Year
lines_melted <- melt(lines, id="Year")  # convert to long format

Type = character(0)
for (i in 1:length(lines_melted$variable)){
  if(lines_melted$variable[i] == "state"){Type <- cbind(Type, "Declined Use of Word")}
  if(lines_melted$variable[i] == "constitution"){Type <- cbind(Type, "Declined Use of Word")}
  if(lines_melted$variable[i] == "power"){Type <- cbind(Type, "Declined Use of Word")}
  if(lines_melted$variable[i] == "america"){Type <- cbind(Type, "Increased Use of Word")}
  if(lines_melted$variable[i] == "new"){Type <- cbind(Type, "Increased Use of Word")}
  if(lines_melted$variable[i] == "world"){Type <- cbind(Type, "Increased Use of Word")}
}
lines_melted$Type <- as.factor(Type[1,])

plt2 <- ggplot(data = lines_melted, aes(x=Year, y=value))
plt2 <- plt2 + geom_line(aes(group = variable, color = variable))
plt2 <- plt2 + facet_wrap(~Type, nrow = 2)
plt2 <- plt2 + ggtitle("Word Usage in Inaugural Speeches over the Years")
plt2 <- plt2 + xlab("Year") +  ylab("Count of Usage")
plt2 <- plt2 + labs(color="Word Used")
plt2 <- plt2 + scale_x_continuous(breaks = seq(1789,2009,20))
plt2 <- plt2 + scale_y_continuous(breaks = seq(0,60,10))
plt2 <- plt2 + theme(axis.title=element_text(size=12,face="bold"), title = element_text(size=18))
plt2 <- plt2 +theme(panel.background = element_rect(fill="grey60"))
#print(plt2)

#Plot4: Network Graph

plotg <- function(net, value=NULL) {
  m <- as.matrix.network.adjacency(net) # get sociomatrix
  # get coordinates from Fruchterman and Reingold's force-directed placement algorithm.
  plotcord <- data.frame(gplot.layout.fruchtermanreingold(m, NULL)) 
  # or get it them from Kamada-Kawai's algorithm: 
  # plotcord <- data.frame(gplot.layout.kamadakawai(m, NULL)) 
  colnames(plotcord) = c("X1","X2")
  edglist <- as.matrix.network.edgelist(net)
  edges <- data.frame(plotcord[edglist[,1],], plotcord[edglist[,2],])
  plotcord$elements <- as.factor(get.vertex.attribute(net, "elements"))
  colnames(edges) <-  c("X1","Y1","X2","Y2")
  edges$midX  <- (edges$X1 + edges$X2) / 2
  edges$midY  <- (edges$Y1 + edges$Y2) / 2
  pnet <- ggplot()  + 
    geom_segment(aes(x=X1, y=Y1, xend = X2, yend = Y2), 
                 data=edges, size = 0.5, colour="grey") +
    geom_point(aes(X1, X2,colour=elements), data=plotcord) +
    scale_colour_brewer(palette="Set1") +
    scale_x_continuous(breaks = NA) + scale_y_continuous(breaks = NA) +
    # discard default grid + titles in ggplot2 
    opts(panel.background = theme_blank()) + opts(legend.position="none")+
    opts(axis.title.x = theme_blank(), axis.title.y = theme_blank()) +
    opts( legend.background = theme_rect(colour = NA)) + 
    opts(panel.background = theme_rect(fill = "white", colour = NA)) + 
    opts(panel.grid.minor = theme_blank(), panel.grid.major = theme_blank())
  return(print(pnet))
}


g <- network(150, directed=FALSE, density=0.03)
classes <- rbinom(150,1,0.5) + rbinom(150,1,0.5) + rbinom(150,1,0.5)
set.vertex.attribute(g, "elements", classes)

plotg(g)


