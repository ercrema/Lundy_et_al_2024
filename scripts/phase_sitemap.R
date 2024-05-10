# Load R libraries and posteriors ----
library(here)
library(coda)
library(rcarbon)
library(scales)
library(elevatr)
library(sf)
library(raster)
library(rnaturalearth)
library(dplyr)
library(ggmap)
library(cowplot)
library(marmap)
library(gridBase)
library(grid)

load(here('results','arrival_estimates.RData'))

# Custom R functions ----
fuzzyRect  <- function(xleft,xright,ybottom,ytop,fuzz,fuzz.n=100,col=adjustcolor('darkgrey',alpha=0.1))
{
	for (i in 1:fuzz.n)
	{
		rect(xleft=rnorm(1,mean=xleft,sd=fuzz),xright=rnorm(1,mean=xright,sd=fuzz),ybottom=ybottom,ytop=ytop,col=col,border=NA)
	}
}


post.bar <- function(x,i,h=0.4,col)
{
	require(grDevices)
	x  <- as.mcmc(x)
	blocks <- c(HPDinterval(x,0.95)[1],HPDinterval(x,0.8)[1],HPDinterval(x,0.5)[1],HPDinterval(x,0.5)[2],HPDinterval(x,0.8)[2],HPDinterval(x,0.95)[2])
	rect(xleft=blocks[1],xright=blocks[2],ybottom=i-h/5,ytop=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.3))
	rect(xleft=blocks[2],xright=blocks[3],ybottom=i-h/5,ytop=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.6))
	rect(xleft=blocks[3],xright=blocks[4],ybottom=i-h/5,ytop=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.9))
	rect(xleft=blocks[4],xright=blocks[5],ybottom=i-h/5,ytop=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.6))
	rect(xleft=blocks[5],xright=blocks[6],ybottom=i-h/5,ytop=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.3))
}

# Generate data.frame with site data ----
sites <- data.frame(names = c('Nakaya','Nakamichi','Tenshoji','Ushimaki','Mamizuka','Asahi'),
		    starts = c(-1000,-600,-400,-1000,-750,-400),
		    ends = c(-800,-400,-300,-800,-550,1),
		    regions = c(rep('Central Highlands',3),rep('Tokai',3)),
		    lat=c(35.35016,35.75463,35.3339,35.20778,35.29226,35.22),
		    lon=c(138.5529,138.4318,138.569,136.9731,136.8213,136.86))

# Generate map data ----
win  <- ne_countries(continent = 'asia',scale=10,returnclass='sf') |> st_union()
japan <- ne_states(country = "japan",returnclass='sf')
elevation <- get_elev_raster(locations = japan, z = 7,clip = "locations",src='aws')
dem <- as.data.frame(elevation, xy = T) |> na.omit()
colnames(dem)[3] <- "elevation"
dem$elevation[which(dem$elevation < 0)] = 0
sites.sf  <- st_as_sf(sites,coords=c('lon','lat'),crs=4326)

general <- ggplot() +
	geom_sf(data=win,aes(),fill='grey65',show.legend=FALSE,lwd=0) +
	xlim(129,146) + 
	ylim(31,45) + 
	geom_rect(aes(xmin = 135, xmax = 140, ymin = 33, ymax = 37),alpha=0.2,fill='orange') +
	theme_void() +
	theme(panel.background = element_rect(fill='white',color='white'))


zoomed <- ggplot() +
	geom_tile(data=dem,aes(x=x,y=y,fill=elevation)) +
	scale_fill_etopo() +
	geom_sf(data=sites.sf,size=1.5,col='black',pch=20) +
	annotate('text',x=136.2,y=35.3,label='Mamizuka') +
	annotate('text',x=136.5,y=35.1,label='Asahi') +
	annotate('text',x=137.5,y=35.4,label='Ushimaki') +
	annotate('text',x=138.5,y=35.2,label='Tenshoji') +
	annotate('text',x=138.6,y=35.5,label='Nakaya') +
	annotate('text',x=138.9,y=35.9,label='Nakamichi') +
	xlim(135,140) +
	ylim(33,37) +
	xlab('Longitude') +
	ylab('Latitude') +
	theme(legend.position = "none")


# Plot everything ----

pdf(file='figure1.pdf',width=8,height=5,pointsize=8)
par(mfrow=c(1,2),mar=c(7,4,4,0))
plot(NULL,xlim=c(-1300,150),ylim=c(-1,10),axes=F,xlab='BCE/CE',ylab='')  
axis(1,at=c(-1200,-1000,-800,-600,-400,-200,1,200),labels=c(1200,1000,800,600,400,200,1,200))


for (i in 1:3)
{
	fuzzyRect(sites$starts[i],sites$ends[i],fuzz=50,ybottom=10.7-i,ytop=11-i)
	text(x=median(c(sites$starts[i],sites$ends[i])),y=10.4-i,label=sites$names[i])
}

dens.highlands <- density(BPtoBCAD(posterior.constrained[,'a[5]']))
dens.highlands$y <- rescale(dens.highlands$y,to=c(6,7))
polygon(x=c(dens.highlands$x,rev(dens.highlands$x)),y=c(dens.highlands$y,rep(6,length(dens.highlands$y))),border=NA,col=adjustcolor('darkorange',alpha=0.8))
points(x=median(BPtoBCAD(posterior.constrained[,'a[5]'])),y=5.8,pch=20)
lines(x=as.numeric(HPDinterval(as.mcmc(BPtoBCAD(posterior.constrained[,'a[5]'])))),y=c(5.8,5.8))
text(x=median(BPtoBCAD(posterior.constrained[,'a[5]'])),y=5.3,label='Posterior arrival date rice farming')
text(x=-1200,y=7.6,'Central Highlands',srt=90,cex=1.3)

for (i in 4:6)
{
	fuzzyRect(sites$starts[i],sites$ends[i],fuzz=50,ybottom=7.7-i,ytop=8-i)
	text(x=median(c(sites$starts[i],sites$ends[i])),y=7.4-i,label=sites$names[i])
}

dens.highlands <- density(BPtoBCAD(posterior.constrained[,'a[4]']))
dens.highlands$y <- rescale(dens.highlands$y,to=c(0,1))
polygon(x=c(dens.highlands$x,rev(dens.highlands$x)),y=c(dens.highlands$y,rep(0,length(dens.highlands$y))),border=NA,col=adjustcolor('darkgreen',alpha=0.8))
points(x=median(BPtoBCAD(posterior.constrained[,'a[4]'])),y=-0.2,pch=20)
lines(x=as.numeric(HPDinterval(as.mcmc(BPtoBCAD(posterior.constrained[,'a[4]'])))),y=c(-0.2,-0.2))
text(x=median(BPtoBCAD(posterior.constrained[,'a[4]'])),y=-0.7,label='Posterior arrival date rice farming')
text(x=-1200,y=1.6,'Tokai',srt=90,cex=1.3)

plot.new()
vps <- baseViewports()
pushViewport(vps$figure)
vp1 <- plotViewport(c(0,0.5,0.5,0))
p <- ggdraw(plot=zoomed) + draw_plot(general,x=0.67,y=0.2,width=0.27,height=0.27)
print(p,vp=vp1)
dev.off()

