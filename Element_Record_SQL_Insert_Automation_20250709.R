library(dplyr)

###########################################
#### PART 1 Ecosystem Element Creation ####
###########################################

# Create example element name data
example <- data.frame(
  sci.bec = c("Spiraea douglasii - Carex sitchensis", "Typha latifolia", "Deschampsia caespitosa - Hordeum brachyantherum"),
  sci.cdc = c("Spiraea douglasii - Carex sitchensis Swamp", "Typha latifolia Marsh", "Deschampsia caespitosa - Hordeum brachyantherum Estuarine Meadow"),
  sci.cdc.html = c("<i>Spiraea douglasii</i> - <i>Carex sitchensis</i> Swamp", "<i>Typha latifolia</i> Marsh", "<i>Deschampsia caespitosa</i> - <i>Hordeum brachyantherum</i> Estuarine Meadow"),
  sci.bec.html = c("<i>Spiraea douglasii</i> - <i>Carex sitchensis</i>", "<i>Typha latifolia</i>", "<i>Deschampsia caespitosa</i> - <i>Hordeum brachyantherum</i>"),
  com.bec = c("Pink spirea - Sitka sedge", "Cattail", "Tufted hairgrass - Meadow barley"),
  com.cdc = c("Pink spirea - Sitka sedge Swamp", "Cattail Marsh", "Tufted hairgrass - Meadow barley Estuarine Meadow"),
  eco.grp = c(60, 58, 3),
  elcode = c("CEBC003151","CEBC003152","CEBC003153"),
  lmh52= c(0,1,0)
)

