data <- read.csv('/Users/teddy/GitHub/PsPM/doc/pspm_options_subfields.csv',header=TRUE)
Table <- matrix(0, 223, 3)
iCount <- 1
for (iRow in 1:length(data[,1])){
  for (iCol in 1:(length(data[1,])-1)){
    if (data[iRow, iCol+1] != '/'){
      Table[iCount,1] <- data[iRow,1]
      Table[iCount,2] <- colnames(data)[iCol+1]
      Table[iCount,3] <- data[iRow, iCol+1]
      iCount <- iCount+1
    }
  }
}
write.csv(Table ,'/Users/teddy/GitHub/PsPM/doc/pspm_options_subfields_simp.csv')