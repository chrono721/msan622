
library(shiny)

#setwd("C:/Users/Charles/Desktop")

shinyUI(
  fluidPage(
    titlePanel("An Overview of the Federalist Papers"),
    
    fluidRow(
      column(width = 3,
             #Information Page
             conditionalPanel(
               condition="input.conditionedPanels==0",
               wellPanel(
                 helpText("What you see to the side is a table containing
                          the basic information based on the Federalist Papers that 
                          were used in the plots."),
                 helpText("Since the application only refers to the Federist Paper numbers, 
                          the table will provide a much easier way to know more details what 
                          papers you are choosing."),
                 helpText("** Please also note that not all 85 Federalist papers were used.")
               )
             ),
             #BARPLOT UI OPTIONS
             conditionalPanel(
               condition="input.conditionedPanels==1",
               wellPanel(
                 radioButtons("barType", "Sort By:", c("Most Frequent", "Highest TF-IDF"), selected="Most Frequent"),
                 sliderInput("barFreq", "Number of Words:", min=1, max=8, value=5),
                 checkboxInput("frametype", label = "Include Stopwords?", value = FALSE)
                 )
               ),
             #WORDCLOUD UI OPTIONS
             conditionalPanel(
               condition="input.conditionedPanels==2",
               wellPanel(
                 radioButtons("cloudAuthor", "Authors to Include:", c("ALL","HAMILTON & MADISON", "HAMILTON & UNKNOWN", "MADISON & UNKNOWN"), selected="ALL"),
                 radioButtons("cloudType", "Word Size Based On:", c("Word Count", "TF-IDF"), selected="Word Count"),
                 radioButtons("cloudOption", "Type of Cloud:", c("Comparison", "Overall"), selected="Comparison"),
                 checkboxInput("frametype", label = "Include Stopwords?", value = FALSE)
               )
             ),
             #LINE MULTIPLES UI OPTIONS
             conditionalPanel(
               condition="input.conditionedPanels==3",
               wellPanel(
                 dateRangeInput("lineDates", "Date of Publish", start=as.Date("1787-10-27"), min =as.Date("1787-10-27"),
                                end = as.Date("1788-08-13"), max = as.Date("1788-08-13"), format = "M-d-yyyy"),
                 sliderInput("lineFreq", "Number of Words:", min=2, max=5, value=3),
                 radioButtons("lineAuthor", "Author to Look At:", 
                              c("ALL","HAMILTON", "MADISON", "UNKNOWN"), selected="ALL"),
                 checkboxInput("frametype", label = "Include Stopwords?", value = FALSE), 
                 helpText("*Note: The top half of the words in the legend refer to the top plot
                          while the bottom half of the words in the legend refer to the bottom plot.")
                 )
             ),
             #NETWORK UI OPTIONS
             conditionalPanel(
               condition="input.conditionedPanels==4",
               wellPanel(
                 selectInput("networkLink", "Words Linked By:", 
                             choices = c("and", "to", "for", "of", "from"), selected = "and"),
                 sliderInput("networkNodes", "Size of Network:", min=5, max=30, value=10),
                 br(),
                 helpText("Please Note: If chosen to create network by Degree, the size will be determined by number of nodes. 
                          If chosen to create network by Edge Counts, the size will be based on the top number of sorted edges."),
                 selectInput('networkDraw','Network Display:', 
                             c("Highest Edge Counts", "Highest Overall Degree")),
                 radioButtons("networkAuthor", "Authors To Network:",
                              choices = c("MADISON", "HAMILTON", "UNKNOWN", "ALL"), selected = "ALL")
               )
             ),
             br(),
             conditionalPanel(
               condition = "(input.conditionedPanels==0 || input.conditionedPanels == 1 || input.conditionedPanels == 2)",
               helpText("\n Use this to select specific papers",
                        "written by specific authors.\n",
                        "Blank entries will default to all papers.\n"),
               selectInput('itemHAM','Papers Written By HAMILTON: ', HAM_Paper_List, multiple=T),
               selectInput('itemMAD','Papers Written By MADISON: ', MAD_Paper_List, multiple=T),
               selectInput('itemUNK','Papers Written By UNKNOWN AUTHOR: ', UNK_Paper_List, multiple=T)
             )
           ),
    
      column(width = 9,
        tabsetPanel(
          tabPanel("About the Federalist Papers", value=0,
                   dataTableOutput('infoTable')
          ),
          tabPanel("Break Down of Words", value=1,
                   plotOutput('Bar')
                ),
          tabPanel("Comparing the Words",value=2,
                   plotOutput('Cloud')
                ),
          tabPanel("Usage of Words",value=3,
                   plotOutput('Line')
                ),
          tabPanel("Phrase Net", value=4,
                   column(width = 8, plotOutput('Network')),
                   column(width = 4, tableOutput('NetworkTable'))                 
                 ),
          id="conditionedPanels"
      )
    )
    )
  )
)




