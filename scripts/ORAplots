# R script for all plots used in figures presenting organic residue analysis data in manuscript and statistical tests 

library("devtools")
library("Rcpp")
library("ggplot2")
library("ggrepel")
library("gridExtra")
library("cowplot")
library("extrafont")
library("extrafontdb")
library("ggrepel")
library("scales")
library("dplyr")
library("ggstar")
library("tibble")
library(dunn.test)

#Read ORAresult spreadsheet 

#download ORAresults.csv

# Set the file path to your CSV file
file_path1 <- "////ORAresults.csv"

# Read data from the CSV file
ALLDATA <- read.csv(file_path1)

# Display the first few rows of the data
head(ALLDATA)

#Read authentic modern reference fats spreadsheet

#dowmload JAPREF.scv

# Set the file path to your CSV file
file_path2 <- "////JAPREF.csv"

# Read data from the CSV file
JAPREF <- read.csv(file_path2)

# Display the first few rows of the data
head(JAPREF)

#colour palettes 

cbPalette1 <- c("#0072B2" ,"#F0E442")
cbPalette2 <- c("#009E73","#F0E442" )


#Filters 

ASA <-filter (ALLDATA,Site_code=="ASA")
HL <-filter (ALLDATA,Subregion=="Central Highlands")
TOK <-filter (ALLDATA,Subregion=="Tokai")

#levels 

# Creating levels 

custom_order <- c("UMK", "MMZ", "ASA", "NKY","NMI", "TSJ")
custom_order2 <- c("no", "yes") 
ALLDATA$Site_code <- factor(ALLDATA$Site_code, levels = custom_order)
TOK$Site_code <- factor(TOK$Site_code, levels = custom_order)
HL$Site_code <- factor(HL$Site_code, levels = custom_order)
HL$Miliacin <- factor(HL$Miliacin, levels = custom_order2)
TOK$Miliacin <- factor(TOK$Miliacin, levels = custom_order2)


# APAA18 E/H ratio of archaeological samples box and dot plot 
box_plotALLAPPA1 <- ggplot(ALLDATA, aes(x=Site_code, y=APAA_EH, fill=Subregion)) +
  geom_boxplot(width=0.8, size=0.2, outlier.size=1)+ geom_dotplot(binaxis="y", stackdir="center")+scale_fill_manual(values=c("#009E73", "#0072B2"))+
  ylab("E/H APAA") + scale_y_continuous(position = "left",limits=c(0,12))+
  theme_bw(base_size = 20)
plot(box_plotALLAPPA1)

# statistical tests 
kruskal.test(APAA_EH ~ Site_code, data = TOK)
kruskal.test(APAA_EH ~ Site_code, data= HL)
dunn.test(ALLDATA$APAA_EH,g= ALLDATA$Site_code)
dunn.test(HL$APAA_EH,g= HL$Site)
dunn.test(TOK$APAA_EH,g= TOK$Site_code)



#  Plot of δ13C16:0 against δ13C18:0 of pottery extracts from central highland sites a) Nakaya, b) Nakamichi, c) Tenshoji and Tokai sites d) Ushimaki, e) Mamizuka and f) Asahi. 

