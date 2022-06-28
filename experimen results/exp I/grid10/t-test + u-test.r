print ("Testing is starting...")
firstIndex <-2
lastIndex <-101

##*************************************************************************************************************##
# print("Testing improvements in the number of executed tests:")

# testNum_NoFilter <- read.table("NoFilter//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
# testNum_F1 <- read.table("F1//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
# testNum_F2 <- read.table("F2//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
# testNum_F3 <- read.table("F3//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

# wilcox.test(testNum_NoFilter,testNum_F1, alternative="greater")
# wilcox.test(testNum_NoFilter,testNum_F2, alternative="greater")
# wilcox.test(testNum_NoFilter,testNum_F3, alternative="greater")

# wilcox.test(testNum_F1,testNum_F2, alternative="greater")
# wilcox.test(testNum_F1,testNum_F3, alternative="greater")
# wilcox.test(testNum_F2,testNum_F3, alternative="greater")

##*************************************************************************************************************##
# print("Testing improvements in the number of discarded inputs:")

# discards_F1 <- read.table("F1//Raw//Discards.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
# discards_F2 <- read.table("F2//Raw//Discards.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
# discards_F3 <- read.table("F3//Raw//Discards.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

# wilcox.test(discards_F1,discards_F2, alternative="greater")
# wilcox.test(discards_F1,discards_F3, alternative="greater")
# wilcox.test(discards_F2,discards_F3, alternative="greater")

##*************************************************************************************************************##
print("Testing improvements in the number failed shrink steps:")

FailedShrinkSteps_NoFilter <- read.table("NoFilter//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
FailedShrinkSteps_F1 <- read.table("F1//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
FailedShrinkSteps_F2 <- read.table("F2//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
FailedShrinkSteps_F3 <- read.table("F3//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

wilcox.test(FailedShrinkSteps_NoFilter,FailedShrinkSteps_F1, alternative="greater")
wilcox.test(FailedShrinkSteps_NoFilter,FailedShrinkSteps_F2, alternative="greater")
wilcox.test(FailedShrinkSteps_NoFilter,FailedShrinkSteps_F3, alternative="greater")

wilcox.test(FailedShrinkSteps_F1,FailedShrinkSteps_F2, alternative="greater")
wilcox.test(FailedShrinkSteps_F1,FailedShrinkSteps_F3, alternative="greater")
wilcox.test(FailedShrinkSteps_F2,FailedShrinkSteps_F3, alternative="greater")

##*************************************************************************************************************##
# print("Testing improvements in the number of shrink steps:")

# ShrinkSteps_NoFilter <- read.table("NoFilter//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
# ShrinkSteps_F1 <- read.table("F1//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
# ShrinkSteps_F2 <- read.table("F2//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
# ShrinkSteps_F3 <- read.table("F3//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

# t.test(ShrinkSteps_NoFilter,ShrinkSteps_F1, alternative="greater")
# t.test(ShrinkSteps_NoFilter,ShrinkSteps_F2, alternative="greater")
# t.test(ShrinkSteps_NoFilter,ShrinkSteps_F3, alternative="greater")

# t.test(ShrinkSteps_F1, ShrinkSteps_F2, alternative="greater")
# t.test(ShrinkSteps_F1, ShrinkSteps_F3, alternative="greater")
# t.test(ShrinkSteps_F2, ShrinkSteps_F3, alternative="greater")

##*************************************************************************************************************##