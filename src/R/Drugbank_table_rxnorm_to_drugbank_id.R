
# PURPOSE -----------------------------------------------------------------

#' To make a table linking RxNorm ids to Drugbank ids


# load libraries ----------------------------------------------------------

library(tidyverse)
library(data.table)

# load data ---------------------------------------------------------------

drug_atc_codes <- fread("../../data/drugbank/drug_atc_codes.csv")

concept <- fread("../../vocabulary_various/CONCEPT.csv",sep="\t")[,.(concept_id,concept_code,
                                                                                      concept_name,concept_class_id)] %>% 
  unique()

concept_relationship <- fread("../../vocabulary_various/CONCEPT_RELATIONSHIP.csv",sep="\t")

# join --------------------------------------------------------------------

atc_code_concepts <- concept[concept_code %in% drug_atc_codes$atc_code,
                           .(atc_code = concept_code,
                             atc_concept_id = concept_id)] %>% 
  unique()


relationships <- 
  concept_relationship[relationship_id=="ATC - RxNorm",
                     .(concept_id_1,concept_id_2)] %>% 
  unique()


atc_code_merged <- 
  merge(
    atc_code_concepts,
    relationships,
    by.x="atc_concept_id",
    by.y="concept_id_1"
)

rxnorm_merged <- merge(
  concept,
  atc_code_merged,
  by.x="concept_id",
  by.y="concept_id_2"
)

setnames(rxnorm_merged,
         old=c("concept_id",
               "concept_code",
               "concept_name",
               "concept_class_id"),
         new=c("rxnorm_concept_id",
               "rxnorm_concept_code",
               "rxnorm_concept_name",
               "rxnorm_concept_class_id")
         )

atc_rxnorm_merged <- 
  merge(
    drug_atc_codes,
    rxnorm_merged,
    by="atc_code"
  )[,c("atc_code",
       "level_1","code_1",
       "level_2","code_2",
       "level_3","code_3",
       "level_4","code_4",
       "drugbank-id",
       "atc_concept_id",
       "rxnorm_concept_id",
       "rxnorm_concept_code",
       "rxnorm_concept_name",
       "rxnorm_concept_class_id"),
    with=F] %>% 
  unique()

atc_rxnorm_merged %>% 
  write_csv("../../data/drugbank/drug_atc_codes_rxnorm_joined.csv")

database_connection <- DBI::dbConnect(RSQLite::SQLite(), "../../drugbank.sqlite")

dplyr::copy_to(database_connection,atc_rxnorm_merged,name="drug_atc_rxnorm_merged",temporary=F)

DBI::dbDisconnect(database_connection)
