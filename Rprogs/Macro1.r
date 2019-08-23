########################################################################
## Tue Dec  3 11:46:13 PST 2002
## Based on (i.e. stolen from) Kenneth Wachter's collection of S programs
## for parsing and crunching socsim output. This contains a set of functions
## that we hope will be useful in general
##
## enter() : will read opop,omar and opox and create a useful data frame
########################################################################


enter<- function(zerodate = 1800.00,startdate =1900.00,
                 enddate=2400.00,filestem="new",add.topend=F){

  ## zerodate - date in years matching month 0 of simulation
  ## startdate -date in years of first month of simulation
  ## enddate -  date in years of last month of simulation
  ## filestemp - full path to which .opop/.opox/.omar can be appended
  ## in order to find the input files

  filestem<-"../adir.tests/adir.exog-grp-inherit/exogout"
  filestem<-"../adir.tests/adir.exog-grp-inherit/grp-inhert-out"
  P <- read.table(file=paste(filestem,".opop",sep=""),header=F,sep="",
                    col.names=
                    c("id","sex","grp","dnv","birth","momid",
                      "dadid","esibm","esibd","lborn",
                      "mar","mstat","death","fmult"))

  M <- read.table(file=paste(filestem,".omar",sep=""),header=F,sep="",
                  col.names=c("marid","wife","husb","sdate","edate",
                    "marend","wifeprior","husbprior"))
  
  X <- read.table(file=paste(filestem,".opox",sep=""),header=F,sep="")

  ## we'll need to sort the opop files before crunching ids.

  P<-P[order(P$id),]
  X<-X[order(P$id),]
  M<-M[order(M$marid),]
  
  ## make all zero personid's into NAs

  if(add.topend){
    P<-rbind(P,rep(0,dim(P)[2]))
    M<-rbind(M,rep(0,dim(M)[2]))

  }
  topend<-dim(P)[1]
  topmar<-dim(M)[1]
  
  P$momid[P$momid ==0]<-NA
  P$dadid[P$dadid ==0]<-NA
  P$esibm[P$esibm ==0]<-NA
  P$esibd[P$esibd ==0]<-NA
  P$lborn[P$lborn ==0]<-NA
  P$id[P$id ==0]<-NA
  P$mar[P$mar ==0]<-NA

  M$marid[M$marid==0]<-NA
  M$wife[M$wife==0]<-NA
  M$husb[M$husb==0]<-NA
  if(add.topend){
    M$wifeprior[M$wifeprior==0]<-topend
    M$husbprior[M$husbprior==0]<-topend
  }
  
  if(add.topend){
    ### set all NA's to topend
    for (col in 1:dim(P)[2]){
      P[is.na(P[,col]),col]<-topend
    }
    for (col in 1:dim(M)[2]){
      M[is.na(M[,col]),col]<-topmar
    }
  }


  ## some additional useful variables

  P$bdate <-ifelse(P$bdate==0,zerodate,zerodate+ round( bdate/12, 2))
  P$ddate <-ifelse(P$ddate == 0,  NA,  zerodate + round( ddate/12, 2))  
  P$age  <- ifelse(is.na(P$ddate),enddate,P$ddate)  - P$bdate

  table(P$grp[M$husb],  P$grp[M$wife])

  table(P$grp[P$momid],P$grp)
  table(P$grp[P$dadid],P$grp)
  
