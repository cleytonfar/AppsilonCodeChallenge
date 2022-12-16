# attaching packages:
library(shiny)
library(bs4Dash)
# sourcing utilities functions:
source("R/utils.R")
# sourcing modules:
source("R/speciesDataset.R")
source("R/mapFrequency.R")
source("R/timeline.R")

# header ----
myHeader = dashboardHeader(

)

# sidebar -----
mySidebar = dashboardSidebar(
    sidebarMenu(
        id = "sidebarmenu",
        menuItem(
            "Search",
            tabName = "search",
            icon = icon("search")
        )
    )
)

# body ----
myBody = dashboardBody(
    tags$style("body { background-color: ghostwhite}"),
    tabItems(
        tabItem(
            tabName = "search",
            fluidRow(
                box(width = 4,
                    title = "Search the Species",
                    speciesDatasetInput("speciesSet")
                ),
                box(width = 8,
                    timelineUI("timelinePlt")
                )
            ),
            fluidRow(
                box(width = 12,
                    title = "Where were the species observed?",
                    mapFrequencyUI("mapPlt")
                )
            )
        )
    )
)

myControlbar = dashboardControlbar()
myFooter = dashboardFooter()

ui = dashboardPage(
    header = myHeader,
    sidebar = mySidebar,
    controlbar = myControlbar,
    body = myBody,
    footer = myFooter
)

server = function(input, output, session){
    # get Data:
    out = speciesDatasetServer(id = "speciesSet")
    # timeline:
    timelineServer(
        id = "timelinePlt", 
        dataset = out$dataset,
        vernacular_nm = out$vernacular_nm,
        scientific_nm = out$scientific_nm
    )
    # map:
    mapFrequencyServer(
        id = "mapPlt", 
        dataset = out$dataset
    )
}

shinyApp(ui, server)
