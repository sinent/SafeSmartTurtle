import plotly.graph_objects as go
import os
import plotly.express as px
import pandas as pd
from plotly.subplots import make_subplots
import numpy
from scipy.spatial import Delaunay
import plotly.figure_factory as ff

# drawing 3d plots

def showPlot2(gridsArray,agensArray,dispsArray,medianArray):
    fig= go.Figure(data=go.Isosurface(
        x=gridsArray,
        y=agensArray,
        z=dispsArray,
        value=medianArray,
        isomin=0,
        isomax=60,
    ))

    fig.show()

def showPlot_surface3d(agensArray,dispsArray,medianArray):
    # mmm = [medianArray[0:5],medianArray[5:10],medianArray[10:15],medianArray[15:20]]
    # print (z_data.values)
    fig = go.Figure(data=[go.Surface(y=agensArray,x=dispsArray,z=medianArray)])

    fig.update_layout(title='Grid=5*5', autosize=False,
                    width=2000, height=1000,
                    margin=dict(l=65, r=50, b=65, t=90))

    fig.show()


def showPairPlot_surface3d_subPlots(agensArray,dispsArray,medianArrayZ3, medianArrayErlang, ConstraintMessage):
    fig = make_subplots(
            rows=2, cols=4,
            specs=[ [{'type': 'surface'}, {'type': 'surface'}, {'type': 'surface'}, {'type': 'surface'}],
                    [{'type': 'surface'}, {'type': 'surface'}, {'type': 'surface'}, {'type': 'surface'}]],
            subplot_titles=("Grid 5*5 - Z3", "Grid 10*10 - Z3", "Grid 15*15 - Z3", "Grid 20*20 - Z3",
                            "Grid 5*5 - QC", "Grid 10*10 - QC", "Grid 15*15 - QC", "Grid 20*20 - QC")
            )

    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArrayZ3[0],showscale=False),
            row=1, col=1)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArrayZ3[1], showscale=False),
            row=1, col=2)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArrayZ3[2], showscale=False ),
            row=1, col=3)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArrayZ3[3],  showscale=False ), 
            row=1, col=4)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArrayErlang[0],showscale=False),
            row=2, col=1)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArrayErlang[1], showscale=False),
            row=2, col=2)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArrayErlang[2], showscale=False ),
            row=2, col=3)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArrayErlang[3],  showscale=False ), 
            row=2, col=4)
    fig.update_layout(
        title_text= ConstraintMessage,
        width = 4000,
        height = 4000
    )
    fig.update_scenes( zaxis = dict(nticks=4, range=[0,60],),) 



    fig.show()

def showPlot_surface3d_subPlots(agensArray,dispsArray,medianArray,z3OrQC,ConstraintMessage):
    fig = make_subplots(
            rows=2, cols=2,
            specs=[ [{'type': 'surface'}, {'type': 'surface'}], [{'type': 'surface'}, {'type': 'surface'}] ],
            subplot_titles=("Grid 5*5 - "+z3OrQC, "Grid 10*10 - "+z3OrQC, "Grid 15*15 - "+z3OrQC, "Grid 20*20 - "+z3OrQC))

    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArray[0],cmin=0, cmax= 60, showscale=True),
            row=1, col=1)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArray[1], cmin=0, cmax= 60,showscale=False),
            row=1, col=2)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArray[2], cmin=0, cmax= 60,showscale=False ),
            row=2, col=1)
    fig.add_trace(
            go.Surface(y=agensArray,x=dispsArray, z=medianArray[3], cmin=0, cmax= 60,showscale=False ), 
            row=2, col=2)
    fig.update_layout(
        # scene = dict(zaxis = dict(nticks=4, range=[0,60],),),
        title_text=ConstraintMessage,
        width = 2000,
        height = 2000
    )
    fig.update_scenes(  xaxis = dict(title = 'Path'),
                        yaxis = dict(title = 'Number of Agents'),
                        zaxis = dict(title = 'Time(sec)',nticks=4, range=[0,60],),) 

    fig.write_html("SavedPlots/"+ConstraintMessage+"-"+ z3OrQC+ ".html")
    # minColor = min(list(numpy.concatenate(medianArray).flat))
    # maxColor = max(list(numpy.concatenate(medianArray).flat))

    # # for k in range(2):
    # fig.data[0].update(marker_cmin=minColor, marker_cmax=maxColor)

    fig.show()

