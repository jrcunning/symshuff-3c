library(lme4)
library(reshape2)
library(effects)
library(lsmeans)

# Load data -----
rm(list=ls())
alldata <- read.csv("data/master.csv")
alldata <- alldata[-360, ]  # Remove duplicate Mc9_2 entry with incorrect Fv/Fm recov2 value
alldata$Species <- factor(alldata$Species, levels=c("Of", "Ss", "Mc"))

# Init Fv/Fm for Mcav during second heat bleaching (=same as recov from 1st)
Mc <- subset(alldata, Species=="Mc" & BleachLvl2=="Heat")
#plot(MaxY.recov ~ PropD.recov, Mc)
mcmaxyrecov.m <- lmer(MaxY.recov ~ PropD.recov + (PropD.recov|Colony), Mc)
anova(mcmaxyrecov.m)
#plot(Effect("PropD.recov", mcmaxyrecov.m))
#plot(MaxY.bleach2 ~ PropD.bleach2, Mc)
mcmaxybleach2.m <- lmer(MaxY.bleach2 ~ PropD.bleach2 + (PropD.recov|Colony), Mc)
#plot(Effect("PropD.bleach2", mcmaxybleach2.m))

# How much is Fv/Fm reduced in Mcav because they were previously bleached? - can't tell because changed to D - confounded

# Get data frame with Of, Ss 10-day bleach  (Med bleach only or all bleachlvls pooled?)
#SsOf <- subset(alldata, BleachLvl=="Med" & Species!="Mc")
SsOf <- subset(alldata, Species!="Mc")
# Get data frame with Mc 10-day bleach (from repeat bleaching experiment)
Mc <- subset(alldata, BleachLvl2=="Heat" & Species=="Mc")
Mc$PropD.init <- Mc$PropD.recov  # Recov from initial bleach = init for repeat bleach / for merging with Ss, Of
Mc$MaxY.init <- Mc$MaxY.recov
Mc$PropD.bleach <- Mc$PropD.bleach2  # repeat bleach = bleach / for merging with Ss, Of
Mc$MaxY.bleach <- Mc$MaxY.bleach2
# Merge three species together (from two separate but comparable bleaching experiments)
bleach10day <- rbind(SsOf, Mc)[, c("Species", "Colony", "Core", "PropD.init", "MaxY.init", "PropD.bleach", "MaxY.bleach")]
bleach10daymelt <- melt(bleach10day, id.vars = c("Species", "Colony", "Core"))
bleach10daymelt <- cbind(bleach10daymelt, colsplit(bleach10daymelt$variable, pattern="\\.", names=c("resp", "time")))
bleachdat <- dcast(bleach10daymelt, formula = Species + Colony + Core + time ~ resp, value.var="value")
bleachdat$time <- factor(bleachdat$time)
# Fit model
bleachmod <- lmer(MaxY ~ PropD * time * Species + (PropD|Species:Colony), bleachdat)
# are random slopes necessary?
#lmerTest::step(bleachmod) #yes
anova(bleachmod)
plot(Effect(c("PropD", "time", "Species"), bleachmod), multiline=T)

# Compare slopes of Fv/Fm vs. PropD among species and times
lst <- lstrends(bleachmod, specs=c("Species", "time"), var="PropD")
contrast(lst, by="Species", method="pairwise")
contrast(lst, by="time", method="pairwise", adjust="mvt")