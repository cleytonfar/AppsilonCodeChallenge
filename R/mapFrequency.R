library(shiny)
library(leaflet)

mapFrequencyUI = function(id) {
    ns = NS(id)
    tagList(
        leafletOutput(outputId = ns('map'))
    )
}

mapFrequencyServer <- function(id, dataset, species_nm) {
    # stop execution if not reactive
    stopifnot(is.reactive(dataset))
    stopifnot(is.reactive(species_nm))

    moduleServer(
        id,
        function(input, output, session) {
            output$map = 
            renderLeaflet({
                # require nrow > 0:
                req(nrow(dataset()) > 0)
                if ( species_nm() == "" ) {
                    getFreq_byLocation_default(dataset()) %>% 
                        plotFreqMap_default()
                } else {
                    getFreq_byLocation(dataset()) %>% 
                        plotFreqMap()
                }
            })
        }
    )
}


mapFrequencyApp <- function() {
    # sourcing speciesDataset module:
    source("R/speciesDataset.R")
    # UI:
    ui = fluidPage(
        theme = bslib::bs_theme(version = "5"),
        sidebarLayout(
            sidebarPanel(
                speciesDatasetInput("id1")
            ),
            mainPanel(
                mapFrequencyUI("id2")
            )
        )
    )
    # Server
    server = function(input, output, session) {
        out = speciesDatasetServer("id1")
        mapFrequencyServer(
            id = "id2", 
            dataset = out$dataset, 
            species_nm = out$species_nm
        )
    }
    
    shinyApp(ui, server)
}

# run if interactive
if( interactive() ) {
    mapFrequencyApp()
}
