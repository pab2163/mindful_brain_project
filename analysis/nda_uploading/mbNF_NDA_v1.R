#setup mbNF NDA uploads
#David Pagliaccio 06/27/24


# Create folder for current upload & download full dataset from redcap as raw data CSV
UPLOAD <- "1_2024July/"

## SETUP ----
library(tidyverse)
library(lubridate)
rootpath <- "/Volumes/columbia/mbNF_MDD/DATA/NDA_uploads/"

## LOAD DATA ----
redcap_df <- read.csv(list.files(path=str_c(rootpath,UPLOAD), pattern = "REMINDMindfulnessBas_DATA*", full.names = T))

## FILTER ONLY PEOPLE WITH GUID, ONLY POSTCONSENT DATA, ONLY CONSENTED/ENROLLED
redcap_df <- redcap_df %>% filter(record_id %in% redcap_df$record_id[redcap_df$nda_guid!=""])
redcap_df <- redcap_df %>% filter(record_id %in% redcap_df$record_id[redcap_df$plog_status >= 4 & !is.na(redcap_df$plog_status)])

redcap_df <- redcap_df %>% filter(redcap_event_name != "closeout_arm_2" & redcap_event_name != "consent_arm_2"  & redcap_event_name != "reconsent_arm_2") #dont need close out data
redcap_df[redcap_df==""]<-NA


## FORMAT VARIABLES REQUIRED ON ALL FORMS
redcap_df$subjectkey <- redcap_df$nda_guid #RENAME GUID
redcap_df <- redcap_df %>% group_by(record_id) %>% fill(subjectkey) %>% ungroup() # FILL GUID ON ALL EVENTS
redcap_df$src_subject_id <- redcap_df$record_id #RENAME ID
redcap_df <- redcap_df %>% mutate(interview_date = case_when(redcap_event_name=="prescreen_arm_2" ~ screen_date,
                                                redcap_event_name=="prescan_arm_2" ~ scan_date,
                                               redcap_event_name=="postmindfulness_arm_2" ~ scan_date[redcap_event_name=="prescan_arm_2"],.default=visit_date)) #RENAME DATE

redcap_df <- redcap_df %>% mutate(sex = case_match(demo_child_sex, 1~"M", 2~"F",3~"O")) #RENAME SEX M = Male; F = Female; O=Other; NR = Not reported
redcap_df <- redcap_df %>% group_by(src_subject_id) %>% fill(sex, .direction = "updown") %>% ungroup() # FILL SEX ON ALL EVENTS

redcap_df <- redcap_df %>% group_by(src_subject_id) %>% fill(dob) %>% ungroup() # FILL SEX ON ALL EVENTS
redcap_df <- redcap_df %>% mutate(interview_age = interval(ymd(dob), ymd(interview_date)) %/% months(1))

redcap_df$interview_date <- format(as.Date(redcap_df$interview_date, format="%Y-%m-%d"), format="%m/%d/%Y")

                                        
redcap_df <- redcap_df %>% mutate(race = case_when(demo_child_race___1==1 ~ "American Indian/Alaska Native",
                                               demo_child_race___2==1 ~ "Asian",
                                               demo_child_race___3==1 ~ "Hawaiian or Pacific Islander",
                                               demo_child_race___4==1 ~ "Black or African American",
                                               demo_child_race___5==1 ~ "White",
                                               demo_child_race___6==1 ~ "More than one race",
                                               demo_child_race___7==1 ~ "Other",
                                               demo_child_race___8==1 ~ "Other",.default=NA)) #RENAME RACE                   
redcap_df <- redcap_df %>% group_by(src_subject_id) %>% fill(race, .direction = "updown") %>% ungroup() # FILL RACE ON ALL EVENTS


redcap_df <- redcap_df %>% group_by(src_subject_id) %>% fill(site, .direction = "updown") %>% ungroup() # FILL site ON ALL EVENTS
redcap_df$site <- case_match(redcap_df$site,1~"New York",2~"Boston",.default=NA)

