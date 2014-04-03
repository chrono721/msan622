
library(ggplot2)
library(scales)

data(movies)

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

plot <- ggplot(data = movies, aes(x=budget/1000000, y=rating, color = mpaa)) + 
        ggtitle("Scatterplot: Ratings due to Movie Budget") +
        geom_point(na.rm = TRUE) +  xlab("Budget (in Millions)") +  
        ylab("Rating") +
        scale_x_continuous(labels = dollar) + 
        scale_y_continuous(breaks = seq(1,10,1)) + 
        theme(axis.title=element_text(size=14,face="bold")) + 
        theme(title = element_text(size=18)) +  
        theme(legend.position="bottom")
print(plot)


