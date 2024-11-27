# Opret forbindelse til MySQL
con <- dbConnect(
  RMySQL::MySQL(),
  dbname = "Biler",          # Navn på databasen
  host = "localhost",        # Adresse til databasen
  port = 3306,               # Porten (standard er 3306 for MySQL)
  user = "root",       # Dit MySQL-brugernavn
  password = "*" # Dit MySQL-password
)


# Vælg kun de nødvendige kolonner
colnames(Alle_biler)
data_to_insert <- Alle_biler %>%
  dplyr::select(carid = carid, model = model, Fra_Land = Fra_Land, link = link, price = price, 
                Kilometer = Kilometer, forhandlerID = forhandlerID, Scrapedate = Scrapedate, location = location,
                Dato = Dato)


# Loop til tabel 1: Forhandler
for (i in 1:nrow(data_to_insert)) {
  tryCatch({
    row <- data_to_insert[i, ]
    forhandlerID <- as.character(row$forhandlerID)
    location <- as.character(row$location)
    
    query <- sprintf(
      "INSERT INTO Forhandler (forhandlerID, location) 
      VALUES ('%s', '%s')",
      forhandlerID, location
    )
    dbExecute(con, query)
  }, error = function(e) {
    cat("Fejl ved indsættelse i Forhandler, række:", i, "\n", e$message, "\n")
  })
}

# Loop til tabel 2: Biler
for (i in 1:nrow(data_to_insert)) {
  tryCatch({
    row <- data_to_insert[i, ]
    carid <- as.integer(row$carid)
    model <- as.character(row$model)
    Fra_Land <- as.character(row$Fra_Land)
    link <- as.character(row$link)
    forhandlerID <- as.character(row$forhandlerID)
    
    query <- sprintf(
      "INSERT INTO Biler (carid, model, Fra_Land, link, forhandlerID) 
      VALUES (%d, '%s', '%s', '%s', '%s')",
      carid, model, Fra_Land, link, forhandlerID
    )
    dbExecute(con, query)
  }, error = function(e) {
    cat("Fejl ved indsættelse i Biler, række:", i, "\n", e$message, "\n")
  })
}

# Loop til tabel 3: Bilpriser
for (i in 1:nrow(data_to_insert)) {
  tryCatch({
    row <- data_to_insert[i, ]
    carid <- as.integer(row$carid)
    Dato <- as.Date(row$Dato)
    price <- as.integer(row$price)
    Kilometer <- as.integer(row$Kilometer)
    Scrapedate <- as_datetime(row$Scrapedate)
    
    query <- sprintf(
      "INSERT INTO Bilpriser (carid, Dato, price, Kilometer, Scrapedate) 
      VALUES (%d, '%s', %d, %d, '%s')",
      carid, Dato, price, Kilometer, Scrapedate
    )
    dbExecute(con, query)
  }, error = function(e) {
    cat("Fejl ved indsættelse i Bilpriser, række:", i, "\n", e$message, "\n")
  })
}


