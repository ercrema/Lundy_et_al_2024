# Load Libraries ----
library(here)
library(brms)
library(coda)

# Custom functions ----
logistic <- function(x)
{
	1/(1+exp(-x))
}

post.plot  <- function(x,i,h,col)
{

	require(scales)
	require(coda)
	dens <- density(x)
	dens$y  <- (dens$y*h + i)
	polygon(x=c(dens$x,rev(dens$x)),y=c(dens$y,rep(i,length(dens$y))),border=NA,col=col)
	points(x=median(x),y=i,pch=20,cex=1.5)
	lines(x=as.numeric(HPDinterval(as.mcmc(x),prob=0.9)),y=c(i,i))
	lines(x=as.numeric(HPDinterval(as.mcmc(x),prob=0.5)),y=c(i,i),lwd=4)
}

post.bar.v <- function(x,i,h=0.4,col)
{
	require(grDevices)
	x  <- as.mcmc(x)
	blocks <- c(HPDinterval(x,0.95)[1],HPDinterval(x,0.8)[1],HPDinterval(x,0.5)[1],HPDinterval(x,0.5)[2],HPDinterval(x,0.8)[2],HPDinterval(x,0.95)[2])
	rect(ybottom=blocks[1],ytop=blocks[2],xleft=i-h/5,xright=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.3))
	rect(ybottom=blocks[2],ytop=blocks[3],xleft=i-h/5,xright=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.6))
	rect(ybottom=blocks[3],ytop=blocks[4],xleft=i-h/5,xright=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.9))
	rect(ybottom=blocks[4],ytop=blocks[5],xleft=i-h/5,xright=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.6))
	rect(ybottom=blocks[5],ytop=blocks[6],xleft=i-h/5,xright=i+h/5,border=NA,col=adjustcolor(col,alpha.f=0.3))
}


post.bar.h <- function(x,i,h=0.4,col)
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

# Read and process seeds data ----
seeds  <- read.csv(here('data','seeds_2.1.0.csv')) |> subset(Region%in%c('Central Highlands','Tokai'))
seeds$Period2 <- NA
seeds$Period2[seeds$Period%in%c('Final Jomon','End of Final Jomon - Initial Yayoi','End of Final Jomon/Initial Yayoi','Late Jomon - Final Jomon')] <- 'LJ/IY'
seeds$Period2[seeds$Period%in%c('Early Yayoi')] <- 'EY'
seeds$Period2[seeds$Period%in%c('Middle Yayoi','First half of Middle Yayoi')]  <- 'MY'
table(seeds$Period2,seeds$Region)
seeds$impressionsTotal  <- seeds$O.sativa.abundance+seeds$Millets.abundance
seeds <- subset(seeds,!is.na(Period2))

### Fit Impression Ratio model (Rice/(Rice + Millet)) ----
seeds.ratio  <- subset(seeds,!is.na(seeds$impressionsTotal))
seeds.ratio$SiteID <- 1:nrow(seeds.ratio) |> as.factor()
seeds.ratio$rice <- seeds.ratio$O.sativa.abundance

fit  <- brm(data=seeds.ratio,family=binomial,rice|trials(impressionsTotal) ~ 1 + (1|SiteID) + Period2 * Region,iter=3000)
summary(fit)
# post <- posterior_samples(fit)
post <- as_draws_df(fit)


# LJ/IY Chubu Highlands
pred  <- data.frame(value = logistic(post$b_Intercept + post$b_Period2LJDIY),
		    period = 'Late Jomon to Initial Yayoi',
		    region = 'Chubu Highlands')

# EY Chubu Highlands
pred <- rbind.data.frame(pred,data.frame(value = logistic(post$b_Intercept),
					 period = 'Early Yayoi',
					 region = 'Chubu Highlands'))
# MY Chubu Highlands
pred  <- rbind.data.frame(pred,data.frame(value = logistic(post$b_Intercept + post$b_Period2MY),
					  period = 'Middle Yayoi',
					  region = 'Chubu Highlands'))

