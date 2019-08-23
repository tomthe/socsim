
fertRates<-function(soc,fseq=c(0,(14:45),100)*12){
  ## Expects list object with $opop and fseq containing age break points
  ## from ratefile. Returns fertility rates undifferentiated by marital status
  
  opop<-soc$opop
  ## age at death or censor
  opop$agedOC<- with(opop,
                   ifelse(dod==0,max(opop$dob),dod) - opop$dob)
  ## age of mother at each person's birth
  opop$momage<- opop$dob-opop[z2na(opop$mom),"dob"]
  ## age categories in ratefile.min
  ##fseq<-c(0,(14:45),100)*12
  
  ## age of mother at birth in ordered factor 
  opop$momagec<-cut(opop$momage,breaks=fseq,include.lowest=TRUE,right=FALSE,
                    ordered_result=TRUE)
  ## event counts by age category
  fert.numer<-with(opop[!is.na(opop$momage),],
                   tapply(pid,momagec,length)
                   )
  ## atrisk
  
  opop$agedOCc<-cut(opop$agedOC,breaks=fseq,include.lowest=TRUE,right=FALSE,
                    ordered_result=TRUE)

  deathOrCensor<-with(opop,
                      tapply(pid,list(agedOCc,fem),length))
  fert.denom<-apply(deathOrCensor,2,function(x){rev(cumsum(rev(x)))})
  
  asfr<-fert.numer/fert.denom[,2]
  ## monthly rates should match those in ratefile.min
  return(cbind(asfr/diff(fseq)))
}
