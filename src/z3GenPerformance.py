from os import wait
from pathGenerator import *
from fileHelper import *
import multiprocessing
import time
import psutil
import shutil

testInputInTimeout = "Time-out"

def tryFindingSolution(pathGenObj, inputNum, generatedData):
    generatedData.append( pathGenObj.genTestInputs(inputNum) )

def incrementalRunExp():

    areaType = "Square" # "Circle"
    areaSize = 2
    conditionType =  "Count" # "Intersection" #  
    # numIntersection = 1
    densityDegree = 3

    cs = (stringToAscii("IN"), (stringToAscii(areaType), areaSize), (stringToAscii(conditionType), densityDegree)) # count condition
    # cs = (stringToAscii("IN"), (stringToAscii(areaType), areaSize), (stringToAscii(conditionType), numIntersection, densityDegree)) # intersection condition

    gridSizes  = [10,15,20,50]#[5,7,10,12,15,17,20]#list ( range(5,6) )
    agentsNums = [10,15,20]#list ( range(5,21) )
    dispStepss = [1,5,10,15,20]#list ( range(1,21) )
    waitSteps = 0
    inputsNum = 1
    repeats = 30
    timeoutSeconds = 60

    TimesFolderName    = "Exp II - results{0}z3-py{0}GenTimes{0}IN {1} {2} {3} {4}{0}" .format(os.path.sep,areaType,areaSize,conditionType,densityDegree) # count condition
    InputsFolderName   = "Exp II - results{0}z3-py{0}GenInputs{0}IN {1} {2} {3} {4}{0}".format(os.path.sep,areaType,areaSize,conditionType,densityDegree) # count condition
    
    # TimesFolderName    = "Exp II - results{0}GenTimes{0}py-30 samples{0}IN {1} {2} {3} {4} {5}{0}" .format(os.path.sep,areaType,areaSize,conditionType,numIntersection,densityDegree) # intersection condition
    # InputsFolderName   = "Exp II - results{0}GenInputs{0}py-30 samples{0}IN {1} {2} {3} {4} {5}{0}".format(os.path.sep,areaType,areaSize,conditionType,numIntersection,densityDegree) # intersection condition

    TimesLogFolderName = "{0}log{1}".format(TimesFolderName ,os.path.sep)
    InputsLogFolderName= "{0}log{1}".format(InputsFolderName,os.path.sep)

    if not os.path.exists(TimesLogFolderName):
        os.makedirs(TimesLogFolderName)
        
    if not os.path.exists(InputsLogFolderName):
        os.makedirs(InputsLogFolderName)

    for rep in range(1,repeats+1):
        for gridSize in gridSizes:
            for agentsNum in agentsNums:
                for dispSteps in dispStepss:
                    # for z3Rand in range(0,31):
                        solutionTime1 = time.time()
                        targetFileName = "G-%d-A-%d-W-%d-D-%d-I-%d-R-%d-T-%d-Gen-Z3.txt" %(gridSize,agentsNum,waitSteps,dispSteps,inputsNum,rep,timeoutSeconds)     
                        # targetFileName = "G-%d-A-%d-W-%d-D-%d-I-%d-R-%d-T-%d-S-%d-Gen-Z3.txt" %(gridSize,agentsNum,waitSteps,dispSteps,inputsNum,rep,timeoutSeconds,z3Rand)     
                        if os.path.exists(InputsFolderName+targetFileName) and os.path.exists(TimesFolderName+targetFileName):
                            continue

                        if os.path.exists(InputsLogFolderName+targetFileName) and os.path.exists(TimesLogFolderName+targetFileName):
                            continue
                                            
                        allTimes  = []
                        allInputs = []
                        prevFileName   = "G-%d-A-%d-W-%d-D-%d-I-%d-R-%d-T-%d-Gen-Z3.txt" %(gridSize,agentsNum,waitSteps,dispSteps,inputsNum,rep-1,timeoutSeconds)
                        # prevFileName   = "G-%d-A-%d-W-%d-D-%d-I-%d-R-%d-T-%d-S-%d-Gen-Z3.txt" %(gridSize,agentsNum,waitSteps,dispSteps,inputsNum,rep-1,timeoutSeconds,z3Rand)
                        if os.path.exists(InputsFolderName+prevFileName) and os.path.exists(TimesFolderName+prevFileName):
                            allTimes  = loadSavedTimes(TimesFolderName,prevFileName)
                            allInputs = loadSavedInputs(InputsFolderName,prevFileName)
                        else:
                            print("\t\tNo previous solution is found!!!")

                        manager  = multiprocessing.Manager() # starting a new manager process
                        generatedData = manager.list()
                        pyMainProcs = [proc for proc in psutil.process_iter() if "python" in  proc.name()]

                        obj = pathGenerator(gridSize,gridSize,agentsNum,waitSteps,dispSteps,cs,timeoutSeconds+1)
                        z3Proc = multiprocessing.Process(target=tryFindingSolution, args=(obj, inputsNum,generatedData))
                        t1= time.time()
                        z3Proc.start()  # starting a new anonymous process
                        z3Proc.join(timeoutSeconds)
                        t2 = time.time()
                        print ("The attempt took %d ms.\n" %(round( (t2-t1)*1000 )))
                        allTimes.append(round( (t2-t1)*1000 ))
                        if z3Proc.is_alive():
                            z3Proc.terminate()
                            z3Proc.join()
                            allInputs.append(testInputInTimeout)
                        else:
                            allInputs.append(generatedData[0])

                        saveTimeResultsToFile(TimesFolderName, targetFileName, allTimes)
                        saveInputResultsToFile(InputsFolderName, targetFileName, allInputs)
                        
                        if os.path.exists(InputsFolderName+prevFileName) and os.path.exists(TimesFolderName+prevFileName):
                            shutil.move(TimesFolderName +prevFileName, TimesLogFolderName +prevFileName)
                            shutil.move(InputsFolderName+prevFileName, InputsLogFolderName+prevFileName)

                        print("The results for %s is ready for repeat %d now." %(targetFileName,rep))

                        pyNewProcs = [proc for proc in psutil.process_iter() if "python" in  proc.name()]
                        [proc.kill() for proc in pyNewProcs if proc not in pyMainProcs]
                        solutionTime2 = time.time()
                        print("The whole time for one try took %d ms.\n\n" %(round( (solutionTime2-solutionTime1)*1000) ) )
                        # time.sleep(1)
    
    print("Experiment is finished successfully.")

