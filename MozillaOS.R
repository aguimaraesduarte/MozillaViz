library(shiny)
library(D3partitionR)
library(jsonlite)

ui <- fluidPage(
  titlePanel("MozillaViz - OS distribution per country"),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Circle Tree Map", D3partitionROutput("circleTreeMap", width = "100%")),
      tabPanel("Sunburst", D3partitionROutput("sunburst", width = "100%")),
      tabPanel("Partition Chart", D3partitionROutput("partitionChart", width = "100%")),
      tabPanel("Tree Map", D3partitionROutput("treeMap", width = "100%")),
      tabPanel("Collapsible Tree", D3partitionROutput("collapsibleTree", width = "100%"))
    )
  )
)

server <- function(input, output, session) {
  
  os2 <- fromJSON("os2.json", simplifyDataFrame = T)
  os2 <- subset(os2, sd == "2016-09")
  os2$path_str <- paste(paste("World", os2$country, os2$city, os2$os, os2$os_version, sep = "/"))
  os2$path <- strsplit(os2$path_str, "/")
  
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
