
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




## Make relative to 0% D (within each species)
pred <- expand.grid(Species=c("Of", "Ss", "Mc"), PropD=seq(0,1,len=101), time=c("init", "bleach"))
#pred$pred <- predict(bleachmod, pred, re.form=NA, se=T)
bootfit <- bootMer(bleachmod, FUN=function(x) predict(x, pred, re.form=NA), nsim=999)
# Extract 90% confidence interval on predicted values
pred$fit <- predict(bleachmod, pred, re.form=NA)
pred$lci <- apply(bootfit$t, 2, quantile, 0.05)
pred$uci <- apply(bootfit$t, 2, quantile, 0.95)

rel <- lapply(split(pred, f=interaction(pred$Species, pred$time)), 
              function(x) within(x, rel <- x[, c("fit", "lci", "uci")] / x$fit[x$PropD==0]))
rel <- do.call("rbind", rel)


## Quantify the "cost" and "benefit" of clade D relative to other symbiont?


# How well does D perform relative to other symbiont under normal conditions?
normal <- rel[rel$PropD==1 & rel$time=="init",]
normal

# How well does D perform relative to other symbiont under stressful conditions?
stress <- rel[rel$PropD==1 & rel$time=="bleach",]
stress


df <- rel[rel$PropD==1, ]
rel.fit <- t(as.matrix(data.frame(normal=normal$rel$fit, stress=stress$rel$fit))) - 1
rel.lci <- t(as.matrix(data.frame(normal=normal$rel$lci, stress=stress$rel$lci))) - 1
rel.uci <- t(as.matrix(data.frame(normal=normal$rel$uci, stress=stress$rel$uci))) - 1
bars <- barplot(rel.fit, beside = T, ylim=c(-0.3,0.8), names.arg=levels(alldata$Species))
arrows(matrix(bars), matrix(rel.lci), matrix(bars), matrix(rel.uci), length = 0.05, lwd=1, xpd=NA, code=3, angle=90)
mtext(side=2, "Relative difference in Fv/Fm of\nclade D and other symbiont", line=2.2, cex=0.8)
legend("topleft", pch=22, pt.bg=c("gray20", "gray80"), pt.cex=2, cex=0.8, inset=c(0.02, -0.05),
       bty = "n", legend = c("Non-stressful conditions", "After 10 days at 32°C"))
abline(h=0)
