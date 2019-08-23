########################################################################
## Some code for quick and dirty analysis of Socsim output
## Carl Mason 
##Tue Mar  5 12:53:30 PST 2013
##
## This is a good place to start figuring out how socsim works
## This file contains code that will allow you to:
##
## (1)run the example socsim simulation in the parent "Sample" directory
## (2)read the resulting population data files into R
## (3)recover the specified rates (ratefile.min)
## (4)recover several of the specified simulation parameters (example.sup)
##
########################################################################

####Running Socsim
## Socsim is generally run from the unix command line by typing:

## socsim sample.sup 13531


## where "sample.sup" is in the Socsim instruction file and "13531"
## is a random number seed.

## Socsim can also be run from within R using the the system()
## function. This is a very convenient thing to do because socsim
## generally must be run many times in order to get statistically
## valid results. That is what we do in this file

## typically socsim will be installed in
## /usr/local/bin if not, then adjust this:
socsim="/usr/local/bin/socsim"
## user needs to be unique in case some one else is running this
## code at the same time as you are
USER=system("echo $USER",intern=TRUE)
## Assuming that this file is in Sample/Rcode  then this should execute
## the example.sup in the parent directory

cmd<-paste("cd ..;", socsim, "sample.sup 13531")
## this command will be run in the shell
cmd
## note that socsim requires a ".sup" file and a random number seed
system(cmd)
## This file contains ReadSocOut() which reads socsim output files

source("ReadSocOut.r")
detach(soc)  ## just in case an old soc is still attached. If not, the
## ignore the error message
rm(opop,omar,otx,opox)
## example.sup causes output to be written to /72hours You
## may need to change this to /tmp or something like that
##output files are large and easy to reproduce.

soc<-ReadSocOut(stem="../SimResults/sample")

## soc is a list containing 4 data frames:
## opop -- population records
## omar -- marriage records
## opox -- "extra" variables will be empty in plain version of socsim
## otx  -- transition history empty unless transition events are specified
names(soc)
attach(soc)
########################################################################
## 
## Below are source()'ed several chunks of code below are intended to
## be self contained. You *should* not need to run the code that deals
## with marriage rates in order to run the code that recovers
## mortality rates. But of course you *should*.
##
## Since there is no particular order to the chunks of code below, you
## may wish to skip around tacklings perhaps some of the easier
## problems such as verifying group inheritance patterns before
## tackling some of the more difficult R code for recovering rates.
##
########################################################################
## Marriage Rates
## recovering marriage rates for males and females.  If sample.sup specifies
## one queue marriage market then only female rates can be compared to
## input rates since males are always available for marriage and are selected
## to optimize the marriage age distribution.
##
## In the 2-queue system, marriage rates are specified for both sexes, but
## marriages happen when compatible pairs are located. Generally this
## means that actuall marriage rates will fall below those specified.
########################################################################

source(file="marriageRates.r")

asmarr<-marriageRates(soc,mseq=c(0,15,20,25,35,45,100)*12)
asmarr

## If you have not modified the sample.sup file then asmarr[,2] should
##  "match" for FIRST marriages rates specified for females in ratefile.min.

## By "match" of course we mean come close to -- this is a stochastic
##  simulation.  If you have changed sample.sup then all bets are
##  off. Among the things that could cause asmarr[,2] to differ from
##  the specified rates are:


## (1) Using the 2 queue marriage system -- under this scheme, women might
## spend time on the marriage queue. Under the 1 queue syste only men
## do (generally)
## (2) Group migration will complicate
## things greatly and
## (3) of course marriage from states such as widowhood
## are ignored here All of these *could* explain why these numbers
## don't match what's in your .sup. If the numbers don't match, it
## would be wise to figure out why.


########################################################################
## Mort rates
## recovering mortality rates
## This assumes that mortality rates do not vary by group or marital
## status. If they do, it's tricker
########################################################################
## age at death or censored

source(file="mortRates.r")
asMort<-mortRates(soc,mseq=c(0,1,12,seq(5,100,by=5)*12))
asMort
########################################################################
## Fertility rates
## Fertility rates can vary by age,group,marital status, and parity
## in the example simulation they vary only by age.
########################################################################

source(file="fertRates.r")
asFert<-fertRates(soc,fseq=c(0,(14:45),100)*12)
asFert

## Fertility rates can differe by group and marital status -- the
## above calucluations assume that they do not.

########################################################################
## birth interval
## minimum birth interval defaults to 9 months. set by
## bint directive in .sup
########################################################################

