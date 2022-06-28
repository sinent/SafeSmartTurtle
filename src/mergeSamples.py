import os
import fileHelper

# merging different repeats of the expeirments

def getTestData(fileAddress):
    # onlyfiles10 = [f for f in os.listdir(folder10Samples) if os.path.isfile(os.path.join(folder10Samples, f))]
    # onlyfiles20 = [f for f in os.listdir(folder20Samples) if os.path.isfile(os.path.join(folder20Samples, f))]

    # if(set(onlyfiles10) != set(onlyfiles20)):
    #     print( "there is a mistake?!")
    #     for f in onlyfiles10:
    #         if f not in onlyfiles20:
    #             print
    # else:
    #     print("OK!")

    # print (len(onlyfiles))
    # for fileName in onlyfiles10:
    savedTimes = []

    # info =  fileName.split('-')
    # gridSize  = int(info[1])
    # agentsNum = int(info[3])
    # waitSteps = int(info[5])
    # dispSteps = int(info[7])
    # inputsNum = int(info[9])
    # repeats   = int(info[11])  
    # timeout   = int(info[13]) 

    f = open(fileAddress, "r")
    fileLine = f.readline() # skipping the first line: 'All times''
    fileLine = f.readline()
    while "Test Set" in fileLine:
        time = int(fileLine.split(':')[1].strip())
        savedTimes.append(time)
        fileLine = f.readline()
    f.close()

    return savedTimes

def merge(folder1,folder2,toSaveFolder):
    gridSizes = [20,50,100]
    agentsNums =[5,10,15,20]
    paths =[1,5,10,15,20]
    csList =[]
    csList.append("IN Square 1 Intersection 1 3")
    csList.append("IN Square 1 Intersection 1 5")
    csList.append("IN Square 1 Intersection 1 8")
    csList.append("IN Square 2 Count 3")
    csList.append("IN Square 2 Count 5")
    csList.append("IN Square 2 Count 8")

    for cs in csList:
        folderName10 = folder1 + cs + os.path.sep
        folderName20 = folder2 + cs + os.path.sep
        for grid in gridSizes:
            for agent in agentsNums:
                if ((cs == "IN Square 1 Intersection 1 8") or (cs == "IN Square 2 Count 8")) and agent==5:
                    continue
                
                for path in paths:
                    fileName10 = "G-%d-A-%d-W-%d-D-%d-I-%d-R-%d-T-%d-Fil-Erl-GenB.txt" %(grid,agent,0,path,1,14,60)    # 14 samples
                    fileName20 = "G-%d-A-%d-W-%d-D-%d-I-%d-R-%d-T-%d-Fil-Erl-GenB.txt" %(grid,agent,0,path,1,16,60)    # 16 samples

                    savedTimes10 = getTestData(folderName10+fileName10)
                    savedTimes20 = getTestData(folderName20+fileName20)

                    fileName30 = "G-%d-A-%d-W-%d-D-%d-I-%d-R-%d-T-%d-Fil-Erl-GenB.txt" %(grid,agent,0,path,1,30,60)                    
                    fileHelper.saveTimeResultsToFile(toSaveFolder+cs+os.path.sep,fileName30,savedTimes10+savedTimes20)                     



if __name__ == "__main__":
    folder1      = "GenTimes/new grid/erl-14 samples/"
    folder2      = "GenTimes/new grid/erl-16 samples/"
    folderMerged = "GenTimes/new grid/erl-30 samples/"
    
    merge(folder1,folder2,folderMerged)

    # times = getTestData("GenTimes/erl-20-samples/IN Square 1 Intersection 1 3 - Erlang/G-5-A-5-W-0-D-1-I-1-R-20-T-60-Fil-Erl-GenB.txt")
    # [print(time) for time in times]