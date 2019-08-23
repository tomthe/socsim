########################
## parity specific fertility rates

library(plyr)
ParYes=FALSE
if(FALSE){
    ## execute for speed boost if parallel proc available
    library(foreach)
    library(doParallel)
    registerDoParallel(cores=12)
    ParYes=TRUE
}

lifHist<-daply(.data=opop[opop$fem==1,],.variables="pid",
               .fun=function(p){
                                        #p<-opop["37481",]
                   ageAtbirths<-opop[opop$mom==p$pid,"momage"]
                   mstarts<-omar[omar$wpid==p$pid,"dstart"]-p$dob
                   mends<-omar[omar$wpid==p$pid,"dend"]
                   mends[mends==0]<-endmo
                   mends<-mends - p$dob
                   deathOC<-ifelse(p$dod ==0,endmo-p$dob,p$dod-p$dob)
      
                   if(length(ageAtbirths >0)){
                       res<-apply(outer(0:1199,sort(ageAtbirths),">="),1,sum)
                   }else{
                       res<-rep(0,1200)
                   }
                   if(length(mends)>0){
                       for(i in 1:length(mstarts)){
                           res[mstarts[i]:mends[i]]<-res[mstarts[i]:mends[i]]+.5
                       }
                   }
                   res[deathOC:1199]<-NA
                   return(res)
               },.parallel=TRUE)



denp0<-apply(lifHist>=0 & lifHist<=.5,2,sum,na.rm=TRUE)
denp1<-apply(lifHist>=1 & lifHist<=1.5,2,sum,na.rm=TRUE)
denp2<-apply(lifHist>=2 & lifHist<=2.5,2,sum,na.rm=TRUE)
denp3<-apply(lifHist>=3 & lifHist<=3.5,2,sum,na.rm=TRUE)
denp4<-apply(lifHist>=4 & lifHist<=4.5,2,sum,na.rm=TRUE)
denp5<-apply(lifHist>=5 & lifHist<=5.5,2,sum,na.rm=TRUE)

denp0m<-apply(lifHist==0.5,2,sum,na.rm=TRUE)
denp1m<-apply(lifHist==1.5,2,sum,na.rm=TRUE)
denp2m<-apply(lifHist==2.5,2,sum,na.rm=TRUE)
denp3m<-apply(lifHist==3.5,2,sum,na.rm=TRUE)
denp4m<-apply(lifHist==4.5,2,sum,na.rm=TRUE)
denp5m<-apply(lifHist==5.5,2,sum,na.rm=TRUE)

table(opop$momage)
maried<-function(wpid,date,Omar=omar){
    ## return T/F if wpid is married on date
    oms<-Omar[Omar$wpid==wpid,]
    i<-1
    while(i<= nrow(oms)){
        if(oms[i,"dstart"] <= date & oms[i,"dend"] == 0) {
            return(TRUE)
        }
        if(oms[i,"dstart"] <= date & oms[i ,"dend"] >= date){
            return(TRUE)
        }
        i<-i+1
    }
    return(FALSE)
    }


opop<-ddply(opop,.variables="mom",
      .fun=function(sibs){
          sibs$mompar<-rank(sibs$dob,ties.method='first')
          sibs$mommar<-
          return(sibs)
          },.parallel=TRUE)


                                        #omar[100,]
#maried(wpid=750, date=1765)


