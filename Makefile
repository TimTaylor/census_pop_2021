.PHONY: all clean

URL := https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationandhouseholdestimatesenglandandwalescensus2021/census2021/census2021firstresultsenglandwales1.xlsx
RAWDAT := data/raw/$(notdir ${URL})
OUTTOTAL := output/census-2021-england-and-wales-total-population.csv
OUTREGIONAL := output/census-2021-england-and-wales-regional-population.csv

all: ${OUTTOTAL} ${OUTREGIONAL}

${RAWDAT}:
	mkdir -p $(@D)
	wget -c -O $@ ${URL}

${OUTTOTAL} ${OUTREGIONAL}: R/tidy.R ${RAWDAT}
	mkdir -p $(@D)
	Rscript --vanilla $^ ${OUTTOTAL} ${OUTREGIONAL}

clean:
	rm -f output/*



