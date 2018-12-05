args = commandArgs(trailingOnly=TRUE)
data=read.table(args[1],head=T)

filtered=data[1]

if("variants_effect_stop_lost" %in% names(data)){filtered=cbind(filtered,data["variants_effect_stop_lost"])}
if("variants_effect_stop_gained" %in% names(data)){filtered=cbind(filtered,data["variants_effect_stop_gained"])}
if("variants_effect_missense_variant" %in% names(data)){filtered=cbind(filtered,data["variants_effect_missense_variant"])}
out=as.data.frame(filtered[apply(filtered[-1],1,sum)>0,1])
names(out)="Cand"
outfile=paste(tools::file_path_sans_ext(args[1]),".Candidates.tsv",sep="")


eff=read.table("/home/ibis/hastreiter/Sporisorium_Reilianum_Virulence/Effektoren")

out$"Effector"= out[,1] %in% eff[,1]

write.table(out,outfile,col.names=T,row.names=F,sep="\t",quote=F)



#out=as.data.frame(data[data$variants_effect_stop_lost>0 | data$variants_effect_stop_gained>0 | data$variants_effect_missense_variant>0,1])


