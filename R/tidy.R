# -------------------------------------------------------------------------
# input -------------------------------------------------------------------
# -------------------------------------------------------------------------
if (interactive()) {
    root <- here::here()
    infile <- file.path(root, "data", "raw", "census2021firstresultsenglandwales1.xlsx")
    outfile_total <- file.path(root, "output", "census-2021-england-and-wales-total-population.csv")
    outfile_regional <- file.path(root, "output", "census-2021-england-and-wales-regional-population.csv")

} else {
    args <- commandArgs(trailingOnly = TRUE)
    infile <- args[1]
    outfile_total <- args[2]
    outfile_regional <- args[3]
}

# -------------------------------------------------------------------------
# packages ----------------------------------------------------------------
# -------------------------------------------------------------------------
library(readxl)
library(data.table)

# -------------------------------------------------------------------------
# main --------------------------------------------------------------------
# -------------------------------------------------------------------------

# load data
dat <- read_xlsx(path = infile, range = "A8:V383", sheet = "P02", col_names = TRUE)
DT <- as.data.table(dat)

# clean column names
nms <- names(dat)
nms <- sub(" [note 2]", "", nms, fixed = TRUE)
nms <- sub("Aged ", "", nms, fixed = TRUE)
nms <- sub("\r\n[note 12]", "", nms, fixed = TRUE)
nms <- gsub(" ", "_", tolower(nms))
setnames(DT, nms)

# remove total column
DT[, all_persons := NULL]

# filter to regions, wales and england and wales
DT <- DT[startsWith(area_code, "E12") |
         startsWith(area_code, "W92") |
         startsWith(area_code, "K04")]

# make long
DT <- melt(DT, id.vars = c("area_code", "area_name"), variable.name = "age_category")

# clean category names
lookup <- c(
    "4_years_and_under" = "[0, 5)",
    "5_to_9_years"      = "[5, 10)",
    "10_to_14_years"    = "[10, 15)",
    "15_to_19_years"    = "[15, 20)",
    "20_to_24_years"    = "[20, 25)",
    "25_to_29_years"    = "[25, 30)",
    "30_to_34_years"    = "[30, 35)",
    "35_to_39_years"    = "[35, 40)",
    "40_to_44_years"    = "[40, 45)",
    "45_to_49_years"    = "[45, 50)",
    "50_to_54_years"    = "[50, 55)",
    "55_to_59_years"    = "[55, 60)",
    "60_to_64_years"    = "[60, 65)",
    "65_to_69_years"    = "[65, 70)",
    "70_to_74_years"    = "[70, 75)",
    "75_to_79_years"    = "[75, 80)",
    "80_to_84_years"    = "[80, 85)",
    "85_to_89_years"    = "[85, 90)",
    "90_years_and_over" = "[90, Inf)"
)
DT[, age_category := lookup[age_category]]

# save total output
fwrite(
    DT[startsWith(area_code, "K04")],
    outfile_total
)

# save regional output
fwrite(
    DT[startsWith(area_code, "E12") | startsWith(area_code, "W92")],
    outfile_regional
)

