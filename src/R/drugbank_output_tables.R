
# PURPOSE -----------------------------------------------------------------

#' To output the drugbnank parsed tables from dbparser
#' 



# load library ------------------------------------------------------------

library(dbparser)

# load data ---------------------------------------------------------------

out <- "../../data/"
drugbank_out <- paste0(out,"drugbank/")
if(!dir.exists(drugbank_out)){
  dir.create(drugbank_out, showWarnings = F)
}

database_connection <- DBI::dbConnect(RSQLite::SQLite(), "../../drugbank.sqlite")

#downloaded xml on 20200923
read_drugbank_xml_db(paste0(out,"drugbank_all_full_database.xml.zip"))

run_all_parsers(save_table = T, save_csv = T, csv_path = drugbank_out, database_connection = database_connection)


