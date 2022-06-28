import matplotlib
import matplotlib.pyplot as plt
import numpy as np

#drawing box plots of different grid sizes in one figure 

def getRawData(grid, filter, data):
    filePath = "exp1-results/grid%d/%s/Raw/%s.txt" %(grid, filter, data)
    f = open(filePath, "r")
    line = f.readline() # skipping the first line: '#turtle=X'
    ans = []
    line = f.readline()
    while len(line.split())>1:
        ans.append(int(line.split()[1]))
        line = f.readline()
    return ans

def drawPlot(targetData, ylabelText):
    # targetData is the foldername containing the data
    # it belongs to [TestsNum, ShrinkSteps, FailedShrinkSteps, Discards]

    def set_box_color(bp, color):
        plt.setp(bp['boxes'], color=color)
        plt.setp(bp['whiskers'], color=color)
        plt.setp(bp['caps'], color=color)
        plt.setp(bp['medians'], color=color)

    data_NoF =[]
    data_F1  =[]
    data_F2  =[]
    data_F3  =[]

    grids = [10,20,50,100]
    for g in grids:
        data_NoF.append( getRawData(g, "NoFilter", targetData) )
        data_F1.append(  getRawData(g, "F1", targetData) )
        data_F2.append(  getRawData(g, "F2", targetData) )
        data_F3.append(  getRawData(g, "F3", targetData) )

    ticks = ['10*10', '20*20', '50*50', '100*100']

    plt.figure()

    bpA = plt.boxplot(data_NoF, positions=np.array(range(len(data_NoF)))*3-0.75, sym='', widths=0.4)
    bpB = plt.boxplot(data_F1,  positions=np.array(range(len(data_F1)))*3-0.25, sym='', widths=0.4)
    bpC = plt.boxplot(data_F2,  positions=np.array(range(len(data_F2)))*3+0.25, sym='', widths=0.4)
    bpD = plt.boxplot(data_F3,  positions=np.array(range(len(data_F3)))*3+0.75, sym='', widths=0.4)

    set_box_color(bpA, '#0579D5') # colors are from http://colorbrewer2.org/
    set_box_color(bpB, '#ff6600')
    set_box_color(bpC, '#a6a6a6')
    set_box_color(bpD, '#ffc61a')

    # draw temporary red and blue lines and use them to create a legend
    plt.plot([], c='#0579D5', label='No Filter')
    plt.plot([], c='#ff6600', label='F1 Filter')
    plt.plot([], c='#a6a6a6', label='F2 Filter')
    plt.plot([], c='#ffc61a', label='F3 Filter')

    plt.xlabel('Grid Size', fontsize=14, fontweight='bold')
    plt.ylabel(ylabelText, fontsize=14, fontweight='bold')
    legend_properties = {'weight':'bold'} 
    plt.legend(prop=legend_properties) 

    # plt.legend()


    plt.xticks(range(0, len(ticks) * 3, 3), ticks)
    plt.tick_params(axis='x', labelsize=14)
    plt.xticks(weight = 'bold')
    plt.tick_params(axis='y', labelsize=14)
    plt.yticks(weight = 'bold')
    # plt.xlim(-2, len(ticks)*2)
    # plt.ylim(0, 8)

    plt.legend(bbox_to_anchor=(0,1.02,1,0.2), loc="lower left", prop = {'weight':'bold', 'size':11.5},
                mode="expand", borderaxespad=0, ncol=4)
            
    # plt.legend(prop={'size': 14})
    # legend_properties = {'weight':'bold'} 
    # plt.legend(prop=legend_properties) 

    plt.tight_layout()

    plt.savefig("exp1-results/boxplots/"+targetData + ".pdf")

#******* notice **********
# run this program in terminal
# running that in vs leads to an error

if __name__ == "__main__":
    drawPlot("TestsNum", "Number of test cases")
    drawPlot("Discards", "Number of test cases")
    drawPlot("ShrinkSteps"      , "Number of steps" )
    drawPlot("FailedShrinkSteps", "Number of steps" )


