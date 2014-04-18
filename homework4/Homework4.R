
library(ggplot2)
library(wordcloud)
require("reshape")

#setwd("C:/Users/Charles/Desktop/Inaugural/")
dir <- getwd()
setwd(dir)

#Load in the Data
info <- read.csv("info.csv")
counts <- read.csv("counts.csv")
tfidf <- read.csv("tfidf.csv")
pos <- read.csv("word.csv")

#Create a dataframe with counts and maxtfidfs
TOTALS <- data.frame(colSums(counts))
TOTALS <- cbind(TOTALS, max(tfidf))
TOTALS$WORDS <- rownames(TOTALS)
TOTALS$POS <- pos$POS
names(TOTALS) <- c("Sum_Counts", "Max_TFIDF", "WORDS", "POS")

#Be Able to subset by president, year and pos
counts$Year <- info$Year
counts$President <- info$President
tfidf$Year <- info$Year
tfidf$President <- info$President

#Analysis
analysis <- data.frame(colSums(counts[1:28,]))
analysis$upper <- colSums(counts[29:56,])
names(analysis) <- c("lower", "upper")
analysis$diff <- analysis$lower - analysis$upper
#1695, 837, 385, 1333 less use
#1943, 1842, 97, 1207  more use

#Plot 1 - lines
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

plt1 <- ggplot(data = lines_melted, aes(x=Year, y=value))
plt1 <- plt1 + geom_line(aes(group = variable, color = variable))
plt1 <- plt1 + facet_wrap(~Type, nrow = 2)
plt1 <- plt1 + ggtitle("Word Usage in Inaugural Speeches over the Years")
plt1 <- plt1 + xlab("Year") +  ylab("Count of Usage")
plt1 <- plt1 + labs(color="Word Used")
plt1 <- plt1 + scale_x_continuous(breaks = seq(1789,2009,20))
plt1 <- plt1 + scale_y_continuous(breaks = seq(0,60,10))
plt1 <- plt1 + theme(axis.title=element_text(size=12,face="bold"), title = element_text(size=18))
plt1 <- plt1 +theme(panel.background = element_rect(fill="grey60"))
#print(plt1)

plot1_save <- paste(dir, "HW4_timeseries.png", sep = "/")
ggsave(filename = plot1_save, plot = plt1, dpi = 72)

#Plot 2 - Barplot for type of word

POS_SUMS<- aggregate(TOTALS$Sum_Counts, by=list(Category=TOTALS$POS), FUN=sum)
POS_SUMS <- POS_SUMS[ order(-POS_SUMS[,2]), ]
rownames(POS_SUMS)<- c(1:8)
POS_SUMS$Category <- factor(POS_SUMS$Category, levels = POS_SUMS$Category)

plt2 <- ggplot(data = POS_SUMS)
plt2 <- plt2 + geom_bar(aes(x=Category, y=x, fill = Category), stat = "identity")
plt2 <- plt2 + ggtitle("POS Usage in all Inaugural Speeches")
plt2 <- plt2 + xlab("Part of Speech (POS)") +  ylab("Total Counts")
plt2 <- plt2 + labs(fill="POS", color = element_blank())
plt2 <- plt2 + scale_y_discrete(breaks = seq(0,35000,5000), expand = c(0.01, 0.5))
plt2 <- plt2 + theme(axis.title=element_text(size=12,face="bold"), title = element_text(size=18))
plt2 <- plt2 + guides(fill=FALSE)
#print(plt2)

plot2_save <- paste(dir, "HW4_barplot.png", sep = "/")
ggsave(filename = plot2_save, plot = plt2, dpi = 72)


#Plot 3 - Heatmap of word type usage

adjective <- TOTALS$WORDS[which(TOTALS$POS == "adjective")]
adverb <- TOTALS$WORDS[which(TOTALS$POS == "adverb")]
noun <- TOTALS$WORDS[which(TOTALS$POS == "noun"|TOTALS$POS == "noun_plural")]
preposition <- TOTALS$WORDS[which(TOTALS$POS == "preposition")]
verb <- TOTALS$WORDS[which(TOTALS$POS == "verb"|TOTALS$POS == "verb_past")]

adjective_sums <- rowSums(counts[,which(names(counts) %in% adjective)]) 
adverb_sums <- rowSums(counts[,which(names(counts) %in% adverb)])
noun_sums <- rowSums(counts[,which(names(counts) %in% noun)])
verb_sums <- rowSums(counts[,which(names(counts) %in% verb)])

adjective_sums <- adjective_sums/sum(adjective_sums)
adverb_sums <- adverb_sums/sum(adverb_sums)
noun_sums <- noun_sums/sum(noun_sums)
verb_sums <- verb_sums/sum(verb_sums)

sums <- data.frame(adjective_sums,adverb_sums,noun_sums,verb_sums)
sums$Year <- info$Year

sums_melted <- melt(sums, id="Year")
palette <- c("#008837", "#f7f7f7", "#f7f7f7", "#7b3294")

plt3 <- ggplot(data = sums_melted, aes(x = Year, y=variable, fill =value))
plt3 <- plt3 + geom_tile()
plt3 <- plt3 + theme_minimal()
plt3 <- plt3 + theme(axis.ticks = element_blank())
plt3 <- plt3 + theme(panel.grid = element_blank())
plt3 <- plt3 + ggtitle("Percentage of POS in Inaugural Speeches over the Years")
plt3 <- plt3 + xlab("Year") +  ylab("Part of Speech (POS)")
plt3 <- plt3 + labs(fill="% Use")
plt3 <- plt3 + scale_x_continuous(breaks = seq(1789,2009,20))
plt3 <- plt3 + scale_fill_gradientn(colours = palette, values = c(0,0.4,0.6, 1))
plt3 <- plt3 + theme(axis.title=element_text(size=12,face="bold"), title = element_text(size=18))
#print(plt3)

plot3_save <- paste(dir, "HW4_heatmap.png", sep = "/")
ggsave(filename = plot3_save, plot = plt3, dpi = 72)


#PLOT 4 - Word Cloud

WORD_TOTALS<- apply(counts, 2, function(x) info$Year[which(x == max(x))[1]])
TOTALS$YEARS <- t(t(WORD_TOTALS))[,1]
presidents <- seq(1,56,9)
word_group <- data.frame(t(counts[presidents,]))
names(word_group) <- info$President[presidents]
word_group <- as.matrix(word_group)

comparison.cloud(word_group, scale=c(4,.5), title.size=2)



