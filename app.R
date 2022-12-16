# attaching packages:
library(shiny)
library(bs4Dash)
library(waiter)
# sourcing utilities functions:
source("R/utils.R")
# sourcing modules:
source("R/speciesDataset.R")
source("R/mapFrequency.R")
source("R/timeline.R")

# header ----
myHeader = dashboardHeader(
    title = tags$li(a(href = 'https://appsilon.com/',
              img(src = 'logo_appsilon.svg',
                  title = "Code Challenge", height = "50px"),
              style = "padding-top:5px; padding-bottom:5px;"),
            class = "dropdown")
)

# sidebar -----
mySidebar = dashboardSidebar(
    width = 4,
    collapsed = F,
    sidebarMenu(
        id = "sidebarId",
        menuItem(
            "Search",
            tabName = "searchSpecies",
            icon = icon("search", verify_fa = F)
        )
    )
)

# body ----
myBody = dashboardBody(
    tags$style("body { background-color: ghostwhite}"),
    tabItems(
        tabItem(
            tabName = "searchSpecies",
            fluidRow(
                box(width = 3, collapsed = T,
                    title = "Looking for a particular Species?",
                    speciesDatasetInput("speciesSet")
                    )
            ),
            fluidRow(
                box(width = 6,
                    title = "Where were the species observed?",
                    mapFrequencyUI("mapPlt")
                ),
                box(width = 6,
                    timelineUI("timelinePlt")
                )
            )
        )
    )
)


ui = dashboardPage(
    preloader = list(html = tagList(spin_3(), "Loading ..."), color = "#3c8dbc"),
    header = myHeader,
    sidebar = mySidebar,
    body = myBody
)

server = function(input, output, session){
    # get Data:
    out = speciesDatasetServer(id = "speciesSet")
    # timeline:
    timelineServer(
        id = "timelinePlt", 
        dataset = out$dataset,
        species_nm = out$species_nm
    )
    # map:
    mapFrequencyServer(
        id = "mapPlt", 
        dataset = out$dataset, 
        species_nm = out$species_nm
    )
}


shinyApp(ui, server)

