print ("Testing is starting...")
firstIndex <-1
lastIndex <-100

##*************************************************************************************************************##
# print("Testing improvements in the number of executed tests:")

testNum_NoFilter <- read.table("NoFilter//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
testNum_F1 <- read.table("F1//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
testNum_F2 <- read.table("F2//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
testNum_F3 <- read.table("F3//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
# testNum_F4 <- read.table("F4//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

wilcox.test(testNum_NoFilter,testNum_F1, alternative="greater")  # Alternative: first data is significantly greater than the second
wilcox.test(testNum_NoFilter,testNum_F2, alternative="greater")
wilcox.test(testNum_NoFilter,testNum_F3, alternative="greater")

wilcox.test(testNum_F1, testNum_NoFilter, alternative="greater")
wilcox.test(testNum_F2, testNum_NoFilter, alternative="greater")
wilcox.test(testNum_F3, testNum_NoFilter, alternative="greater")

##*************************************************************************************************************##
##*************************************************************************************************************##

FaultDetection_NoFilter <- read.table("NoFilter//Raw//Fault Detection Steps.txt", sep = "" , header = F )[(firstIndex:lastIndex),1]
FaultDetection_F1 <- read.table("F1//Raw//Fault Detection Steps.txt", sep = "" , header = F )[(firstIndex:lastIndex),1]
FaultDetection_F2 <- read.table("F2//Raw//Fault Detection Steps.txt", sep = "" , header = F )[(firstIndex:lastIndex),1]
FaultDetection_F3 <- read.table("F3//Raw//Fault Detection Steps.txt", sep = "" , header = F )[(firstIndex:lastIndex),1]

# wilcox.test(FaultDetection_NoFilter,FaultDetection_F1, alternative="greater") # means alternative hypothesis is that the first is greater than the second
# wilcox.test(FaultDetection_NoFilter,FaultDetection_F2, alternative="greater")
# wilcox.test(FaultDetection_NoFilter,FaultDetection_F3, alternative="greater")

# wilcox.test(FaultDetection_F1, FaultDetection_NoFilter, alternative="greater")
# wilcox.test(FaultDetection_F2, FaultDetection_NoFilter, alternative="greater")
# wilcox.test(FaultDetection_F3, FaultDetection_NoFilter, alternative="greater")

##*************************************************************************************************************##
# print("Testing improvements in the number failed shrink steps:")

FailedShrinkSteps_NoFilter <- read.table("NoFilter//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
FailedShrinkSteps_F1 <- read.table("F1//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
FailedShrinkSteps_F2 <- read.table("F2//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
FailedShrinkSteps_F3 <- read.table("F3//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

# wilcox.test(FailedShrinkSteps_NoFilter,FailedShrinkSteps_F1, alternative="greater") # means alternative hypothesis is that the first is greater than the second
# wilcox.test(FailedShrinkSteps_NoFilter,FailedShrinkSteps_F2, alternative="greater")
# wilcox.test(FailedShrinkSteps_NoFilter,FailedShrinkSteps_F3, alternative="greater")

# wilcox.test(FailedShrinkSteps_F1, FailedShrinkSteps_NoFilter, alternative="greater")
# wilcox.test(FailedShrinkSteps_F2, FailedShrinkSteps_NoFilter, alternative="greater")
# wilcox.test(FailedShrinkSteps_F3, FailedShrinkSteps_NoFilter, alternative="greater")

##*************************************************************************************************************##
# print("Testing improvements in the number of shrink steps:")

ShrinkSteps_NoFilter <- read.table("NoFilter//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
ShrinkSteps_F1 <- read.table("F1//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
ShrinkSteps_F2 <- read.table("F2//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
ShrinkSteps_F3 <- read.table("F3//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

# wilcox.test(ShrinkSteps_NoFilter,ShrinkSteps_F1, alternative="greater")
# wilcox.test(ShrinkSteps_NoFilter,ShrinkSteps_F2, alternative="greater")
# wilcox.test(ShrinkSteps_NoFilter,ShrinkSteps_F3, alternative="greater")

# t.test(ShrinkSteps_F1,ShrinkSteps_NoFilter, alternative="greater")
# t.test(ShrinkSteps_F2,ShrinkSteps_NoFilter, alternative="greater")
# t.test(ShrinkSteps_F3,ShrinkSteps_NoFilter, alternative="greater")