redcap_df <- redcap_df %>% group_by(src_subject_id) %>% fill(condition, .direction = "updown") %>% ungroup() # FILL condition ON ALL EVENTS
redcap_df$trtarm <- case_match(redcap_df$condition,0~"15 minutes",1~"30 minutes",.default=NA)



#remove prescreen data?
redcap_df <- redcap_df %>% filter(redcap_event_name != "prescreen_arm_2")


redcap_df <- redcap_df %>% mutate(visit = str_remove(redcap_event_name,"_arm_2")) #RENAME visit



## ndar_subject01_template.csv ----
ndar_subject01_template <- read.csv(file = str_c(rootpath,"/NDA_Templates/ndar_subject01_template.csv"),skip = 1)

redcap_df$phenotype <- "MDD"
redcap_df$phenotype_description <- "MDD"
redcap_df$twins_study <- "No"
redcap_df$sibling_study <- "No"
redcap_df$family_study <- "No"
redcap_df$sample_taken <- "No"


tofill <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","race","phenotype","phenotype_description","twins_study","sibling_study","family_study","sample_taken","visit","trtarm")
ndar_subject01_template[1:NROW(redcap_df),] <- NA
ndar_subject01_template[,tofill] <- redcap_df[,tofill]


file.copy(str_c(rootpath,"/NDA_Templates/ndar_subject01_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = ndar_subject01_template, file = str_c(rootpath,UPLOAD,"ndar_subject01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

rm(tofill)

# CDRS cdrsr01_template.csv ----
cdrsr01_template <- read.csv(file = str_c(rootpath,"/NDA_Templates/cdrsr01_template.csv"),skip = 1)


tofill <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","cdrs1au","cdrs2au","cdrs3au","cdrs4au","cdrs5au","cdrs6au","cdrs7au","cdrs8au","cdrs9au","cdrs10au","cdrs11au","cdrs12au","cdrs13au","cdrs14au","cdrs15bu","cdrs16bu","cdrs17bu" ,"visit")
cdrsr01_template[1:sum(!is.na(redcap_df$cdrsr_complete)),] <- NA
cdrsr01_template[,tofill] <- redcap_df[!is.na(redcap_df$cdrsr_complete),tofill]


file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/cdrsr01_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = cdrsr01_template, file = str_c(rootpath,UPLOAD,"cdrsr01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

rm(tofill,cdrsr01_template)


# MFQ mfq01_template.csv ----
mfq01_template <- read.csv(file = str_c(rootpath,"/NDA_Templates/mfq01_template.csv"),skip = 1)

#no item 34 = mfqc6_5
tofillT <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","mfqc1_1","mfqc1_2","mfqc1_3","mfqc1_4","mfqc1_5","mfqc1_6","mfqc2_1","mfqc2_2","mfqc2_3","mfqc2_4","mfqc2_5","mfqc2_6","mfqc3_1","mfqc3_2","mfqc3_3","mfqc3_4","mfqc3_5","mfqc3_6","mfqc4_1","mfqc4_2","mfqc4_3","mfqc4_4","mfqc4_5","mfqc4_6","mfqc5_1","mfqc5_2","mfqc5_3","mfqc5_4","mfqc5_5","mfqc6_1","mfqc6_2","mfqc6_3","mfqc6_4","visit")
tofillR <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","mfq1","mfq2","mfq3","mfq4","mfq5","mfq6","mfq7","mfq8","mfq9","mfq10","mfq11","mfq12","mfq13","mfq14","mfq15","mfq16","mfq17","mfq18","mfq19","mfq20","mfq21","mfq22","mfq23" ,"mfq24","mfq25","mfq26","mfq27","mfq28","mfq29","mfq30","mfq31", "mfq32","mfq33","visit")

# add 1 to match template scoring 1-3 instead of 0-2
redcap_df <- redcap_df %>% mutate(across(mfq1:mfq33, ~ .x + 1))

mfq01_template[1:sum(!is.na(redcap_df$mfq_complete)),] <- NA
mfq01_template[,tofillT] <- redcap_df[!is.na(redcap_df$mfq_complete),tofillR]


file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/mfq01_template.csv"), to = str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = mfq01_template, file = str_c(rootpath,UPLOAD,"mfq01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

rm(tofillT,tofillR,mfq01_template)


# FFMQ ffmq01_template.csv ----
ffmq01_template <- read.csv(file = str_c(rootpath,"/NDA_Templates/ffmq01_template.csv"),skip = 1)

tofill <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","ffmq1","ffmq2","ffmq3","ffmq4","ffmq5","ffmq6","ffmq7","ffmq8","ffmq9","ffmq10","ffmq11","ffmq12","ffmq13","ffmq14","ffmq15","ffmq16","ffmq17","ffmq18","ffmq19","ffmq20","ffmq21","ffmq22","ffmq23","ffmq24","ffmq25","ffmq26","ffmq27","ffmq28","ffmq29","ffmq30","ffmq31","ffmq32","ffmq33","ffmq34","ffmq35","ffmq36","ffmq37","ffmq38","ffmq39" ,"visit")

# add 1 to match template scoring 1-5 instead of 0-4
redcap_df <- redcap_df %>% mutate(across(ffmq1:ffmq39, ~ .x + 1))

ffmq01_template[1:sum(!is.na(redcap_df$ffmq_complete)),] <- NA
ffmq01_template[,tofill] <- redcap_df[!is.na(redcap_df$ffmq_complete),tofill]


file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/ffmq01_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = ffmq01_template, file = str_c(rootpath,UPLOAD,"ffmq01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

rm(tofill,ffmq01_template)


# RCADS cde_rcadsyouth01_template ----

# CHECK VISIT COLUMN!!!
cde_rcadsyouth01_template <- read.csv(file = str_c(rootpath,"/NDA_Templates/cde_rcadsyouth01_template.csv"),skip = 1)

# add 1 to match template scoring 1-4 instead of 0-3
redcap_df <- redcap_df %>% mutate(across(rcads_1:rcads_47, ~ .x + 1))

redcap_df$rcads_y26 <- 1 # English language version

#relabel to match subset of items in template 
tofillT <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","rcads_y01","rcads_y02","rcads_y03","rcads_y04","rcads_y05","rcads_y06","rcads_y07","rcads_y08","rcads_y09","rcads_y10","rcads_y11","rcads_y12","rcads_y13","rcads_y14","rcads_y15","rcads_y16","rcads_y17","rcads_y18","rcads_y19","rcads_y20","rcads_y21","rcads_y22","rcads_y23","rcads_y24","rcads_y25","rcads_y26")
tofillR <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","rcads_2","rcads_4","rcads_5","rcads_6","rcads_13","rcads_33","rcads_32","rcads_11","rcads_17","rcads_15","rcads_36","rcads_42","rcads_19","rcads_26","rcads_25","rcads_29","rcads_31","rcads_37","rcads_40","rcads_41","rcads_21","rcads_43","rcads_44","rcads_47","rcads_27","rcads_y26")


cde_rcadsyouth01_template[1:sum(!is.na(redcap_df$rcads_complete)),] <- NA
cde_rcadsyouth01_template[,tofillT] <- redcap_df[!is.na(redcap_df$rcads_complete),tofillR]


file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/cde_rcadsyouth01_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = cde_rcadsyouth01_template, file = str_c(rootpath,UPLOAD,"cde_rcadsyouth01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

rm(tofillT,tofillR,cde_rcadsyouth01_template)

# Handedness cde_rcadsyouth01_template ----
chaphand01_template <- read.csv(file = str_c(rootpath,"/NDA_Templates/chaphand01_template.csv"),skip = 1)

#relabel to match subset of items in template - no item 3
tofillT <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","hu001","hu002","hu004","hu005","hu006","hu007","hu008","hu009","hu010","hu011","hu012","hu013","hu014","visit")
tofillR <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","hu001","hu002","hu003","hu004","hu005","hu006","hu007","hu008","hu009","hu010","hu011","hu012","hu013","visit")

chaphand01_template[1:sum(!is.na(redcap_df$handedness_complete)),] <- NA
chaphand01_template[,tofillT] <- redcap_df[!is.na(redcap_df$handedness_complete),tofillR]


file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/chaphand01_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = chaphand01_template, file = str_c(rootpath,UPLOAD,"chaphand01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

rm(tofillT,tofillR,chaphand01_template)


# WASI wasi201_template ----
wasi201_template <- read.csv(file = str_c(rootpath,"/NDA_Templates/wasi201_template.csv"),skip = 1)

#relabel to match template -- DOUBLE CHECK
tofillT <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","vocab_totalrawscore","ss_vocabularytscore2","matrix_totalrawscore" ,"ss_matrixreasoningtscore2" ,"iqscores_full2sumtscores","visit")
tofillR <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","vocabulary_total_score","vocabulary_t_score","matrix_reasoning_total_raw" ,"matrix_reasoning_total_t" ,"full_scale_2_t_score","visit")

wasi201_template[1:sum(!is.na(redcap_df$wasi_scoring_complete)),] <- NA
wasi201_template[,tofillT] <- redcap_df[!is.na(redcap_df$wasi_scoring_complete),tofillR]


file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/wasi201_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = wasi201_template, file = str_c(rootpath,UPLOAD,"wasi201_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

rm(tofillT,tofillR,wasi201_template)


# RRS ffmq01_template.csv ----
rrs01_template <- read.csv(file = str_c(rootpath,"/NDA_Templates/rrs01_template.csv"),skip = 1)

tofill <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex","rrs_1","rrs_2","rrs_3","rrs_4","rrs_5","rrs_6","rrs_7","rrs_8","rrs_9","rrs_10","rrs_11","rrs_12","rrs_13","rrs_14","rrs_15","rrs_16","rrs_17","rrs_18","rrs_19","rrs_20","rrs_21","rrs_22" ,"visit")

# add 1 to match template scoring 1-4 instead of 0-3
redcap_df <- redcap_df %>% mutate(across(rrs_1:rrs_22, ~ .x + 1))

rrs01_template[1:sum(!is.na(redcap_df$rrs_complete)),] <- NA
rrs01_template[,tofill] <- redcap_df[!is.na(redcap_df$rrs_complete),tofill]


file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/rrs01_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = rrs01_template, file = str_c(rootpath,UPLOAD,"rrs01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

rm(tofill,rrs01_template)


# Tanner
names(redcap_df)[grep("tann",names(redcap_df))]


tofillT <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex", "tsf1", "tsf2", "tsf3", "pubertyg_19", "pubertyg_20", "pubertyb_17", "pubertyb_18", "pubertyg_14", "pubertyg_15", "pubertyb_9", "pubertyb_16", "pubertyg_13", "visit", "pubertyb_11", "pubertyb_14")
tofillR <- c("subjectkey","src_subject_id", "interview_date","interview_age","sex", "tanner_2a", "tanner_3a", "tanner_4a", "tanner_5a_f", "tanner_6a_f", "tanner_5a_m", "tanner_6a_m", "tanner_7_f", "tanner_7b_f", "pubertyb_9", "puberty_13", "puberty_13", "visit", "pubertyb_11", "pubertyb_14")   

pubscrn01_template <- read.csv(file = str_c(rootpath,"../Codebook/NDA_Templates/pubscrn01_template.csv"),skip = 1)



pubscrn01_template[1:sum(!is.na(redcap_df$tanner_complete)),] <- NA
pubscrn01_template[,tofillT] <- redcap_df[!is.na(redcap_df$tanner_complete),tofillR]

# make blank items that don't match the participant sex
pubscrn01_template = mutate(pubscrn01_template,
                            pubertyb_16 = ifelse(sex == "M", pubertyb_16, ""),
                            pubertyg_13 = ifelse(sex == "F", pubertyg_13, ""))


#pubscrn01_template = mutate(pubscrn01_template, )

file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/pubscrn01_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = pubscrn01_template, file = str_c(rootpath,UPLOAD,"pubscrn01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

rm(tofillT,tofillR, pubscrn01_template)

# Service use
maps_serviceuse01_template <- read.csv(file = str_c(rootpath,"../Codebook/NDA_Templates/maps_serviceuse01_template.csv"),skip = 1)
maps_serviceuse01_key = read.csv(file = str_c(rootpath,"../Codebook/NDA_Templates/maps_serviceuse01_redcap_to_template.csv")) 

# only use variables from the "key" between redcap and template where we have made a match
maps_serviceuse01_key[maps_serviceuse01_key == ''] = NA
maps_serviceuse01_key = maps_serviceuse01_key %>% 
  tidyr::drop_na()

# Match up different definitions of medications
redcap_df = mutate(redcap_df, 
                  su_curr_meds_type = case_when(
                      su_curr_meds_type___1 == 1 ~ 1,
                      su_curr_meds_type___2 == 1 ~ 4,
                      su_curr_meds_type___3 == 1 ~ 2,
                      su_curr_meds_type___4 == 1 ~ 6,
                      su_curr_meds_type___5 == 1 ~ 3,
                      su_curr_meds_type___6 == 1 ~ 6),
                  su_start_meds_type = case_when(
                      su_start_meds_type___1 == 1 ~ 1,
                      su_start_meds_type___2 == 1 ~ 4,
                      su_start_meds_type___3 == 1 ~ 2,
                      su_start_meds_type___4 == 1 ~ 6,
                      su_start_meds_type___5 == 1 ~ 3,
                      su_start_meds_type___6 == 1 ~ 6),
                  su_stop_meds_type = case_when(
                      su_stop_meds_type___1 == 1 ~ 1,
                      su_stop_meds_type___2 == 1 ~ 4,
                      su_stop_meds_type___3 == 1 ~ 2,
                      su_stop_meds_type___4 == 1 ~ 6,
                      su_stop_meds_type___5 == 1 ~ 3,
                      su_stop_meds_type___6 == 1 ~ 6),
                  su_stop_ad_reason = case_when(
                      su_stop_ad_reason___1 == 1 ~ 1,
                      su_stop_ad_reason___2 == 1 ~ 2,
                      su_stop_ad_reason___3 == 1 ~ 3,
                      su_stop_ad_reason___4 == 1 ~ 4,
                      su_stop_ad_reason___5 == 1 ~ 5,
                      su_stop_ad_reason___6 == 1 ~ 6,
                      su_stop_ad_reason___7 == 1 ~ 7,
                      su_stop_ad_reason___8 == 1 ~ 8),
                  su_stop_ax_reason = case_when(
                      su_stop_ax_reason___1 == 1 ~ 1,
                      su_stop_ax_reason___2 == 1 ~ 2,
                      su_stop_ax_reason___3 == 1 ~ 3,
                      su_stop_ax_reason___4 == 1 ~ 4,
                      su_stop_ax_reason___5 == 1 ~ 5,
                      su_stop_ax_reason___6 == 1 ~ 6,
                      su_stop_ax_reason___7 == 1 ~ 7,
                      su_stop_ax_reason___8 == 1 ~ 8),
                  su_stop_st_reason = case_when(
                      su_stop_st_reason___1 == 1 ~ 1,
                      su_stop_st_reason___2 == 1 ~ 2,
                      su_stop_st_reason___3 == 1 ~ 3,
                      su_stop_st_reason___4 == 1 ~ 4,
                      su_stop_st_reason___5 == 1 ~ 5,
                      su_stop_st_reason___6 == 1 ~ 6,
                      su_stop_st_reason___7 == 1 ~ 7,
                      su_stop_st_reason___8 == 1 ~ 8),
                  su_stop_ap_reason = case_when(
                      su_stop_ap_reason___1 == 1 ~ 1,
                      su_stop_ap_reason___2 == 1 ~ 2,
                      su_stop_ap_reason___3 == 1 ~ 3,
                      su_stop_ap_reason___4 == 1 ~ 4,
                      su_stop_ap_reason___5 == 1 ~ 5,
                      su_stop_ap_reason___6 == 1 ~ 6,
                      su_stop_ap_reason___7 == 1 ~ 7,
                      su_stop_ap_reason___8 == 1 ~ 8),
                  su_stop_ot_reason = case_when(
                      su_stop_ot_reason___1 == 1 ~ 1,
                      su_stop_ot_reason___2 == 1 ~ 2,
                      su_stop_ot_reason___3 == 1 ~ 3,
                      su_stop_ot_reason___4 == 1 ~ 4,
                      su_stop_ot_reason___5 == 1 ~ 5,
                      su_stop_ot_reason___6 == 1 ~ 6,
                      su_stop_ot_reason___7 == 1 ~ 7,
                      su_stop_ot_reason___8 == 1 ~ 8),
                  su_curr_psych_type = case_when(
                      su_curr_psych_type___1 == 1 ~ 1,
                      su_curr_psych_type___2 == 1 ~ 2,
                      su_curr_psych_type___3 == 1 ~ 3,
                      su_curr_psych_type___4 == 1 ~ 4),
                  su_start_psych_type = case_when(
                      su_start_psych_type___1 == 1 ~ 1,
                      su_start_psych_type___2 == 1 ~ 2,
                      su_start_psych_type___3 == 1 ~ 3,
                      su_start_psych_type___4 == 1 ~ 4),
                  su_stop_psych_type = case_when(
                      su_stop_psych_type___1 == 1 ~ 1,
                      su_stop_psych_type___2 == 1 ~ 2,
                      su_stop_psych_type___3 == 1 ~ 3,
                      su_stop_psych_type___4 == 1 ~ 4),
                  su_stop_it_reason = case_when(
                      su_stop_it_reason___1 == 1 ~ 1,
                      su_stop_it_reason___2 == 1 ~ 2,
                      su_stop_it_reason___3 == 1 ~ 3,
                      su_stop_it_reason___4 == 1 ~ 4),
                  su_stop_ft_reason = case_when(
                      su_stop_ft_reason___1 == 1 ~ 1,
                      su_stop_ft_reason___2 == 1 ~ 2,
                      su_stop_ft_reason___3 == 1 ~ 3,
                      su_stop_ft_reason___4 == 1 ~ 4),
                  su_stop_mm_reason = case_when(
                      su_stop_mm_reason___1 == 1 ~ 1,
                      su_stop_mm_reason___2 == 1 ~ 2,
                      su_stop_mm_reason___3 == 1 ~ 3,
                      su_stop_mm_reason___4 == 1 ~ 4),
                  su_stop_ox_reason = case_when(
                      su_stop_ox_reason___1 == 1 ~ 1,
                      su_stop_ox_reason___2 == 1 ~ 2,
                      su_stop_ox_reason___3 == 1 ~ 3,
                      su_stop_ox_reason___4 == 1 ~ 4)) %>%
  rowwise() %>%
  mutate(total_meds = sum(c(su_curr_meds_type___1, su_curr_meds_type___2, su_curr_meds_type___3, 
                            su_curr_meds_type___4, su_curr_meds_type___5, su_curr_meds_type___6), na.rm=TRUE),
         total_meds_started = sum(c(su_start_meds_type___1, su_start_meds_type___2, su_start_meds_type___3, 
                                  su_start_meds_type___4, su_start_meds_type___5, su_start_meds_type___6), na.rm=TRUE),
         total_meds_stopped = sum(c(su_stop_meds_type___1, su_stop_meds_type___2, su_stop_meds_type___3, 
                                  su_stop_meds_type___4, su_stop_meds_type___5, su_stop_meds_type___6), na.rm=TRUE),
         total_psych = sum(c(su_curr_psych_type___1, su_curr_psych_type___2, su_curr_psych_type___3, 
                             su_curr_psych_type___4), na.rm=TRUE),
         total_psych_started = sum(c(su_start_psych_type___1, su_start_psych_type___2, su_start_psych_type___3, 
                                     su_start_psych_type___4), na.rm=TRUE),
         total_psych_started = sum(c(su_stop_psych_type___1, su_stop_psych_type___2, su_stop_psych_type___3, 
                                     su_stop_psych_type___4), na.rm=TRUE)) %>%
  ungroup() %>%
  mutate(su_curr_meds_type = ifelse(total_meds > 1, 7, su_curr_meds_type),
         su_start_meds_type = ifelse(total_meds > 1, 7, su_start_meds_type),
         su_stop_meds_type = ifelse(total_meds > 1, 7, su_stop_meds_type),
         su_curr_psych_type = ifelse(total_meds > 1, 5, su_curr_psych_type),
         su_start_psych_type = ifelse(total_meds > 1, 5, su_start_psych_type),
         su_stop_psych_type = ifelse(total_meds > 1, 5, su_stop_psych_type))

redcap_df %>% mutate(su_it_start =  ##fixing date format for su_it_start

maps_serviceuse01_template[1:sum(!is.na(redcap_df$service_use_complete)),] <- NA
maps_serviceuse01_template[,maps_serviceuse01_key$template_name] <- redcap_df[!is.na(redcap_df$service_use_complete),maps_serviceuse01_key$redcap_name]

file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/maps_serviceuse01_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = maps_serviceuse01_template, file = str_c(rootpath,UPLOAD,"maps_serviceuse01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")
               
# C-SSRS ------------------------------------------------------------------
cssrs01_template <- read.csv(file = str_c(rootpath,"../Codebook/NDA_Templates/cssrs01_template.csv"),skip = 1)

redcap_df$cssrs_si_1_l

cssrs01_template_key = read.csv(file = str_c(rootpath,"../Codebook/NDA_Templates/cssrs01_redcap_to_template.csv"))

# only use variables from the "key" between redcap and template where we have made a match
cssrs01_template_key[cssrs01_template_key == ''] = NA
cssrs01_template_key = cssrs01_template_key %>%
  dplyr::select(redcap_name, template_name, visit) %>%
  tidyr::drop_na()

# different matches to nda template based on visit
cssrs01_template_key_screening = dplyr::filter(cssrs01_template_key, visit == 'screening')
cssrs01_template_key_followup = dplyr::filter(cssrs01_template_key, visit == 'followup')


# separately add screening & follow-up data to template
cssrs01_tofill_screening = redcap_df[!is.na(redcap_df$cssrs_complete) & redcap_df$visit == 'screening',cssrs01_template_key_screening$redcap_name]
names(cssrs01_tofill_screening) = cssrs01_template_key_screening$template_name

cssrs01_template = plyr::rbind.fill(cssrs01_template, cssrs01_tofill_screening)

cssrs01_tofill_followup = redcap_df[!is.na(redcap_df$cssrs_complete) & redcap_df$visit == 'followup',cssrs01_template_key_followup$redcap_name]
names(cssrs01_tofill_followup) = cssrs01_template_key_followup$template_name

cssrs01_template = plyr::rbind.fill(cssrs01_template, cssrs01_tofill_followup)

# recoding responses (in redcap, "no" is coded as 0, but for many in the NDA template, "no" is coded as 2)
zero_to_two_vars = c('si1l', 'si2l', 'si3l', 'si4l', 'si5l', 
                     'sb2l', 'sbnssibl', 'sb3l', 'sb4l', 'sb5l',
                     'lvsi1', 'lvsi2', 'lvsi3', 'lvsi4', 'lvsi5', 
                     'lvsb1', 'lvsb2', 'lvsb4', 'lvsb4', 'lvsb5')

# Function to replace all 0s with 2s in a vector
zero_to_two = function(x){
  output = ifelse(x ==0, 2, x)
  return(output)
}

# replace the 0s for all the variables listed in zero_to_two_vars
cssrs01_template = cssrs01_template %>%
  dplyr::mutate_at(.vars = zero_to_two_vars, .funs = zero_to_two)

file.copy(from = str_c(rootpath,"../Codebook/NDA_Templates/cssrs01_template.csv"), str_c(rootpath,UPLOAD), overwrite = TRUE)
write.table(x = cssrs01_template, file = str_c(rootpath,UPLOAD,"cssrs01_template.csv"), sep=",",  col.names=FALSE, row.names = FALSE,append=T, na="")