# LJ/IY Tokai
pred  <- rbind.data.frame(pred,data.frame(value = logistic(post$b_Intercept + post$b_Period2LJDIY + post$'b_Period2LJDIY:RegionTokai' + post$b_RegionTokai),
					  period = 'Late Jomon to Initial Yayoi',
					  region = 'Tokai'))
# EY Tokai
pred  <- rbind.data.frame(pred,data.frame(value = logistic(post$b_Intercept + post$b_RegionTokai),
					    period = 'Early Yayoi',
					    region = 'Tokai'))

# MY Tokai
pred  <- rbind.data.frame(pred,data.frame(value = logistic(post$b_Intercept + post$b_Period2MY + post$b_RegionTokai + post$'b_Period2MY:RegionTokai'),
					  period = 'Middle Yayoi',
					  region = 'Tokai'))



# Plot posteiors
col1  <- 'darkorange'
col2 <- 'darkgreen'


# plot(NULL,xlim=c(0.5,3.5),ylim=c(0,1),xlab='Region',ylab='Proportion Rice Seed Impressions',axes=FALSE)
# post.bar.v(subset(pred,region=='Tokai'&period=='Late Jomon to Initial Yayoi')$value,i=1-0.15,col=col2)
# post.bar.v(subset(pred,region=='Chubu Highlands'&period=='Late Jomon to Initial Yayoi')$value,i=1+0.15,col=col2)
# post.bar.v(subset(pred,region=='Tokai'&period=='Early Yayoi')$value,i=2-0.15,col=col1)
# post.bar.v(subset(pred,region=='Chubu Highlands'&period=='Early Yayoi')$value,i=2+0.15,col=col2)
# post.bar.v(subset(pred,region=='Tokai'&period=='Middle Yayoi')$value,i=3-0.15,col=col1)
# post.bar.v(subset(pred,region=='Chubu Highlands'&period=='Middle Yayoi')$value,i=3+0.15,col=col2)
# axis(2)
# axis(1,at=c(1,2,3),labels=c('Late Jomon-Initial Yayoi','Early Yayoi','Middle Yayoi'))
# box()
# 
# legend(x=0.4,y=1.0,legend=c('95% HPD','80% HPD','50% HPD'),fill=c(adjustcolor(col1,alpha.f = 0.9),adjustcolor(col1,alpha.f = 0.6),adjustcolor(col1,alpha.f = 0.3)),title='Tokai',bty='n',bg='white',cex=1)
# legend(x=0.4,y=0.8,legend=c('95% HPD','80% HPD','50% HPD'),fill=c(adjustcolor(col2,alpha.f = 0.9),adjustcolor(col2,alpha.f = 0.6),adjustcolor(col2,alpha.f = 0.3)),title='Chubu Highlands',bty='n',bg='white',cex=1)
# 
# nsamples <- c(sum(seeds.ratio$Region=='Tokai'&seeds.ratio$Period2=='LJ/IY'),
# 	      sum(seeds.ratio$Region=='Central Highlands'&seeds.ratio$Period2=='LJ/IY'),
# 	      sum(seeds.ratio$Region=='Tokai'&seeds.ratio$Period2=='EY'),
# 	      sum(seeds.ratio$Region=='Central Highlands'&seeds.ratio$Period2=='EY'),
# 	      sum(seeds.ratio$Region=='Tokai'&seeds.ratio$Period2=='MY'),
# 	      sum(seeds.ratio$Region=='Central Highlands'&seeds.ratio$Period2=='MY'))
# axis(3,at=c(0.85,1.15,1.85,2.15,2.85,3.15),labels=nsamples,padj=.5)
# mtext(side=3,line=2,'Number of Sites')
# 
# 
pdf(file=here('images','riceprop.pdf'),width=7,height=6)
plot(NULL,xlim=c(-0.2,1.2),ylim=c(-0.4,8.1),xlab='Rice Impressions/All Impressions',ylab='',axes=FALSE)
par(mar=c(6,1,1,2))
axis(1,at=c(0,0.2,0.4,0.6,0.8,1.0))

