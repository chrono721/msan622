
library(shiny)

#setwd("C:/Users/Charles/Desktop")
#TO CREATE
#groupMPAA
#colorScheme
#groupAction, groupAnimation, ...
#dotsize
#dotalpha
#
#

shinyUI(
  fluidPage(  
    titlePanel("IMDB Movie Ratings"),
    
    sidebarPanel(width = 2,
      radioButtons("groupMPAA", "MPAA Rating:",
        c("All", "PG", "PG-13", "NC-17", "R", "No Rating")),
      br(),
      checkboxGroupInput("GroupGenre", "Movie Genre:",
                         choices = list("Action" = 1, "Animation" = 2, "Comedy" = 3, "Drama"=4, "Documentary"=5, "Romance"=6, "Short"=7))
      #br(),
      
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Scatterplot",
                 fluidRow(plotOutput("scatterPlot")),
                 hr(),
                 h3("Plot Settings:"),
                 fluidRow(
                   column(3,offset = 1,
                    selectInput("colorScheme", "Color Scheme:", 
                               choices = c("Default", "Accent", "Set1", "Set2","Set3", "Dark2", "Pastel1", "Pastel2", "None")),
                    selectInput("pointShape", "Shape of Dots:", 
                               choices = c("Circle", "Triangle", "Diamond", "Square","X", "Star", "Target", "Plus"))
                    ),
                   column(6,offset = 1,
                    sliderInput("dotsize", "Dot Size:", min=1, max=10, value=3),
                    sliderInput("dotalpha", "Dot alpha:", min=0.1, max=1.0, value=0.5),
                    br(),
                    sliderInput("xaxis_lim", "X-Axis Limits:", min=0, max=200, value=c(0,200)),
                    sliderInput("yaxis_lim", "Y-Axis Limits:", min=1, max=10, value=c(1,10)))
                   ),
                 br(),
                 br(),
                 br(),
                 br(),
                 br()
                 ),
        
        tabPanel("Summary of Data", 
                 p("Below contains a summary of all the data that is SHOWN in the Scatter Plot."),
                 p("These values are likely to change if you change the options."), 
                 br(),
                 fluidRow(
                   column(7,
                    h3("NUMERIC DATA"),
                    tableOutput("table_numeric")),
                   column(4,
                    h3("FACTOR DATA"),
                    tableOutput("table_factor"))
                 )
        )
      )
    )
  )  
)

#runApp()

