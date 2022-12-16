# Attaching packages:
library(shiny)
library(dqshiny)
library(arrow)
library(dplyr)
source("R/utils.R")

# list of country names:
country_nms = open_dataset("data/occurrence/") %>% 
    distinct(country) %>%
    pull(country)

# Species Dataset module:
speciesDatasetInput <- function(id) {
    ns = NS(id)
    tagList(
        # country names:
        selectizeInput(
            inputId = ns("country_nm"),
            label = "Country Name",
            choices = country_nms,
            selected = "Poland", 
            multiple = F
        ),
        # vernacuar names:
        selectizeInput(
            inputId = ns("vernacular_nm"),
            label = "Vernacular Name",
            choices = NULL,
            multiple = F
        ),
        # scientific names:
        selectizeInput(
            inputId = ns("scientific_nm"), 
            label = "Scientific Name", 
            choices = NULL, 
            multiple = F
        )
    )
}

# Server
speciesDatasetServer <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            # update vernacular name according to country:
            observeEvent(input$country_nm, {
                # getting vernacular names for the "country_nm" provided
                vernacularNms = open_dataset("data/occurrence/") %>% 
                    filter(country == input$country_nm) %>% 
                    distinct(vernacularName) %>% 
                    filter(!is.na(vernacularName) ) %>% 
                    collect()
                # update vernacular options:
                updateSelectizeInput(
                    session,
                    inputId = "vernacular_nm",
                    choices = vernacularNms$vernacularName, 
                    server = T, ## using server = TRUE to use R process for searching
                    selected = character(0)
                )
            })
            # update scientific name according to country and vernacular:
            observeEvent(input$vernacular_nm, {
                # getting scientific names for the "country_nm" and 
                # "vernacular_nm" provided
                scientificNms = open_dataset("data/occurrence/") %>% 
                    filter(country == input$country_nm & vernacularName == input$vernacular_nm) %>% 
                    distinct(scientificName) %>% 
                    filter(!is.na(scientificName) ) %>% 
                    collect()
                # update scientfic options:
                updateSelectizeInput(
                    session,
                    inputId = "scientific_nm",
                    choices = scientificNms$scientificName, 
                    server = T, ## using server = TRUE to use R process for searching
                    selected = character(0)
                )
            })
            
            # getting the dataset for the selected species:
            dataset = reactive({
                #req(input$country_nm != "" & input$scientific_nm != "")
                getSpeciesData(
                    src = "data/occurrence/",
                    country_nm = input$country_nm,
                    vernacular_nm = input$vernacular_nm,
                    scientific_nm = input$scientific_nm
                )
            })
            
            # return list of reactives:
            list(
                dataset = dataset,
                vernacular_nm = reactive(input$vernacular_nm),
                scientific_nm = reactive(input$scientific_nm)
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