## produces a list for each woman of the months between births
sibdif<-with(opop[opop$mom !=0,],
             tapply(dob,mom,function(x){diff(sort(x))}
             ))

## min should match bint
summary(unlist(sibdif))

plot(table(unlist(sibdif)),main="Birth Intervals")
sum(asFert,na.rm=TRUE)*12
########################################################################
## heterogeneous fertility
## heterogeneous fertility is controlled by the hetfert directive
## which defaults to 1/true. When enabled (default) each woman has an
## "fmult" value which is drawn from a gamma distribution.
## strength of inheritance from mother is determined by alpha and beta
## directives.
########################################################################

plot(density(opop$fmult))


## collect realized fertility of all women with complete lives
## this will only catch women with at least on birth that's ok
fert<-with(opop[opop$mom !=0 & opop$dod != 0,],
           tapply(pid,mom,length)
           )
## collect fmult on all women with complete lives
fmult<-with(opop[opop$mom !=0 & opop$dod != 0 & opop$fem==1,],
           tapply(fmult,pid,mean)
           )

ff<-data.frame(
               fmult=fmult,
               ## NAs will happen for women with no births
               fert=fert[match(names(fmult),names(fert))])

## NAs are zeros
ff$fert[is.na(ff$fert)]<-0
summary(lm(fert~fmult,data=ff))
## mean fmult by realized fertility: higher fert; higher fmult

with(ff,
     boxplot(fert~cut(fmult,breaks=12),
             main="Realized fertility and fmult",
             xlab="Fertility multiplier",
             ylab="Completed fertility")
     )

cbind(with(ff,
     tapply(fmult,fert,mean)
     ))


#############################################
## Fertmult inheritance
############################################
opop$momfmult<- opop[z2na(opop$mom),"fmult"]

## should be insignificant if alpha /beta are default
summary(lm(fmult~momfmult,data=opop,subset=fem==1))
     

#############################################
## *child_inherits_group from_
## ** group inheritance at birth: from_father from_mother 
## ** from_same_sex_parent or from_opposite_sex_parent

#############################################

## frequency table: group of ego vs group of mother
with(opop[opop$mom >0,],
     table(group,opop[mom,"group"])
   )
## frequency table: group of ego vs group of father
with(opop[opop$pop >0,],
     table(group,opop[pop,"group"])
   )

#############################################
## Marriage age pattern marriage preference across age is either
## "preference" or "distribution" as per the "marriage_eval"
## directive.  preference is the old way under which each potential
## spouse is evaluated according to a fixed preference for groom_age -
## bride_age. example.sup invokes the newer scheme which is driven by
## the difference between the observed and desired disribution of the
## age difference at marriage. Currently the target distribution is
## normal with mean/sd specified in .sup for each group.  unspecified
## groups default to group1 values.
#############################################


########################################################################
## for marriage_eval==distribution
## verify in sample.sup that marriage_eval is set to *distribution*
########################################################################
m.ages<-data.frame(
                   ## older --> lower dob so this is his age - her age
                   adif=(opop[omar$wpid,"dob"]-opop[omar$hpid,"dob"])/12,
                   fgroup=opop[omar$wpid,"group"],
                   mgroup=opop[omar$hpid,"group"])
head(m.ages)
plot(density(m.ages$adif))
function(x){c(mean(x),sd(x))}
## mean and sd of age difference at marriage by group of woman
with(m.ages,
     list(means= tapply(adif,list(fgroup),mean),
          sds= tapply(adif,list(fgroup),sd)
          )
     )


## compare age difference distribution to normal
opar<-par(mfrow=c(length(unique(m.ages$fgroup)),1))
for(fg in 1:max(m.ages$fgroup)){
  qqnorm(m.ages[m.ages$fgroup==fg,"adif"],
         main=paste("age difference at marriage female group:",fg))
}
par(opar)
########################################################################
## for marriage_eval==preference
## VERIFY that sample.sup specifies marriage_eval *preference*
########################################################################
## histogram of age difference at marriage
hist(m.ages$adif)
m.ages.tab<-table(m.ages$adif)
## marriage_age_peak
peak<-as.numeric(names(m.ages.tab)[m.ages.tab==max(m.ages.tab)]);peak

## marriage_age_slope_ratio is not very effective. If cohort sizes are
## equal and marriage is common, it is difficult to find men much
## older than available women. The effect of marriage_age_slope is
## visible in the sample sim if you set it very high and constrain
## marriage_age_min and marriage_age_max to be around 12 and 60
## repectively.

