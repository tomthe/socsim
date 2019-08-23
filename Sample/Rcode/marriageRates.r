marriageRates<-function(soc,mseq=c(0,15,20,25,35,45,100)*12){
  ## expects list containing $opop and $omar and mseq which contains
  ## age break points from marriage rates
  
  ## recovers marriag rates entire population. Makes sense if marriage
  ## rates are constant throughout simulation.

  ##age at death OR END OF SIMULATION
  opop<-soc$opop
  omar<-soc$omar
  opop$aged<- with(opop,
                   ifelse(dod==0,max(opop$dob),dod) - opop$dob)
  ## wife's age at marriage attached to opop (NA for males of course)
  omar$wage<-with(omar,
                  dstart-opop[wpid,"dob"])
  ## husband's age at marriage
  omar$hage<-with(omar,
                  dstart-opop[hpid,"dob"])
                                        #wife's age at end of marriage or end of simulation
  omar$wend<-with(omar,
                  ifelse(dend==0,max(opop$dob),dend),-opop[wpid,"dob"])
  omar$hend<-with(omar,
                  ifelse(dend==0,max(opop$dob),dend),-opop[hpid,"dob"])
  
  ## to cut into categories that match the input rates
  ## recall that upper age bounds are part of the next higher age category
  ## 
  
  ## h/w ages as  category as ordered factor
  
  omar$wagec<-cut(omar$wage,breaks=mseq,include.lowest=TRUE,right=FALSE,
                  ordered_result=TRUE)
  omar$hagec<-cut(omar$hage,breaks=mseq,include.lowest=TRUE,right=FALSE,
                  ordered_result=TRUE)
  
  ## same with age at death (needed for atrisk set)
  opop$agedc<-cut(opop$aged,breaks=mseq,include.lowest=TRUE,right=FALSE,
                  ordered_result=TRUE)
  
  ## For the numerator we need counts of events by age category
  mar.numer<-with(omar,
                  cbind(
                        tapply(mid,list(hagec),length),    ## male
                        tapply(mid,list(wagec),length)     ## female
                        )
                  )
  
  
  ## atrisk set -- for the denominator we need person years lived at
  ## risk how much remarriage is going on?  -- we're just doing marriage
  ## rates of single people aka first marriage rates but it's good to
  ## know what's going on
 # table(table(omar$wpid))
 # table(table(omar$hpid))
  ## age cat of wife at first marriage tacked onto opop
  opop$wagec1<-omar[match(opop$pid,omar$wpid),"wagec"]
  ## second marriage
  ##opop$wagec2<-omar[match(opop$pid,omar$wpid[duplicated(omar$wpid)]),"wagec"]
  
  opop$hagec1<-omar[match(opop$pid,omar$hpid),"hagec"]
  opop$hagec2<-omar[match(opop$pid,omar$hpid[duplicated(omar$hpid)]),"hagec"]
  sum(!is.na(opop$hagec2))
  sum(table(table(omar$hpid))[-1])

  ## if NA then age at death -- or end of sim marks the end of atrisk period
  opop$wagec1[is.na(opop$wagec1)]<-opop$agedc[is.na(opop$wagec1)]
  opop$hagec1[is.na(opop$hagec1)]<-opop$agedc[is.na(opop$hagec1)]
  
  mar.denom<-NULL
  for(age in levels(opop$agedc)){
    mar.denom<-rbind(mar.denom,
                     c(
                       sum(opop$fem==0 & opop$agedc >= age & opop$hagec1>=age),
                       sum(opop$fem==1 & opop$agedc >= age & opop$wagec1>=age))
                     )
    
#    print(age)
  }
  ## translate to monthly probs of death
  asmarr<- 1-(1-(mar.numer/mar.denom))^(1/diff(mseq))
  colnames(asmarr)<-c("M","F")
  return(asmarr )
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
  
}