#--------------------------------  Testing and debugging  --------------------------------


#-------------------------------- functions for debugging --------------------------------
def procStatus(message):
    print("proc status:" + message)
    allProc = [x.name() for x in psutil.process_iter()]
    procCount = len(allProc)
    print("proc count: %d" %(procCount))
    pyProc = [pyProc for pyProc in allProc if "python" in pyProc]
    pyProcCount = len(pyProc)
    print("python proc count: %d" %(pyProcCount))
    time.sleep(3)
    return [procCount,pyProcCount]

def getPyProcIDs():
    allProc = [x.name() for x in psutil.process_iter()]
    procCount = len(allProc)
    print("proc count: %d" %(procCount))
    pyProc = [pyProc for pyProc in allProc if pyProc]
    pyProcCount = len(pyProc)
    print("python proc count: %d" %(pyProcCount))
    time.sleep(3)
    return [procCount,pyProcCount]
#---------------------------------------------------------------------------------------
   
if __name__ == "__main__":
    incrementalRunExp()
    # runExperiment()

    # fileName = "G-20-A-10-W-0-D-10-I-4-R-2-T-1-Gen-Z3.txt"

    # inputsFolderName  = "GenInputs"+ os.path.sep+"IN Square 2 Count 5 - new2"+ os.path.sep
    # ans = loadSavedInputs(inputsFolderName, fileName)
    # saveInputResultsToFile("GenInputs"+ os.path.sep+"TestCode"+ os.path.sep,fileName, ans)

    # TimesFolderName  = "GenTimes"+ os.path.sep+"IN Square 2 Count 5 - new2"+ os.path.sep
    # ans = loadSavedTimes(TimesFolderName, fileName)
    # print (ans)

#---------------------------------------------------------
# #not incremental calculation
# def runExperiment():
#     cs = (stringToAscii("IN"), (stringToAscii("Square"), 2), (stringToAscii("Count"), 5))
#     gridSize = 20
#     waitSteps = 0
#     inputsNum = 1
#     repeats = 1
#     timeoutSeconds = 1
#     TimesFolderName  = "GenTimes" + os.path.sep + "IN Square 2 Count 5 - new2" + os.path.sep
#     InputsFolderName = "GenInputs"+ os.path.sep + "IN Square 2 Count 5 - new2" + os.path.sep

#     for agentsNum in range(10,11):
#         for dispSteps in range(10,11):
#             allTimes = []
#             manager = multiprocessing.Manager() # starting a new manager process
#             generatedData = manager.list()
#             for counter in range(0,repeats):
#                 obj = pathGenerator(gridSize,gridSize,agentsNum,waitSteps,dispSteps,cs,timeoutSeconds+1)
#                 z3Proc = multiprocessing.Process(target=tryFindingSolution, args=(obj, inputsNum,generatedData))
#                 t1= time.time()
#                 z3Proc.start()  # starting a new anonymous process
#                 z3Proc.join(timeoutSeconds)
#                 t2 = time.time()
#                 print ("It took %d ms.\n" %(round( (t2-t1)*1000 )))
#                 allTimes.append(round( (t2-t1)*1000 ))
#                 if z3Proc.is_alive():
#                     print("%s!\n" %(testInputInTimeout))
#                     z3Proc.terminate()
#                     z3Proc.join() 
#                     generatedData.append(testInputInTimeout)
    
#             fileName = "G-%d-A-%d-W-%d-D-%d-I-%d-R-%d-T-%d-Gen-Z3.txt" %(gridSize,agentsNum,waitSteps,dispSteps,inputsNum,repeats,timeoutSeconds)
#             saveTimeResultsToFile(TimesFolderName, fileName, allTimes)
#             saveInputResultsToFile(InputsFolderName, fileName, generatedData)
#             print("The results for %s is ready now." %(fileName))
#             time.sleep(1)
    
#     print("Experiment is finished successfully.")
