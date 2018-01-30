


# Add species to the 'Dat' file , each row of 'LB.ShortForm' will be a unique tow and the species catch (kg) will be in added columns

base::load("Funcs and Data/LBData.1981.2015.dmp")  # Load main raw data, if not already loaded, used inside of PacFIN.Logbook.Catch.Effort.Sp() below

sort(unique(LBData.1981.2015$SPID))
#   [1] "ALBC" "ARR1" "ART1" "ARTH" "ASRK" "BCC1" "BGL1" "BLK1" "BLU1" "BMO1" "BNK1" "BRW1" "BRZ1" "BSKT" "BSOL" "BSRK" "BSRM" "BTCR" "BTRY"
#  [20] "BYL1" "CBZ1" "CBZN" "CHL1" "CHLB" "CHN1" "CHNK" "CLP1" "CMCK" "CMSL" "CNR1" "COP1" "CSKT" "CSOL" "CSRK" "CUDA" "CWC1" "DBR1" "DCRB"
#  [39] "DOVR" "DSOL" "DSRK" "DVR1" "EELS" "EGL1" "EGLS" "EULC" "FLG1" "FNTS" "FSOL" "GBAS" "GBL1" "GPH1" "GRDR" "GRS1" "GSP1" "GSR1" "GSTG"
#  [58] "HNY1" "HTRB" "JMCK" "KFSH" "KGL1" "KLP1" "KLPG" "LCD1" "LCOD" "LDB1" "LSKT" "LSP1" "LSRK" "MAKO" "MEEL" "MISC" "MSC2" "MSHP" "MSQD"
#  [77] "NANC" "NUSF" "NUSP" "NUSR" "OBAS" "OCRB" "OCRK" "OCTP" "OFLT" "OGRN" "OLV1" "ORCK" "OSCL" "OSKT" "OSRK" "OSRM" "OURC" "PBNT" "PCOD"
#  [96] "PDAB" "PDB1" "PHLB" "PHRG" "PLCK" "POP1" "POP2" "PROW" "PRR1" "PSDN" "PSHP" "PSRK" "PTR1" "PTRL" "PWHT" "QLB1" "RATF" "RCK1" "RCK2"
# [115] "RCK3" "RCK4" "RCK5" "RCK6" "RCK7" "RCK9" "RCLM" "RCRB" "RDB1" "REX"  "REX1" "ROS1" "RPRW" "RSL1" "RSOL" "RST1" "RURC" "SABL" "SBL1"
# [134] "SCLP" "SCR1" "SDB1" "SFL1" "SHAD" "SHP1" "SLNS" "SMLT" "SNS1" "SPK1" "SPRW" "SQID" "SQR1" "SRFP" "SSO1" "SSOL" "SSP1" "SSRK" "STL1"
# [153] "STNA" "STR1" "STRY" "SWRD" "SWS1" "TCOD" "TGR1" "THDS" "TRE1" "TSRK" "UCRB" "UDAB" "UECH" "UFLT" "UHAG" "UHLB" "UKCR" "UMCK" "UMSK"
# [172] "UPOP" "URCK" "USCL" "USCU" "USHR" "USKT" "USLF" "USLP" "USRK" "USRM" "USTG" "USTR" "UTCR" "UTRB" "VRM1" "WBAS" "WCRK" "WDW1" "WEEL"
# [191] "WSTG" "YEY1" "YLTL" "YTR1"



# *************************************** Good tows only *******************************************

load("Funcs and Data/LB Shortform Final Dat 25 Jan 2018.dmp") # Only good tows in LB.ShortForm # rows = 1,033,637,  cols =  46
source("Funcs and Data/PacFIN.Logbook.Catch.Effort.Sp.R") # Species or species group aggregate catch


# ******** Add species here *****************

SP.List <- list(LCOD.kg = c("LCOD", "LCD1"), POP.kg = c("POP1", "POP2", "UPOP")) # ** kg label here **
# SP.List <- list(YTRK.kg = c("YTRK", "YTR1")) # ** kg label here **


