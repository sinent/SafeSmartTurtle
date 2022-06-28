from fileinput import filename
import statistics
import numpy
import os

# save/load experimental result/time from/to file

testInputInTimeout = "Time-out"

def loadSavedTimes(TimesFolderName, fileName):
    ans = []
    if not os.path.exists(TimesFolderName+fileName):
        return ans

    f = open(TimesFolderName+fileName, "r")
    f.readline() # skipping the first line: 'All times''
    line = f.readline() 
    while "Test Set" in line:
        time = line.split(':')[1].strip()
        ans.append(int(time))
        line = f.readline()
    f.close()

    return ans

def loadSavedInputs(inputsFolderName, fileName):
    ans = []
    print(fileName)
    if not os.path.exists(inputsFolderName+fileName):
        return ans

    info =  fileName.split('-')
    agentsNum = int(info[3])
    waitSteps = int(info[5])
    dispSteps = int(info[7])
    inputsNum = int(info[9])
    repeats   = int(info[11])   

    f = open(inputsFolderName+fileName, "r")

    for r in range(repeats):
        f.readline() # Repeat Index:i
        f.readline()
        f.readline()
        
        OneRepeatData = numpy.full((inputsNum,agentsNum,dispSteps+waitSteps+1,2),-1, dtype=int)   
        for i in range(inputsNum):
            repeatInfo = f.readline() # 'Test input:indexX' or 'Time-out'
            if repeatInfo.strip()==testInputInTimeout:
                OneRepeatData = testInputInTimeout
                f.readline()
                break
     
            for a in range(agentsNum):
                agentInfo = f.readline()
                # print ("agent Info: "+ agentInfo)

                startPose = agentInfo.split(';')[1]
                startX = int (startPose.split('=')[1].split(',')[0].replace('(','').strip())
                startY = int (startPose.split('=')[1].split(',')[1].replace(')','').strip())
                OneRepeatData[i][a][0][0] = startX
                OneRepeatData[i][a][0][1] = startY
                
                moves = agentInfo.split(';')[2].split('=')[1].split(',')
                for t in range (waitSteps+dispSteps): # waitSteps+dispSteps = len(moves)
                    newMove = moves[t]
                    if newMove.strip() =="right":
                        OneRepeatData[i][a][t+1][0] = OneRepeatData[i][a][t][0] + 1
                        OneRepeatData[i][a][t+1][1] = OneRepeatData[i][a][t][1]
                    elif newMove.strip() =="left":
                        OneRepeatData[i][a][t+1][0] = OneRepeatData[i][a][t][0] - 1
                        OneRepeatData[i][a][t+1][1] = OneRepeatData[i][a][t][1]
                    elif newMove.strip() =="up":
                        OneRepeatData[i][a][t+1][0] = OneRepeatData[i][a][t][0]
                        OneRepeatData[i][a][t+1][1] = OneRepeatData[i][a][t][1] + 1                    
                    elif newMove.strip() =="down":
                        OneRepeatData[i][a][t+1][0] = OneRepeatData[i][a][t][0]
                        OneRepeatData[i][a][t+1][1] = OneRepeatData[i][a][t][1] - 1          
                    else: # nop
                        OneRepeatData[i][a][t+1][0] = OneRepeatData[i][a][t][0]
                        OneRepeatData[i][a][t+1][1] = OneRepeatData[i][a][t][1]
            f.readline()
        f.readline()
        ans.append(OneRepeatData)
    
    f.close() 
    return ans   

def saveInputResultsToFile(InputsFolderName, fileName, generatedData):
    if not os.path.exists(InputsFolderName):
        os.makedirs(InputsFolderName)

    if not os.path.exists(InputsFolderName+fileName):
        f = open(InputsFolderName+fileName, "x")
        f.close()
    
    f = open(InputsFolderName+fileName, "w")
    for repeatIndex in range(0,len(generatedData)):
        f.write("Repeat Index:%d\n\n\n" %(repeatIndex+1))
        oneSetInput = generatedData[repeatIndex]

        if ( type(oneSetInput) == str and oneSetInput == testInputInTimeout):  # time-out input
            f.write ("%s\n\n\n" %(testInputInTimeout))
            continue

        for i in range(len(oneSetInput)):
            f.write ("Test input:" + str(i+1) + "\n")
            for j in range(len(oneSetInput[i])):
                f.write ("AgentNum={0:>3d};".format(j+1))
                for t in range (len(oneSetInput[i][j])):
                    if t==0:
                        f.write(" Start=({0:>2d},{1:>2d}); Moves=".format(oneSetInput[i][j][t][0],oneSetInput[i][j][t][1]))
                    else:
                        x0 = oneSetInput[i][j][t-1][0]
                        y0 = oneSetInput[i][j][t-1][1]
                        x1 = oneSetInput[i][j][t][0]
                        y1 = oneSetInput[i][j][t][1]

                        # WARNING - in the case of having waiting steps
                        #   in the borders, the kind of actions can be misinterpreted
                        #   the path would be the same, but the actions can be replaced with 'nop' in the borders

                        if (x1>x0):
                            f.write ("{0:<5s}".format("right")) 
                        elif(x1<x0):
                            f.write ("{0:<5s}".format("left")) 
                        elif(y1>y0): # x0=x1
                            f.write ("{0:<5s}".format("up")) 
                        elif(y1<y0):
                            f.write ("{0:<5s}".format("down")) 
                        else: # x0=x1 and y0=y1
                            f.write ("nop") # no operation 
                    if t>0 and t< len(oneSetInput[i][j])-1:
                        f.write (",")
                f.write("\n")
            f.write("\n")
        f.write("\n")

    # print("printing is done!")
    f.close()
    
def saveTimeResultsToFile(TimesFolderName, fileName, allTimes):
    print(allTimes)

    if not os.path.exists(TimesFolderName):
        os.makedirs(TimesFolderName)

    if not os.path.exists(TimesFolderName+fileName):
        f = open(TimesFolderName+fileName, "x")
        f.close()

    f = open(TimesFolderName+fileName, "w")

    f.write("All Times:\n")
    for i in range(len(allTimes)):
        f.write("Test Set {0:>2d}:{1:>7d}\n".format(i+1, round(allTimes[i])) )
    f.write("\n")

    allTimes.sort()
    f.write("Statistics:\n")
    f.write("Total               :{0:>7d}\n"  .format( round( sum(allTimes))) ) 
    f.write("Average             :{0:>7d}\n"  .format( round( statistics.mean(allTimes)))) 
    if len(allTimes)>2:
        f.write("Average (no Min/Max):{0:>7d}\n"  .format( round( statistics.mean(allTimes[1:len(allTimes)-1]))))
    else:
        f.write("Average (no Min/Max):    ---\n")
    f.write("Median              :{0:>7d}\n\n".format( round( statistics.median(allTimes))) )

    f.close()

