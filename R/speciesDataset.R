# Attaching packages:
library(shiny)
library(arrow)
library(dplyr)
source("R/utils.R")

# Species Dataset module:
speciesDatasetInput <- function(id) {
    ns = NS(id)
    tagList(
        # vernacuar names:
        selectizeInput(
            inputId = ns("species_nm"),
            label = "Species Name",
            choices = NULL,
            multiple = F,
            options = list(maxOptions = 50)
        )
    )
}

# Server
speciesDatasetServer <- function(id) {
    # data source
    src = open_dataset("data/occurrence/country=Poland/")
    moduleServer(
        id,
        function(input, output, session) {
            observe({
                # vernacular names:
                vernacular_nms = src %>% 
                    filter(vernacularName != "") %>% 
                    distinct(vernacularName) %>%
                    pull(vernacularName)
                # scientficic names
                scientific_nms = src %>%
                    filter(scientificName != "") %>% 
                    pull(scientificName)
                nms = unique(vernacular_nms, scientific_nms)
                # update name list:
                updateSelectizeInput(
                    session, 
                    inputId = 'species_nm',
                    choices = nms,
                    selected = character(0),
                    server = T
                )
            })
            
            # getting the dataset for the selected species:
            dataset = reactive({
                #req(input$country_nm != "" & input$scientific_nm != "")
                getSpeciesData(
                    src = src,
                    species_nm = input$species_nm
                )
            })
            
            # return list of reactives:
            list(
                dataset = dataset,
                species_nm = reactive(input$species_nm)
            )
        }
    )
}

speciesApp <- function(){
    # UI:
    ui = fluidPage(
        theme = bslib::bs_theme(version = '5'),
        sidebarLayout(
            sidebarPanel(
                speciesDatasetInput("id1")
            ),
            mainPanel(
                DT::DTOutput("out")
            )
        )
    )
    # Server
    server = function(input, output, session) {
        out = speciesDatasetServer("id1")
        output$out = DT::renderDT({
            out$dataset()
        })
    }
    # App
    shinyApp(ui, server)
}

# run if interactive
if ( interactive() ) {
    speciesApp()
}
