
library(shiny)

#setwd("C:/Users/Charles/Desktop")

shinyUI(
  fluidPage(
    titlePanel("An Overview of the Federalist Papers"),
    
    sidebarPanel(width = 3,
                 sliderInput("fedPaper", "Range of Federalist Papers:", min=1, max=85, value=c(5,13)),
                 selectInput("colorScheme", "Color Scheme:", 
                             choices = c("Default", "Accent", "Set1", "Set2","Set3", "Dark2", "Pastel1", "Pastel2", "None"))
                 ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Bar Multiples",
                  fluidRow(
                   column(4,offset = 2,
                          radioButtons("barType", "Sort By:", c("Most Frequent", "Least Frequent", "Highest TF-IDF", "LOWEST TF-IDF"), selected="Most Frequent")
                          ),
                   column(4,
                          sliderInput("barFreq", "Number of Words:", min=1, max=10, value=5)
                   ) 
                  )
                ),
        tabPanel("Cloud",
                 fluidRow(
                   column(4,offset = 2,
                          checkboxGroupInput("cloudAuthor", "Authors to Compare:",
                                             choices = list("MADISON" = 1, "HAMILTON" = 2, "JAY" = 3, "UNKNOWN"=4))
                   ),
                   column(4,
                          radioButtons("cloudType", "Word Size Based On:", c("Word Count", "TF-IDF"), selected="Word Count")
                   )
                  )
                ),
        tabPanel("Lines",
                 fluidRow(
                   column(4,
                          dateRangeInput("lineDates", "Date of Publish", start=as.Date("1787-10-27"), min =as.Date("1787-10-27"),
                                         end = as.Date("1788-08-13"), max = as.Date("1788-08-13"), format = "M-d-yyyy")
                   ),
                   column(3,
                          sliderInput("lineFreq", "Number of Words:", min=1, max=10, value=3)
                   ),
                   column(3,
                          checkboxGroupInput("lineAuthor", "Authors to Compare:",
                                             choices = list("MADISON" = 1, "HAMILTON" = 2, "JAY" = 3, "UNKNOWN"=4))
                   ),
                   column(2,
                          radioButtons("lineFacet", "Compare:", c("Separately", "Same Plot"), selected="Separately")
                          )
                 )
                ),
        tabPanel("Network", 
                  fluidRow(
                    column(2,
                           selectInput("networkLink", "Words Linked By:", 
                                       choices = c("and", "to", "for", "of", "from"), selected = "and")
                   ),
                    column(5, offset = 1,
                           sliderInput("networkNodes", "Maximum Number of Nodes:", min=5, max=30, value=10)
                    ),
                   column(3, offset = 1,
                          radioButtons("networkAuthor", "Authors To Network:",
                                             choices = c("MADISON", "HAMILTON", "JAY", "UNKNOWN", "ALL"), selected = "ALL")
                   )
                  )
                 )
      )
    )
  )
)




