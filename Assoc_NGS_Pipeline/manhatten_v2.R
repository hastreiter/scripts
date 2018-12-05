library(qqman)

args = commandArgs(trailingOnly=TRUE)

d=read.table(args[1],head=T,stringsAsFactors=F)
names(d)[1]="CHR_Org"

strings=unique(d$CHR_Org)
numbers=1:length(strings)
names(numbers)=strings
d$CHR=numbers[d$CHR_Org]

d2=d[!is.na(d$P),]


pval=as.numeric(args[6])
cutoff=-log10(pval)

nvar=args[7]

ADJUST=args[8]


if(args[3]=="Assoc"){

	d2=d2[!is.na(d2$F_A),]
	d2=d2[!is.na(d2$F_U),]

	#

	#check direction of association
	bool=d2$F_A>d2$F_U		
	d2_healthy=d2[!bool,]
	d2_affected=d2[bool,]	


	if(ADJUST=="BH"){
		d2_healthy$P=p.adjust(d2_healthy$P,method="BH")
		d2_affected$P=p.adjust(d2_affected$P,method="BH")

		out1=d2_healthy[d2_healthy$P<pval,c(1,3)]
		out2=d2_affected[d2_affected$P<pval,c(1,3)]

		write.table(out1,"Targets.1.tmp",sep="\t",row.names=F,col.names=F,quote=F)
		write.table(out2,"Targets.2.tmp",sep="\t",row.names=F,col.names=F,quote=F)
	}



	png(file=paste(tools::file_path_sans_ext(args[1]),".Manhatten_",args[4],".png",sep=""),width=1200,height=700)
	manhattan(d2_healthy,chrlabs=paste(unique(d2_healthy$CHR_Org)),cex=0.6, cex.axis = 0.9,ylim=c(0,max(-log10(d2$P))+10),suggestiveline=FALSE,genomewideline=cutoff,main=paste(args[2],args[4],sep="|"))
	mtext(paste("#Variants: ",nvar,"\tPval-Cutoff (-log10(p)): ",round(-log10(pval),3),"\tP-Adjust: ",ADJUST))	
	dev.off()
	png(file=paste(tools::file_path_sans_ext(args[1]),".Manhatten_",args[5],".png",sep=""),width=1200,height=700)
	manhattan(d2_affected,chrlabs=paste(unique(d2_affected$CHR_Org)),cex=0.6, cex.axis = 0.9,ylim=c(0,max(-log10(d2$P))+10),suggestiveline=FALSE,genomewideline=cutoff,main=paste(args[2],args[5],sep="|"))
	mtext(paste("#Variants: ",nvar,"\tPval-Cutoff (-log10(p)): ",round(-log10(pval),3),"\tP-Adjust: ",ADJUST))
	dev.off()

}else{
	print("Outdated...Please check first")
	#d2$P=p.adjust(d2$P,method="BH")
	#d3=d2[d2$CHR>23,]
	#d4=d2[d2$CHR<24,]

	#png(file=paste(tools::file_path_sans_ext(args[1]),".ManhattenP2.png",sep=""),width=1200,height=700)
	#manhattan(d3,chrlabs=paste(unique(d3$CHR_Org)),cex=0.6, cex.axis = 0.9,ylim=c(0,max(-log10(d2$P))+10),suggestiveline=FALSE,genomewideline=cutoff,main=paste(args[2],sep=""))
	#dev.off()
	#png(file=paste(tools::file_path_sans_ext(args[1]),".ManhattenP1.png",sep=""),width=1200,height=700)
	#manhattan(d4,chrlabs=paste(unique(d4$CHR_Org)),cex=0.6, cex.axis = 0.9,ylim=c(0,max(-log10(d2$P))+10),suggestiveline=FALSE,genomewideline=cutoff,main=paste(args[2],sep=""))
	#dev.off()

}


