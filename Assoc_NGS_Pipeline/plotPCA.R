args = commandArgs(trailingOnly=TRUE)

eigenvec=read.table(args[1])
pheno=read.table(args[2])
data=merge(eigenvec,pheno,by="V1")
m2=data[data$V6.y>0,]

png(file=paste(tools::file_path_sans_ext(args[1]),".png",sep=""),width=1200,height=700)
plot(m2[3:4],col=m2$V6.y,xlab="PC1",ylab="PC2",main=paste(args[3],"Affected",sep="|"))
legend("top",c("Healthy",unlist(strsplit(args[3],"VS"))[[1]]),col=c("black","red"),pch=19)
dev.off()