for ( i in 1:length(SP.List)) {
     cat("\n", names(SP.List)[i], "\n"); flush.console()
     tmp <- PacFIN.Logbook.Catch.Effort.Sp(SP.List[[i]])
     tmp[,ncol(tmp)] <- tmp[,ncol(tmp)]/2.20462  # ** Converting from lbs to kg here **
     names(tmp)[ncol(tmp)] <- names(SP.List)[i]
     LB.ShortForm <- match.f(LB.ShortForm, tmp, "Key", "Key", ncol(tmp))
}

LB.ShortForm[1:4,]



sum(LB.ShortForm$POPlbs/2.20462 - LB.ShortForm$POP.kg) # sum = 0, testing new method with match.f() with old method using POP



# Overwrite WDFW's DURATION with WDFW's ADJ_TOWTIME for WA 
LB.ShortForm$DURATION[LB.ShortForm$AGID  %in% 'W' & !is.na(LB.ShortForm$ADJ_TOWTIME)] <- LB.ShortForm$ADJ_TOWTIME[LB.ShortForm$AGID  %in% 'W' & !is.na(LB.ShortForm$ADJ_TOWTIME)]

LB.ShortForm <- LB.ShortForm[
			# tow duration	
				(LB.ShortForm$DURATION > 0.2) &	      # records with tow duration > 0.2
				(LB.ShortForm$DURATION <= 24.0) &     # records with tow duration <= 6 hours  
                                (!is.na(LB.ShortForm$DURATION)) 
			, ]


# Specify state waters where catch was taken - areas for analsyis using ARID_PSMFC
LB.ShortForm$State.Waters <- NA
LB.ShortForm$State.Waters[LB.ShortForm$ARID_PSMFC %in% c("3A","3B","3S","3C", "3S", "3D")] <- "WA" #  # 3S [SOUTHERN PORTION OF AREA 3C (UNITED STATES ONLY)] added - JRW
LB.ShortForm$State.Waters[LB.ShortForm$ARID_PSMFC %in% c("2B","2C","2A","2E","2F")] <- "OR"  
LB.ShortForm$State.Waters[LB.ShortForm$ARID_PSMFC %in% c("1A","1B","1C")] <- "CA"            



# Will be using GIS depth for midwater tows (see DataProcessExplore - JRW.R)
# Tows that have both a Strategy of 'HAKE' and a GRID label of 'MDT' will be removed as hopefully 'true' hake tows (see below). Clusters of midwater tows in PacFIN are mislabeled.

# Need to improve this with more species and perhaps add a Bottom Rockfish (BRF) strategy 


change(LB.ShortForm) # Rows = 1,018,571, Col = 49

LB.ShortForm$Strategy <- 'OTHER'
LB.ShortForm$Strategy[(ptrlbs + POPlbs > thdlbs + dovlbs + sablbs) & (ptrlbs + POPlbs > whtlbs)] <- 'NSM'
LB.ShortForm$Strategy[(thdlbs + dovlbs + sablbs > ptrlbs + POPlbs) & (thdlbs + dovlbs + sablbs > whtlbs)] <- 'DWD' # TDS species
# LB.ShortForm$Strategy[(whtlbs > 10 * ptrlbs) & (whtlbs > 10 * (thdlbs + dovlbs + sablbs))] <- 'HAKE'
LB.ShortForm$Strategy[(whtlbs > 10 * ptrlbs) & (whtlbs > 10 * (thdlbs + dovlbs))] <- 'HAKE'  # Sablefish are far more often seen in hake tows then thornies or dover

Table(LB.ShortForm$Strategy, LB.ShortForm$GRID)


# *** May want to leave in Hake tows for Sablefish ***