post.bar.h(subset(pred,region=='Chubu Highlands'&period=='Late Jomon to Initial Yayoi')$value,i=7,h=1,col=col2)
text(x=0.75,y=7,label=paste0('n=',sum(subset(seeds.ratio,Region=='Central Highlands'&Period2=='LJ/IY')$impressionsTotal),'(',sum(seeds.ratio$Region=='Central Highlands'&seeds.ratio$Period2=='LJ/IY'),')'))
post.bar.h(subset(pred,region=='Tokai'&period=='Late Jomon to Initial Yayoi')$value,i=6,h=1,col=col1)
text(x=0.08,y=6,label=paste0('n=',sum(subset(seeds.ratio,Region=='Tokai'&Period2=='LJ/IY')$impressionsTotal),'(',sum(seeds.ratio$Region=='Tokai'&seeds.ratio$Period2=='LJ/IY'),')'))
text(x=-0.1,y=6.5,label='Late/Final Jomon',srt=90)

post.bar.h(subset(pred,region=='Chubu Highlands'&period=='Early Yayoi')$value,i=4,h=1,col=col2)
text(x=0.15,y=4,label=paste0('n=',sum(subset(seeds.ratio,Region=='Central Highlands'&Period2=='EY')$impressionsTotal),'(',sum(seeds.ratio$Region=='Central Highlands'&seeds.ratio$Period2=='EY'),')'))
post.bar.h(subset(pred,region=='Tokai'&period=='Early Yayoi')$value,i=3,h=1,col=col1)
text(x=1.08,y=3,label=paste0('n=',sum(subset(seeds.ratio,Region=='Tokai'&Period2=='EY')$impressionsTotal),'(',sum(seeds.ratio$Region=='Tokai'&seeds.ratio$Period2=='EY'),')'))
text(x=-0.1,y=3.5,label='Early Yayoi',srt=90)

post.bar.h(subset(pred,region=='Chubu Highlands'&period=='Middle Yayoi')$value,i=1,h=1,col=col2)
text(x=0.86,y=1,label=paste0('n=',sum(subset(seeds.ratio,Region=='Central Highlands'&Period2=='MY')$impressionsTotal),'(',sum(seeds.ratio$Region=='Central Highlands'&seeds.ratio$Period2=='MY'),')'))
post.bar.h(subset(pred,region=='Tokai'&period=='Middle Yayoi')$value,i=0,h=1,col=col1)
text(x=1.08,y=0,label=paste0('n=',sum(subset(seeds.ratio,Region=='Tokai'&Period2=='MY')$impressionsTotal),'(',sum(seeds.ratio$Region=='Tokai'&seeds.ratio$Period2=='MY'),')'))
text(x=-0.1,y=0.5,label='Middle Yayoi',srt=90)

legend(x=0.9,y=6,legend=c('95% HPD','80% HPD','50% HPD'),fill=c(adjustcolor(col1,alpha.f = 0.9),adjustcolor(col1,alpha.f = 0.6),adjustcolor(col1,alpha.f = 0.3)),title='Tokai',bty='n',bg='white',cex=1)
legend(x=0.9,y=8.5,legend=c('95% HPD','80% HPD','50% HPD'),fill=c(adjustcolor(col2,alpha.f = 0.9),adjustcolor(col2,alpha.f = 0.6),adjustcolor(col2,alpha.f = 0.3)),title='Chubu Highlands',bty='n',bg='white',cex=1)
dev.off()

# Absolute Frequencies ----
seeds.freq <- subset(seeds,N >= 0 & !is.na(Millets.abundance) & !is.na(O.sativa.abundance))
seeds.freq$SiteID <- 1:nrow(seeds.freq) |> as.factor()
fit.millet  <- brm(data=seeds.freq,family='negbinomial',Millets.abundance ~ 1 + Period2 * Region +  offset(log(N)),iter=3000,seed=123)
fit.rice  <- brm(data=seeds.freq,family='negbinomial',O.sativa.abundance ~ 1 + Period2 * Region + offset(log(N)),iter = 3000,seed=123)
post.millet <- as_draws_df(fit.millet)
post.rice <- as_draws_df(fit.rice)

# Millet:
# LJ/IY Chubu Highlands
pred.millet  <- data.frame(value = exp(post.millet$b_Intercept + post.millet$b_Period2LJDIY),
		    period = 'Late Jomon to Initial Yayoi',
		    region = 'Chubu Highlands')

