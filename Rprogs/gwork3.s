
#  gwork3.s       COMBINED SCRIPTS FOR ITERATING SOCSIM
#       Kenneth W. Wachter and Gene Hammel 29 March 2002 
#
#  enter.s     Input .opop, .omar, and .opox files for Population
#      Kenneth W. Wachter,   last revised 2 February 1998
#      Coding  death dates for the living as 3333; also edate. 
# 
    header _ paste("K.W.Wachter", date(), sep="") 

#             Settings for the beginning and ending dates
 zerodate  _ 1800.00 
 startdate _ 1900.00
 enddate   _ 2400.00
#      Be sure that zerodate is date in years matching month 0 
#          and enddate is date in years at which simulation ends. 
# print( c(zerodate, enddate) ) 
 
 
######################################################################### 
#####    Read in Socsim Population List and Create Variables  
########################################################################## 
 
# Format of .opop files 
#  1=id; 2=sex; 3=group; 4=nextevent;  5=dob;  6=momid; 7=dadid  
#        8=elder sibling through mom;  9 = esibdad;  10 = last born child 
#        11= last marriage;  12 = marital status; 13 = deathdate ; 14=fmult 
 
# Format of .omar files 
#   1=marid; 2=wife; 3=husband; 4=datestart;  5=dateend;  6=reasonend 
#        7=wifeprior;  8=husbandprior 
 
# Format of .opox files 
#   1=id;  2= group at death 3=date of migration 

 scanpop _ list( id=1, sex=2, grp=3, dnv=4, birth=5 ) 
 scanpop _ c(scanpop, list( momid=6, dadid=7, esibm=8, esibd=9, lborn=10)  ) 
 scanpop _ c(scanpop, list( mar=11, mstat=12,  death=13, fmult=14)  )    
 
 scanmar _ list( marid=1, wife=2, husband=3, sdate=4, edate=5 )
 scanmar _ c(scanmar, list( marend=6,  wifeprior=7, husbandprior=8 ) )
 scanx   _ list( id=1,  bgrp=2, migdate = 3, wt= 4, tmult=5 ) 
 
 P _    scan( "new.opop",  what=scanpop, flush=TRUE ) 
 X _    scan( "new.opox",  what=scanx,   flush=TRUE ) 
## M _  scan( "new.omar",  what=scanmar, flush=TRUE ) 

#      The opop file must be sorted. 
#           The omar file is already written in sorted order. 
 h _ order(P$id) 
 
#    Empty field points to element adjoined to end of vector rather 
#             than to zero.  
 topend  _  1 + length(P$id) 
## topmar  _  1 + length(M$marid) 

#              Variables from .opop file   
 perid   _  c(P$id[h],    topend ) 
 female  _  c(P$sex[h],    0 ) 
 group   _  c(P$grp[h],    0 ) 
 bdate   _  c(P$birth[h],  0 )   
 momid   _  c(P$mom[h],  topend )
 dadid   _  c(P$dad[h],  topend )
 ddate   _  c(P$death[h],  0 )  
## mstat   _  c(P$mstat[h],   0 ) 
## esibm   _  c(P$esibm[h], topend )
## esibd   _  c(P$esibd[h], topend )
## lborn   _  c(P$lborn[h], topend )
## lastmar _  c(P$mar[h],   topmar ) 
## fmult   _  c(P$fmult[h],  0     )

#              Variables from .omar file  
# marid   _  c(M$marid,    topmar ) 
# wifid   _  c(M$wife,     topend ) 
# husid   _  c(M$husband,  topend ) 
# sdate   _  c(M$sdate,       0   ) 
# edate   _  c(M$edate,       0    ) 
# marend  _  c(M$marend,       0    ) 
# wprior  _  c(M$wifeprior,topmar ) 
# hprior  _  c(M$husbandprior,topmar ) 

#              Variables from .opox file  
 bgroup  _  c(X$bgrp[h],    0  )  #  Group at birth 
 migdate _  c(X$migdate[h], 0  )  #  Transition date 
 wt      _  c(X$wt[h],      0  )  #  Survey weight  
 tmult   _  c(X$tmult[h],   0  )  #  Transit multiplier  

## errorflg_  range(  -X$id - P$id) 
 
 rm(P, h, X ) 
## rm(M)  

 momid   _  ifelse(  momid == 0, topend, momid )
 dadid   _  ifelse ( dadid == 0,  topend, dadid )
