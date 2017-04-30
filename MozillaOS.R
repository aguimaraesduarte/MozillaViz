library(shiny)
library(D3partitionR)
library(jsonlite)

ui <- fluidPage(
  titlePanel("MozillaViz - OS distribution per country"),
  
  htmlOutput("header"),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Circle Tree Map", D3partitionROutput("circleTreeMap", width = "100%"), value = 1),
      tabPanel("Sunburst", D3partitionROutput("sunburst", width = "100%"), value = 2),
      tabPanel("Partition Chart", D3partitionROutput("partitionChart", width = "100%"), value = 3),
      tabPanel("Tree Map", D3partitionROutput("treeMap", width = "100%"), value = 4),
      tabPanel("Collapsible Tree", D3partitionROutput("collapsibleTree", width = "100%"), value = 5)
    )
  ),
  
  sidebarPanel(htmlOutput("info"))
  
)

server <- function(input, output, session) {
  
  output$header <- renderUI({
    HTML(
      paste0("<h3>Select the type of visualization you wish to see from the tabs below.</h3>")
    )
  })
  
  output$info <- renderUI({
    HTML(
      paste0(
        '<h4>Info</h4>
        <ul>
        <li>Each partition size is proportional to the importance of that subset relative to the larger ones;</li>
        <li>All sub-partition within a larger one add up to 100%;</li>
        <li>For each partition, we have the relative importance as a whole ("from the beginning") and with respect to the parent ("from previous step").</li>
        </ul>',
        '<br><br><br>',
        'This is a proof of concept of different visualizations. We hand-selected some countries in Europe, but this analysis could be done with any city in the world that has Firefox users.',
        '<br><br><br>',
        'Authors: Connor Ameres, Andre Duarte'
      )
    )
  })
  
  os2 <- fromJSON("os2.json", simplifyDataFrame = T)
  os2 <- subset(os2, sd == "2016-09")
  os2$path_str <- paste(paste("World", os2$country, os2$city, os2$os, os2$os_version, sep = "/"))
  os2$path <- strsplit(os2$path_str, "/")
  os2$cnt <- round(os2$cnt/sum(os2$cnt)*100, 3)
  
  output$circleTreeMap <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "circleTreeMap")
  })
  
  output$partitionChart <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "partitionChart")
  })
  
  output$treeMap <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "treeMap")
  })
  
  output$sunburst <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "sunburst")
  })
  
  output$collapsibleTree <- renderD3partitionR({
    D3partitionR(data=list(path=os2$path, value=os2$cnt),
                 type = "collapsibleTree")
  })
  
}

shinyApp(ui = ui, server = server)