# EY Chubu Highlands
pred.millet <- rbind.data.frame(pred.millet,data.frame(value = exp(post.millet$b_Intercept),
					 period = 'Early Yayoi',
					 region = 'Chubu Highlands'))
# MY Chubu Highlands
pred.millet  <- rbind.data.frame(pred.millet,data.frame(value = exp(post.millet$b_Intercept + post.millet$b_Period2MY),
					  period = 'Middle Yayoi',
					  region = 'Chubu Highlands'))

# LJ/IY Tokai
pred.millet  <- rbind.data.frame(pred.millet,data.frame(value = exp(post.millet$b_Intercept + post.millet$b_Period2LJDIY + post.millet$'b_Period2LJDIY:RegionTokai' + post.millet$b_RegionTokai),
					  period = 'Late Jomon to Initial Yayoi',
					  region = 'Tokai'))
# EY Tokai
pred.millet  <- rbind.data.frame(pred.millet,data.frame(value = exp(post.millet$b_Intercept + post.millet$b_RegionTokai),
					    period = 'Early Yayoi',
					    region = 'Tokai'))

# MY Tokai
pred.millet  <- rbind.data.frame(pred.millet,data.frame(value = exp(post.millet$b_Intercept + post.millet$b_Period2MY + post.millet$b_RegionTokai + post.millet$'b_Period2MY:RegionTokai'),
					  period = 'Middle Yayoi',
					  region = 'Tokai'))


# Rice:
# LJ/IY Chubu Highlands
pred.rice  <- data.frame(value = exp(post.rice$b_Intercept + post.rice$b_Period2LJDIY),
		    period = 'Late Jomon to Initial Yayoi',
		    region = 'Chubu Highlands')

# EY Chubu Highlands
pred.rice <- rbind.data.frame(pred.rice,data.frame(value = exp(post.rice$b_Intercept),
					 period = 'Early Yayoi',
					 region = 'Chubu Highlands'))
# MY Chubu Highlands
pred.rice  <- rbind.data.frame(pred.rice,data.frame(value = exp(post.rice$b_Intercept + post.rice$b_Period2MY),
					  period = 'Middle Yayoi',
					  region = 'Chubu Highlands'))

# LJ/IY Tokai
pred.rice  <- rbind.data.frame(pred.rice,data.frame(value = exp(post.rice$b_Intercept + post.rice$b_Period2LJDIY + post.rice$'b_Period2LJDIY:RegionTokai' + post.rice$b_RegionTokai),
					  period = 'Late Jomon to Initial Yayoi',
					  region = 'Tokai'))
# EY Tokai
pred.rice  <- rbind.data.frame(pred.rice,data.frame(value = exp(post.rice$b_Intercept + post.rice$b_RegionTokai),
					    period = 'Early Yayoi',
					    region = 'Tokai'))

# MY Tokai
pred.rice  <- rbind.data.frame(pred.rice,data.frame(value = exp(post.rice$b_Intercept + post.rice$b_Period2MY + post.rice$b_RegionTokai + post.rice$'b_Period2MY:RegionTokai'),
					  period = 'Middle Yayoi',
					  region = 'Tokai'))

