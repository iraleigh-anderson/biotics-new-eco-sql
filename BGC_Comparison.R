library(tidyverse)
library(readr)
library(stringr) #required for string query for old two digit Site Series codes
library(glue)    #required for SQL query generation
#### IMPORTS ####
BGC <- read_csv("data/BC_COMM_SUB_BGC.csv") #Biotics BGC extensible table
BGCD <- read_csv("data/BC_D_BGC_ZSVP.csv") #Domain for Biotics BGC extensible table
BEC12 <- read_csv("data/BEC12.csv")
#### COMPARE BIOTICS GBC DOMAIN TABLE AGAINST BEC12 ####
BGCD <- BGCD %>%
  mutate(In_BEC12 = if_else(BGC_CD %in% BEC12$MAP_LABEL, "Yes", "No"),
         ) # Add BGCD$In_BEC12 Y or N flag
BGCD_Deprecated_12 <- BGCD %>%
  filter(In_BEC12 == "No") %>%
  select(BGC_CD, everything())
#### PROBLEMATIC BGC RECORDS ####
### Records lacking a site unit
BGC <- BGC %>%
  mutate(
    # Flags records with missing site series data
    Has_Site = if_else(is.na(SITE_SERIES) | nchar(trimws(SITE_SERIES)) == 0 | SITE_SERIES == 'na', "No", "Yes"),
    # Isolates records annotated only to Zone
    Zone_Only = if_else(BGC_CD %in% c("BAFA", "BG", "BWBS", "CDF", "CMA", "CWH", "ESSF", "ICH", "IDF", "IMA", "MH", "MS", "PP", "SBPS", "SBS", "SWB"), "Yes", "No"), # isolates records in BGC subzones that are not in BEC12
    Deprecated_12 = if_else(BGC_CD %in% BGCD_Deprecated_12$BGC_CD & Zone_Only == 'No', "Yes", "No"),
    # Flags strictly two-digit numeric series (e.g. 01, 97) while excluding 00
    Numeric_Site_Series = if_else(str_detect(trimws(SITE_SERIES), "^[0-9]{2}$") & trimws(SITE_SERIES) != "00", "Yes", "No"))
# Subsets for quick view()
BGC_No_Site <- BGC %>%
  filter(Has_Site == "No") %>%
  select(BGC_CD, everything())
BGC_Zone_Only <- BGC %>%  
  filter(Zone_Only == "Yes") %>%
  select(BGC_CD, everything())
BGC_Deprecated_12 <- BGC %>%
  filter(Deprecated_12 == "Yes") %>%
  select(BGC_CD, everything())
#### WRITE CSV TABLES FOR MANUAL CROSSWALKING ####
### BGC AND SITE SERIES REVIEW
BGC_SITE_REVIEW <- BGC_Deprecated_12 %>%
  filter(Numeric_Site_Series == "Yes") %>% 
  # Add empty text columns
  mutate(
    CORRECTED_BGC = "",      
    CORRECTED_SITE_SERIES = "",      
    X_WALK_NOTES = ""       
  ) %>%
  # Arrange columns
  select(BGC_CD, SITE_SERIES, CORRECTED_BGC, CORRECTED_SITE_SERIES, X_WALK_NOTES, BC_COMM_SUB_BGC_ID, ELEMENT_SUBNATIONAL_ID, everything())
write_csv(BGC_SITE_REVIEW, "BGC_SITE_REVIEW.csv")
### BGC ONLY REVIEW
BGC_REVIEW <- tibble(
  # Filter to remove BGC's that will be addressed in BGC and SITE review above
  BGC_CD = BGC_Deprecated_12 %>%
    filter(Numeric_Site_Series != "Yes") %>%
    pull(BGC_CD) %>%
    unique(),
  # Add blank column for corrections
  BGC_CD_CORRECT = ""
) %>%
  arrange(BGC_CD) # Sort alphabetically
print(BGC_REVIEW)
write_csv(BGC_REVIEW, "BGC_REVIEW.csv")

#### SQL UPDATE STATEMENTS ####
### BGC REPLACE STATEMENTS FOR DEPRECATED BGC CODE
BGC_CORRECTIONS <- read_csv("data/BGC_REVIEW_CORRECTED.csv") # BGC_REVIEW.csv after manual review and correction

target_table  <- "bc_comm_sub_bgc"
target_col    <- "BGC_CD"

sql_output <- BGC_CORRECTIONS %>%
  # Filter out rows where no correction was provided
  filter(!is.na(BGC_CD_CORRECT) & BGC_CD_CORRECT != "") %>%
  mutate(
    # Construct the SQL statement using exact matching (=)
    # Wraps the string values in single quotes required by SQL
    sql_query = glue("UPDATE {target_table} SET {target_col} = '{BGC_CD_CORRECT}' WHERE {target_col} = '{BGC_CD}';")
  )

# Write the resulting SQL queries to a file
write_lines(sql_output$sql_query, "bulk_updates.sql")


