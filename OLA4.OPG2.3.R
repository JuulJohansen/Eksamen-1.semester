# Rens DK
simulated_results$Fra_Land <- "DK"

simulated_results <- simulated_results %>%
  mutate(
    Dato = sub("^(\\d+/\\d{4}).*", "\\1", property),
    Kilometer = sub("^\\d+/\\d{4}(.*)", "\\1", property) 
  )

simulated_results <- simulated_results[,c(-2,-4)]

# Nyt dataset
simulated_results1 <- simulated_results

# ForhandlerID
simulated_results1$forhandlerID[is.na(simulated_results1$forhandlerID)] <- "PrivatForhandler"

# Pris
simulated_results1$price <- gsub("kr.", "", simulated_results1$price)
simulated_results1$price <- gsub("[^0-9.,]", "", simulated_results1$price)
simulated_results1$price <- gsub("\\.", "", simulated_results1$price)
simulated_results1$price <- as.integer(simulated_results1$price)

# Kilometer
simulated_results1$Kilometer <- gsub(" km-", "", simulated_results1$Kilometer)
simulated_results1$Kilometer <- as.numeric(gsub("\\.", "", simulated_results1$Kilometer))
simulated_results1$Kilometer <- as.integer(simulated_results1$Kilometer)

# Carid
simulated_results1$carid <- as.integer(simulated_results1$carid)

# Dato
simulated_results1$Dato <- gsub("^(\\d{1})/", "0\\1/", simulated_results1$Dato)
# Tilføj "01/" foran datoer med format MM/YYYY
simulated_results1$Dato <- ifelse(grepl("^\\d{2}/\\d{4}$", simulated_results1$Dato),
                                  paste0("01/", simulated_results1$Dato),
                                  simulated_results1$Dato)

# Konverter til Date-format
simulated_results1$Dato <- as.Date(simulated_results1$Dato, format = "%d/%m/%Y")


con1 <- dbConnect(
  RMySQL::MySQL(),
  dbname = "Biler",          # Navn på databasen
  host = "localhost",        # Adresse til databasen
  port = 3306,               # Porten (standard er 3306 for MySQL)
  user = "root",       # Dit MySQL-brugernavn
  password = "Rev1l0 hceb" # Dit MySQL-password
)

# Upload til en ny tabel i databasen
dbWriteTable(con1, "simulated_data", simulated_results1, overwrite = TRUE, row.names = FALSE)

# Kontrollér, at tabellen blev oprettet
dbGetQuery(con1, "SHOW TABLES")



#Test - Henter data fra SQL ind i R
simulated_data <- dbGetQuery(con, "SELECT * FROM Combined_Data")
#Gør det til en karakter
simulated_data <- simulated_data %>%
  mutate(CarId = as.integer(CarId))

colnames(calldf)
colnames(simulated_data)

#Matcher kolonne navne og sletter det der ikke er nødvendigt
calldf_renamed <- calldf1 %>%
  rename(
    CarId = carid,                 # Match CarId
    NewPrice = price,              # Match NewPrice
    NewScrapeDate = Sys.time..,    # Match NewScrapeDate
    OldPrice = NULL,               # Ikke relevant i calldf
    OldScrapeDate = NULL,          # Ikke relevant i calldf
    SOLD = NULL,                   # Bliver beregnet
    PriceStatus = NULL,            # Bliver beregnet
    IsNewCar = NULL                # Bliver beregnet
  ) %>%
  select(CarId, NewPrice, NewScrapeDate)  # Behold kun relevante kolonner


#Merger de to dataset
merged_data <- full_join(simulated_data, calldf_renamed, by = "CarId")

#Tilpas kolonnenavnene efter join
merged_data <- merged_data %>%
  rename(
    NewPrice = NewPrice.y,          # Behold 'NewPrice' fra det nye dataset
    NewScrapeDate = NewScrapeDate.y # Behold 'NewScrapeDate' fra det nye dataset
  ) %>%
  select(
    CarId, OldPrice, NewPrice, OldScrapeDate, NewScrapeDate, SOLD, PriceStatus, IsNewCar
  )


#Opdatere kolonnerne for at se om bilerne er solgt eller pris ændret
merged_data <- merged_data %>%
  mutate(
    # Markér som SOLGT, hvis der ikke findes en ny scraping dato og pris
    SOLD = ifelse(is.na(NewPrice), "TRUE", "FALSE"),
    
    # Opdater PRICESTATUS baseret på prisændring
    PriceStatus = case_when(
      is.na(NewPrice) ~ NA_character_,            # Hvis bilen er solgt
      OldPrice == NewPrice ~ "UÆNDRET",           # Hvis prisen er uændret
      OldPrice != NewPrice ~ "ÆNDRET"             # Hvis prisen er ændret
    ),
    
    # Markér som NY bil, hvis den ikke fandtes i det gamle datasæt
    IsNewCar = ifelse(is.na(OldPrice), "TRUE", "FALSE")
  )


#Beregn antallet af nye biler, solgte biler og biler med ændret pris
summary_stats <- merged_data %>%
  summarize(
    Nye_Biler = sum(IsNewCar == "TRUE", na.rm = TRUE),
    Solgte_Biler = sum(SOLD == "TRUE", na.rm = TRUE),
    Pris_Ændret = sum(PriceStatus == "ÆNDRET", na.rm = TRUE)
  )

summary_long <- summary_stats %>%
  tidyr::pivot_longer(cols = everything(), names_to = "Kategori", values_to = "Antal")

# 3. Lav et søjlediagram
ggplot(summary_long, aes(x = Kategori, y = Antal, fill = Kategori)) +
  geom_col() +
  geom_text(aes(label = Antal), vjust = -0.5, size = 5) +
  labs(title = "178 biler er blevet solgt siden sidste scrape for 20 dage siden",
       x = "Kategori",
       y = "Antal Biler") +
  theme_minimal()

#Plot








