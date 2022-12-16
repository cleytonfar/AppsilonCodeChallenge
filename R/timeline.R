library(shiny)
library(highcharter)
library(ggplot2)


timelineUI <- function(id) {
    ns = NS(id)
    tagList(
        highchartOutput(outputId = ns("timeline"))
    )
}

timelineServer = function(id, dataset, vernacular_nm, scientific_nm,
                          minYears = 5, type = "highchart") {
    # stop execution if not reactive
    stopifnot(is.reactive(dataset))
    stopifnot(is.reactive(vernacular_nm))
    stopifnot(is.reactive(scientific_nm))
    
    moduleServer(
        id,
        function(input, output, session) {
            # plot timeline:
            output$timeline = renderHighchart({
                req( nrow(dataset()) > 0 )
                plotTimeline(
                    dataset = dataset(),
                    vernacular_nm = vernacular_nm(),
                    scientific_nm = scientific_nm()
                )
            })
            
        }
    )
}

# test app:
if ( interactive() ) {
    timelineApp <- function() {
        library(shiny)
        source("R/utils.R")
        source("R/speciesDataset.R")
        
        ui = fluidPage(
            theme = bslib::bs_theme(version = "5"),
            sidebarLayout(
                sidebarPanel(
                    speciesDatasetInput("id1")
                ),
                mainPanel(
                    timelineUI("id2")
                )
            )
        )
        
        server = function(input, output, session) {
            out = speciesDatasetServer("id1")
            timelineServer(
                id = "id2", 
                dataset = out$dataset, 
                vernacular_nm = out$vernacular_nm,
                scientific_nm = out$scientific_nm
            )
        }
        
        shinyApp(ui, server)
    }
    timelineApp()
}