# Make Plot
# plot(NULL,xlim=c(0,1),ylim=c(-0.4,8.1),xlab='Rice Impressions/Sherds',ylab='',axes=FALSE)
# post.bar.h(subset(pred.millet,region=='Chubu Highlands'&period=='Late Jomon to Initial Yayoi')$value,i=7,h=1,col=col2)
# text(x=0.7,y=7,label=paste0(sum(subset(seeds.freq,Region=='Central Highlands'&Period2=='LJ/IY')$N),'(',sum(seeds.freq$Region=='Central Highlands'&seeds.freq$Period2=='LJ/IY'),')'))
# post.bar.h(subset(pred.millet,region=='Tokai'&period=='Late Jomon to Initial Yayoi')$value,i=6,h=1,col=col1)
# text(x=0.06,y=6,label=paste0(sum(subset(seeds.freq,Region=='Tokai'&Period2=='LJ/IY')$N),'(',sum(seeds.freq$Region=='Tokai'&seeds.freq$Period2=='LJ/IY'),')'))
# text(x=-0.1,y=6.5,label='Late/Final Jomon',srt=90)
# 
# post.bar.h(subset(pred.millet,region=='Chubu Highlands'&period=='Early Yayoi')$value,i=4,h=1,col=col2)
# text(x=0.12,y=4,label=paste0(sum(subset(seeds.freq,Region=='Central Highlands'&Period2=='EY')$N),'(',sum(seeds.freq$Region=='Central Highlands'&seeds.freq$Period2=='EY'),')'))
# post.bar.h(subset(pred.millet,region=='Tokai'&period=='Early Yayoi')$value,i=3,h=1,col=col1)
# text(x=1.1,y=3,label=paste0(sum(subset(seeds.freq,Region=='Tokai'&Period2=='EY')$N),'(',sum(seeds.freq$Region=='Tokai'&seeds.freq$Period2=='EY'),')'))
# text(x=-0.1,y=3.5,label='Early Yayoi',srt=90)
# 
# post.bar.h(subset(pred.millet,region=='Tokai'&period=='Middle Yayoi')$value,i=1,h=1,col=col1)
# text(x=1.1,y=1,label=paste0(sum(subset(seeds.freq,Region=='Central Highlands'&Period2=='MY')$N),'(',sum(seeds.freq$Region=='Central Highlands'&seeds.freq$Period2=='MY'),')'))
# post.bar.h(subset(pred.millet,region=='Chubu Highlands'&period=='Middle Yayoi')$value,i=0,h=1,col=col2)
# text(x=0.8,y=0,label=paste0(sum(subset(seeds.freq,Region=='Tokai'&Period2=='MY')$N),'(',sum(seeds.freq$Region=='Tokai'&seeds.freq$Period2=='MY'),')'))
# text(x=-0.1,y=0.5,label='Middle Yayoi',srt=90)
# 
# legend(x=0.9,y=6,legend=c('95% HPD','80% HPD','50% HPD'),fill=c(adjustcolor(col1,alpha.f = 0.9),adjustcolor(col1,alpha.f = 0.6),adjustcolor(col1,alpha.f = 0.3)),title='Tokai',bty='n',bg='white',cex=0.9)
# legend(x=0.9,y=8.5,legend=c('95% HPD','80% HPD','50% HPD'),fill=c(adjustcolor(col2,alpha.f = 0.9),adjustcolor(col2,alpha.f = 0.6),adjustcolor(col2,alpha.f = 0.3)),title='Chubu Highlands',bty='n',bg='white',cex=0.9)
# axis(1)
# 

# Generate Table 
ord <- c(2,1,3,5,4,6)
med.rice <- aggregate(value ~ period+region,data=pred.rice,FUN=function(x){round(median(x),4)})[ord,]
hpd.rice <- aggregate(value ~ period+region,data=pred.rice,FUN=function(x){round(HPDinterval(as.mcmc(x)),4)})[ord,]

med.millet <- aggregate(value ~ period+region,data=pred.millet,FUN=function(x){round(median(x),4)})[ord,]
hpd.millet <- aggregate(value ~ period+region,data=pred.millet,FUN=function(x){round(HPDinterval(as.mcmc(x)),4)})[ord,]

nsherds <- aggregate(N ~ Period2 + Region, data=seeds.freq,FUN=sum)[ord,]
nsites <- aggregate(N ~ Period2 + Region, data=seeds.freq,FUN=length)[ord,]

table.out  <- med.rice
colnames(table.out)[3] <- 'rice'
table.out$rice  <- paste0(table.out$rice,'(',hpd.rice[,3][,1],'-',hpd.rice[,3][,2],')')
table.out$millet <- paste0(med.millet[,3],'(',hpd.millet[,3][,1],'-',hpd.millet[,3][,2],')')
table.out$n.sites <- nsites[,3]
table.out$nsherds <- nsherds[,3]
write.csv(table.out,here('results','table_seed_freq.csv'),row.names=F)