## 
table(cut(m.ages$adif,breaks=seq(-peak, 3*peak,length=8)))
plot(
        table(cut(m.ages$adif,breaks=seq(-peak, 3*peak,length=40)))
     )

#############################################
## random_father
## if 1 then random dads selected for each birth to unmarried female
## if 0 then such births have father's id = 0
## The initial population always has 0s for both parents
#############################################
dim(opop)
dim(omar)
## how many have no fathers
sum(opop$pop==0)
## of those how many are in the initial pop
sum(opop$pop==0 & opop$mom==0)


########################################################################
## random_father_min_age
########################################################################
## Not perfect since marriage could happen after birth of child
## and we assume no divorce

if(sum(opop$pop==0) == sum(opop$pop==0 & opop$mom==0)){
  ## random dad must be in effect since only init pop is paternally
  ## zeroless (but universal marriage OR zero nonmarital fertility
  ## would also do this)

  ## find marid where mom and dad are spouses
  opop$md.mid<-match(paste(opop$mom,opop$pop),paste(omar$wpid,omar$hpid))
  ## how many random dads (delete init pop):
  random.kids<-sel<- is.na(opop$md.mid) & opop$mom !=0; sum(sel)
  
  ## kids dob - fathers where father is randomly assigned
  ## in years
  summary( random.dad.ages<-(opop[random.kids,"dob"] -
                             opop[opop[random.kids,"pop"],"dob"] )/12
          )
  hist(random.dad.ages)
}else{
  print("kids born in simulation with father=zero random_father not enabled?")
}

#############################################
## Endogamy/Exogamy/Randomogomy
#############################################
## First check group distribution
if(length(unique(opop$group))==1){
  print("only one group in simulation Endogamy not interesting")
}else{
  table(opop$group)
  ## crosstab of group by marriage
  mgrp.tab<-table(opop[omar$wpid,"group"],opop[omar$hpid,"group"])
  mgrp.tab; prop.table(mgrp.tab)
  plot(mgrp.tab,main="Intergroup marriage pattern")
  table(opop$group)
}




########################################################################
## Group Transitions  (commented out in ratefile.min ? )

### Recovering transition rates is tricky since exposure is determined
### by marital status AND group membership.  It is possible also to
### make transition rates depend on duration in group INSTEAD of
### age. These calculations assume that you have NOT done that.

## obviously, transitions have to be specified in example.sup for this
## to work at all. Unless you have uncommented them in the ratefile,
## group transitions are *probabaly* in the simulation. As long as
## rates are group invariant (as they are in the plain sample.sup
## example) then they will not complicate other calculations.
########################################################################
names(otx)
## count transitions -- assuming they are specified in example.sup
table(otx$fromg,otx$tog)

## Let's try to recover the specified rates using survival analysis.

## create matrix with one row for each transition, birth or 
## death (from and to group 0 respectively) ordered by date of event
## we'll use this to run Survfit.  needs pid, fromg, tog, start time,
## end time and censorhood.  Need to add marriage records too as censoring
## events. In example, txrates only apply to single people.

opop$birth.group<-
  ifelse(opop$pid %in% otx$pid,
         otx$fromg[match(opop$pid,otx$pid)],
         opop$group)

birth.rex<-cbind(opop[,c("pid","dob")],0,opop$birth.group,0)
lastmo<-max(c(opop$dob,opop$dod,otx$tod))
death.rex<-cbind(opop$pid,
                 ifelse(opop$dod==0,lastmo,opop$dod),
                 opop$group,opop$group,
                 ifelse(opop$dod==0,lastmo-opop$dob,opop$dod-opop$dob))

colnames(death.rex)<-colnames(birth.rex)<-
  nvec<-c("pid","dot","fromg","tog","age")

## tx rates for single only so first marriage is a censor point
marF.rex<-marM.rex<-NULL
if(length(omar)>0){
  
  marF.rex<-cbind(omar[,c("wpid","dstart")],NA,NA,
                  omar$dstart -opop$dob[omar$wpid])
  
  marF.rex<-marF.rex[!duplicated(marF.rex[,1]),]
  marM.rex<-cbind(omar[,c("hpid","dstart")],NA,NA,
                  omar$dstart - opop$dob[omar$hpid])
  marM.rex<-marM.rex[!duplicated(marM.rex[,1]),]
  colnames(marF.rex)<-colnames(marM.rex)<-nvec
}

