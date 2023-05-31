# Load required library
library(sf)

# Read CSV file and Shapefile
lithic_data = read.csv("../encounter_data/CSV_tables/lithicDBv032.csv")
japan_shape = st_read("../encounter_data/Shapefiles/japan_jgd2000.shp")

# Convert lithic_data to spatial format using the same CRS as japan_shape
spatial_lithic = st_as_sf(lithic_data, coords=c("lon","lat"), crs=st_crs(japan_shape))

# Remove columns containing "その他" (others) from spatial_lithic
spatial_lithic = spatial_lithic[, !grepl("その他", colnames(spatial_lithic))]

# Define regions in Japan
chubu_prefectures = c("Gifu", "Nagano", "Yamanashi")
tokai_prefectures = c("Mie", "Aichi", "Shizuoka")

# Select regions from japan_shape
chubu_region = japan_shape[japan_shape$prefecture %in% chubu_prefectures, ]
tokai_region = japan_shape[japan_shape$prefecture %in% tokai_prefectures, ]

# Filter spatial_lithic for each region
chubu_lithic = st_filter(spatial_lithic, chubu_region)
tokai_lithic = st_filter(spatial_lithic, tokai_region)

# Merge and extract tools related data
merged_data = rbind(chubu_lithic, tokai_lithic)
harvesting_tools = merged_data[, grep("収穫具", colnames(merged_data))]
fishing_tools = merged_data[, grep("漁撈具", colnames(merged_data))]

# Plot lithics sites all period
plot(st_geometry(harvesting_tools), col="blue", pch=20)

# Filter out rows with NA in StartDatePhase column
spatial_lithic = spatial_lithic[!is.na(spatial_lithic$StartDatePhase), ]


# Re-filter data after removing NA
chubu_lithic = st_filter(spatial_lithic, chubu_region)
tokai_lithic = st_filter(spatial_lithic, tokai_region)

# Merge data again
merged_data = rbind(chubu_lithic, tokai_lithic)

# Crop japan_shape to the bounding box of the merged data
japan_shape = st_crop(japan_shape, merged_data)

# Select rows with hunting and fishing tools
tool_categories = grepl("漁撈具|狩猟具.武器", colnames(merged_data))
valid_rows = apply(st_drop_geometry(merged_data[, tool_categories]), 1, sum) > 0

# Update merged_data and tools data
merged_data = merged_data[valid_rows,]
harvesting_tools = merged_data[, grep("収穫具", colnames(merged_data))]
other_tools = merged_data[, tool_categories]

# Plot lithics sites defined
plot(st_geometry(harvesting_tools), col="red", pch=1,add=T)

# Calculate total and proportions for tools
other_tools$tot = apply(st_drop_geometry(other_tools), 1, sum)
total_harvest = apply(st_drop_geometry(harvesting_tools), 1, sum)
harvesting_tools$perc = (total_harvest + 1) / (other_tools$tot + total_harvest + 1)


# Plot proportions

plot(harvesting_tools[,"perc"], logz=F, pch=20, cex=3, reset=F, breaks=seq(0, 1, length.out = 21), pal=rev(hcl.colors(20,"RdYlGn")), main="")
mtext(expression(frac(収穫具,収穫具+漁撈具+狩猟具.武器)), 3, -2, cex=1.2)
plot(st_geometry(japan_shape), add=T)


