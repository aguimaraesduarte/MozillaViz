#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(D3partitionR)
library(jsonlite)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  navbarPage("MozillaViz",
             tabPanel("Firefox Versions Map", includeHTML("index.html")),
             navbarMenu("Firefox OS Maps",
                        tabPanel("Circle Tree Map", D3partitionROutput("circleTreeMap", width = "100%")),
                        tabPanel("Sunburst", D3partitionROutput("sunburst", width = "100%")),
                        tabPanel("Partition Chart", D3partitionROutput("partitionChart", width = "100%")),
                        tabPanel("Tree Map", D3partitionROutput("treeMap", width = "100%")),
                        tabPanel("Collapsible Tree", D3partitionROutput("collapsibleTree", width = "100%"))
             ),
             footer = "Built by Connor Ameres, Andre Duarte",
             inverse = T
  )
  
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
   
  os2 <- fromJSON("os2.json", simplifyDataFrame = T)
  os2 <- subset(os2, sd == "2016-09")
  os2$path_str <- paste(paste("World", os2$country, os2$city, os2$os, os2$os_version, sep = "/"))
  os2$path <- strsplit(os2$path_str, "/")
  os2$cnt <- round(os2$cnt/sum(os2$cnt)*100, 3)
  
  output$circleTreeMap <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "circleTreeMap",
                 trail = T)
  })
  
  output$partitionChart <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "partitionChart",
                 trail = T)
  })
  
  output$treeMap <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "treeMap",
                 trail = T)
  })
  
  output$sunburst <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "sunburst",
                 trail = T)
  })
  
  output$collapsibleTree <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "collapsibleTree",
                 trail = T,
                 specificOptions = list(bar=T))
  })
}

addResourcePath('static', '.')

# Run the application 
shinyApp(ui = ui, server = server)