otx$age<-otx$dot - opop[otx$pid,"dob"]
tx.rex<-rbind(birth.rex[,nvec],death.rex[,nvec],
              otx[,nvec],marF.rex[,nvec],marM.rex[,nvec])

## order by date of event within pid
tx.rex<-tx.rex[order(tx.rex$pid,tx.rex$dot),]
## add fem
tx.rex$fem<-opop$fem[match(tx.rex$pid,opop$pid)]
                  
## add mstatus
tx.rex.dom<-ifelse(tx.rex$fem==0,
                   omar$dstart[match(tx.rex$pid,omar$hpid)],
                   omar$dstart[match(tx.rex$pid,omar$wpid)])
tx.rex$evermarr<-ifelse(tx.rex$dot > tx.rex.dom,TRUE,FALSE)
tx.rex$evermarr[is.na(tx.rex.dom)]<-FALSE
## get a sequence number so we can affix the start date of
## each event waiting time
tx.rex.seq<-unlist(tapply(tx.rex$dot,tx.rex$pid,order))
## indx is composed of pid and sequence number of event 
tx.rex$indx<- paste(tx.rex$pid,tx.rex.seq,sep=':')

## tog and fromg are same for marriage events and are previous tog
tx.rex.prev.grp<-tx.rex$tog[match(paste(tx.rex$pid,tx.rex.seq-1,sep=':'),
                                  tx.rex$indx)]
tx.rex$fromg[is.na(tx.rex$fromg)]<-tx.rex.prev.grp[is.na(tx.rex$fromg)]
tx.rex$tog[is.na(tx.rex$tog)]<-tx.rex.prev.grp[is.na(tx.rex$tog)]

## now get start.age right

## age at start is the time of the previous event -- which could be birth
## but birth events should have no previous and therefore windup NA
tx.rex$start.age<-tx.rex$age[match(paste(tx.rex$pid,tx.rex.seq-1,sep=':'),
                                   tx.rex$indx)]

table(tx.rex$fromg)
sum(is.na(tx.rex$start.age))
##tx.rex<-tx.rex[!is.na(tx.rex$start.age),]
tx.rex<-tx.rex[tx.rex$fromg !=0,]
table(tx.rex$fromg)
## delete birth records
dim(tx.rex)

library(survival)
tx.rex$depvar<-with(tx.rex,
                    Surv(time=start.age,
                         time2=age+.01,  ## end time must be > start time
                         event=ifelse(fromg==tog,0,1)))

fit1<-survfit(depvar ~ fromg+fem+evermarr, data=tx.rex)
plot(fit1)
## translate rates from ratefile referenced in example.sup
## into dotted red lines of truth
## at risk period is 10 years
spec.rates<-c(.01,.005,.003,.001,.03)
sprobs<- 1-(1-spec.rates)^120
abline(h= 1-sprobs,col='red',lty=2)
text(x=50,y=1-sprobs,label=paste(spec.rates),pos=3,adj=1)
head(tx.rex)

########################################################################
## Suggestions
##
## (1) change a single rate in the ratefile -- mortality, fertiliy or
## transit and verify that you can recover it from the simulation
## results. Obviously this will require rerunning socsim and
## re-reading the .opop and .omar files.

## (2) Explore the interplay of population growth rates with the
## proportion_male and random_father directives. Leaving fertility
## rates constant, how would you expect an increase(decrease) in the
## proportion of births which are male to affect population growth --
## remember there are both marital and NONmarital fertility
## rates. Predict also the effect of random_father which determines
## whether or not fathers are assigned at random to children borh to
## unmarried mothers.

## (3) figure out how you might cause all married people to
## immediately transit to a particular group. Test you configuration
## by examing the .opop and .omar files.

## (4) Create a second simulation segment with one different rates
##  Measure the change in the output resulting from this
## change.  The R challenge is to distinguish between events a that
## occured during the first and second simulation segments.


## (5) Explore the effects of the endogamy parameter. Note that
## specifying a number other than -1,0,1 results in socsim
## stochastically rejecting potential suitors but does NOT specify
## directly the proportion of marriages that will be between members
## of various groups.

## (6) Explore the effects of the one vs two queue marriage system and
## the preference vs distribution setting of the marriage_eval
## parameter.  The one queue marriage system and the distribution
## matching marriage evaluation scheme are new to Socsim.

## (7) if none of these appeal or if you just have too much time on
## your hands, extend this exercise in some other more interesting
## way.