REF <- ggplot()+
  scale_shape_manual(breaks=c(), values=c(1,2))+
  labs(x=expression(delta^{13}*C[16:0]*"(\u2030)"), y=expression(delta^{13}*C[18:0]*"(\u2030)"))+
  scale_x_continuous(position="top", limits=c(-40,-15))+
  scale_y_continuous(position = "left",limits=c(-40,-15))+
  theme_bw()+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  theme(axis.ticks.length=unit(-0.2,"cm"))+
  theme(plot.title=element_text(hjust=0.5, family = "Times New Roman"))+
  theme(axis.text=element_text(size=18),
        axis.title = element_text(size=18),
        axis.text.x.top = element_text(margin = margin(b = 8)),
        axis.title.x.top = element_text(margin = margin(t=10, b=15)),
        axis.text.y.right = element_text(margin = margin(l= 8)),
        axis.title.y.right = element_text(margin = margin(l=15)),
        title = element_text(size=18)) +
  guides(color=FALSE, shape=FALSE)+
  #geom_abline(intercept=-3.3, slope= 1, linetype="dashed")+
  #geom_abline(intercept=-1 ,slope= 1, linetype="dashed")+
  annotate("text", label = "C4/millet", x = -20, y = -17, size = 4, colour = "black")+ 
  annotate("text", label = "Marine", x = -25, y = -22, size = 4, colour = "black")+ 
  annotate("text", label = "Freshwater", x = -31, y = -29, size = 4, colour = "black")+ 
  annotate("text", label = "Wild boar", x = -30, y = -27, size = 4, colour = "black")+ 
  annotate("text", label = "Ruminant", x = -29, y = -35, size = 4, colour = "black")+ 
  annotate("text", label = "C3 nuts", x = -35, y = -33, size = 4, colour = "black")+
  annotate("text", label = "Rice", x = -34, y = -34, size = 4, colour = "black")+ 
  stat_ellipse(geom= "polygon", data=JAPREF, alpha=0.2, linetype=2, level=0.68, aes (x=d13C16, y= d13C18, group=Catagory))+
  coord_fixed(ratio = 1)
plot1 <- REF + geom_star(data=TOK, aes(y=d13C18,x=d13C16, fill= Miliacin, starshape=Miliacin), size=4, stroke=3, alpha=0.8)+
  scale_fill_manual(values=cbPalette1)+coord_cartesian(ylim=c(-37,-17), xlim = c(-37,-17))+ scale_starshape_manual(name="Milllet biomarker", breaks=c("yes","no"),values=c(1,15))+
  facet_grid (~ Site_code)+  theme_bw(base_size = 25)+   theme(legend.position = "none")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ theme(strip.background = element_blank(), strip.text = element_blank())
plot1

plot2 <- REF + geom_star(data=HL, aes(y=d13C18,x=d13C16, fill= Miliacin, starshape=Miliacin), size=4, stroke=3, alpha=0.8)+
  scale_fill_manual(values=cbPalette2)+coord_cartesian(ylim=c(-37,-17), xlim = c(-37,-17))+ scale_starshape_manual(name="Milllet biomarker", breaks=c("yes","no"),values=c(2,15))+
  facet_grid (~ Phase)+  theme_bw(base_size = 25)+   theme(legend.position = "none")+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+ theme(strip.background = element_blank(), strip.text = element_blank())
plot2

kruskal.test(d13C16 ~ Site_code, data = TOK)
kruskal.test(d13C16~ Site_code, data= HL)
dunn.test(ALLDATA$d13C16,g= ALLDATA$Site_code)

#ASAHI BY PHASE (EARLY/ MIDDLE YAYOI)
plot3 <- REF + geom_point(data=ASA, aes(y=d13C18,x=d13C16, shape=Typology, fill=Site), colour= 'black', size=3, stroke=1, alpha=0.8)+
  scale_shape_manual(values=c(21,22,23,24)) +
  scale_fill_manual(values=c("#D55E00","#009E73"))+
  facet_grid (~Site)+theme_bw(base_size = 15)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
plot3

kruskal.test(d13C16 ~ Phase, data = ASA)

#ASAHI BY POTTERY FORM 
plot4 <- REF + geom_point(data=ASA, aes(y=d13C18,x=d13C16, shape=Typology, fill=Site), colour= 'black', size=3, stroke=1, alpha=0.8)+
  scale_shape_manual(values=c(21,22,23,24)) +
  scale_fill_manual(values=c("#D55E00","#009E73"))+
  facet_grid (~Form)+  theme_bw(base_size = 15)+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
plot4

kruskal_result<- kruskal.test(d13C16 ~ Form, data = ASA)

# Calculate the effect size (Eta-squared)
n_groups <- length(unique(ASA$Form))
n <- nrow(ASA)

# Calculate the Kruskal-Wallis statistic
H <- kruskal_result$statistic

# Calculate the degrees of freedom
df <- kruskal_result$parameter

# Calculate Eta-squared
eta_squared <- (H - df) / (n - df)

# Report the effect size
cat("Kruskal-Wallis Test Effect Size (Eta-squared): ", round(eta_squared, 2), "\n")
cat("Kruskal-Wallis Test p-value: ", kruskal_result$p.value, "\n")
