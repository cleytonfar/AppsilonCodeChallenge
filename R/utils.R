
# Function to query the observations for the selected species in a country:
getSpeciesData = function(src, country_nm, vernacular_nm, scientific_nm)  {
    library(arrow)
    library(dplyr)
    # If "vernacular_nm" and "scientific_nm" are not set, take all species
    # from "country_nm":
    if ( (vernacular_nm == "" & scientific_nm == "")  ) {
        dataset = open_dataset(src) %>% 
            filter(country == country_nm)  %>%
            collect()
    } else {
        dataset = open_dataset(src) %>% 
            filter(country == country_nm & vernacularName == vernacular_nm & scientificName == scientific_nm)  %>%
            collect()
    }
    dataset
}

# Function to calculate the frequency by location 
# given the result from getSpecies():
getFreq_byLocation <- function(dataset)  {
    library(dplyr)
    dataset %>% 
        count(id, vernacularName, scientificName, eventDate, locality, individualCount, lifeStage, 
              latitudeDecimal, longitudeDecimal, sort = T)
}

# Function to plot the map with the frequencies by location:
plotFreqMap = function(dataset) {
    library(leaflet)
    # plot map:
    leaflet(dataset) %>% 
        addTiles() %>% 
        addMarkers(
            lng = ~longitudeDecimal, 
            lat = ~latitudeDecimal,
            clusterOptions = markerClusterOptions(),
            popup = ~paste0(
                "<strong>Details</strong>",
                "<br/>",
                "<br/>",
                "<strong>Vernacular Name:</strong> ", vernacularName,
                "<br/>",
                "<strong>Scientific Name:</strong> ", scientificName,
                "<br/>",
                "<strong>Date:</strong> ", eventDate,
                "<br/>",
                "<strong>Number:</strong> ", individualCount,
                "<br/>",
                "<strong>Life Stage:</strong> ", lifeStage,
                "<br/>",
                "<strong>Locality:</strong> ", locality
            )
        )
}

# Function to plot the timeline of observations of the selected species.
# This function plots at least 'minYears' of data.
# Also, it can plot using two libraries: 'highchart' and 'ggplot':
plotTimeline <- function(dataset, vernacular_nm, scientific_nm, 
                         minYears = 5, type = "highchart") {
    # required packages:
    library(ggplot2)
    library(dplyr)
    library(tidyr)
    library(lubridate)
    library(highcharter)
    
    # dataset = res
    # minYears = 5
    # type = "highchart"
    
    # frequency by year:
    res = dataset %>% 
        mutate(year = year(eventDate)) %>% 
        count(year)
    
    # create a timeline of at least 5 years:
    ## year range:
    year1 = range(res$year)[[1]]
    year2 = range(res$year)[[2]]
    ## getting the minimum year
    year1 = min(year2 - minYears, year1)
    ## merge:
    res = left_join(
        tibble(year = seq(year1, year2)),
        res,   
        by = "year"
    )
    ## replace NA with 0s:
    res = res %>% 
        mutate(n = replace_na(n, 0),
               year = as.integer(year))
    
    # plotting:
    ## title:
    if (vernacular_nm == "" & scientific_nm == "") {
        myTitle = "<b>When were all the species observed?</b>"
    } else {
        myTitle = paste0("<b>When was the ", scientific_nm, " observed?</b>")
    }
    ## subtitle:
    if (vernacular_nm == "" & scientific_nm == "") {
        mySubtitle = "Frequency of observations of all species."
    } else {
        mySubtitle = paste0("Frequency of observations of the ", scientific_nm, " species.")
    }
    
    if (type == "highchart") {
        ## HighChart:
        hchart(res, type = "line", hcaes(x = year, y = n)) %>% 
            # Title
            hc_title(
                text = myTitle,
                useHTML = T
            ) %>% 
            # Subtitle
            hc_subtitle(
                text = mySubtitle
            ) %>% 
            # Axis
            hc_yAxis(
                title = list(
                    text = "<b>Number of observations</b>",
                    useHTML = TRUE
                )
            ) %>% 
            hc_xAxis(
                title = list(
                    text = "<b>Year</b>", 
                    useHTML = TRUE
                ),
                showFirstLabel = TRUE,
                showLastLabel = TRUE
            ) %>% 
            # Tooltip
            hc_tooltip(
                backgroundColor = "#F0F0F0",
                shared = TRUE, 
                borderWidth = 2,
                pointFormat = 'Year: <b>{point.x}</b><br>Frequency: <b>{point.y}</b>'
                
            )
    } else if(type == "ggplot") {
        ## ggplot:
        res %>% 
            ggplot(aes(x = year, y = n)) + 
            geom_point() + 
            geom_line(size = .2) +
            theme_minimal() +
            theme(plot.title = element_text(hjust = .5)) + 
            labs(
                y = "Number of observations", 
                x = "Year",
                title = "Observations Through Time"
            )
    }

}
