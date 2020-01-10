library(tidyr)
library(here)
library(readr)
library(stringr)

# Prep RAYYAN extract for ML ----------------------------------------------

df <- read.csv(here("data","rayyan_articles.csv"))

# Remove day/month
df <- df[,c(1:3,6:17)]

df$notes  <- gsub("RAYYAN", "| RAYYAN", df$notes)

df2 <- separate(df, notes, c("notes","relevant", "notes3", "labels"), sep = "\\|") 

df2 <- df2[,c(1:14,16,18)]


df2$relevant <- gsub("RAYYAN-INCLUSION: \\{\"Luke\"=>\"Excluded\"\\}", "0",df2$relevant)
df2$relevant <- gsub("RAYYAN-INCLUSION: \\{\"Luke\"=>\"Included\"\\}", "1",df2$relevant)
df2$relevant <- gsub("RAYYAN-INCLUSION: \\{\"Luke\"=>\"Maybe\"\\}", "0",df2$relevant)

df2$labels  <- gsub("RAYYAN-LABELS:", "",df2$labels)


# Map keywords from Endnote extract ---------------------------------------

#Ensure that keywords are column 17

df3 <- read.csv(here("data","endnote_keywords.csv"), header = FALSE)

df3 <- df3[,(c(11,4,14,13,15))]

colnames(df3)[1] <- "url"
colnames(df3)[2] <- "title"
colnames(df3)[3] <- "abstract"
colnames(df3)[4] <- "keywords"

df3$keywords <- gsub(";", "; ", df3$keywords)

df4 <- df2[,c(10,2,14,15)]

df5 <- merge(df4, df3 , by=c("url"), all.x = TRUE)

df6 <- df5[,c(2:4,7)]

df6$relevant<-as.numeric(df6$relevant)

# Extract 'mini' dataframe ------------------------------------------------


#Ensure that keywords are column 17
mini_df <- df6[,c(3,1,2,4)]

colnames(mini_df)[2] <- "title"
colnames(mini_df)[3] <- "abstract"

write_csv(mini_df, here("data", "lipids_dem_ml_data.csv"), col_names = FALSE)



# Extracted included record numbers ---------------------------------------

df5$relevant <- as.numeric(df5$relevant)

df_included <- df5[which(df5$relevant==1),]

writeLines(test, here("data","included_record_numbers.txt"))
