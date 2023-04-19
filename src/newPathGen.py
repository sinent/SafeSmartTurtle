import sys
from z3 import *
import random

class newPathGen:

    def __init__(self, gridX, gridY, agentsNum, waitSteps, dispSteps, constraints):
        self.gridX = gridX
        self.gridY = gridY
        self.agentsNum = agentsNum
        self.waitSteps = waitSteps
        self.dispSteps = dispSteps
        self.constraits = constraints
        self.stepLength = self.waitSteps + self.dispSteps
        self.solver = Solver()

        self.stateSort, self.mk_state, (self.getX,self.getY,self.getW,self.getD) = TupleSort("state", [IntSort(), IntSort(),IntSort(),IntSort()])

        self.agentIndex = Int('agentIndex')
        self.agentTime = Int('time')
        self.stateFunc = Function('stateFunc', IntSort(), IntSort(), self.stateSort)

        self.__initializeSolver()

    def __initializeSolver(self):
        
        indexRange_CS = And(self.agentIndex>=0, self.agentIndex<self.agentsNum, self.agentTime>=0,self.agentTime<=self.stepLength)

        stateRange_CS = ForAll([self.agentIndex, self.agentTime],
                            And(
                                self.getX(self.stateFunc(self.agentIndex, self.agentTime))>=0,
                                self.getX(self.stateFunc(self.agentIndex, self.agentTime))<=self.gridX,

                                self.getY(self.stateFunc(self.agentIndex, self.agentTime))>=0,
                                self.getY(self.stateFunc(self.agentIndex, self.agentTime))<=self.gridY,

                                self.getW(self.stateFunc(self.agentIndex, self.agentTime))>=0,
                                self.getW(self.stateFunc(self.agentIndex, self.agentTime))<=self.waitSteps,

                                self.getD(self.stateFunc(self.agentIndex, self.agentTime))>=0,
                                self.getD(self.stateFunc(self.agentIndex, self.agentTime))<=self.dispSteps
                            )
                        )
        init_last_CS = ForAll([self.agentIndex, self.agentTime],
                            And(
                                self.getW(self.stateFunc(self.agentIndex,0))==0,
                                self.getD(self.stateFunc(self.agentIndex,0))==0,
                                self.getW(self.stateFunc(self.agentIndex,self.stepLength))==self.waitSteps,
                                self.getD(self.stateFunc(self.agentIndex,self.stepLength))==self.dispSteps
                            ) 
                        )  

        newTime = Int('newTime')
        distinct_initialXY_CS = ForAll([self.agentIndex, self.agentTime],
                                    Or(
                                        self.agentTime == newTime,
                                        self.getX(self.stateFunc(self.agentIndex, self.agentTime)) != self.getX(self.stateFunc(self.agentIndex, newTime)), 
                                        self.getY(self.stateFunc(self.agentIndex, self.agentTime)) != self.getY(self.stateFunc(self.agentIndex, newTime))
                                    )
                                )   
        oneCS = ForAll([self.agentIndex, self.agentTime],
                        self.agentTime == self.getD(self.stateFunc(self.agentIndex,self.agentTime)) + self.getW(self.stateFunc(self.agentIndex,self.agentTime)))

        paths_CS = ForAll([self.agentIndex, self.agentTime],
                        Or( 
                            Or(self.agentIndex >= self.agentsNum, self.agentTime >= (self.dispSteps+ self.waitSteps)),
                            And(
                                And(self.agentIndex < self.agentsNum, self.agentTime < (self.dispSteps+ self.waitSteps)),
                                Or(
                                    And(    # Moving Right
                                        self.getD(self.stateFunc(self.agentIndex,self.agentTime)) < self.dispSteps,
                                        # self.getX(self.stateFunc(self.agentIndex,self.agentTime)) < self.gridX,
                                        self.getD(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getD(self.stateFunc(self.agentIndex,self.agentTime))+1 ,
                                        self.getW(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getW(self.stateFunc(self.agentIndex,self.agentTime)) #,
                                        # self.getX(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getX(self.stateFunc(self.agentIndex,self.agentTime))+1 ,
                                        # self.getY(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getY(self.stateFunc(self.agentIndex,self.agentTime))
                                        ),

                                    # And(    # Moving Left
                                    #     self.getD(self.stateFunc(self.agentIndex,self.agentTime)) < self.dispSteps,
                                    #     self.getX(self.stateFunc(self.agentIndex,self.agentTime)) > 0,
                                    #     self.getD(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getD(self.stateFunc(self.agentIndex,self.agentTime))+1 ,
                                    #     self.getW(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getW(self.stateFunc(self.agentIndex,self.agentTime)) ,
                                    #     self.getX(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getX(self.stateFunc(self.agentIndex,self.agentTime))-1 ,
                                    #     self.getY(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getY(self.stateFunc(self.agentIndex,self.agentTime))
                                    #     ),
                                    
                                    # And(    # Moving Up
                                    #     self.getD(self.stateFunc(self.agentIndex,self.agentTime)) < self.dispSteps,
                                    #     self.getY(self.stateFunc(self.agentIndex,self.agentTime)) < self.gridY,
                                    #     self.getD(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getD(self.stateFunc(self.agentIndex,self.agentTime))+1 ,
                                    #     self.getW(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getW(self.stateFunc(self.agentIndex,self.agentTime)) ,
                                    #     self.getX(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getX(self.stateFunc(self.agentIndex,self.agentTime)) ,
                                    #     self.getY(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getY(self.stateFunc(self.agentIndex,self.agentTime))+1
                                    #     ),
                                    
                                    # And(    # Moving Down
                                    #     self.getD(self.stateFunc(self.agentIndex,self.agentTime)) < self.dispSteps,
                                    #     self.getY(self.stateFunc(self.agentIndex,self.agentTime)) > 0,
                                    #     self.getD(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getD(self.stateFunc(self.agentIndex,self.agentTime))+1 ,
                                    #     self.getW(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getW(self.stateFunc(self.agentIndex,self.agentTime)) ,
                                    #     self.getX(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getX(self.stateFunc(self.agentIndex,self.agentTime)) ,
                                    #     self.getY(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getY(self.stateFunc(self.agentIndex,self.agentTime))-1
                                    #     ),
                                
                                    And(    # Waiting
                                        self.getW(self.stateFunc(self.agentIndex,self.agentTime)) < self.waitSteps,
                                        self.getD(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getD(self.stateFunc(self.agentIndex,self.agentTime)),
                                        self.getW(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getW(self.stateFunc(self.agentIndex,self.agentTime))+1#,
                                        # self.getX(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getX(self.stateFunc(self.agentIndex,self.agentTime)) ,
                                        # self.getY(self.stateFunc(self.agentIndex,self.agentTime+1)) == self.getY(self.stateFunc(self.agentIndex,self.agentTime))
                                        )#,
                                    # And( 
                                    #     self.getW(self.stateFunc(self.agentIndex,self.agentTime))>= self.waitSteps,
                                    #     self.getD(self.stateFunc(self.agentIndex,self.agentTime))>= self.dispSteps
                                    # )

                                )
                            )
                            
                        )
                    )

        self.solver.add(And(indexRange_CS, stateRange_CS, init_last_CS, distinct_initialXY_CS,oneCS, paths_CS))
    
    
def main():
    # the constraint "IN Circle 1 Count 2"
    cs = None

    gridX = 10
    gridY = 10
    agentsNum = 3
    waitSteps = 1
    dispSteps = 3
    inputNum = 5
    obj = newPathGen(gridX,gridY,agentsNum,waitSteps,dispSteps,cs)
    if( obj.solver.check()==sat):
        print(obj.solver.model())
    else: 
        print("inconsistent constraints.\n")

    print("The constraints:")
    for s in obj.solver.assertions():
        print (s)

    
if __name__ == "__main__":
    main()