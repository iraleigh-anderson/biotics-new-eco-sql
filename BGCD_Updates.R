library(tidyverse)
library(readr)
library(glue)
#### IMPORTS ####
BGCD <- read_csv("data/BC_D_BGC_ZSVP.csv") #Domain for Biotics BGC extensible table
BEC13 <- read_csv("data/BEC13.csv")
#### COMPARE BIOTICS DOMAIN TABLE AGAINST BEC13 ####