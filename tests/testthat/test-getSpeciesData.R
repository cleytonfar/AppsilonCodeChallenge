test_that("getSpeciesData returns data for the selected species", {
    
    # country sample:
    country_nm = open_dataset("../../data/occurrence/") %>% 
        count(country) %>% 
        collect() %>% 
        sample_n(1) %>% 
        pull(country)
    
    # Species sample:
    species_nm = open_dataset("../../data/occurrence/") %>% 
        filter(country == country_nm) %>% 
        count(vernacularName, scientificName) %>% 
        collect() %>% 
        sample_n(1)
    vernacular_nm = species_nm$vernacularName
    scientific_nm = species_nm$scientificName
    
    # expected results:
    res1 = open_dataset("../../data/occurrence/") %>% 
        filter(country == country_nm) %>% 
        collect() %>% 
        arrange(id)
    res2 = open_dataset("../../data/occurrence/") %>% 
        filter(country == country_nm, 
               vernacularName == vernacular_nm,
               scientificName == scientific_nm) %>% 
        collect() %>% 
        arrange(id)
    
    ## 1. species name not defined:
    expect_equal(
        getSpeciesData(
            src = "../../data/occurrence/", 
            country_nm = country_nm,
            vernacular_nm = "",
            scientific_nm = ""
        ) %>% 
            arrange(id), 
        expected = res1
    )
    
    # 2. species name defined:
    expect_equal(
        getSpeciesData(
            src = "../../data/occurrence/", 
            country_nm = country_nm,
            vernacular_nm = vernacular_nm,
            scientific_nm = scientific_nm
        ) %>% 
            arrange(id),
        expected = res2
    )
    
    # ====== These are hierarchical cases ====== #

    # country sample:
    country_nm = open_dataset("../../data/occurrence/") %>% 
        filter(vernacularName == "") %>% 
        count(country) %>% 
        collect() %>% 
        sample_n(1) %>% 
        pull(country)
    
    # Species sample:
    species_nm = open_dataset("../../data/occurrence/") %>% 
        filter(country == country_nm, vernacularName == "") %>% 
        count(vernacularName, scientificName) %>% 
        collect() %>% 
        sample_n(1)
    vernacular_nm = species_nm$vernacularName
    scientific_nm = species_nm$scientificName
    
    # expected results:
    res1 = open_dataset("../../data/occurrence/") %>% 
        filter(country == country_nm) %>% 
        collect() %>% 
        arrange(id)
    res2 = open_dataset("../../data/occurrence/") %>% 
        filter(country == country_nm, 
               vernacularName == vernacular_nm,
               scientificName == scientific_nm) %>% 
        collect() %>% 
        arrange(id)
    
    # 3. only vernacular name defined:
    expect_equal(
        getSpeciesData(
            src = "../../data/occurrence/", 
            country_nm = country_nm,
            vernacular_nm = vernacular_nm,
            scientific_nm = ""
        ) %>% 
            arrange(id),
        res1
    )
    
    # 4. only scientific name defined:
    expect_equal(
        getSpeciesData(
            src = "../../data/occurrence/", 
            country_nm = country_nm,
            vernacular_nm = "",
            scientific_nm = scientific_nm
        ) %>% 
            arrange(id),
        expected = res2
    )
    
})
