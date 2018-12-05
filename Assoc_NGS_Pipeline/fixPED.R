args = commandArgs(trailingOnly=TRUE)


p1=read.table(args[1])
p2=read.table(args[2])
m=merge(p1,p2,by="V1",all.x=T)
m[is.na(m$V2.y),7]=-9
m$V6 <- NULL
outPath=paste(tools::file_path_sans_ext(args[2]),".adjusted.ped",sep="")
write.table(m,outPath,row.names=F,col.names=F,quote=F,sep="\t")

