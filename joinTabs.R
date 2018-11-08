# setwd('/home/arina/Kenji_proj/Kinase/test')

lig1=read.delim('ligands.tab', sep='\t', header = TRUE )
lig2=read.delim('lig_solv.tab', sep='\t', header = TRUE )

comp1=read.delim('compl.tab', sep='\t', header = TRUE )
comp2=read.delim('smina.scores.tab', sep='\t', header = TRUE )
comp3=read.delim('xscores.tab', sep='\t', header = TRUE )
comp4=read.delim('inter.report.tab', sep='\t', header = TRUE )

tarSim=read.delim('tarSim_allPairs.tab', sep='\t', header = TRUE )
prTar=read.delim('priority_targets.list', sep='\t', header = FALSE )

names(lig1)[2] = "Comp"
lig1=lig1[,-c(1)]
m1=merge(lig1, lig2, by='Comp')

names(prTar)=c('Comp','prTar','act')
prTar=prTar[,-c(3)]
ligSum=merge(m1, prTar, by='Comp')

m2=merge(comp1,comp2,by='Compl')
m3=merge(m2,comp3,by='Compl')
m4=merge(m3,comp4,by='Compl')

library(tidyr)

m4$Compl2=m4$Compl
m4=separate(data = m4, col = Compl2, into = c("Tar", "Comp"), sep = "_")
m5=merge(m4,ligSum,by='Comp')

tarSim=tarSim[,-c(1,2)]
m5$tarPair=paste(m5$Tar, m5$prTar, sep=":")
complSum=merge(m5, tarSim, by='tarPair')

write.table(complSum, file="test_compl_descr.tab", sep='\t', col.names = TRUE, row.names = FALSE, quote = FALSE)
