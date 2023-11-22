# Date and R scripts used for the organic residue analysis (ORA) study of Late Jomon to Yayoi pottery from Tokai and Central Highlands in Japan

The repository is organised into four main directories: data, images, results and 
The _data_ directory contains the organic residue analysis summary data, human isotope data and seed impression data, pre-processing script for c14 radiocarbon dates, and radiocarbon date dataset; images_ contains figures created from rscripts, results_  contains statistical analysis of ORA results, chronological phase data, constrained chronological phase data and seed impression frequencies, runscript_ contains all scripts for running the analyses in the paper. 

# File Structure

### data
* ` ORAresults.csv `... Spreadsheet containing ceramic information and organic residue analysis summary data 
* ` Humanisotope.csv`... Spreadsheet containing previously publish human isotope data from Tokai and Central Highlands ceramic information and organic residue analysis summary data
* `prepare_data.R` ... R scripts for pre-processing `R14CDB.csv` and `prefecture_region_match.csv`. Generates the R image file `c14rice.RData`.
* `c14rice.RData` ... R image file containing R objects required for analyses. Generated using `prepare_data.R`, `R14CDB.csv`, and `prefecture_region_match.csv`.
* `seeds_2.10. csv` ... Spreadsheet containing previously published seed impression data from Tokai and Central Highlands 
### images 
* `phase_sitemap.R... Contains an Rscript for generating constrained arrival of rice in Tokai and Central Highlands and site map for fig. 1 in manuscript. 
### results 
* `StattestORA` ... contains results from statistical analysis of ORA results reported in manuscript from 
* `phase.RData` and `phase_constrained... RData` ... Contains the R script for running the unconstrained and constrained versions of the hierarhichal Bayesian phase models. Results are shown in figure produced by phase contrained and site map.R 
* `table_seed_freq.csv... table of seed impression frequencies  

### manuscript
To be added after acceptance from journal 
# R Session Info
```
R version 4.1.2 (2021-11-01)

# Funding
This research was funded by the ERC grant _Demography, Cultural Change, and the Diffusion of Rice and Millets during the Jomon-Yayoi transition in prehistoric Japan (ENCOUNTER)_ (Project N. 801953, PI: Enrico Crema).

You can download it using:
```bash
git clone git@github.com:ercrema/encounter_data.git
```


