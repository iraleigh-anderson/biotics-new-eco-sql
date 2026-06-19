#### Libraries ####
library(tidyverse)

#### PART 1 Ecosystem Element Creation ####

#### Create Example Element Data ####
# Create outlandish example element name data
# example <- data.frame(
#   sci.bec = c("Spiraea douglasiilili - Carex sitchensis", "Typha latifolialalala", "Deschampsia caespitosa - Hordeum brachyantherum"),
#   sci.cdc = c("Spiraea douglasiilili - Carex sitchensis Swamp", "Typha latifolialalala Marsh", "Deschampsia caespitosa - Hordeum brachyantherum Estuarine Meadow"),
#   sci.cdc.html = c("<i>Spiraea douglasiilili</i> - <i>Carex sitchensis</i> Swamp", "<i>Typha latifolialalala</i> Marsh", "<i>Deschampsia caespitosa</i> - <i>Hordeum brachyantherum</i> Estuarine Meadow"),
#   sci.bec.html = c("<i>Spiraea douglasiilili</i> - <i>Carex sitchensis</i>", "<i>Typha latifolialalala</i>", "<i>Deschampsia caespitosa</i> - <i>Hordeum brachyantherum</i>"),
#   com.bec = c("Pink spireaeeaea - Sitka sedge", "Cattail", "Tufted hairgrass - Meadow barley"),
#   com.cdc = c("pink spireaeeaea - Sitka sedge Swamp", "cattail Marsh", "tufted hairgrass - meadow barley Estuarine Meadow"),
#   com.ns = c(Pink Spireaeeaea - Sitka Sedge Swamp", "Cattail Marsh", "Tufted Hairgrass - Meadow Barley Estuarine Meadow"),
#   com.nbec = c("Ws99", "Wm05", "Em88"),
#   eco.grp = c(60, 58, 3),
#   elcode = c("CEBC003153","CEBC003154","CEBC003155"),
#   lmh52= c(0,1,0)
# )
# Test with element Ws12
example <- data.frame(
  sci.bec = c("Picea engelmannii x glauca - Carex scopulorum - Aulacomnium palustre"), #From BECdb, because not in SS catalogue.
  sci.cdc = c("Picea x albertiana - Carex scopulorum - Aulacomnium palustre Swamp"),
  sci.cdc.html = c("<i>Picea</i> x <i>albertiana</i> - <i>Carex scopulorum</i> - <i>Aulacomnium palustre</i> Swamp"),
  sci.bec.html = c("<i>Picea engelmannii</i> x <i>glauca</i> - <i>Carex scopulorum</i> - <i>Aulacomnium palustre</i> "),
  com.bec = c("Spruce - Rocky Mountain sedge - Glow moss"), # From SS catalogue because it matches guides
  com.cdc = c("spruce spp. - Rocky Mountain sedge - glow moss Swamp"),
  com.ns = c("Spruce spp. - Rocky Mountain Sedge - Glow Moss Swamp"),
  com.nbec = c("Ws12"),
  eco.grp = c(60),
  elcode = c("CEBC003153"),
  lmh52= c(1))

