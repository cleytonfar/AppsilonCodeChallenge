
# Function to query the observations for the selected species in a country:
getSpeciesData = function(src, species_nm)  {
    library(arrow)
    library(dplyr)
    # If species_nm are not set, take all species:
    if ( species_nm == "" ) {
        dataset = src %>% 
            select(id, vernacularName, scientificName, eventDate, locality, 
                   individualCount, lifeStage, 
                   latitudeDecimal, longitudeDecimal,  accessURI) %>% 
            collect()
    } else {
        dataset = src %>% 
            filter(vernacularName == species_nm | scientificName == species_nm)  %>% 
            select(id, vernacularName, scientificName, eventDate, locality, 
                   individualCount, lifeStage, 
                   latitudeDecimal, longitudeDecimal, accessURI) %>% 
            collect()
    }
    dataset
}

# Function to calculate the frequency by location (locality)
# given the result from getSpecies(). Default when species not specified:
getFreq_byLocation_default <- function(dataset)  {
    library(data.table)
    setDT(dataset)
    dataset[, .(lat = mean(latitudeDecimal), 
                lng = mean(longitudeDecimal),
                N = n_distinct(id)),
            locality]
}

# Function to calculate the frequency by location (latitude, longitude)
# given the result from getSpecies():
getFreq_byLocation <- function(dataset)  {
    library(dplyr)
    dataset %>% 
        count(id, vernacularName, scientificName, eventDate, locality, individualCount, lifeStage, 
              latitudeDecimal, longitudeDecimal,  accessURI, sort = T)
}

# Function to plot the map with the frequencies by locality. Default when 
# species not specified:
plotFreqMap_default = function(dataset) {
    library(leaflet)
    # pallete:
    pal <- colorQuantile(palette = "Reds", domain = dataset$N, n = 3)
    # plot map:
    leaflet(dataset) %>% 
        addTiles() %>% 
        addCircleMarkers(
            lat = ~lat,
            lng = ~lng, 
            color = ~pal(N),  
            stroke = FALSE, fillOpacity = 0.5,
            popup = ~paste0(
                "<strong>Locality: </strong>", locality,
                "<br>",
                "<strong>Frequency: </strong>", N
                ),
            ) %>% 
        addLegend(
            position = "bottomright",
            pal = pal, 
            values = ~N,
            title = "% of all species observations",
            labFormat = labelFormat( prefix = '', suffix = ''),
            opacity = 1
        )
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
                ifelse(is.na(accessURI), "", paste0("<center><img src = ", accessURI, "' width='100px' height='100px'></center>")),
                "<br/>",
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
plotTimeline <- function(dataset, species_nm,
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
    ## title an subtitle:
    if (species_nm == "") {
        myTitle = "When were all the species observed?"
        mySubtitle = "Frequency of observations of all species."
    } else {
        myTitle = paste0("When was the ", species_nm, " observed?")
        mySubtitle = paste0("Frequency of observations of the ", species_nm, " species.")
    }
    
    if (type == "highchart") {
        ## HighChart:
        hchart(res, type = "line", hcaes(x = year, y = n)) %>% 
            # Title
            hc_title(
                text = paste0("<b>",myTitle,"</b>"),
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
            labs(
                y = "Number of observations", 
                x = "Year",
                title = myTitle,
                subtitle = mySubtitle
            )
    }

}
