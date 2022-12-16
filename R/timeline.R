library(shiny)
library(highcharter)
library(ggplot2)


timelineUI <- function(id) {
    ns = NS(id)
    tagList(
        highchartOutput(outputId = ns("timeline"))
    )
}

timelineServer = function(id, dataset, species_nm,
                          minYears = 5, type = "highchart") {
    # stop execution if not reactive
    stopifnot(is.reactive(dataset))
    stopifnot(is.reactive(species_nm))
    
    moduleServer(
        id,
        function(input, output, session) {
            # plot timeline:
            output$timeline = renderHighchart({
                req( nrow(dataset()) > 0 )
                plotTimeline(
                    dataset = dataset(),
                    species_nm = species_nm(),
                    type = type
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
                species_nm = out$species_nm
            )
        }
        
        shinyApp(ui, server)
    }
    timelineApp()
}