def showPlot_scatter3d(gridsArray,agensArray,dispsArray,medianArray):
    # species = ["setosa" for i in range(len(gridsArray))]
    # sizes = [ss*10 for ss in medianArray]
    myData = pd.DataFrame(list(zip(gridsArray,agensArray,dispsArray,medianArray)), columns=[ 'Grid', 'Agents', 'Path', 'Median'])
    fig = px.scatter_3d(myData, x='Agents', y='Path', z='Grid', color='Median')
    fig.show()

def getData_Median(folderName):
    onlyfiles = [f for f in os.listdir(folderName) if os.path.isfile(os.path.join(folderName, f))]

    gridsArray = []
    agentsArray = []
    dispsArray = []
    medianArray = []

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

        if gridSize not in [5,10,15,20]:
            continue
        if agentsNum not in [5,10,15,20]:
            continue
        if dispSteps not in [1,5,10,15,20]:
            continue 

        f = open(folderName+fileName, "r")
        line = f.readline() # skipping the first line: 'All times''
        while "Median" not in line:
            line = f.readline()
        median = int(line.split(':')[1].strip())
        f.close()

        gridsArray.append(gridSize)
        agentsArray.append(agentsNum)
        dispsArray.append(dispSteps)
        medianArray.append(round(median/1000))

    return gridsArray,agentsArray,dispsArray,medianArray

def getMedian3d(gridsArray,agentsArray,dispsArray,medianArray):
    sortedGridArray   = list(set(gridsArray))
    sortedGridArray.sort()
    sortedAgentsArray = list(set(agentsArray))
    sortedAgentsArray.sort()
    sortedDispsArray  = list(set(dispsArray))
    sortedDispsArray.sort()

    median3d = numpy.full((len(sortedGridArray),len(sortedAgentsArray),len(sortedDispsArray)),-1, dtype=int)

    for i in range(len(medianArray)):
        gIndex = sortedGridArray.index(gridsArray[i])
        aIndex = sortedAgentsArray.index(agentsArray[i])
        dIndex = sortedDispsArray.index(dispsArray[i])
        median3d[gIndex][aIndex][dIndex] = medianArray[i]
    
    # print(median3d)
    return median3d

def drawSurface3dPlots(TimesFolderName, z3oRQC, constraint):
    gridsArray,agentsArray,dispsArray,medianArray = getData_Median(TimesFolderName)
    median3d = getMedian3d(gridsArray,agentsArray,dispsArray,medianArray)

    sortedGridArray   = list(set(gridsArray))
    sortedGridArray.sort()
    sortedAgentsArray = list(set(agentsArray))
    sortedAgentsArray.sort()
    sortedDispsArray  = list(set(dispsArray))
    sortedDispsArray.sort()

    showPlot_surface3d_subPlots(sortedAgentsArray,sortedDispsArray,median3d,z3oRQC, constraint)

def drawPairSurface3dPlots(TimesFolderZ3, TimesFolderQC, ConstraintMessage):
    gridsArray,agentsArray,dispsArray,medianz3 = getData_Median(TimesFolderZ3)
    median3d_z3 = getMedian3d(gridsArray,agentsArray,dispsArray,medianz3)

    gridsArray,agentsArray,dispsArray,medianQC = getData_Median(TimesFolderQC)
    median3d_QC = getMedian3d(gridsArray,agentsArray,dispsArray,medianQC)

    sortedGridArray   = list(set(gridsArray))
    sortedGridArray.sort()
    sortedAgentsArray = list(set(agentsArray))
    sortedAgentsArray.sort()
    sortedDispsArray  = list(set(dispsArray))
    sortedDispsArray.sort()

    showPairPlot_surface3d_subPlots(sortedAgentsArray,sortedDispsArray,median3d_z3,median3d_QC,ConstraintMessage)  

