library(readxl)
library(tidyr)
library(dplyr)

df <- read_excel("./collected_data.xlsx")

### COLLECTED DATA TO RAW DATA -------------------------------------------------
## Filtering unfinished surveys
df <- df |>
  filter(Finished == "True")

## Renaming columns 
# Creating a function to change posts columns names according to:
# 1. stimulus type (anti/pro, left/right)
# 2. rating type (support/extreme ratings)
rename_columns <- function(df, cols, prefix, idx, question_type) {
  df |>
    rename_with(
      .cols = all_of(cols),
      .fn = ~ {
        suffix <- rep(question_type, times = length(idx))
        paste0(prefix, "_", rep(idx, each = 2), "_", suffix)})}

# Renaming all columns
question_type <- c("support", "extreme")
idx <- 1:18
df <- df |>
  rename_columns(20:55, "pro_right", idx, question_type) |>
  rename_columns(56:91, "anti_left", idx, question_type) |>
  rename_columns(92:127, "pro_left", idx, question_type) |>
  rename_columns(128:163, "anti_right", idx, question_type) |>
  rename(
    sample_rating            = Q327_1,
    subject_code             = Q471,
    political_involvement    = Q54_1,
    political_camp_raw       = Q56_1,
    government_support_raw   = Q270_1,
    coalition_opposition_raw = Q399_1,
    voting_party             = Q397,
    gender                   = Q96,
    gender_text              = Q96_3_TEXT,
    age                      = Q97,
    education                = Q473,
    education_text           = Q473_7_TEXT,
    mother_tongue            = Q328,
    mother_tongue_text       = Q328_6_TEXT)

## Coding variable
df <- df |>
  mutate(
    # Demographics
    age = as.numeric(age),
    gender = as.factor(case_when(
      gender == "גבר" ~ "male",
      gender == "אישה" ~ "female")), 
    education = case_when(
      education == "תיכונית מלאה" ~ "high school",
      education == "על-תיכונית" ~ "tertiary",
      education == "תואר ראשון" ~ "BA/BSc",
      education == "תואר שני ומעלה"~ "MA and above",
      education == "אחר" ~ "other"),
    mother_tongue = case_when(
      mother_tongue == "עברית" ~ "hebrew",
      TRUE ~ "other"),
    # Political orientation
    political_camp_raw       = as.numeric(political_camp_raw),
    government_support_raw   = as.numeric(government_support_raw),
    coalition_opposition_raw = as.numeric(coalition_opposition_raw),
    political_involvement    = as.numeric(political_involvement),
    political_camp = as.factor(case_when(
      political_camp_raw >= 60 ~ "left",
      political_camp_raw <= 40 ~ "right",
      TRUE ~ "undecided")),
    government_support = as.factor(case_when(
      government_support_raw >= 60 ~ "Benet-Lapid",
      government_support_raw <= 40 ~ "Netanyahu",
      TRUE ~ "neutral")),
    coalition_opposition = as.factor(case_when(
      coalition_opposition_raw >= 60 ~ "opposition",
      coalition_opposition_raw <= 40 ~ "coalition",
      TRUE ~ "unclear")))

## mutating dates
df <- df |>
  mutate(
    StartDate    = as.Date(as.numeric(StartDate), origin = "1899-12-30"),
    EndDate      = as.Date(as.numeric(EndDate), origin = "1899-12-30"),
    RecordedDate = as.Date(as.numeric(RecordedDate), origin = "1899-12-30"))

## deleting unnecessary columns
df <- df |>
  mutate(
    Status              = NULL,
    IPAddress           = NULL,
    ResponseId          = NULL,
    RecipientFirstName  = NULL, 
    RecipientLastName   = NULL,
    RecipientEmail      = NULL,
    ExternalReference   = NULL,
    LocationLatitude    = NULL,
    LocationLongitude   = NULL,
    DistributionChannel = NULL,
    "NA"                = NULL)

# Saving the raw data in a wide format before converting to a long format
write.csv(df, "./raw_data_wide.csv")

## Converting to a wide format
df <- df |>
  pivot_longer(
    cols = starts_with("pro") | starts_with("anti"),   
    names_to = c("stimulus_type", "index", "question_type"),  
    names_pattern = "(.*)_(.*)_(.*)", 
    values_to = "rating")

# Separating question type to two variables - support and extreme rating
df <- df |>
  pivot_wider(
    names_from = question_type, 
    values_from = rating,
    names_prefix =  "") |>
  mutate(
    stimulus_identity = paste(stimulus_type, index, sep = "_"),
    support = as.numeric(support),
    extreme = as.numeric(extreme),
    stimulus_type = factor(stimulus_type,  levels = c("pro_right", "anti_left", "pro_left", "anti_right")))

# Saving the raw data on a long format
write.csv(df, "./raw_data_long.csv")
save(df, file = "raw_data_long.RData")
