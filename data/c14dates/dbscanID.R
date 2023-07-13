dbscanID = function(sitename,longitude,latitude,eps=0.2)
{
  require(dbscan)
  require(dplyr)
  require(sf)
  db = data.frame(SiteName=sitename,Longitude=longitude,Latitude=latitude)
  db$LocID = paste0(sitename,longitude,latitude)
  spatial = unique(db)
  # Use SF instead from here ...
  spatial  <- st_as_sf(spatial,coords=c('Longitude','Latitude'),crs=4326)
  distMat  <- st_distance(spatial)
  spatial$SiteID = dbscan(as.dist(distMat),eps=eps,minPts=1)$clust
  res=left_join(db,spatial,by=c('LocID'='LocID'))
  return(res$SiteID)
}
