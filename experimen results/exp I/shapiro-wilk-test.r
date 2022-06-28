
print ("Testing normality is starting...")

#********************************************* Reading the inputs from file ***********************************************
firstIndex <-2
lastIndex <-100

discards_F1 <- read.table("F1//Raw//Discards.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
discards_F2 <- read.table("F2//Raw//Discards.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
discards_F3 <- read.table("F3//Raw//Discards.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

testNum_NoFilter <- read.table("NoFilter//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
testNum_F1 <- read.table("F1//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
testNum_F2 <- read.table("F2//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
testNum_F3 <- read.table("F3//Raw//TestsNum.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

FailedShrinkSteps_NoFilter <- read.table("NoFilter//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
FailedShrinkSteps_F1 <- read.table("F1//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
FailedShrinkSteps_F2 <- read.table("F2//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
FailedShrinkSteps_F3 <- read.table("F3//Raw//FailedShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]

ShrinkSteps_NoFilter <- read.table("NoFilter//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
ShrinkSteps_F1 <- read.table("F1//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
ShrinkSteps_F2 <- read.table("F2//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
ShrinkSteps_F3 <- read.table("F3//Raw//ShrinkSteps.txt", sep = "" , header = F )[(firstIndex:lastIndex),2]
#****************************************************************************************************************************

#************************************************* Testing the normality of the data ****************************************
shapiro.test(discards_F1)
shapiro.test(discards_F2)
shapiro.test(discards_F3)

shapiro.test(testNum_NoFilter)
shapiro.test(testNum_F1)
shapiro.test(testNum_F2)
shapiro.test(testNum_F3)

shapiro.test(ShrinkSteps_NoFilter)
shapiro.test(ShrinkSteps_F1)
shapiro.test(ShrinkSteps_F2)
shapiro.test(ShrinkSteps_F3)

shapiro.test(FailedShrinkSteps_NoFilter)
shapiro.test(FailedShrinkSteps_F1)
shapiro.test(FailedShrinkSteps_F2)
shapiro.test(FailedShrinkSteps_F3)
#****************************************************************************************************************************

print ("Testing normality is done.")