barcodes<-NULL
for(i in 1:500){
	seq=paste(sample(c("A","C","G","T"),6,rep=TRUE,prob=c(0.25,0.25,0.25,0.25)),collapse="")
	barcodes=c(barcodes,seq)
}

barcodes=unique(barcodes)
write.table(barcodes,"Barcodes.txt",col.names=F,row.names=F,quote=F)
