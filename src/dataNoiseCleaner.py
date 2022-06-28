import os
import fileHelper

# cleaning the possible noise in the experiments
# caused by a process or z3 call stop/start and the calculated time

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

def findNoises(folderNoisy,folderClean):
    gridSizes = [5,10,15,20,50,100]
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
        # print("Noises in %s\n"%(cs))
        folderCS = folderNoisy + cs + os.path.sep
        for grid in gridSizes:
            for agent in agentsNums:
                if ((cs == "IN Square 1 Intersection 1 8") or (cs == "IN Square 2 Count 8")) and agent==5:
                    continue
                
                for path in paths:
                    fileName = "G-%d-A-%d-W-%d-D-%d-I-%d-R-%d-T-%d-Gen-Z3.txt" %(grid,agent,0,path,1,30,60)
                    data = getTestData(folderCS+fileName)
                    noises = list(filter(lambda score: (score//1000) > 60, data))
                    if len(noises)>0:
                        print("Noise found in %s - %s"%(folderCS,fileName))
                        print(noises)
                        cleanedData = [59999 if (x//1000) > 60 else x for x in data]
                        # print(cleanedData)
                        fileHelper.saveTimeResultsToFile(folderClean,fileName,cleanedData)                     



if __name__ == "__main__":
    folderNoisy      = "GenTimes/py-30 samples/"
    folderClean      = "GenTimes/py-30 samples-Clean/"

    # if os.path.exists(folderNoisy):
    #     print(True)
    # else:
    #     open(folderNoisy,"x")
    findNoises(folderNoisy,folderClean)

    # times = getTestData("GenTimes/erl-20-samples/IN Square 1 Intersection 1 3 - Erlang/G-5-A-5-W-0-D-1-I-1-R-20-T-60-Fil-Erl-GenB.txt")
    # [print(time) for time in times]