def printAll_1():
    cs="IN Square 1 Intersection 1 3"
    f_z3   = "GenTimes/"+cs+"/"
    drawSurface3dPlots(f_z3, "z3", cs)

    cs="IN Square 1 Intersection 1 3"
    f_z3   = "GenTimes/"+cs+ " - Erlang/"
    drawSurface3dPlots(f_z3, "QC", cs)



    cs="IN Square 1 Intersection 1 5"
    f_z3   = "GenTimes/"+cs+"/"
    drawSurface3dPlots(f_z3, "z3", cs)

    cs="IN Square 1 Intersection 1 5"
    f_z3   = "GenTimes/"+cs+ " - Erlang/"
    drawSurface3dPlots(f_z3, "QC", cs)
    

    cs="IN Square 1 Intersection 1 8"
    f_z3   = "GenTimes/"+cs+"/"
    drawSurface3dPlots(f_z3, "z3", cs)

    cs="IN Square 1 Intersection 1 8"
    f_z3   = "GenTimes/"+cs+ " - Erlang/"
    drawSurface3dPlots(f_z3, "QC", cs)



    cs="IN Square 2 Count 3"
    f_z3   = "GenTimes/"+cs+ "/"
    drawSurface3dPlots(f_z3, "z3", cs)

    cs="IN Square 2 Count 3"
    f_z3   = "GenTimes/"+cs+ " - Erlang/"
    drawSurface3dPlots(f_z3, "QC", cs)


    cs="IN Square 2 Count 5"
    f_z3   = "GenTimes/"+cs+ "/"
    drawSurface3dPlots(f_z3, "z3", cs)

    cs="IN Square 2 Count 5"
    f_z3   = "GenTimes/"+cs+ " - Erlang/"
    drawSurface3dPlots(f_z3, "QC", cs)


    cs="IN Square 2 Count 8"
    f_z3   = "GenTimes/"+cs+ "/"
    drawSurface3dPlots(f_z3, "z3", cs)

    # cs="IN Square 2 Count 8"
    f_z3   = "GenTimes/"+cs+ " - Erlang/"
    drawSurface3dPlots(f_z3, "QC", cs)


def draw_triSurf1():
    u = numpy.linspace(0, 2*numpy.pi, 8) # making a list including the points in range 0 to 2*pi splitted by 24 equal distances
    v = numpy.linspace(-1, 1, 8)
    u,v = numpy.meshgrid(u,v)
    u = u.flatten()
    v = v.flatten()

    tp = 1 + 0.5*v*numpy.cos(u/2.)
    x = tp*numpy.cos(u)
    y = tp*numpy.sin(u)
    z = 0.5*v*numpy.sin(u/2.)

    points2D = numpy.vstack([u,v]).T
    tri = Delaunay(points2D)
    simplices = tri.simplices

    fig = ff.create_trisurf(x=x, y=y, z=z,
                            colormap="Portland",
                            simplices=simplices,
                            title="Mobius Band")
    fig.show()

