args <- commandArgs(trailingOnly = TRUE)


pdf(args[11])

par(mar=c(5,4,4,5)+.1)
par(lwd=2)
plot(args[1:5],type="l",ylab="TSTV",xlab="",col="red",xaxt="n")
par(new=TRUE)
plot(args[6:10],type="l",ylab="",xlab="",col="blue",xaxt="n",yaxt="n")
axis(4)
axis(1,c(1:5),labels=c("Original","GQ_DP","GQMEAN","HWE","CallRate"))
mtext("Number of Variants",side=4,line=3)
legend("top",col=c("red","blue"),lty=1,legend=c("TSTV Ratio","NVAR"))

dev.off()
