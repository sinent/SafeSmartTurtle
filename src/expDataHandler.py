import os
from numpy import average
import pandas as pd

# gathering/combining the experimeental data into relevant files

def getData_MedianAverage(folderName):
    onlyfiles = [f for f in os.listdir(folderName) if os.path.isfile(os.path.join(folderName, f))]

    gridsArray = []
    agentsArray = []
    dispsArray = []
    medianArray = []
    averageArray=[]

    # print (len(onlyfiles))
    for fileName in onlyfiles:
        if len(fileName.split('.'))<2 or fileName.split('.')[1]!="txt": # skipping files like .DS_Store 
            continue
        #print ( "file name is "+ fileName)
        info =  fileName.split('-')
        gridSize  = int(info[1])
        agentsNum = int(info[3])
        waitSteps = int(info[5])
        dispSteps = int(info[7])
        inputsNum = int(info[9])
        repeats   = int(info[11])  
        timeout   = int(info[13]) 

        if gridSize not in [10,15,20,50]:
            continue
        if agentsNum not in [10,15,20]:
            continue
        if dispSteps not in [1,5,10,15,20]:
            continue 

        f = open(folderName+fileName, "r")
        line = f.readline() # skipping the first line: 'All times''
        while "Average" not in line:
            line = f.readline()
        average = int(line.split(':')[1].strip())
        while "Median" not in line:
            line = f.readline()
        median = int(line.split(':')[1].strip())
        f.close()

        gridsArray.append(gridSize)
        agentsArray.append(agentsNum)
        dispsArray.append(dispSteps)
        medianArray.append(round(median/1000))
        averageArray.append(round(average/1000))

    return gridsArray,agentsArray,dispsArray,medianArray,averageArray

def saveData(methodName,csList,timeout):
    csAll = []
    gridsAll = []
    agentsAll=[]
    pathsAll=[]
    mediansAll=[]
    averagesAll=[]

    for cs in csList:
        if methodName == "z3":
            folderMethod = "/python-z3" 
        else:
            folderMethod = "/erl-qc" 
        dataFolder = "Exp II - results/time-out "+ str(timeout)+ folderMethod+ "/times/"+cs +"/"
        grids,agents,paths,medians,averages = getData_MedianAverage(dataFolder)

        csAll.extend([cs]*len(grids))
        gridsAll.extend(grids)
        agentsAll.extend(agents)
        pathsAll.extend(paths)
        mediansAll.extend(medians)
        averagesAll.extend(averages)

        # save data for statistical tests on constraints

    data = {'Method': [methodName]*len(gridsAll),
            'Constraint': csAll,
            'GridSize':gridsAll,
            'NumberOfAgents':agentsAll,
            'PathLength': pathsAll,
            'Time_Median': mediansAll,
            'Time_Average': averagesAll}
    df = pd.DataFrame(data)
    sortedDataFrame = df.sort_values(by=['Constraint','GridSize', 'NumberOfAgents', 'PathLength'], ascending=True)
    if methodName == "z3":
        sortedDataFrame.to_csv (r'z3_data.csv', index = False, header=True)
    else:
        sortedDataFrame.to_csv (r'erlang_data.csv', index = False, header=True)

    # converting the constraints from string type to an integer type
    size1 = len(set(gridsAll))*len(set(agentsAll))*len(set(pathsAll)) # cs1 or cs2 cases for each method
    # size2 = len(set(gridsAll))*(len(set(agentsAll))-1)*len(set(pathsAll)) # cs3 cases for each method
    # oneMethodSize = size1 + size1 + size2
    oneMethodSize = 3*size1

    csChangedNames =[]
    csChangedNames.extend([3]*size1)
    csChangedNames.extend([5]*size1)
    # csChangedNames.extend([8]*size2)
    csChangedNames.extend([8]*size1)

    # saving intersection constraint
    dataCS = {  'Method':        sortedDataFrame['Method'].tolist()[:oneMethodSize],
                'Constraint':    csChangedNames,
                'GridSize':      sortedDataFrame['GridSize'].tolist()[:oneMethodSize],
                'NumberOfAgents':sortedDataFrame['NumberOfAgents'].tolist()[:oneMethodSize],
                'PathLength':    sortedDataFrame['PathLength'].tolist()[:oneMethodSize],
                'Time_Median':   sortedDataFrame['Time_Median'].tolist()[:oneMethodSize],
                'Time_Average':  sortedDataFrame['Time_Average'].tolist()[:oneMethodSize]}

    # print("I am here!")
    # print (len(sortedDataFrame))
    # print (len(gridsAll))
    # print (len(sortedDataFrame))
    # print (len(pathsAll))
    # print (len(mediansAll))
    # print (len([methodName]*len(gridsAll)) )
    
    df = pd.DataFrame(dataCS)
    if methodName == "z3":
        df.to_csv (r'z3_intersection.csv', index = False, header=True)
    else:
        df.to_csv (r'erlang_intersection.csv', index = False, header=True)
    
    # saving count constraint
    dataCS = {  'Method':        sortedDataFrame['Method'].tolist()[oneMethodSize:],
                'Constraint':    csChangedNames,
                'GridSize':      sortedDataFrame['GridSize'].tolist()[oneMethodSize:],
                'NumberOfAgents':sortedDataFrame['NumberOfAgents'].tolist()[oneMethodSize:],
                'PathLength':    sortedDataFrame['PathLength'].tolist()[oneMethodSize:],
                'Time_Median':   sortedDataFrame['Time_Median'].tolist()[oneMethodSize:],
                'Time_Average':  sortedDataFrame['Time_Average'].tolist()[oneMethodSize:]}

    # print("I am here!")
    # print (len(sortedDataFrame))
    # print (len(gridsAll))
    # print (len(sortedDataFrame))
    # print (len(pathsAll))
    # print (len(mediansAll))
    # print (len([methodName]*len(gridsAll)) )

    df = pd.DataFrame(dataCS)
    if methodName == "z3":
        df.to_csv (r'z3_count.csv', index = False, header=True)
    else:
        df.to_csv (r'erlang_count.csv', index = False, header=True)
    

if __name__ == "__main__":

    csList =[]
    csList.append("IN Square 1 Intersection 1 3")
    csList.append("IN Square 1 Intersection 1 5")
    csList.append("IN Square 1 Intersection 1 8")
    csList.append("IN Square 2 Count 3")
    csList.append("IN Square 2 Count 5")
    csList.append("IN Square 2 Count 8")

    timeout = 60
    saveData("erlang",csList,timeout)  # we need separated files for z3 and qc results, to apply statistical tests easier on them
    saveData("z3",csList,timeout)

    # f_z3   = "GenTimes/"+cs #+" - Erlang/"
    # gridsArray,agentsArray,dispsArray,medianz3 = getData_Median(f_z3)
    # data = {#'Method': ["z3"]*len(gridsArray),
    #         #'Constraint': [cs]*len(gridsArray),
    #         'Grid Size':gridsArray,
    #         'Number of Agents':agentsArray,
    #         'Path Length': dispsArray,
    #         'Time (Median)': medianz3}
    
    # # Create DataFrame
    # df = pd.DataFrame(data)
    # # Print the output.
    # # df.sort_values(by=['Grid Size', 'Number of Agents', 'Path Length'])
    # sortedDataFrame = df.sort_values(by=['Grid Size', 'Number of Agents', 'Path Length'], ascending=True)
    # sortedDataFrame.to_csv (r'expData.csv', index = False, header=True)
    # print(sortedDataFrame)