# 1. INSERT Statements for SCIENTIFIC_NAME
# this generates scientific name record for the CDC name for the element
# CDC names may change over time.
example$sci.name.cdc.sql <- paste0(
  "INSERT INTO scientific_name (SCIENTIFIC_NAME_ID, SCIENTIFIC_NAME, FORMATTED_SCIENTIFIC_NAME, D_NAME_CATEGORY_ID, D_CLASSIFICATION_LEVEL_ID, AUTHOR_NAME, REC_CREATE_USER) 
  VALUES (",
  "getnextseq('SCIENTIFIC_NAME_ID'), '",
  trimws(example$sci.cdc), "', '",
  trimws(example$sci.cdc.html), "', ",
  "11, 52, 'BC', 'ida lmh77');"
)

# 1. (Continued) INSERT Statements for SCIENTIFIC_NAME
# this generates scientific name record for the BEC name for the element
# BEC names should come verbatim from the vegetation hierarchy and should never be modified. They are the durable linkage between BEC and Biotics.
example$sci.name.bec.sql <- paste0(
  "INSERT INTO scientific_name (SCIENTIFIC_NAME_ID, SCIENTIFIC_NAME, FORMATTED_SCIENTIFIC_NAME, D_NAME_CATEGORY_ID, D_CLASSIFICATION_LEVEL_ID, AUTHOR_NAME, REC_CREATE_USER) 
  VALUES (",
  "getnextseq('SCIENTIFIC_NAME_ID'), '",
  trimws(example$sci.bec), "', '",
  trimws(example$sci.bec.html), "', ",
  "11, 52, 'BC', 'ida lmh77');"
)

# 2. INSERT Statements for ELEMENT_GLOBAL
# CONCEPT_REFERENCE_ID = 292448 is the draft reference for the 2026 veg hierarchy
example$elem.glo.sql <- paste0(
  "INSERT INTO element_global (ELEMENT_GLOBAL_ID, ELCODE_BCD, GNAME_ID, CONCEPT_REFERENCE_ID, CONCEPT_NAME_ID, G_PRIMARY_COMMON_NAME, D_CLASSIFICATION_STATUS_ID, D_LANGUAGE_ID, REC_CREATE_USER) 
  VALUES (",
  "getnextseq('ELEMENT_GLOBAL_ID'), '",
  trimws(example$elcode), "', ",
  "(SELECT SCIENTIFIC_NAME_ID FROM scientific_name WHERE SCIENTIFIC_NAME = '", 
  trimws(example$sci.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",  "'292448', ",
  "(SELECT SCIENTIFIC_NAME_ID FROM scientific_name WHERE SCIENTIFIC_NAME = '", 
  trimws(example$sci.bec), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(example$com.cdc), "', ",
  "1, 2, 'ida lmh77');"
)


# 3. INSERT Statements for SCIENTIFIC_NAME_REF
# REFERENCE_ID = 292448 is the draft reference for the 2026 veg hierarchy
example$sci.ref.sql <- paste0(
  "INSERT INTO scientific_name_ref (SCIENTIFIC_NAME_ID, PRIMARY_NAME_REF_IND, REC_CREATE_USER, REFERENCE_ID, SCIENTIFIC_NAME_REF_ID) 
  VALUES (",
  "(SELECT scientific_name_id FROM scientific_name WHERE SCIENTIFIC_NAME = '", 
  trimws(example$sci.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'Y', 'ida lmh77', 292448, getnextseq('SCIENTIFIC_NAME_REF_ID'));"
)

# 4. INSERT Statements for ELEMENT_NATIONAL
example$elem.nat.sql <- paste0(
  "INSERT INTO element_national (ELEMENT_NATIONAL_ID, ELEMENT_GLOBAL_ID, NATION_ID, NNAME_ID, N_PRIMARY_COMMON_NAME, D_LANGUAGE_ID, REC_CREATE_USER) 
  VALUES (",
  "getnextseq('ELEMENT_NATIONAL_ID'), ",
  "(SELECT ELEMENT_GLOBAL_ID FROM element_global WHERE G_PRIMARY_COMMON_NAME = '", trimws(example$com.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "38, ",
  "(SELECT scientific_name_id FROM scientific_name WHERE SCIENTIFIC_NAME = '", trimws(example$sci.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(example$com.cdc), "', ",
  "1, 'ida lmh77');"
)

# 5. INSERT Statements for COMMUNITY_NATIONAL
example$com.nat.sql <- paste0(
  "INSERT INTO community_national (ELEMENT_NATIONAL_ID, D_CURR_PRESENCE_ABSENCE_ID, D_DIST_CONFIDENCE_ID, REC_CREATE_USER) 
  VALUES (",
  "(SELECT ELEMENT_NATIONAL_ID FROM element_national WHERE N_PRIMARY_COMMON_NAME = '", trimws(example$com.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "1, 1, 'ida lmh77');"
)

# 6. INSERT Statements for ELEMENT_SUBNATIONAL
example$elem.sub.sql <- paste0(
  "INSERT INTO element_subnational (ELEMENT_SUBNATIONAL_ID, ELEMENT_NATIONAL_ID, SUBNATION_ID, SNAME_ID, S_PRIMARY_COMMON_NAME, D_LANGUAGE_ID, REC_CREATE_USER, D_DATA_SENSITIVE_ID) 
  VALUES (",
  "getnextseq('ELEMENT_SUBNATIONAL_ID'), ",
  "(SELECT ELEMENT_NATIONAL_ID FROM element_national WHERE N_PRIMARY_COMMON_NAME = '", trimws(example$com.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "61, ",
  "(SELECT scientific_name_id FROM scientific_name WHERE SCIENTIFIC_NAME = '", trimws(example$sci.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(example$com.cdc), "', ",
  "1, 'ida lmh77', 2);"
)

# 7. INSERT Statements for COMMUNITY_SUBNATIONAL
example$com.sub.sql <- paste0(
  "INSERT INTO community_subnational (ELEMENT_SUBNATIONAL_ID, D_CURR_PRESENCE_ABSENCE_ID, D_DIST_CONFIDENCE_ID, REC_CREATE_USER) 
  VALUES (",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "1, 1, 'ida lmh77');"
)

# 8. INSERT Statements for ELEMENT_SUBNATL_REF
# REFERENCE_ID = 292448 is the draft reference for the 2026 veg hierarchy
example$sub.ref.vh.sql <- paste0(
  "INSERT INTO element_subnatl_ref (ELEMENT_SUBNATL_REF_ID, ELEMENT_SUBNATIONAL_ID, REFERENCE_ID, SCIENTIFIC_NAME_IND, ",
  "PRIMARY_SCIENTIFIC_NAME_IND, CLASSIFICATION_TAXONOMY_IND, RANK_FACTORS_IND, REC_CREATE_USER) 
  VALUES (",
  "getnextseq('ELEMENT_SUBNATL_REF'), ",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "292448, 'Y', 'Y', 'Y', 'N', 'ida lmh77');"
)

# 8. (Continued) INSERT Statements for ELEMENT_SUBNATL_REF
# REFERENCE_ID = 292449 is the draft reference for LMH77
example$sub.ref.77.sql <- paste0(
  "INSERT INTO element_subnatl_ref (ELEMENT_SUBNATL_REF_ID, ELEMENT_SUBNATIONAL_ID, REFERENCE_ID, SCIENTIFIC_NAME_IND, ",
  "PRIMARY_SCIENTIFIC_NAME_IND, CLASSIFICATION_TAXONOMY_IND, RANK_FACTORS_IND, REC_CREATE_USER) 
  VALUES (",
  "getnextseq('ELEMENT_SUBNATL_REF'), ",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "292449, 'N', 'N', 'Y', 'Y', 'ida lmh77');"
)

# 8. (Continued) INSERT Statements for ELEMENT_SUBNATL_REF
# REFERENCE_ID = 169749 is the reference for LMH 52
example$sub.ref.52.sql <- ifelse(
  example$lmh52 == 1,
  paste0(
    "INSERT INTO element_subnatl_ref (ELEMENT_SUBNATL_REF_ID, ELEMENT_SUBNATIONAL_ID, REFERENCE_ID, SCIENTIFIC_NAME_IND, ",
    "PRIMARY_SCIENTIFIC_NAME_IND, CLASSIFICATION_TAXONOMY_IND, RANK_FACTORS_IND, REC_CREATE_USER) 
    VALUES (",
    "getnextseq('ELEMENT_SUBNATL_REF'), ",
    "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
    trimws(example$com.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
    "169749, 'N', 'N', 'N', 'Y', 'ida lmh77');"
  ),
  "[skipped]"
)

# 9. INSERT Statements for OTHER_SUB_COMMON_NAME
example$oth.sub.com.sql <- paste0(
  "INSERT INTO other_sub_common_name (OTHER_SUB_COMMON_NAME_ID, ELEMENT_SUBNATIONAL_ID, OTHER_SUB_COMMON_NAME, D_LANGUAGE_ID, REC_CREATE_USER) 
  VALUES (",
  "getnextseq('OTHER_SUB_COMMON_NAME_ID'), ",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '", 
  trimws(example$com.cdc), "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(example$com.bec), "', ",
  "1, 'ida lmh77');"
)

# 10. INSERT Statements for EL_SUBNATL_AGENCY_STATUS
example$agen.stat.sql <- paste0(
  "INSERT INTO el_subnatl_agency_status (EL_SUBNATL_AGENCY_STATUS_ID, ELEMENT_SUBNATIONAL_ID, AGENCY_NAME, AGENCY_STATUS, REC_CREATE_USER) 
  VALUES (","getnextseq('EL_SUBNATL_AGENCY_STATUS_ID'), ",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '",
  trimws(example$com.cdc), 
  "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'BC Conservation Data Centre','N/A', 'ida lmh77');"
)

# 11. INSERT Statements for BC_COMM_SUB_ECOSYS_GRP 
example$eco.grp.sql <- paste0(
  "INSERT INTO bc_comm_sub_ecosys_grp (BC_COMM_SUB_ECOSYS_GRP_ID, ELEMENT_SUBNATIONAL_ID, ECOSYS_GRP_ID, DATE_ASSESSED, REC_CREATE_USER) 
  VALUES (","getnextseq('BC_COMM_SUB_ECOSYS_GRP_ID'), ",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '",
  trimws(example$com.cdc), 
  "' AND REC_CREATE_USER = 'ida lmh77'), ","'", trimws(example$eco.grp), "', '2025-07-15', 'ida lmh77');"
)
  
  
# Open a connection to the output SQL file
sql_file <- file("Ecology_Element_Insert.sql", open = "wt")
# Loop through each row and write the SQL statements in order, with a blank line between sets
for (i in 1:nrow(example)) {
  writeLines(example$sci.name.cdc.sql[i], sql_file)
  writeLines(example$sci.name.bec.sql[i], sql_file)
  writeLines(example$elem.glo.sql[i], sql_file)
  writeLines(example$sci.ref.sql[i], sql_file)
  writeLines(example$elem.nat.sql[i],sql_file)
  writeLines(example$com.nat.sql[i],sql_file)
  writeLines(example$elem.sub.sql[i],sql_file)
  writeLines(example$com.sub.sql[i],sql_file)
  writeLines(example$sub.ref.vh.sql[i],sql_file)
  writeLines(example$sub.ref.77.sql[i],sql_file)
  writeLines(example$sub.ref.52.sql[i],sql_file)
  writeLines(example$oth.sub.com.sql[i],sql_file)
  writeLines(example$agen.stat.sql[i],sql_file)
  writeLines(example$eco.grp.sql[i],sql_file)
  writeLines("", sql_file) # Add a blank line between each set
}
# Close the file connection
close(sql_file)

write.csv(example,file = "Ecology_Element_Insert.csv")

###########################################
#### PART 2 BGC Range ####
###########################################
BGCexample <- data.frame(
  com.cdc = c("Cattail Marsh", "Cattail Marsh", "Cattail Marsh", "Cattail Marsh", "Cattail Marsh"),
  bgc = c("ICHxw", "MSdw", "IDFxv", "BGxh1", "PPdh2"),
  ss = c("Wm05","01","02","11","Wm05")
  )

# 12. INSERT Statements for BC_COMM_SUB_BGC 
#E26MAC01BCCA is the 2026 BEC vegetation hierarchy
BGCexample$eco.grp.sql <- paste0(
  "INSERT INTO bc_comm_sub_bgc (BC_COMM_SUB_BGC_ID, ELEMENT_SUBNATIONAL_ID, BGC_CD, SITE_SERIES, D_OCCURRENCE_STATUS_ID, NOTE, REC_CREATE_USER) VALUES (",
  "getnextseq('BC_COMM_SUB_BGC_ID'), ",
  "(SELECT ELEMENT_SUBNATIONAL_ID FROM element_subnational WHERE S_PRIMARY_COMMON_NAME = '",
  trimws(BGCexample$com.cdc), 
  "' AND REC_CREATE_USER = 'ida lmh77'), ",
  "'", trimws(BGCexample$bgc), "', ",
  "'", trimws(BGCexample$ss), "', ",
  "1, 'Reference: E26MAC01BCCA', ",
  "'ida lmh77');"
)

sql_file <- file("Ecology_BGC_Insert.sql", open = "wt")
# Loop through each row and write the SQL statements in order, with a blank line between sets
for (i in 1:nrow(BGCexample)) {
  writeLines(BGCexample$eco.grp.sql[i], sql_file)

}
# Close the file connection
close(sql_file)

write.csv(example,file = "Ecology_BGC_Insert.csv")