#### 1. INSERT Statements for SCIENTIFIC_NAME ####
# this generates scientific name record for the CDC name for the element
# CDC names may change over time.
example$sci.name.cdc.sql <- paste0(
  "INSERT INTO scientific_name (SCIENTIFIC_NAME, FORMATTED_SCIENTIFIC_NAME, D_NAME_CATEGORY_ID, D_CLASSIFICATION_LEVEL_ID, AUTHOR_NAME, REC_CREATE_USER, D_MAINTAINED_BY_STATUS_ID) 
  VALUES ('",
  trimws(example$sci.cdc), "', '",
  trimws(example$sci.cdc.html), "', ",
  "11, 52, 'BC', 'ida lmh77', 2);"
)

# this generates scientific name record for the BEC name for the element
# BEC names should come verbatim from the vegetation hierarchy and should never be modified. They are the durable linkage between BEC and Biotics.
example$sci.name.bec.sql <- paste0(
  "INSERT INTO scientific_name (SCIENTIFIC_NAME, FORMATTED_SCIENTIFIC_NAME, D_NAME_CATEGORY_ID, D_CLASSIFICATION_LEVEL_ID, AUTHOR_NAME, REC_CREATE_USER, D_MAINTAINED_BY_STATUS_ID) 
  VALUES ('",
  trimws(example$sci.bec), "', '",
  trimws(example$sci.bec.html), "', ",
  "11, 52, 'BC', 'ida lmh77',2);"
)

#### 2. INSERT Statements for ELEMENT_GLOBAL ####
# CONCEPT_REFERENCE_ID = 292448 is the draft reference for the 2026 veg hierarchy
example$elem.glo.sql <- paste0(
  "INSERT INTO element_global (ELCODE_BCD, GNAME_ID, CONCEPT_REFERENCE_ID, CONCEPT_NAME_ID, INACTIVE_IND, G_PRIMARY_COMMON_NAME, D_CLASSIFICATION_STATUS_ID, D_LANGUAGE_ID, REC_CREATE_USER, D_MAINTAINED_BY_STATUS_ID) 
  VALUES ('",
  trimws(example$elcode), "', ",
  "(SELECT SCIENTIFIC_NAME_ID FROM scientific_name WHERE SCIENTIFIC_NAME = '", 
  trimws(example$sci.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",  "'292448', ",
  "(SELECT SCIENTIFIC_NAME_ID FROM scientific_name WHERE SCIENTIFIC_NAME = '", 
  trimws(example$sci.bec), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'Y', ",
  "'", trimws(example$com.ns), "', ",
  "1, 1, 'ida lmh77', 2);"
)


#### 3. INSERT Statements for SCIENTIFIC_NAME_REF ####
# REFERENCE_ID = 292448 is the draft reference for the 2026 veg hierarchy
example$sci.ref.sql <- paste0(
  "INSERT INTO scientific_name_ref (SCIENTIFIC_NAME_ID, PRIMARY_NAME_REF_IND, REC_CREATE_USER, REFERENCE_ID) 
  VALUES (",
  "(SELECT SCIENTIFIC_NAME_ID FROM scientific_name WHERE SCIENTIFIC_NAME = '", 
  trimws(example$sci.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'Y', 'ida lmh77', 292448);"
)

#### 4. INSERT Statements for ELEMENT_NATIONAL ####
example$elem.nat.sql <- paste0(
  "INSERT INTO element_national (ELEMENT_GLOBAL_ID, NATION_ID, NNAME_ID, N_PRIMARY_COMMON_NAME, D_LANGUAGE_ID, REC_CREATE_USER, D_MAINTAINED_BY_STATUS_ID) 
  VALUES (",
  "(SELECT ELEMENT_GLOBAL_ID FROM element_global WHERE G_PRIMARY_COMMON_NAME = '", trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "38, ",
  "(SELECT scientific_name_id FROM scientific_name WHERE SCIENTIFIC_NAME = '", trimws(example$sci.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(example$com.ns), "', ",
  "1, 'ida lmh77', 2);"
)

#### 5. INSERT Statements for COMMUNITY_NATIONAL ####
example$com.nat.sql <- paste0(
  "INSERT INTO community_national (ELEMENT_NATIONAL_ID, D_CURR_PRESENCE_ABSENCE_ID, D_DIST_CONFIDENCE_ID, REC_CREATE_USER) 
  VALUES (",
  "(SELECT ELEMENT_NATIONAL_ID FROM element_national WHERE N_PRIMARY_COMMON_NAME = '", trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "1, 1, 'ida lmh77');"
)

#### 6. INSERT Statements for ELEMENT_SUBNATIONAL ####
example$elem.sub.sql <- paste0(
  "INSERT INTO element_subnational (ELEMENT_NATIONAL_ID, SUBNATION_ID, SNAME_ID, S_PRIMARY_COMMON_NAME, D_LANGUAGE_ID, REC_CREATE_USER, D_DATA_SENSITIVE_ID, D_MAINTAINED_BY_STATUS_ID) 
  VALUES (",
  "(SELECT ELEMENT_NATIONAL_ID FROM element_national WHERE N_PRIMARY_COMMON_NAME = '", trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "61, ",
  "(SELECT scientific_name_id FROM scientific_name WHERE SCIENTIFIC_NAME = '", trimws(example$sci.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(example$com.ns), "', ",
  "1, 'ida lmh77', 2, 2);"
)

#### 7. INSERT Statements for COMMUNITY_SUBNATIONAL ####
example$com.sub.ns.sql <- paste0(
  "INSERT INTO community_subnational (ELEMENT_SUBNATIONAL_ID, D_CURR_PRESENCE_ABSENCE_ID, D_DIST_CONFIDENCE_ID, REC_CREATE_USER) 
  VALUES (",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "1, 1, 'ida lmh77');"
)

#### 8. INSERT Statements for ELEMENT_SUBNATL_REF ####
# REFERENCE_ID = 292448 is the draft reference for the 2026 veg hierarchy
example$sub.ref.vh.sql <- paste0(
  "INSERT INTO element_subnatl_ref (ELEMENT_SUBNATIONAL_ID, REFERENCE_ID, SCIENTIFIC_NAME_IND, ",
  "PRIMARY_SCIENTIFIC_NAME_IND, CLASSIFICATION_TAXONOMY_IND, RANK_FACTORS_IND, REC_CREATE_USER) 
  VALUES (",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "292448, 'Y', 'Y', 'Y', 'N', 'ida lmh77');"
)

#### 8. (Continued) INSERT Statements for ELEMENT_SUBNATL_REF ####
# REFERENCE_ID = 292449 is the draft reference for LMH77
example$sub.ref.77.sql <- paste0(
  "INSERT INTO element_subnatl_ref (ELEMENT_SUBNATIONAL_ID, REFERENCE_ID, SCIENTIFIC_NAME_IND, ",
  "PRIMARY_SCIENTIFIC_NAME_IND, CLASSIFICATION_TAXONOMY_IND, RANK_FACTORS_IND, REC_CREATE_USER) 
  VALUES (",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "292449, 'N', 'N', 'Y', 'Y', 'ida lmh77');"
)

# REFERENCE_ID = 169749 is the reference for LMH 52

example$sub.ref.52.sql <- ifelse(
  example$lmh52 == 1,
  paste0(
    "INSERT INTO element_subnatl_ref (ELEMENT_SUBNATIONAL_ID, REFERENCE_ID, SCIENTIFIC_NAME_IND, ",
    "PRIMARY_SCIENTIFIC_NAME_IND, CLASSIFICATION_TAXONOMY_IND, RANK_FACTORS_IND, REC_CREATE_USER) ",
    "VALUES (","(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
    trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
    "169749, 'N', 'N', 'N', 'Y', 'ida lmh77');"
  ),
  ""
)

#### 8. Continued INSERT Statements for ELEMENT_GLOBAL_REF ####
# REFERENCE_ID = 292448 is the draft reference for the 2026 veg hierarchy
example$glo.ref.sql <- paste0(
  "INSERT INTO element_global_ref (ELEMENT_GLOBAL_REF_ID, ELEMENT_GLOBAL_ID, REFERENCE_ID, ",
  "SCIENTIFIC_NAME_IND, PRIMARY_SCIENTIFIC_NAME_IND, CLASSIFICATION_TAXONOMY_IND, REC_CREATE_USER, DISPLAY_ORDER) ",
  "VALUES (",
  "getnextseq('element_global_ref'), ",
  "(SELECT ELEMENT_GLOBAL_ID FROM element_global WHERE G_PRIMARY_COMMON_NAME = '", trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "292448, 'Y', 'Y', 'Y', 'ida lmh77', 1);"
)

#### 9. INSERT Statements for OTHER_SUB_COMMON_NAME ####
#a. BEC Name (matches BEC) TO CONFIRM WITH CORA AND JASON THAT WE WANT THIS
example$oth.sub.com.bec.sql <- paste0(
  "INSERT INTO other_sub_common_name (ELEMENT_SUBNATIONAL_ID, OTHER_SUB_COMMON_NAME, D_LANGUAGE_ID, REC_CREATE_USER) ", 
  "VALUES (", "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(example$com.bec), "', ",
  "1, 'ida lmh77');"
)
#b. CDC Name for BCSEE (Matches CDC botany lowercase naming)
example$oth.sub.com.cdc.sql <- paste0(
  "INSERT INTO other_sub_common_name (ELEMENT_SUBNATIONAL_ID, OTHER_SUB_COMMON_NAME, D_LANGUAGE_ID, REC_CREATE_USER) ", 
  "VALUES (", "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(example$com.cdc), "', ",
  "1, 'ida lmh77');"
)
#c. nBEC Name for BCSEE
example$oth.sub.com.nbec.sql <- paste0(
  "INSERT INTO other_sub_common_name (ELEMENT_SUBNATIONAL_ID, OTHER_SUB_COMMON_NAME, D_LANGUAGE_ID, REC_CREATE_USER) ", 
  "VALUES (", "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(example$com.nbec), "', ",
  "1, 'ida lmh77');"
)

#### 10. INSERT Statements for EL_SUBNATL_AGENCY_STATUS ####
example$agen.stat.sql <- paste0(
  "INSERT INTO el_subnatl_agency_status (ELEMENT_SUBNATIONAL_ID, AGENCY_NAME, AGENCY_STATUS, REC_CREATE_USER) 
  VALUES (","(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '",
  trimws(example$com.ns), 
  "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'BC Conservation Data Centre','N/A', 'ida lmh77');"
)

#### 11. INSERT Statements for BC_COMM_SUB_ECOSYS_GRP ####
example$eco.grp.sql <- paste0(
  "INSERT INTO bc_comm_sub_ecosys_grp (BC_COMM_SUB_ECOSYS_GRP_ID, ELEMENT_SUBNATIONAL_ID, ECOSYS_GRP_ID, DATE_ASSESSED, REC_CREATE_USER) 
  VALUES (","getnextseq('bc_comm_sub_ecosys_grp'), ",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '",
  trimws(example$com.ns), 
  "' AND REC_CREATE_USER = 'ida lmh77'), ","'", trimws(example$eco.grp), "', '2025-07-15', 'ida lmh77');"
)

#### 12. INSERT Statements for SYNONYM_SUBNATIONAL ####
example$syn.sub.sql <- paste0(
  "INSERT INTO synonym_subnational (ELEMENT_SUBNATIONAL_ID, SCIENTIFIC_NAME_ID, S_SYNONYM_ADD_DATE, REC_CREATE_USER) VALUES (",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '",
  trimws(example$com.ns), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "(SELECT SCIENTIFIC_NAME_ID FROM scientific_name WHERE SCIENTIFIC_NAME = '", 
  trimws(example$sci.bec), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'2025-07-15','ida lmh77');"
)

#### 13. INSERT Statments for COMM_CAS ####
# required to avoid the glitch that Robyn and Ira learned about where creation of a new CAS deletes some of the data in an element.
example$comm.cas.sql <- paste0(
  "INSERT INTO comm_cas (ELEMENT_SUBNATIONAL_ID, REC_CREATE_USER) VALUES (",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '",
  trimws(example$com.ns), 
  "' AND REC_CREATE_USER = 'ida lmh77'), 'ida lmh77');"
)

#### 14. WRITE SQL Statements to File ####
# Generate today's date in yyyymmdd format
today <- format(Sys.Date(), "%Y%m%d")
# Create the filename with the date appended
sql_filename <- paste0("outputs/", "Ecology_Element_Insert_", today, ".sql")

# Open a connection to the output SQL file
sql_file <- file(sql_filename, open = "wt")
# Loop through each row and write the SQL statements in order, with a blank line between sets
for (i in 1:nrow(example)) {
  writeLines(example$sci.name.cdc.sql[i], sql_file)
  writeLines(example$sci.name.bec.sql[i], sql_file)
  writeLines(example$elem.glo.sql[i], sql_file)
  writeLines(example$sci.ref.sql[i], sql_file)
  writeLines(example$elem.nat.sql[i],sql_file)
  writeLines(example$com.nat.sql[i],sql_file)
  writeLines(example$elem.sub.sql[i],sql_file)
  writeLines(example$com.sub.ns.sql[i],sql_file)
  writeLines(example$sub.ref.vh.sql[i],sql_file)
  writeLines(example$sub.ref.77.sql[i],sql_file)
  writeLines(example$sub.ref.52.sql[i],sql_file)
  writeLines(example$glo.ref.sql[i],sql_file)
  writeLines(example$oth.sub.com.bec.sql[i],sql_file)
  writeLines(example$oth.sub.com.cdc.sql[i],sql_file)
  writeLines(example$oth.sub.com.nbec.sql[i],sql_file)
  writeLines(example$agen.stat.sql[i],sql_file)
  writeLines(example$eco.grp.sql[i],sql_file)
  writeLines(example$syn.sub.sql[i],sql_file)
  writeLines(example$comm.cas.sql[i],sql_file)
  writeLines("", sql_file) # Add a blank line between each set
}
# Close the file connection
close(sql_file)
# Create the filename with the date appended
#csv.name <- paste0("Ecology_Element_Insert_", today, ".csv")
#write.csv(example,file = csv.name, row.names = FALSE)


#### PART 2 BGC Range ####
#### Example BGC range data #### 
BGCexample <- data.frame(
  com.ns = c("Spruce spp. - Rocky Mountain Sedge - Glow Moss Swamp", "Spruce spp. - Rocky Mountain Sedge - Glow Moss Swamp"),
  bgc = c("MSxk1","ESSFxc1"),
  ss = c("Ws12","Ws12")
  )

#### 15. INSERT Statements for BC_COMM_SUB_BGC ####
#E26MAC01BCCA is the 2026 BEC vegetation hierarchy
BGCexample$comm.sub.bgc.sql <- paste0(
  "INSERT INTO bc_comm_sub_bgc (BC_COMM_SUB_BGC_ID, ELEMENT_SUBNATIONAL_ID, BGC_CD, SITE_SERIES, D_OCCURRENCE_STATUS_ID, NOTE, REC_CREATE_USER) VALUES (",
  "getnextseq('bc_comm_sub_bgc'), ",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '",
  trimws(BGCexample$com.ns), 
  "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(BGCexample$bgc), "', ",
  "'", trimws(BGCexample$ss), "', ",
  "1, 'Reference: E26MAC01BCCA', ",
  "'ida lmh77');"
)
#### 16. WRITE BGC SQL Statements to File ####
# Create the filename with the date appended
bgc.sql.name <- paste0("outputs/", "Ecology_BGC_Insert_", today, ".sql")
# Open the file for writing
sql_file <- file(bgc.sql.name, open = "wt")
# Loop through each row and write the SQL statements
for (i in 1:nrow(BGCexample)) {
  writeLines(BGCexample$comm.sub.bgc.sql[i], sql_file)
  writeLines("", sql_file)  # Add a blank line between entries
}
# Close the file connection
close(sql_file)


