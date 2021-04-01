library(janitor)
library(opendatatoronto)
library(ggthemes)
library(readxl)
library(ggplot2)
library(tibble)
library(tidyr)
library(readr)
library(purrr)
library(dplyr)
library(stringr)
library(forcats)

nbhood_profile <- opendatatoronto::search_packages("Neighbourhood Profile") %>%
  opendatatoronto::list_package_resources() %>% 
  dplyr::filter(name == "neighbourhood-profiles-2016-csv") %>% 
  opendatatoronto::get_resource()
# Get shape data for mapping 
#daily_data <- here::here("app/data", "CityofToronto_COVID-19_Daily_Public_Reporting.xlsx")


# Cases reported by date (double check the sheet is correct)
# Should be a sheet names something like  
## 'Cases by Reported Date'
reported_raw <- read_excel("app/data/CityofToronto_COVID-19_Daily_Public_Reporting.xlsx", sheet = 6) %>% 
  clean_names()

# Cases by outbreak type (double check the sheet is correct)
# Should be a sheet names something like  
## 'Cases by Outbreak Type and Epis'
outbreak_raw <- read_excel(daily_data, sheet = 4) %>% 
  clean_names()

# When was this data updated?
date_daily <- read_excel(daily_data, sheet = 1) %>% 
  clean_names()

# By neighbourhood
#neighbourood_data <- here::here("app/data", "CityofToronto_COVID-19_NeighbourhoodData.xlsx")

# Cases reported by date
nbhood_raw <- read_excel("app/data/CityofToronto_COVID-19_NeighbourhoodData.xlsx", sheet = 2) %>% 
  clean_names()

# Date the neighbourhood data was last updated
date_nbhood <- read_excel(neighbourood_data, sheet = 1) %>% 
  clean_names()

#don't need these anymore
rm(daily_data, neighbourood_data)

#############################################################
# Step four: Load the neighbourhood data from Toronto City. #
#############################################################

# Get neighbourhood profile data
#nbhood_profile <- readRDS(here::here("app/data", "neighbourhood_profile.Rds"))


# Get shape data for mapping 
nbhoods_shape_raw <- readRDS("app/data/neighbourhood_shapefile.Rds") %>% 
  sf::st_as_sf() ## Makes sure shape info is in the most up to date format


income <- nbhood_profile %>% 
  #filter(Topic == "Low income in 2015") %>% 
  mutate(Characteristic = sub("^\\s+", "", Characteristic)) %>% 
  dplyr::filter(`_id` == 1075 | `_id` == 1337 | `_id` == 3) %>%
  t() %>%
  #mutate_if(is.character, as.numeric) %>%
  as.data.frame(keep.rownames = TRUE) %>%
  slice(7:n()) %>%
  tibble::rownames_to_column("neighbourhood_name") %>%
  mutate_if(is.character, str_replace_all, ",", "")

nbhoods_all <- nbhoods_shape_raw %>%
  mutate(AREA_NAME = 
           str_replace(AREA_NAME, "North St.James Town", "North St. James Town")) %>%
  mutate(AREA_NAME = 
           str_replace(AREA_NAME, "Weston-Pellam Park", "Weston-Pelham Park")) %>%
  mutate(AREA_NAME =
           str_replace(AREA_NAME, "Cabbagetown-South St.James Town", 
                       "Cabbagetown-South St. James Town")) %>%
  mutate(neighbourhood_name = sub("\\s*\\([^\\d$)]+\\)", "", AREA_NAME)) %>%
  left_join(income, by="neighbourhood_name")%>%
  left_join(nbhood_raw, by="neighbourhood_name")%>%
  rename(rate_per_100000 = "rate_per_100_000_people",
         population = "V1",
         low_income_pt_18_64 = "V2",
         visible_minority = "V3")%>%
  select("neighbourhood_name", "rate_per_100000", "low_income_pt_18_64", "visible_minority", "population")%>%
  mutate(visible_minority_rate = (as.numeric(visible_minority)/as.numeric(population)))

nbhoods_final <- nbhoods_all 

present_map <- function(column, colour, title, legend) {
  ggplot(data = nbhoods_final)+
    geom_sf(aes(fill = as.numeric(column))) +
    theme_map()+
    theme(legend.position = "right") +
    scale_fill_gradient(name=legend, low = "white", high = colour) +
    labs(title = title) #,
         #caption = str_c("Created by Keli Chiu ", "for STA303/1002, U of T \n", 
                         #"Source: Ontario Ministry of Health, 
                      # Integrated Public Health Information System and CORES \n",  
                        # date_daily[1,1]))
}
