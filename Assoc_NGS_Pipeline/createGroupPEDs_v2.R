args = commandArgs(trailingOnly=TRUE)

analysis=args[1]
data=read.table(args[2],sep=";",head=T,fill=TRUE,stringsAsFactors=F)
comparisons=args[c(-1,-2)]

for (test in comparisons){
	print(test)
	unaffected=unlist(strsplit(test,"vs"))[1]
	affected=unlist(strsplit(test,"vs"))[2]

	unaffected_groups=as.numeric(unlist(strsplit(unaffected,"G"))[-1])
	unaffected_data=unlist(data[unaffected_groups])
	unaffected_data=as.data.frame(unaffected_data[unaffected_data!=""])
	unaffected_data$Group=1
	names(unaffected_data)[1]="V1"

	affected_groups=as.numeric(unlist(strsplit(affected,"G"))[-1])
	affected_data=unlist(data[affected_groups])
	affected_data=as.data.frame(affected_data[affected_data!=""])
	affected_data$Group=2
	names(affected_data)[1]="V1"

	final=rbind(unaffected_data,affected_data)
	#final$V1=paste("NG-9974_",final[[1]],sep="")

	outfile=paste("/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/Association_Analysis/",analysis,"/",test,"/",test,".ped",sep="")
	dir.create(file.path(paste("/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/Association_Analysis/",analysis,sep=""), test), showWarnings = FALSE)
	write.table(final,outfile,sep="\t",row.names=F,col.names=F,quote=F)
}
