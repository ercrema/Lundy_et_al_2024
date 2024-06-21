[![DOI](https://zenodo.org/badge/647683887.svg)](https://zenodo.org/doi/10.5281/zenodo.11164557)

# Data and R scripts for the paper 'Culinary continuity in central Japan across the transition to agriculture'

This repository contains data and R scripts for the following paper:

Lundy,J.,Bondetti,M.,Lucquin,A.,Talbot,H.M.,Murakami,N.,Nakayama,S.,Harada,M.,Suzuki,M.,Endo,E.,Stevens,C.,Crema,E.R.,Craig,O.E.,Shoda,S.(2024).Culinary continuity in central Japan across the transition to agriculture. Anthropological and Archaeological Sciences.https://doi.org/10.1007/s12520-024-01992-9   

The repository is organised into four main directories: _data_, _scripts_, and _results_. 
The _data_ directory contains the organic residue analysis summary data, human isotope and seed impression data, a pre-processing script for C14 radiocarbon dates, and a radiocarbon date dataset; _scripts_ contains all R scripts for executing the analyses, and _results_ contains output CSV and R image files. 


# File Structure

### data
* `ORAresults.csv`... Spreadsheet containing ceramic information and organic residue analysis summary data.
* `JAPREF.csv`... Spreadsheet containing ceramic information and organic residue analysis summary data.
* `Humanisotope.csv`... Spreadsheet containing previously published human isotope data from Tokai and Central Highlands ceramic information and organic residue analysis summary data.
* `data_prep_c14_rice.R` ... R scripts for pre-processing rice radiocarbon dates from [Crema et al 2022](https://github.com/ercrema/yayoi_rice_dispersal). Generates the R image file `c14rice.RData`.
* `prefecture_region_match.csv` ... lookup table to aggregate geographic regions.
* `c14rice.RData` ... R image file containing R objects required for analyses. Generated using `data_prep_c14_rice.R` and `prefecture_region_match.csv`.
* `seeds_2.10. csv` ... Spreadsheet containing previously published seed impression data from Tokai and Central Highlands. Based on [Endo and Leipe 2022](https://doi.org/10.1016/j.quaint.2021.11.027) with additional fields on sherd counts.
  
### scripts 
* `phase_sitemap.R`... Contains R scripts for estimating arrival dates of rice in Tokai and Central Highlands and a site map for fig. 1 in the manuscript.
* `ORAscript.R` ... Contains R scripts for statistical analyses and basic visualisation of ORA.
* `seeds.R` ... Contains R scripts for the analyses of seed impressions data.
* `rice_arrival.R` ... Contains R scripts for the reanalysis of [Crema et al 2022](https://github.com/ercrema/yayoi_rice_dispersal) dataset.
  
### results 
* `arrival_estimates.RData` ...  output of `rice_arrival.R`, containing arrival dates in Chubu Highlands and Tokai.
* `table_seed_freq.csv`... output generated from the analyses of seed impression data (`seeds.R`)

# R Session Info
```
R version 4.3.1 (2023-06-16)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 20.04.6 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.9.0 
LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.9.0

locale:
 [1] LC_CTYPE=en_GB.UTF-8       LC_NUMERIC=C              
 [3] LC_TIME=en_GB.UTF-8        LC_COLLATE=en_GB.UTF-8    
 [5] LC_MONETARY=en_GB.UTF-8    LC_MESSAGES=en_GB.UTF-8   
 [7] LC_PAPER=en_GB.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C            
[11] LC_MEASUREMENT=en_GB.UTF-8 LC_IDENTIFICATION=C       

time zone: Europe/London
tzcode source: system (glibc)

attached base packages:
[1] grid      parallel  stats     graphics  grDevices utils     datasets 
[8] methods   base     

other attached packages:
 [1] marmap_1.0.10       rnaturalearth_0.3.3 gridBase_0.4-7     
 [4] cowplot_1.1.1       raster_3.6-26       sp_2.0-0           
 [7] sf_1.0-14           elevatr_0.99.0      scales_1.2.1       
[10] brms_2.19.0         Rcpp_1.0.11         dunn.test_1.3.5    
[13] dplyr_1.1.2         ggstar_1.0.4        ggplot2_3.4.2      
[16] coda_0.19-4         rcarbon_1.5.1       nimbleCarbon_0.2.5 
[19] nimble_1.0.1       

loaded via a namespace (and not attached):
  [1] shape_1.4.6            jsonlite_1.8.5         tensorA_0.36.2        
  [4] magrittr_2.0.3         estimability_1.4.1     spatstat.utils_3.0-4  
  [7] farver_2.1.1           vctrs_0.6.2            memoise_2.0.1         
 [10] spatstat.explore_3.2-5 base64enc_0.1-3        terra_1.7-39          
 [13] htmltools_0.5.5        distributional_0.3.2   StanHeaders_2.26.26   
 [16] pracma_2.4.2           KernSmooth_2.23-22     htmlwidgets_1.6.2     
 [19] plyr_1.8.8             cachem_1.0.8           emmeans_1.8.9         
 [22] zoo_1.8-12             igraph_1.5.1           mime_0.12             
 [25] lifecycle_1.0.4        iterators_1.0.14       pkgconfig_2.0.3       
 [28] colourpicker_1.2.0     Matrix_1.6-1.1         R6_2.5.1              
 [31] fastmap_1.1.1          shiny_1.7.4            digest_0.6.31         
 [34] numDeriv_2016.8-1.1    colorspace_2.1-0       ps_1.7.5              
 [37] tensor_1.5             RSQLite_2.3.1          crosstalk_1.2.0       
 [40] spatstat.linnet_3.1-3  progressr_0.14.0       gdistance_1.6.4       
 [43] fansi_1.0.4            spatstat.sparse_3.0-3  httr_1.4.6            
 [46] polyclip_1.10-6        abind_1.4-5            mgcv_1.9-0            
 [49] compiler_4.3.1         proxy_0.4-27           bit64_4.0.5           
 [52] withr_2.5.0            backports_1.4.1        inline_0.3.19         
 [55] shinystan_2.6.0        DBI_1.1.3              spatstat.model_3.2-8  
 [58] pkgbuild_1.4.0         classInt_0.4-10        gtools_3.9.4          
 [61] loo_2.6.0              tools_4.3.1            units_0.8-4           
 [64] httpuv_1.6.11          threejs_0.3.3          goftest_1.2-3         
 [67] glue_1.6.2             callr_3.7.3            nlme_3.1-163          
 [70] promises_1.2.0.1       checkmate_2.2.0        reshape2_1.4.4        
 [73] generics_0.1.3         snow_0.4-4             gtable_0.3.3          
 [76] spatstat.data_3.0-3    class_7.3-22           utf8_1.2.3            
 [79] spatstat.geom_3.2-7    foreach_1.5.2          pillar_1.9.0          
 [82] markdown_1.7           stringr_1.5.0          posterior_1.4.1       
 [85] later_1.3.1            splines_4.3.1          lattice_0.22-5        
 [88] bit_4.0.5              deldir_1.0-9           tidyselect_1.2.0      
 [91] miniUI_0.1.1.1         knitr_1.45             gridExtra_2.3         
 [94] stats4_4.3.1           xfun_0.41              adehabitatMA_0.3.16   
 [97] bridgesampling_1.1-2   matrixStats_1.0.0      DT_0.28               
[100] rstan_2.21.8           stringi_1.7.12         codetools_0.2-19      
[103] spatstat_3.0-7         tibble_3.2.1           cli_3.6.1             
[106] RcppParallel_5.1.7     rpart_4.1.21           shinythemes_1.2.0     
[109] xtable_1.8-4           munsell_0.5.0          processx_3.8.1        
[112] doSNOW_1.0.20          spatstat.random_3.2-1  rstantools_2.3.1.1    
[115] ellipsis_0.3.2         blob_1.2.4             prettyunits_1.1.1     
[118] dygraphs_1.1.1.6       bayesplot_1.10.0       Brobdingnag_1.2-9     
[121] mvtnorm_1.2-2          xts_0.13.1             e1071_1.7-13          
[124] ncdf4_1.21             purrr_1.0.1            crayon_1.5.2          
[127] rlang_1.1.2            shinyjs_2.1.0
```

# Funding
This research was funded by the ERC grant _Demography, Cultural Change, and the Diffusion of Rice and Millets during the Jomon-Yayoi transition in prehistoric Japan (ENCOUNTER)_ (Project N. 801953, PI: Enrico Crema) and the JSPS KAKENHI (grant numbers 21H04370, 20H05820 and 17H04777).