def getColorMap(minValue, maxValue):
    colors = [
        "#006FFF", # yellow
        "#0044FF", # light yellow
        "#1508BF", # light green
        "#2108BF", # green
        "#3908BF", # green
        "#5108BF", # green
        "#7C07C0", # light blue
        "#8F07C0", # daker light blue
        "#9B07C0", # other darker blue
        "#B407C0", # the lighter version 
        "#C007AE", # light purple
        "#FF0089", # light purple
                ]
    if maxValue>55:
        maxValue = 56
    
    maxColorIndex = (maxValue//5)
    minColorIndex = (minValue//5)

    if minColorIndex==maxColorIndex:
        if maxColorIndex ==0:
            maxColorIndex=1
        else:
            minColorIndex = minColorIndex -1

    # return colors[0: (maxValue//5)+1]
    # print(colors[minColorIndex:maxColorIndex])
    return colors[minColorIndex:maxColorIndex+1]

def drawTriSurf_allGrids(cs, z3OrQC):
    if z3OrQC == "z3":
        path   = "GenTimes/"+cs+"/"
    else:
        path   = "GenTimes/"+cs+ " - Erlang/"
    gridsArray,agentsArray,dispsArray,medianz3 = getData_Median(path)

    x = [5,10,15,20]
    y = [1,5,10,15,20]
    x,y = numpy.meshgrid(x,y)
    x = x.flatten()
    y = y.flatten() # 2d array to 1d array

    u = [1,2,3,4]
    v = [1,2,3,4,5]
    u,v = numpy.meshgrid(u,v)
    u = u.flatten()
    v = v.flatten() # 2d array to 1d array
    points2D = numpy.vstack([u,v]).T
    tri = Delaunay(points2D)
    simplices = tri.simplices

    agents = []
    paths = []
    # medians2 = []
    medians_g5  = numpy.full(4*5, -1, dtype = int)
    medians_g10 = numpy.full(4*5, -1, dtype = int)
    medians_g15 = numpy.full(4*5, -1, dtype = int)

    for g in range(0,len(gridsArray)):
        ai = (agentsArray[g]//5) # 1,2,3,4
        di = (dispsArray[g]//5) # 0,1,2,3,4
        if( gridsArray[g] == 5):
            medians_g5[(di)*4 + ai-1]  = medianz3[g]
        elif( gridsArray[g] == 10):
            medians_g10[(di)*4 + ai-1] = medianz3[g]
        elif( gridsArray[g] == 15):
            medians_g15[(di)*4 + ai-1] = medianz3[g]

    z = medians_g5
    fig = ff.create_trisurf(x=x, y=y, z=z,
                            # colormap="Portland",
                            colormap=getColorMap(max(z)),
                            simplices=simplices,
                            title="Time of test generation",
                            show_colorbar = False,
                            )
    fig.update_scenes(  xaxis = dict(title = 'Number of Agents',    tickvals=[5, 10, 15, 20]),
                        yaxis = dict(title = 'Path',                tickvals=[1, 5, 10, 15, 20]),
                        zaxis = dict(title = 'Time(sec)',           tickvals=[10, 20, 30, 40, 50, 60], range=[0,60],),) 
    fig.update_layout(
        font=dict(size=15)
    )    
    # fig.show()
    fig.write_html("SavedPlots/trisurf/"+cs+"-g5-"+ z3OrQC+ ".html")

    z = medians_g10
    fig = ff.create_trisurf(x=x, y=y, z=z,
                            # colormap="Portland",
                            colormap=getColorMap(max(z)),
                            simplices=simplices,
                            title="Time of test generation",
                            show_colorbar = False,
                            )
    fig.update_scenes(  xaxis = dict(title = 'Number of Agents',    tickvals=[5, 10, 15, 20]),
                        yaxis = dict(title = 'Path',                tickvals=[1, 5, 10, 15, 20]),
                        zaxis = dict(title = 'Time(sec)',           tickvals=[10, 20, 30, 40, 50, 60], range=[0,60],),) 
    # fig.show()
    fig.update_layout(
        font=dict(size=15)
    )
    fig.write_html("SavedPlots/trisurf/"+cs+"-g10-"+ z3OrQC+ ".html")

    z = medians_g15
    fig = ff.create_trisurf(x=x, y=y, z=z,
                            # colormap="Portland",
                            colormap=getColorMap(max(z)),
                            simplices=simplices,
                            title="Time of test generation",
                            show_colorbar = False,
                            )
    fig.update_scenes(  xaxis = dict(title = 'Number of Agents',    tickvals=[5, 10, 15, 20]),
                        yaxis = dict(title = 'Path',                tickvals=[1, 5, 10, 15, 20]),
                        zaxis = dict(title = 'Time(sec)',           tickvals=[10, 20, 30, 40, 50, 60], range=[0,60],),) 
    fig.update_layout(
        font=dict(size=15)
    )
    # fig.show()
    fig.write_html("SavedPlots/trisurf/"+cs+"-g15-"+ z3OrQC+ ".html")


def drawPlotsManual():

    cs = "IN Square 2 Count 8"
    f_z3   = "GenTimes/"+cs+" - Erlang/"
    z3OrQC = "Erlang"
    targetGridSize=15

    gridsArray,agentsArray,dispsArray,medianz3 = getData_Median(f_z3)

    x_axixValues = [10,15,20]
    y_axixValues = [1,5,10,15,20]
    x,y = numpy.meshgrid(x_axixValues,y_axixValues)
    x = x.flatten()
    y = y.flatten() # 2d array to 1d array

    u = list(range(1,len(x_axixValues)+1)) #[1,2,3,4]
    v = list(range(1,len(y_axixValues)+1)) #[1,2,3,4,5]
    u,v = numpy.meshgrid(u,v)
    u = u.flatten()
    v = v.flatten() # 2d array to 1d array

    agents = []
    paths = []
    medians2 = []
    medians = numpy.full(len(x_axixValues)*len(y_axixValues), -1, dtype = int)
    for g in range(0,len(gridsArray)):
        if( gridsArray[g] == targetGridSize):
            agents.append(agentsArray[g])
            ai = (agentsArray[g]//5) -1 # 1,2,3,4
            paths.append(dispsArray[g])
            di = (dispsArray[g]//5) # 0,1,2,3,4
            medians[(di)*len(x_axixValues) + ai-1] = medianz3[g]
            medians2.append(medianz3[g])
    z = medians
    # z[len(z)-1] = 1
    print(z)
    points2D = numpy.vstack([u,v]).T
    tri = Delaunay(points2D)
    simplices = tri.simplices

    fig = ff.create_trisurf(x=x, y=y, z=z,
                            # colormap="Portland",
                            # colormap=["#006FFF", "#0044FF"], #getColorMap(max(z)),
                            colormap = getColorMap(max(z)),
                            simplices=simplices,
                            title=cs,
                            # show_colorbar = True,
                            )
    fig.update_scenes(  xaxis = dict(title = 'Number of Agents', tickvals=x_axixValues),
                        yaxis = dict(title = 'Path',             tickvals=y_axixValues),
                        zaxis = dict(title = 'Time(sec)',        tickvals=[10, 20, 30, 40, 50, 60], range=[0,60],),) 
    fig.update_layout(
        font=dict(size=15),
    )
    # fig.show()
    fig.write_html("SavedPlots/trisurf/"+cs+"-g"+str(targetGridSize)+"-"+ z3OrQC+ ".html")

def getSortedData(method, gridSize,agentsNum, pathlength, cs):
    if method == "z3":
        if ("Intersection" in cs):
            fileName = "GenTimes/z3_intersection.csv"
        else:
            fileName = "GenTimes/z3_count.csv"
    else:
        if ("Intersection" in cs):
            fileName = "GenTimes/erlang_intersection.csv"
        else:
            fileName = "GenTimes/erlang_count.csv"

    if ("3" in cs):
        csValue = 3
    elif("5" in cs):
        csValue = 5
    elif("8" in cs):
        csValue = 8
    else:
        print("wrong cs!")

    data = pd.read_csv(fileName)

    agentsAll=[]
    pathsAll=[]
    mediansAll=[]
    averageAll=[]

    for index in range(0,len(data)):
        if ((data['Constraint'].values[index] == csValue) and
            (data['GridSize'].values[index] == gridSize) and 
            (data['NumberOfAgents'].values[index] in agentsNum) and 
            (data['PathLength'].values[index]     in pathlength)) :
                agentsAll.append(   data['NumberOfAgents'].values[index])
                pathsAll.append(    data['PathLength'].values[index]  )
                mediansAll.append(  data['Time_Median'].values[index] )
                averageAll.append(  data['Time_Average'].values[index])
    
    newData = { 'NumberOfAgents':agentsAll,
                'PathLength':    pathsAll,
                'Time_Median':   mediansAll,
                'Time_Average':  averageAll}

    return pd.DataFrame(newData)


    
def drawDataAutomatiaclly(data,method,cs,gridSize):
    data = data.sort_values(by=['NumberOfAgents', 'PathLength'], ascending=True)

    x = list(set(data['NumberOfAgents']))
    x.sort()
    y = list(set(data['PathLength']))
    y.sort()

    u = list(range(1,len(x)+1)) #[1,2,3,4]
    v = list(range(1,len(y)+1)) #[1,2,3,4,5]
    u,v = numpy.meshgrid(u,v)
    u = u.flatten()
    v = v.flatten() # 2d array to 1d array

    points2D = numpy.vstack([u,v]).T
    tri = Delaunay(points2D)
    simplices = tri.simplices

    data = data.sort_values(by=['PathLength', 'NumberOfAgents'], ascending=True)
    fig = ff.create_trisurf(x=data['NumberOfAgents'], y=data['PathLength'], z=data['Time_Average'],
                            # colormap="Portland",
                            # colormap=["#006FFF", "#0044FF"], #getColorMap(max(z)),
                            colormap = getColorMap(min(data['Time_Average']), max(data['Time_Average'])),
                            simplices=simplices,
                            title=cs,
                            # show_colorbar = True,
                            )

    fig.update_scenes(  xaxis = dict(title = '<b>Number of Agents</b>', tickvals=x ),
                        yaxis = dict(title = '<b>Path Length</b>',      tickvals=y ),
                        zaxis = dict(title = '<b>Time(sec)</b>',        tickvals=[10, 20, 30, 40, 50, 60], range=[0,60],),) 
    fig.update_layout(
        font=dict(size=20),
        width = 1200,
        height = 1400
    )
    fig.update_yaxes(tickfont_family="Arial Black")
    # fig.show()
    fig.write_html("SavedPlots/trisurf/"+cs+"-g"+str(gridSize)+"-"+ method+ ".html")


def drawCloseToMinMaxPlot(data,method,cs,gridSize, isZero):
    data = data.sort_values(by=['NumberOfAgents', 'PathLength'], ascending=True)

    x = list(set(data['NumberOfAgents']))
    x.sort()
    y = list(set(data['PathLength']))
    y.sort()

    u = list(range(1,len(x)+1)) #[1,2,3,4]
    v = list(range(1,len(y)+1)) #[1,2,3,4,5]
    u,v = numpy.meshgrid(u,v)
    u = u.flatten()
    v = v.flatten() # 2d array to 1d array

    points2D = numpy.vstack([u,v]).T
    tri = Delaunay(points2D)
    simplices = tri.simplices

    data = data.sort_values(by=['PathLength', 'NumberOfAgents'], ascending=True)
    # fig = ff.create_trisurf(x=data['NumberOfAgents'], y=data['PathLength'], z=data['Time_Median'],
    fig = ff.create_trisurf(x=data['NumberOfAgents'], y=data['PathLength'], z=data['Time_Average'],
                            # colormap="Portland",
                            colormap=["#006FFF", "#0044FF"], #getColorMap(max(z)),
                            # colormap = getColorMap(max(data['Time_Median'])),
                            simplices=simplices,
                            title=cs,
                            # show_colorbar = True,
                            )

    fig.update_scenes(  xaxis = dict(title = '<b>Number of Agents</b>', tickvals=x ),
                        yaxis = dict(title = '<b>Path Length</b>',      tickvals=y ),
                        zaxis = dict(title = '<b>Time(sec)</b>',        tickvals=[10, 20, 30, 40, 50, 60], range=[0,60],),) 
    fig.update_layout(
        font=dict(size=20),
        width = 1200,
        height = 1400
    )
    fig.update_yaxes(tickfont_family="Arial Black")
    # fig.show()
    fig.write_html("SavedPlots/trisurf/"+cs+"-g"+str(gridSize)+"-"+ method+ ".html")

if __name__ == "__main__":
    methods = ["z3", "erlang"]
    # gridSizes = [5,10,15,20,50,100]
    gridSizes = [10,15,20,50]
    pathlengths = [1,5,10,15,20]

    csList =[]
    csList.append("IN Square 1 Intersection 1 3")
    csList.append("IN Square 1 Intersection 1 5")
    csList.append("IN Square 1 Intersection 1 8")
    csList.append("IN Square 2 Count 3")
    csList.append("IN Square 2 Count 5")
    csList.append("IN Square 2 Count 8")


    for method in methods:
        for cs in csList:
            for gridSize in gridSizes:
                if (cs =="IN Square 2 Count 8") or (cs =="IN Square 1 Intersection 1 8"):
                    agentsNums = [10,15,20]
                else:
                    # agentsNums = [5,10,15,20]
                    agentsNums = [10,15,20]
                data = getSortedData(method,gridSize,agentsNums,pathlengths,cs)
                # print("data")
                # print(data['Time_Average'])
                #check if all data is zero - trisurf cannot be drawn by the library for the all the same or very close values
                # if( max(data['Time_Median']) < min(data['Time_Median'])+2):
                #     data.at[0,'Time_Median']= min(data['Time_Median'])+1

                if( max(data['Time_Average']) == min(data['Time_Average']) ):
                    print("The plot of {0:s},{1:s}, grid={2:d} needs modification.".format(method,cs,gridSize))
                    if max(data['Time_Average']) == 0:
                        data.at[0,'Time_Average'] = 1
                        # drawCloseToMinMaxPlot(data,method,cs,gridSize,True)
                    else:
                        data.at[0,'Time_Average'] = data.at[0,'Time_Average'] -1
                        # drawCloseToMinMaxPlot(data,method,cs,gridSize,False)
                    drawDataAutomatiaclly(data,method,cs,gridSize)
                    # print("data")
                    # print(data['Time_Median'])
                    
                    # drawCloseToMinMaxPlot(data,method,cs,gridSize)   # they need to be fixed by MS Paint

                else:
                    drawDataAutomatiaclly(data,method,cs,gridSize)
    
    