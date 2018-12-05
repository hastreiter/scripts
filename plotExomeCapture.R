#!/bin/Rscript
args <- commandArgs(TRUE)

infile = args[1]
pdf("capture_efficiency.pdf")
data = read.table(infile,sep="\t",head=T)
colors = (ncol(data))-1
plot(data[c(1:100),1],data[c(1:100),2],type="l",col=rainbow(colors)[1],xlab="Coverage",ylab="% of target region covered",main="Capture Efficiency",ylim=c(0,100))
for(i in 2:ncol(data)){
	lines(data[c(1:100),1],data[c(1:100),i],col=rainbow(colors)[i])
}

dev.off()