pspec.fertRates<-function(soc,fseq=c(0,(14:45),100)*12,startmo=NA,endmo=NA){
    ## Expects list object with $opop and fseq containing age break
    ## points from ratefile. Returns parity specific fertility rates
    ## differentiated by marital status
    if(FALSE){
        startmo<-2000
        endmo<-2002
        }
    maxAge<-60*12
    minAge<-10*12

    ## we make vectors of sequences of ages during which mothers are
    ## at each parity and married then combine with %in% to find
    ## denom and ultimately with table() to add them all up
    
    ## lets do everything in terms of age of mother in months
    ## so startmo and endmo will be used to drop ages
    omar<-soc$omar             
    opop<-soc$opop
    
    if(is.na(startmo)){startmo<-min(opop$dob)}
    if(is.na(endmo)){endmo<-max(c(opop$dod,opop$dob))}
    
    ## age at death or censor
    opop$agedOC<- with(opop,
                       ifelse(dod==0,max(opop$dob),dod) - opop$dob)
    ## age of mother at each person's birth
    opop$momage<- opop$dob-opop[z2na(opop$mom),"dob"]
    opop$startage<-max(0,startmo-opop$dob)
    
    ## a matrix of mother B month of age holding corresponding parity
    parityline<-daply(opop,.variables="mom",
                      .fun=function(x){
                          apply(outer(minAge:maxAge,sort(x$momage),">="),1,sum)
                      },.parallel=ParYes)
    ## delete mom==0
    colnames(parityline)<-minAge:maxAge
    parityline<-parityline[rownames(parityline) != "0",]
    ## get age limits based on startmo and endmo -- so we can not count
    ## moms ages at times not in period of interest
    ageLim.hi<-with(opop[rownames(parityline),],
                    ifelse(dob > endmo,0,
                    ifelse(dod > endmo,endmo-dob,
                    ifelse(dod < startmo,0,dod-dob))))
    ageLim.hi[ageLim.hi > maxAge]<-maxAge
                           
                        
    ageLim.lo<-with(opop[rownames(parityline),],
                    ifelse(dob < startmo & dod > startmo, startmo-dob,0))
    ageLim.lo[ageLim.lo>maxAge]<-maxAge
    names(ageLim.lo)<-names(ageLim.hi)<-rownames(parityline)
    ## adjust parity matrix so that out of bounds ages are NA
    plx<-apply(cbind(parityline,ageLim.lo),MAR=1,
               FUN=function(x){a<-x[length(x)]
                   x<-x[-length(x)]
                   x[0:(a-minAge)]<-NA
                   return(x)})
    parityline<-t(apply(cbind(t(plx),ageLim.hi),MAR=1,
                  FUN=function(x){a<-x[length(x)]
                      x<-x[-length(x)]
                      x[max(0,(a-minAge+1)):(maxAge-minAge+1)]<-NA
                      return(x)}))
    rm(plx)

    ##ageLim.lo[ageLim.lo !=0 & ageLim.hi !=0]
    ##ageLim.lo["2729"];ageLim.hi["2729"]
    ##parityline["2729",]

    ## list of births to each mom
    ## list of births to each mom
    ## tapply is much faster than daply but more complicated to use later
    ## moms<-with(opop,tapply(momage,mom,sort))
    ## list of start.. end (ages) of marriages to women
    mars<-dlply(.data=omar,.variables="wpid",
                .fun=function(p){
                    return(sort(c(ifelse(startmo < p$dstart,p$dstart,startmo),
                                  ifelse(endmo > p$dend,p$dend,endmo))))-p$dob})

    a2i<-function(a){
        a1<-a-minAge
        res<-ifelse(a < minAge,0,
                    ifelse( a > maxAge,maxAge-minAge, a1))
        return(res)
        }
        
        
foo<-    lapply(rownames(parityline),function(p){
        res<-parityline[p,]
        if(p %in% names(mars)){
            mdates<-mars[[p]]
            dts<-NULL
            for(i in seq(from=1,to=length(mdates),by=2)){
                dts<-c(dts,seq(mdates[i],mdates[i+2]))
            }
            res[a2i(dts)]<-res[a2i(dts)]+.5
            return(res)
        }
        else {
            return(res)
            }})
                
                

            r<-a2i(mars[[p]][1]):a2i(mars[[p]][1])
            res<-parityline[p,]
            res[r]<-res[r]+.5
            return(res)
        }else{
            return(parityline[p,])
            }
            
    ## maritial parity spec fert
    den0<-lapply(names(mars),FUN=function(w){
#    w<-'1161'    
        dob<-opop[w,'dob']
        ages.married<-{m<-matrix(mars[[w]],ncol=2,byrow=TRUE)
            unlist(
                mapply(function(x,y){return(seq(x,y))},m[,1],m[,2])
            )- dob
        }
        age.start<- ifelse(startmo>dob,startmo-dob,0)
        age.end<-opop[w,"agedOC"]

        lifecourse<-c(0,moms[[w]],age.end)                
        age.parity<-mapply(function(x,y){return(seq(x,y))},
                           lifecourse[-length(lifecourse)],
                           lifecourse[-1])



        
        denoms.mfert<-lapply(ages.parity,
                       function(ap){ap[ap %in% ages.married &
                                       ap >= age.start &
                                       ap <= age.end]})
        return(denoms)
    })
    
    res<-vector()
    poo<-table(unlist(lapply(den0, function(x){append(res,x[[1]])})))
    poo<-table(unlist(lapply(den0, function(x){append(res,x[[2]])})))
    poo<-table(unlist(lapply(den0, function(x){append(res,x[[3]])})))