N.with.Hake <- nrow(LB.ShortForm)
LB.ShortForm.No.Hake.Strat <- LB.ShortForm[!(LB.ShortForm$Strategy %in% 'HAKE'),] # Rows = 976,494,  Cols = 50
100 * (1 - nrow(LB.ShortForm.No.Hake.Strat)/N.with.Hake) # Percent of hake tows removed
Table(LB.ShortForm.No.Hake.Strat$Strategy, LB.ShortForm.No.Hake.Strat$GRID)



# Principal components approach from Kot
# DatG$PC <- "PC3"
# DatG$PC[DatG$CPUE_petrale <= quantile(DatG$CPUE_petrale, 0.75) & DatG$CPUE_dover > quantile(DatG$CPUE_dover, 0.50) & 
#               DatG$CPUE_thorny <= quantile(DatG$CPUE_thorny, 0.75) & DatG$CPUE_sablefish <= quantile(DatG$CPUE_sablefish, 0.75)] <- "PC2"
# DatG$PC[DatG$CPUE_petrale > quantile(DatG$CPUE_petrale, 0.50) & DatG$CPUE_dover <= quantile(DatG$CPUE_dover, 0.75) & 
#               DatG$CPUE_thorny <= quantile(DatG$CPUE_thorny, 0.75) & DatG$CPUE_sablefish <= quantile(DatG$CPUE_sablefish, 0.75)] <- "PC1"

# Species picked above
save(LB.ShortForm.No.Hake.Strat, file= "Funcs and Data/LB ShortForm No Hake Strat 26 Jan 2018.dmp")  # LCOD & POP
# save(LB.ShortForm.No.Hake.Strat, file= "Funcs and Data/LB.ShortForm.No.Hake.Strat 22 Mar 2017.dmp")  # "YTRK"

# Check Data

if(F) {

   Table(LB.ShortForm.No.Hake.Strat$ARID_PSMFC, LB.ShortForm.No.Hake.Strat$State.Waters)

   change(LB.ShortForm.No.Hake.Strat[is.na(LB.ShortForm.No.Hake.Strat$State.Waters), ])
   imap()
   points(SET_LONG, SET_LAT, col='red') # Some good tows can appear on land due to the use of Logbook blocks.

   change(LB.ShortForm.No.Hake.Strat[LB.ShortForm.No.Hake.Strat$ARID_PSMFC %in% '4A', ])
   points(SET_LONG, SET_LAT, col='green')  # These 5 points appear in the ocean not in the Puget Sound (3B or perhaps 3A)


   change(LB.ShortForm.No.Hake.Strat)

   agg.table(aggregate(List(LCOD.kg/1000), List(RYEAR, Strategy), sum))
   agg.table(aggregate(List(POP.kg/1000), List(RYEAR, Strategy), sum))


   agg.table(aggregate(List(dovlbs/2204.62), List(RYEAR, Strategy), sum))
   agg.table(aggregate(List(ptrlbs/2204.62), List(RYEAR, Strategy), sum))
   agg.table(aggregate(List(sablbs/2204.62), List(RYEAR, Strategy), sum))
   agg.table(aggregate(List(thdlbs/2204.62), List(RYEAR, Strategy), sum))
   agg.table(aggregate(List(thdlbs/2204.62), List(RYEAR, Strategy), sum))

   Table(LB.ShortForm$RYEAR, LB.ShortForm$AGID, LB.ShortForm$ptrlbs > 0)
   Table(LB.ShortForm$RYEAR, LB.ShortForm$AGID, LB.ShortForm$sablbs > 0)
   Table(LB.ShortForm$RYEAR, LB.ShortForm$AGID, LB.ShortForm$dovlbs > 0)
   Table(LB.ShortForm$RYEAR, LB.ShortForm$AGID, LB.ShortForm$POPlbs > 0)   
   Table(LB.ShortForm$RYEAR, LB.ShortForm$AGID, LB.ShortForm$thdlbs > 0)
   Table(LB.ShortForm$RYEAR, LB.ShortForm$AGID, LB.ShortForm$whtlbs > 0)
   
}





