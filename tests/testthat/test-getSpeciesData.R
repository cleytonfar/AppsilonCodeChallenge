test_that("getSpeciesData returns data for the selected species", {
    
    # data source
    ds = open_dataset("../../data/occurrence/") 
    
    # Species sample:
    species_nm = ds %>% 
        count(vernacularName, scientificName) %>% 
        collect() %>% 
        sample_n(1)
    
    vernacular_nm = species_nm$vernacularName
    scientific_nm = species_nm$scientificName
    species_nm = sample(c(vernacular_nm, scientific_nm), 1)
    species_nm
    
    # expected results:
    ## default:
    res1 = ds %>% 
        collect() %>%
        select(
            id, vernacularName, scientificName, 
            eventDate, locality, 
            individualCount, lifeStage, 
            latitudeDecimal, longitudeDecimal, accessURI
        ) %>% 
        arrange(id)
    ## selected species:
    res2 = ds %>% 
        filter(vernacularName == species_nm | scientificName == species_nm) %>% 
        select(
            id, vernacularName, scientificName, 
            eventDate, locality, 
            individualCount, lifeStage, 
            latitudeDecimal, longitudeDecimal, accessURI
        ) %>% 
        collect() %>% 
        arrange(id)
    
    # Two cases:
    
    ## 1. species name not defined:
    expect_equal(
        getSpeciesData(
            src = ds, 
            species_nm = ""
        ) %>% 
            arrange(id), 
        expected = res1
    )
    
    ## 2. species name defined:
    expect_equal(
        getSpeciesData(
            src = ds, 
            species_nm = species_nm
        ) %>% 
            arrange(id),
        expected = res2
    )
    
})