## esibm   _  ifelse ( esibm == 0,  topend, esibm )
## esibd   _  ifelse ( esibd == 0,  topend, esibd )
 bdate   _  ifelse( bdate == 0,  zerodate,  zerodate + round( bdate/12, 2)  )  
 ddate   _  ifelse( ddate == 0,  3333,  zerodate + round( ddate/12, 2)  )  
## age     _  ifelse( ddate == 3333,  enddate,  ddate) - bdate    #  in years   
## lastmar _  ifelse( lastmar== 0, topmar,  lastmar ) 
## alive   _  ifelse( ddate == 3333,  1,  0)    # still living at end of run 
## migdate _  ifelse( migdate == 0, 3333, zerodate + round( migdate/12, 2) )  
   
## wifid   _  ifelse( wifid== 0,   topend,  wifid ) 
## husid   _  ifelse( husid== 0,   topend,  husid ) 
 
## sdate   _  ifelse( sdate== 0,   3333,  zerodate + round(sdate/12,2 )  ) 
## edate   _  ifelse( edate== 0,   3333,  zerodate + round(edate/12,2 )  ) 
## wprior  _  ifelse( wprior== 0,  topmar,  wprior ) 
## hprior  _  ifelse( hprior== 0,  topmar,  hprior ) 
 
#     Create the person-pointer to current spouse. 
#     A never-married person's spouse is topend; the "marriage" is topmar. 
## spouse  _  female*husid[lastmar] + (1-female)*wifid[lastmar]  
 
#####################################################################
######      Age Pyramid 
#####################################################################
 
     system("touch jage")  # Make sure file jage exists for writing 
     
     L  _  perid[ ddate > enddate & bdate > startdate]        #  living
     D  _  perid[ bdate < enddate - 100 & bdate > startdate]  #  dead in cohorts

     agex    _  5*c(0:20)              # starting ages of age groups, 0, 5, etc.   
     agexx   _  c(0,1, agex[-1] )      # 0,1,5,10, etc.  
     agecat  _  cut( enddate -bdate, breaks = c(agex,999), labels= paste(agex))
     z    _       table( agecat[L], female[L] )  #  Two columns for age pyramid 

     deathcat _  cut( ddate - bdate, breaks = c(agexx, 999), labels= paste(agexx) )
     zz  _       table( deathcat[D], female[D] )  # Two columns for death distrib.
     
     write( as.vector(z), file = "jage" , 42, append = TRUE) 

#            To plot age pyramid  
    plot(  c(-rev(z[,1]),  z[,2],0), c(rev(agex),  agex,0 ),  type ="l",
                 ylab = "Age",  xlab = "", main = "Age Pyramid at End"  )
    title( sub = header) 

    dage   _  ddate[D] - bdate[D]            #  age at death   
    print (  mean( dage[female[D] == 1] ))    #  female average age at death 
    print (  mean( dage[female[D] == 0] ))    #    male average age at death 

#            To plot distribution of ages at death 
    barplot(  zz[,2], main = "Female Ages at Death (Split 0-1;1-5) " )
    barplot(  zz[,1], main = "Male Ages at Death (Split 0-1;1-5) " )

#                 Parity Distribution
#                     (Note,  R is slow with tables, so we work round them.)
      pvec   _  sort( c(momid, perid)) 
      dvec   _  c( diff(pvec), 1 ) 
      u      _  seq(dvec)[dvec == 1 ] 
      parity _  c( u[1], diff(u) ) - 1 
      parity[topend] _ 0
      zp     _ table( parity[female == 1 ])
      barplot(zp) 

#                 Define group of egos 
      K      _  perid[ enddate - bdate > 19 & enddate - bdate < 61 & female == 0 ]
      K      _  K[ddate[K]>enddate]
      K      _  K[dadid[K] < topend]   # restrict to boys who have a father
      K      _  K[dadid[dadid[K]] < topend]   # restrict to boys who have a father

#                 Number of in-group sons for all population members       
      pvec   _  sort( c(dadid[K], perid )) 
      dvec   _  c( diff(pvec), 1 ) 
      u      _  seq(dvec)[dvec == 1 ]   
      sons   _  c( u[1], diff(u) ) - 1 
      sons[topend] _ 0
      b      _  sons[dadid[K]] - 1  

#                 Father's brothers' sons 
      pvec     _  sort( c( dadid[dadid[K]], perid) ) 
      dvec     _  c( diff(pvec), 1 ) 
      u        _  seq(dvec)[dvec == 1 ]  
      sonssons _  c( u[1], diff(u) ) - 1
      sonssons[topend] _ 0
      fbs    _  sonssons[dadid[dadid[K]]] - sons[dadid[K]] 

#     rm(pvec, dvec, u )





     system("touch proceed" )

