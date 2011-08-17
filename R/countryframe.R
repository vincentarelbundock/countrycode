`countryframe` <-function(TYPE,CODE,YEARS){
  codes<-countrycode_data[is.na(countrycode_data[,CODE])==FALSE,CODE]
  if (TYPE=="directed.dyads"){
	dyads<-data.frame(expand.grid(codes, codes))
	for (i in 1:2){dyads[,i]<-as.character(dyads[,i])}
	if (is.numeric(YEARS)==TRUE){
		dyads<-merge(YEARS, dyads)[,c(2,3,1)]
		code1<-paste(CODE, 1, sep=".")
		code2<-paste(CODE, 2, sep=".")
		names(dyads)<-c(code1, code2, "years")
	}
  }else if (TYPE=="undirected.dyads"){
	dyads<-data.frame(t(combn(codes, 2)))
	for (i in 1:2){dyads[,i]<-as.character(dyads[,i])}
	if (is.numeric(YEARS)==TRUE){
		dyads<-merge(YEARS, dyads)[,c(2,3,1)]
		code1<-paste(CODE, 1, sep=".")
		code2<-paste(CODE, 2, sep=".")
		names(dyads)<-c(code1, code2, "years")
	}
  }else if (TYPE=="country.years"){
	dyads<-merge(codes, YEARS)
	dyads[,1]<-as.character(dyads[,1])
	names(dyads)<-c(CODE, "years")
  }
return(dyads)
}

