
library(shiny)

#setwd("C:/Users/Charles/Desktop/")

shinyUI(
  fluidPage(
    titlePanel("UK Driver Data"),
    sidebarPanel(width = 3, 
                 dateInput("XzoomStart", "Start Date", value = "1969-01-01", format = "M-yyyy", min = "1969-01-01", max = "1984-12-01", startview = "month"),
                 dateInput("XzoomEnd", "End Date", value = "1984-12-01", format = "M-yyyy", min = "1969-01-01", max = "1984-12-01", startview = "month"),
                 checkboxInput("law", label = "Law Enacted (Jan-1983)", value = TRUE)
                 ),
    mainPanel(width = 9,
      tabsetPanel(
        tabPanel("Line Plot: Rising Kms", 
                 fluidRow(
                   column(6,offset = 3,
                    sliderInput("petrolSlide", "Petrol Price Above:", min=0.08, max=0.14, value=0.13)
                   )
                 ),
                 br(),
                 plotOutput("LinePlot")),
        tabPanel("Stacked Area: Number of Deaths", 
                 fluidRow(
                   column(6,offset = 3,
                    radioButtons("areaType", "Type of Plot:", c("Area", "Percent"), selected="Area")
                   ) 
                 ),
                 br(),
                 plotOutput("StackedArea")),
        tabPanel("Heat Map: Percent of Deaths", 
                 fluidRow(
                   column(4,offset = 1,
                    radioButtons("heatType", "Type of Coloring Scheme:", c("Contrasting", "Single Color"), selected="Contrasting")
                   ),
                   column(4,offset = 2,
                    selectInput("colorScheme", "Color Scheme:", choices = c("ColorScheme1","ColorScheme2","ColorScheme3","ColorScheme4"))
                   )
                 ), 
                 br(),
                 plotOutput("HeatMap"))
      )
    )
  )
)


