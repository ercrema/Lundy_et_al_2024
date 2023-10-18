library(here)
library(ggplot2)
library(brms)
library(tidybayes)
library(coda)

seeds  <- read.csv(here('data','seeds_2.1.0.csv')) |> subset(Region%in%c('Central Highlands','Tokai'))
seeds$Period2 <- NA
seeds$Period2[seeds$Period%in%c('Final Jomon','End of Final Jomon - Initial Yayoi','End of Final Jomon/Initial Yayoi','Late Jomon - Final Jomon')] <- 'LJ/IY'
seeds$Period2[seeds$Period%in%c('Early Yayoi')] <- 'EY'
seeds$Period2[seeds$Period%in%c('Middle Yayoi','First half of Middle Yayoi')]  <- 'MY'
table(seeds$Period2,seeds$Region)
seeds$impressionsTotal  <- seeds$O.sativa.abundance+seeds$Millets.abundance
seeds <- subset(seeds,!is.na(Period2))

### Fit Model 1 (Rice/Millet Ratio) ----
seeds.model1  <- subset(seeds,!is.na(seeds$impressionsTotal))
seeds.model1$SiteID <- 1:nrow(seeds.model1) |> as.factor()
seeds.model1$rice <- seeds.model1$O.sativa.abundance

fit  <- brm(data=seeds.model1,family=binomial,rice|trials(impressionsTotal) ~ 1 + (1|SiteID) + Period2 * Region)
summary(fit)
# post <- posterior_samples(fit)
post <- as_draws_df(fit)

logistic <- function(x)
{
	1/(1+exp(-x))
}

# Combine Prediction ----
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

# Plot posteiors ----
col1  <- 'darkorange'
col2 <- 'darkgreen'
post.bar <- function(x,i,h=0.4,col)
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

plot(NULL,xlim=c(0.5,3.5),ylim=c(0,1),xlab='Region',ylab='Proportion Rice Seed Impressions',axes=FALSE)
post.bar(subset(pred,region=='Tokai'&period=='Late Jomon to Initial Yayoi')$value,i=1-0.15,col=col2)
post.bar(subset(pred,region=='Chubu Highlands'&period=='Late Jomon to Initial Yayoi')$value,i=1+0.15,col=col2)
post.bar(subset(pred,region=='Tokai'&period=='Early Yayoi')$value,i=2-0.15,col=col1)
post.bar(subset(pred,region=='Chubu Highlands'&period=='Early Yayoi')$value,i=2+0.15,col=col2)
post.bar(subset(pred,region=='Tokai'&period=='Middle Yayoi')$value,i=3-0.15,col=col1)
post.bar(subset(pred,region=='Chubu Highlands'&period=='Middle Yayoi')$value,i=3+0.15,col=col2)
axis(2)
axis(1,at=c(1,2,3),labels=c('Late Jomon-Initial Yayoi','Early Yayoi','Middle Yayoi'))
box()

legend(x=0.4,y=1.0,legend=c('95% HPD','80% HPD','50% HPD'),fill=c(adjustcolor(col1,alpha.f = 0.9),adjustcolor(col1,alpha.f = 0.6),adjustcolor(col1,alpha.f = 0.3)),title='Tokai',bty='n',bg='white',cex=1)
legend(x=0.4,y=0.8,legend=c('95% HPD','80% HPD','50% HPD'),fill=c(adjustcolor(col2,alpha.f = 0.9),adjustcolor(col2,alpha.f = 0.6),adjustcolor(col2,alpha.f = 0.3)),title='Chubu Highlands',bty='n',bg='white',cex=1)

nsamples <- c(sum(seeds.model1$Region=='Tokai'&seeds.model1$Period2=='LJ/IY'),
	      sum(seeds.model1$Region=='Central Highlands'&seeds.model1$Period2=='LJ/IY'),
	      sum(seeds.model1$Region=='Tokai'&seeds.model1$Period2=='EY'),
	      sum(seeds.model1$Region=='Central Highlands'&seeds.model1$Period2=='EY'),
	      sum(seeds.model1$Region=='Tokai'&seeds.model1$Period2=='MY'),
	      sum(seeds.model1$Region=='Central Highlands'&seeds.model1$Period2=='MY'))
axis(3,at=c(0.85,1.15,1.85,2.15,2.85,3.15),labels=nsamples,padj=.5)
mtext(side=3,line=2,'Number of Sites')


