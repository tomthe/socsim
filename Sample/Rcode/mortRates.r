mortRates<-function(soc,mseq=c(0,1,12,seq(5,100,by=5)*12)){
## expects a list object containing $opop element and mseq which gives
## the break points of the age intervals in the ratefile.

  opop<-soc$opop
  ## This assumes that mortality rates do not vary by group or marital
  ## status. 
  
  opop$agedOC<- with(opop,
                     ifelse(dod==0,max(opop$dob),dod) - opop$dob)
  ## age at death 
  opop$aged<- with(opop,
                   ifelse(dod==0,NA,dod) - opop$dob)
  
                                        #mseq<-c(0,1,12,seq(5,100,by=5)*12)
  ## age category at death  as ordered factor
  opop$agedc<-cut(opop$aged,breaks=mseq, include.lowest=TRUE,right=FALSE,
                  ordered_result=TRUE)
  
  ## event counts by age category
  mort.numer<-with(opop[!is.na(opop$mom),],
                   tapply(pid,list(agedc,fem),length)
                   )
  
  
  ## atrisk
  ## age at death OR censoring as ordered factor
  opop$agedOCc<-cut(opop$agedOC,breaks=mseq, include.lowest=TRUE,right=FALSE,
                    ordered_result=TRUE)
  
  deathOrCensor<-with(opop,
                      tapply(pid,list(agedOCc,fem),length))
  
  mort.denom<-apply(deathOrCensor,2,function(x){rev(cumsum(rev(x)))})
  ## translate to monthly probs of death
  ##
  ## deaths/atrisk  =    1-((1-p)^t)
  ## p = ages specific monthly probability of death      
  
  asMr<- 1-(1-(mort.numer/mort.denom))^(1/diff(mseq))
  colnames(asMr)<-c("M","F")
  return(asMr)  ## should look like mort rates IFF no difference by group or marital stat
}
