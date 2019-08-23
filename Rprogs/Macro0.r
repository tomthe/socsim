########################################################################
## Tue Dec  3 11:46:13 PST 2002
## Based on (i.e. stolen from) Kenneth Wachter's collection of S programs
## for parsing and crunching socsim output. This contains a set of functions
## that we hope will be useful in general
##
## enter() : will read opop,omar and opox and create a useful data frame
########################################################################


enter<- function(zerodate = 1800.00,startdate =1900.00,
                 enddate=2400.00,filestem="new"){

  ## zerodate - date in years matching month 0 of simulation
  ## startdate -date in years of first month of simulation
  ## enddate -  date in years of last month of simulation
  ## filestemp - full path to which .opop/.opox/.omar can be appended
  ## in order to find the input files

  filestem<-"../adir.tests/adir.uslater/exogamy"
  P <- read.table(file=paste(filestem,".opop",sep=""),header=F,sep="",
                    col.names=
                    c("id","sex","grp","dnv","birth","momid",
                      "dadid","esibm","esibd","lborn",
                      "mar","mstat","death","fmult"))
  X <- read.table(file=paste(filestem,".opox",sep=""),header=F,sep="")

  ## we'll need to sort the opop files before crunching ids.

  P<-P[order(P$id),]
  X<-X[order(P$id),]

  ## let's create a ficticious NULL person for all the zero pointers
  ## to point to
  topend <-max(P$id)+1
#  P<-rbind(P,c(topend,0,0,0,0,topend,topend,topend,topend,topend,topend,
#               0,0,0))
  P<-rbind(P,rep(0,dim(P)[2]))
  X<-rbind(X,rep(0,dim(X)[2]))
  P$momid[P$momid ==0]<-topend
  P$dadid[P$dadid ==0]<-topend
  P$esibm[P$esibm ==0]<-topend
  P$esibd[P$esibd ==0]<-topend
  P$lborn[P$lborn ==0]<-topend
  P$id[P$id ==0]<-topend
  P$mar[P$mar ==0]<-topend

  ## some additional useful variables

  P$bdate <-ifelse(P$bdate==0,zerodate,zerodate+ round( bdate/12, 2))
  P$ddate <-ifelse(P$ddate == 0,  NA,  zerodate + round( ddate/12, 2))  
  P$age  <- ifelse(is.na(P$ddate),enddate,P$ddate)  - P$bdate

  
