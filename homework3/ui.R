library(shiny)

#setwd("C:/Users/Charles/Desktop/")

shinyUI(
  fluidPage(
    titlePanel("STATES DATA"),
    mainPanel(width = 12,
      tabsetPanel(
        tabPanel("Bubble Plot",plotOutput("bubblePlot")),
        tabPanel("Small Multiples Plot",plotOutput("scatterMatrix")),
        tabPanel("Parallel Coordinates Plot",
                 sidebarPanel(width = 3,
                              checkboxGroupInput("titles_selected","Select at least 2 Coordinates",
                                                 choices = list("Population"=1, "Income"=2 , "Illiteracy"=3, "Life Expectancy"=4,"Murder Rate"=5,"High-School Grad Rate"=6,
                                                                "Frost"=7, "Area"=8))),
                 mainPanel(plotOutput("parCoords"))
        ),
        tabPanel("Heat Map Plot", plotOutput("heatMap"))
      )
    ),
    sidebarPanel(width = 3,
      radioButtons("intensityvar", "HEAT/SIZE:",
                   c("Population", "Income", "Illiteracy", "Life Expectancy", "Murder Rate", 
                     "HS Grad Rate", "Area"),selected = "Murder Rate"),
      selectInput("colorScheme2", "Heat Schemes:", 
                  choices = c("Blues", "Greens", "Oranges", "Putples","Reds", "RdGy","RdBu","PRGn"))
    ),
    sidebarPanel(width = 3,
      selectInput("xplotvar", "X-axis Var:", 
                  choices = c("Population", "Income", "Illiteracy", "Life Expectancy", "Murder Rate", 
                              "HS Grad Rate", "Area"), selected = "Illiteracy"), 
      selectInput("yplotvar", "Y-axis Var:", 
                  choices = c("Population", "Income", "Illiteracy", "Life Expectancy", "Murder Rate", 
                              "HS Grad Rate", "Area"), selected = "Income"),
      radioButtons("grouping", "Color By:",c("Region", "Division","None"))
    ),
    sidebarPanel(width = 3,
      checkboxGroupInput("groupLocation", "Subset by Region and Division:",
                         choices = list("Northeast: New England" = 1, 
                                        "Northeast: Middle Atlantic" = 2, 
                                        "North Central: East Side" = 3, 
                                        "North Central: West Side" = 4,
                                        "South: South Atlantic" = 5,
                                        "South: East South Atlantic" = 6,
                                        "South: West South Central" = 7,
                                        "West: Pacific" = 8,
                                        "West: Mountain" = 9))
      ),
    sidebarPanel(width = 3,
      selectInput("colorScheme", "Color Scheme:", 
                  choices = c("Default", "Accent", "Set1", "Set2","Set3", "Dark2", "Pastel1", "Pastel2", "None")),
      selectInput("pointShape", "Shape of Dots:", 
                  choices = c("Circle", "Triangle", "Diamond", "Square")),
      sliderInput("dotsize", "Dot Size:", min=5, max=25, value=10),
      sliderInput("dotalpha", "Dot alpha:", min=0.1, max=1.0, value=0.8)
      
    )
  )
)











