z2na<-function(x){x[x==0]<-NA;return(x)}

ReadSocOut<-function(stem){
  ## stem is path to directory + what comes before .opop
  ## Will read .opop and .omar .opox ,otx and assign useful names



  print(paste("Looking in ",stem))
  print("reading opop...")
  
  opop<-try(read.table(file=paste(stem,".opop",sep='')),silent=TRUE)
  if(class(opop) == "try-error"){
    warning( paste( paste(stem,".opop",sep=''), "is empty or NOT FOUND",sep=' '))
    warning("Nothing good can happen without an opop file... exiting")
    return()
  }else{
    names(opop)<-c("pid","fem","group",
                   "nev","dob","mom","pop","nesibm","nesibp",
                   "lborn","marid","mstat","dod","fmult")
    rownames(opop)<-opop$pid
    print(paste("read ",nrow(opop), " records into opop"))
  }
####### opox
  print("reading opox")
    opox<-try(read.table(file=paste(stem,".opox",sep=''),sep=""),silent=TRUE)
  if(class(opox)=="try-error"){
    print("opox empty or missing skipped")
  }else{
    rownames(opox)<-opop$pid
  }
  
  ##### omar
  print("reading omar")
  omar<-try(read.table(file=paste(stem,".omar",sep=''),sep=""),
            silent=TRUE)
  
  if(class(omar)=="try-error"){
    print("skipping empty .omar file")
  }else{
    names(omar)<-c("mid","wpid","hpid","dstart","dend",
                   "rend","wprior","hprior")
    rownames(omar)<-omar$mid
  }
  
  

##### Transition history



    print("reading otx (transition history")
    otx<-try(read.table(file=paste(stem,".otx",sep=''),sep=""),
             silent=TRUE)
  if(class(otx)=="try-error"){
    print("skipping empty .otx  (transition history) file")
  }else{
    names(otx)<-c("pid","dot","fromg","tog","pos")
    
    rownames(otx)<-paste(otx$pid,otx$pos,sep='')
  }


  return(foo<-list(opop=opop,
              omar=omar,
              opox=opox,
                   otx=otx
                   ))
}

