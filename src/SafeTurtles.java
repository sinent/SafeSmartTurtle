import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Random;
import java.util.Scanner;
import java.io.File;  // Import the File class
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.nio.file.Files;
import java.nio.file.Path;

public class SafeTurtles {
	
	public ArrayList<Turtle> turtles ;
	public Position gridSize;  // indexes of grid: 0,1,2,...,(gridSize-1)
	
	enum movementAction {up, down, right, left, nop}
	
	public SafeTurtles(ArrayList<Turtle>  turtles, Position gridSize) {
		this.turtles = turtles;
		this.gridSize = gridSize;
	}
	
	public SafeTurtles(String fileName) {
		SafeTurtles st = readSUTInput(fileName);
		this.turtles = st.turtles;
		this.gridSize = st.gridSize;
	}
	
	@Override
	public boolean equals(Object obj) {
		if(obj instanceof SafeTurtles) {
			SafeTurtles safeTurtles = (SafeTurtles) obj;
			if(!this.gridSize.equals(safeTurtles.gridSize))
				return false;
			if(this.turtles.size()!=safeTurtles.turtles.size())
				return false;
			for(int tIndex=0;tIndex<this.turtles.size();tIndex++) {
				if(!this.turtles.get(tIndex).equals(safeTurtles.turtles.get(tIndex)))
					return false;
			}
			return true;
		}
		return false;
	}
	
	public static movementAction getNextMove(Position current, Position next) {
		if(next.x == current.x && next.y ==current.y)
			return movementAction.nop;
		if(next.x == current.x && next.y ==current.y +1)
			return movementAction.up;
		if(next.x == current.x && next.y ==current.y -1)
			return movementAction.down;
		if(next.x == current.x-1 && next.y ==current.y)
			return movementAction.left;
		if(next.x == current.x+1 && next.y ==current.y)
			return movementAction.right;
		System.out.println("Error: impossible turtle move!");
		return null;
	}
	
	public static Position getNextPosition(Position current, movementAction move ) {
		Position nextPosition = switch (move) {
			case nop: 	yield new Position(current.x, current.y);
			case up: 	yield new Position(current.x, current.y+1);
			case down: 	yield new Position(current.x, current.y-1);
			case right: yield new Position(current.x+1, current.y);
			case left: 	yield new Position(current.x-1, current.y);	
			default:	throw new IllegalArgumentException("Unexpected value: " + move);
		};
		return nextPosition;
	}
	
	public ArrayList<ArrayList<Position>> runTurtles(){	
		while( !completeMission()) { // check there is still any turtle not finished its journey
			// Getting the current positions
			ArrayList<Position> currentPositions = new ArrayList<Position>(
					turtles.stream()
	 					.map(turtle-> turtle.currentPosition)
	 					.toList()
	 				);
			
			// There are turtles with different priority
			// The one with smaller index has higher priority
			// A turtle with a higher priority has priority to plan to move to an free position
			ArrayList<Position> higherPriorityNextPlans = new ArrayList<Position>();
			
			for(int i=0;i<turtles.size();i++) {
				
//				double faultPossibility = 0.01;
//				boolean injectedFault1 = new Random().nextDouble()<faultPossibility ? true: false;
//				boolean injectedFault2 = new Random().nextDouble()<faultPossibility ? true: false;
//				boolean injectedFault3 = new Random().nextDouble()<faultPossibility ? true: false;
				boolean injectedFault1 = false;
				boolean injectedFault2 = false;
				boolean injectedFault3 = false;
				int faultNum ; new Random().nextInt(4);	
				
				if(turtles.get(i).stepsFault.size()!=0) {
					int nextFault = turtles.get(i).stepsFault.remove(0);
					faultNum = nextFault;
					turtles.get(i).stepsFault.add(faultNum);			
				}				
				else
					faultNum = new Random().nextInt(4);	
				
				switch(faultNum) {
					case 0: break; // no fault in this case
					case 1: injectedFault1=true;break;
					case 2: injectedFault2=true;break;
					case 3: injectedFault3=true;break;
					default: System.out.println("Wrong fault number!");	
			}
						
//				boolean injectedFault1 = i==0 ? true: false;
//				boolean injectedFault2 = i==1 ? true: false;
//				boolean injectedFault3 = i==2 ? true: false;
				
				
				if(turtles.get(i).completedMission())
					continue;
				
				ArrayList<Position> otherCurrentPositions = new ArrayList<Position>(currentPositions);
				otherCurrentPositions.remove(i);
				
				Position currentPos = turtles.get(i).currentPosition;
				Position nextPos = turtles.get(i).getNext(); 
				
				if(injectedFault1 && turtles.get(i).enteredGrid()) { 
					// the turtle thinks it will reach the planned position in the next move, 
					// but it will reach another one due to the fault
					ArrayList<Position> adjPoints = getAdjacentPoints(currentPos);
					Position believedCurrentPos = adjPoints.get(new Random().nextInt(adjPoints.size()));
					movementAction nextPlannedMove = getNextMove(currentPos, nextPos);
					Position believedNextPos = getNextPosition(believedCurrentPos, nextPlannedMove); 
					if(!believedNextPos.inGrid(gridSize))
						believedNextPos = new Position(believedCurrentPos);
					
					currentPos = believedCurrentPos;
					nextPos = believedNextPos;
				}				
				// if the next planned position is not safe for the turtle
				if(otherCurrentPositions.contains(nextPos) || higherPriorityNextPlans.contains(nextPos)) {
					
//					if(injectedFault2 || injectedFault3) 
//						// the turtle does not react to the dangers in the next move due to the fault
//						continue;
					
					//if the turtle has not still on the board
					if(!turtles.get(i).enteredGrid()) {
						turtles.get(i).plannedNextMoves.add(0, currentPos);
						continue;
					}
					
					// Considering the current position, which is safe, and the other safe adjacent positions
					// choosing one of those safe positions RANDOMLY to move in the next step
					// if an adjacent position is chosen, the plan to the final goal should be regenerated
					// safe adjacent point: not currently occupied, not planned to visit by higher priority turtles
					// if (ii) is not possible, the agent just waits in its current position
					
					ArrayList<Position> safePositions = new ArrayList<Position>();
					safePositions.add(currentPos);
					
//					System.out.println("adjacent points of turtle "+i+ " :"+ getAdjacentPoints(currentPos));
					for(Position p: getAdjacentPoints(currentPos)) 
						if( (!otherCurrentPositions.contains(p) && !injectedFault2) ||
							(!higherPriorityNextPlans.contains(p) && !injectedFault3) )
							safePositions.add(p);
					
					
					
//					System.out.println("safe positions for turtle "+i+ " :"+ safePositions);
					
					int randomMove = (new Random()).nextInt(safePositions.size());
					
					movementAction nextMove = getNextMove(currentPos, safePositions.get(randomMove));
					if(nextMove == movementAction.nop)
						turtles.get(i).plannedNextMoves.add(0, turtles.get(i).currentPosition);
					else {
						Position nextPosToMove = getNextPosition(turtles.get(i).currentPosition, nextMove);
						if(!nextPosToMove.inGrid(gridSize)) 
							turtles.get(i).plannedNextMoves.add(0, turtles.get(i).currentPosition);
						else {
							turtles.get(i).replan(nextPosToMove, turtles.get(i).getGoal());
						}
					}
					
					
//					if(safePositions.get(randomMove).equals(currentPos)) {// choosing to stay in the current position
////						System.out.println("turtle "+i+" has planned to stay in its current position:"+currentPos);
//						turtles.get(i).plannedNextMoves.add(0, currentPos);
//					}
//					else {// choosing to move to an adjacent safe position
////						System.out.println("turtle "+i+" has planned to move to:"+ safePositions.get(randomMove));
//						turtles.get(i).replan(safePositions.get(randomMove), turtles.get(i).getGoal());
//					}
				}
				// else: do nothing,i.e., the next plan will be followed with no change
		
				higherPriorityNextPlans.add(turtles.get(i).getNext());			
			}
			
			for(Turtle turtle: turtles)
				turtle.moveNext();
			
//			for(Turtle t:turtles) {
//				System.out.println(t.executedMoves+"->"+t.plannedNextMoves);
//			}	
//			System.out.println();
//		
//			ArrayList<ArrayList<Position>> ap = new ArrayList<ArrayList<Position>>();
//			for(Turtle t:turtles)
//				ap.add(t.executedMoves);
//			if(hasCollision(ap)){
//				System.exit(0);
//			}
					
			if(turtles.get(0).executedMoves.size()>100) {
				System.out.println("Possibility of deadlock.");
				System.out.println("....");
				break;
			}
		}
		
		// returning all executed moves by all turtles 
		List<ArrayList<Position>> executedMovesAll = turtles.stream()
				.map(turtle->turtle.executedMoves)
				.toList();
		return new ArrayList<ArrayList<Position>>(executedMovesAll);	
	}

	private ArrayList<Position> getAdjacentPoints(Position p){
		ArrayList<Position> ans = new ArrayList<Position>();
		
		if(p.x-1>=0)
			ans.add(new Position(p.x-1, p.y));
		if(p.x+1<gridSize.x)
			ans.add(new Position(p.x+1, p.y));
		if(p.y-1>=0)
			ans.add(new Position(p.x, p.y-1));
		if(p.y+1<gridSize.y)
			ans.add(new Position(p.x, p.y+1));
		return ans;
		
	}
	
	public boolean completeMission() {
		for (Turtle turtle : turtles)
			if(!turtle.completedMission())
				return false;
		return true;
	}
	
	public static boolean hasCollision(ArrayList<ArrayList<Position>> executedMoves) {
		
		for(int time=0;time<executedMoves.get(0).size();time++) {
			
			ArrayList<Position> positionsAtSameTime = new ArrayList<>();
			for(int turtleNum=0;turtleNum<executedMoves.size();turtleNum++) {
				
				Position p = executedMoves.get(turtleNum).get(time);
				if(positionsAtSameTime.contains(p)) {
					System.out.println("Collision at step: " +time+ " , position:"+p);
					return true;
				}
				else
					positionsAtSameTime.add(p);
			}
		}
		return false;
	}
	
	public static void testSafeTurtles() {
		Position grid  = new Position(10, 10);
		int numOfTests = 100000;
		int turtleNumsInGrid = 5;
		int wSteps = 5;
		int dSteps = 5;
		
		for (int testNum = 0; testNum <numOfTests; testNum++) {
			System.out.println("----- Runnint test: "+testNum+ " ------");
			
			ArrayList<Turtle> turtlesList = new ArrayList<Turtle>();
			for(int turtleNum=1;turtleNum<=turtleNumsInGrid;turtleNum++) 
				turtlesList.add( new Turtle(turtleNum, grid, wSteps, dSteps));
			
			SafeTurtles safeTurtles = new SafeTurtles(turtlesList,grid);
			ArrayList<ArrayList<Position>> executedPaths = safeTurtles.runTurtles();
			
			if(hasCollision(executedPaths)) {
				System.out.println("Test Failed: a collision has happended by turtles.");
				for(ArrayList<Position> path:executedPaths) 
					System.out.println(path);
				return;
			}
				
			System.out.println("Test "+ testNum+ " is finished successfully.");
		}		
	}
	
	private SafeTurtles readSUTInput(String fileName){
//		System.out.println("reading the file: "+ fileName);
		Position newGridSize = null;
		ArrayList<Turtle> newTurtles = new ArrayList<Turtle>();
		
		try {
			File myFile = new File(fileName);
			Scanner myReader = new Scanner(myFile);

			if (myReader.hasNext()) {
				// the first line declares grid size: in the form of 'Grid Size: (X,Y)'
				String XY = myReader.nextLine().split(":")[1].replace("(", "").replace(")", "");
				int gridX = Integer.parseInt(XY.strip().split(",")[0]);
				int gridY = Integer.parseInt(XY.strip().split(",")[1]);
				newGridSize = new Position(gridX, gridY);
			}

			while (myReader.hasNextLine()) {
				String data = myReader.nextLine();
				if (data.replaceAll("\\s+", "").isEmpty())
					break;
				int id = Integer.parseInt(data.split("-")[0].split(":")[1].strip());

				String start = data.split("-")[1].split(":")[1].replace("(", "").replace(")", "");
				int startX = Integer.parseInt(start.split(",")[0].strip());
				int startY = Integer.parseInt(start.split(",")[1].strip());
				Position startPosition = new Position(startX, startY);

				String[] moves = data.split("-")[2].split(":")[1].strip().split(",");
				ArrayList<movementAction> turtleMoves = new ArrayList<>();
				for (String move : moves) {
					movementAction turtleMove = switch (move) {
					case "up":
						yield movementAction.up;
					case "down":
						yield movementAction.down;
					case "left":
						yield movementAction.left;
					case "right":
						yield movementAction.right;
					case "nop":
						yield movementAction.nop;
					default:
						throw new IllegalArgumentException("Unexpected value: " + move);
					};
					turtleMoves.add(turtleMove);
				}
				
				String[] faultsStr = data.split("-")[3].split(":")[1].strip().split(",");
				ArrayList<Integer> faultsInt = new ArrayList<>();
				for (String str:faultsStr)
					faultsInt.add(Integer.parseInt(str));
					
				Turtle newTurtle = new Turtle(id, newGridSize, startPosition, turtleMoves, faultsInt);
				newTurtles.add(newTurtle);
			}
			myReader.close();
		} catch (FileNotFoundException e) {
			System.out.println("An error occurred.");
			e.printStackTrace();
		}
		
		return new SafeTurtles(newTurtles, newGridSize);	
	}
	
	public static boolean haveTheSameStartsAndFaults(SafeTurtles st1, SafeTurtles st2) {
		
		if(st1.turtles.size()!=st2.turtles.size())
			return false;
		for(int tIndex=0; tIndex<st1.turtles.size();tIndex++) {
//			if(!st1.turtles.get(tIndex).getStart().equals(st2.turtles.get(tIndex).getStart()))
//				return false;			
			if(!st1.turtles.get(tIndex).stepsFault.equals(st2.turtles.get(tIndex).stepsFault))
				return false;
		}
		
		return true;		
	}
	
	public static void runServer() {

		int receivePort =1234;
		int sendPort = 6789;
		
		DatagramSocket receiveSocket = null;
		DatagramSocket sendSocket = null;
		
		final String executionFolderName = "SUT inp-out log - ordered";
		File reportDirectory = new File(executionFolderName);
	
		if(reportDirectory.exists()) {	
			//cleaning the folder
			try {
				Files.walk(reportDirectory.toPath())
				.sorted(Comparator.reverseOrder())
				.map(Path::toFile)
				.forEach(File::delete);
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
//		else 
		reportDirectory.mkdir();
		
		final String inputsFolderName 	 = executionFolderName+File.separator+"inputs";
		final String outputsFolderName 	 = executionFolderName+File.separator+"outputs";
		File inputsDirectory = new File(inputsFolderName);
		File outputsDirectory = new File(outputsFolderName);
		inputsDirectory.mkdir();
		outputsDirectory.mkdir();
		
		String runReport = executionFolderName+File.separator+"All pass-fails.txt";
		
		try {
			FileWriter myWriter = new FileWriter(runReport, true); 
			
			System.out.println("Starting SUT Server..");
			receiveSocket = new DatagramSocket(receivePort);
			byte[] buf = new byte[1024];	
			
			int runCounter=1;
			while(true) {
				DatagramPacket receivingPacket= new DatagramPacket(buf, 1024);
				receiveSocket.receive(receivingPacket);
				String receivedFileName = new String(receivingPacket.getData(), 0, receivingPacket.getLength());
				
				SafeTurtles safeTurtles = new SafeTurtles(receivedFileName);
				ArrayList<ArrayList<Position>> executedPaths = safeTurtles.runTurtles();
				
				if(hasCollision(executedPaths)) {
					System.out.println("SUT run "+ runCounter+ " is finished. --> Collision");
					myWriter.write("SUT run "+ runCounter+ " is finished. --> Collision\n");
					myWriter.flush();
				}
				else {
					System.out.println("SUT run "+ runCounter+ " is finished. --> Safe");
					myWriter.write("SUT run "+ runCounter+ " is finished. --> Safe\n");
					myWriter.flush();
				}
				String savingInpFileName = 	inputsFolderName+ File.separator + "Run " + runCounter;
				File savingInpFile = new File(savingInpFileName);

				Files.copy(new File(receivedFileName).toPath(),savingInpFile.toPath());
				
				String outputFileName = outputsFolderName+ File.separator + "Run " +runCounter;
				saveTestSUTReport(outputFileName,executedPaths);
				
				runCounter++;

				String testReport = hasCollision(executedPaths) ? "Fail": "Pass";
				InetAddress ia = receivingPacket.getAddress();
				DatagramPacket sendingPacket= new DatagramPacket(testReport.getBytes(), testReport.length(), 
						ia, sendPort);
				receiveSocket.send(sendingPacket);	
			}
		} 
		catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally {
			if(receiveSocket!= null)
				receiveSocket.close();
		}
	}

	public static void reformatInputsOutputs() throws IOException {
		// it is not working since the noshrink() function of QuickCheck is not working as we expected
		// QuickCheck still shrinks the generator for a few steps after reaching a failure
		// the next approach is to use the test report to find out which runs are for shrinking and which ones
		// are for shrinking --> reformatInputsOutputs1()
		String[] testFilters = new String[]{"NoFilter","F1","F2","F3"};
		String qcExpTestReportFolder = "exp1-SUT3"+File.separator+"G-20-A-5-W-5-D-5-R-100-GenD--SUT-randFilterOrCorrect";
		int faultDetectionNum = 100;
		
		String inpFolder	= "SUT inp-out log - ordered"+File.separator+"inputs";
		String outFolder	= "SUT inp-out log - ordered"+File.separator+"outputs";		
		String resultFolder	= "SUT inp-out log - formatted";  // the saved SUT input/outputs, not formatted ones

		if((new File(resultFolder)).exists()) {	
			//cleaning the folder
			try {
				System.out.println("Cleaning the folder..");
				Files.walk(new File(resultFolder).toPath())
					.sorted(Comparator.reverseOrder())
					.map(Path::toFile)
					.forEach(File::delete);
					System.out.println("Cleaning is done.");
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}

		int runIndex = 1;
		for(String testFilter: testFilters) {	
			
			File stepsFile = new File(resultFolder +File.separator+testFilter+File.separator+"Fault Detection Steps.txt");
			stepsFile.getParentFile().mkdirs();
			stepsFile.createNewFile();		
			FileWriter stepsWriter = new FileWriter(stepsFile.toString(),true);
			
			for (int faultIndex=1; faultIndex<=faultDetectionNum; faultIndex++) {
				
				SafeTurtles safeTurtlesCanditate = new SafeTurtles(inpFolder+File.separator+"Run "+ runIndex);
				SafeTurtles safeTurtlesNext 	 = new SafeTurtles(inpFolder+File.separator+"Run "+ (runIndex+1));
											
				String faultFolder = resultFolder+File.separator+testFilter+File.separator+"Fault Detection"+File.separator+"Fault "+ faultIndex;
				File faultDetectionInputs  = new File(faultFolder +File.separator+ "Fault Detection Process"+File.separator+ "Inps.txt");
				File faultDetectionOutputs = new File(faultFolder +File.separator+ "Fault Detection Process"+File.separator+ "Outs.txt");	
				faultDetectionInputs.getParentFile().mkdirs();
				faultDetectionInputs.createNewFile();
				faultDetectionOutputs.createNewFile();
				
				int counterFD=1;
				int totalSteps = 0; // the total number of steps (time unit) up to detection the fault
				while(!haveTheSameStartsAndFaults(safeTurtlesCanditate, safeTurtlesNext)) { // the fault has not revealed yet

					copyFile("Detection Run "+counterFD,inpFolder+File.separator+"Run "+ runIndex, faultDetectionInputs.toString());
					copyFile("Detection Run "+counterFD,outFolder+File.separator+"Run "+ runIndex, faultDetectionOutputs.toString());     
					
					totalSteps+=getExecutedSteps(outFolder+File.separator+"Run "+ runIndex);			
					counterFD++;
					runIndex++;
					
					safeTurtlesCanditate = safeTurtlesNext;
					safeTurtlesNext 	 = new SafeTurtles(inpFolder+File.separator+"Run "+ (runIndex+1));
					
				}			
				// the fault is revealed
				copyFile("Fault Detection Run "+counterFD,inpFolder+File.separator+"Run "+ runIndex, faultDetectionInputs.toString());
				copyFile("Fault Detection Run "+counterFD,outFolder+File.separator+"Run "+ runIndex, faultDetectionOutputs.toString());     
				
				totalSteps+=getExecutedSteps(outFolder+File.separator+"Run "+ runIndex);		
				//counterFD++;
				runIndex++;
				
				safeTurtlesCanditate = safeTurtlesNext;
				safeTurtlesNext 	 = new SafeTurtles(inpFolder+File.separator+"Run "+ (runIndex+1));		
				
				stepsWriter.write(totalSteps+"\n");
				
				// Starting the shrinking process
				
				File shrinkInputs  = new File(faultFolder +File.separator+ "Shrinking Process"+File.separator+ "Inps.txt");
				File shrinkOutputs = new File(faultFolder +File.separator+ "Shrinking Process"+File.separator+ "Outs.txt");		
				shrinkInputs.getParentFile().mkdirs();
				shrinkInputs.createNewFile();
				shrinkOutputs.createNewFile();
				
				int counterShrink=1;
				while(haveTheSameStartsAndFaults(safeTurtlesCanditate, safeTurtlesNext)) {
					copyFile("Shrinking Run "+counterShrink,inpFolder+File.separator+"Run "+ runIndex, shrinkInputs.toString());
					copyFile("Shrinking Run "+counterShrink,outFolder+File.separator+"Run "+ runIndex, shrinkOutputs.toString());     

					counterShrink++;
					runIndex++;
					if( !((new File(outFolder+File.separator+"Run "+ (runIndex+1))).exists()) )
						break;
										
					safeTurtlesCanditate = safeTurtlesNext;
					safeTurtlesNext 	 = new SafeTurtles(inpFolder+File.separator+"Run "+ (runIndex+1));			
				}
				// the last shrink file
				copyFile("Shrink Run "+counterShrink,inpFolder+File.separator+"Run "+ runIndex, shrinkInputs.toString());
				copyFile("Shrink Run "+counterShrink,outFolder+File.separator+"Run "+ runIndex, shrinkOutputs.toString()); 
				runIndex++; 
			}
			stepsWriter.close();
		}

		//copying steping files to the qc experiment report files
		// System.out.println("Copying files is starting..");
		// for(String testFilter: testFilters) {	
		// 	File file1 = new File(resultFolder +File.separator+testFilter+File.separator+"Fault Detection Steps.txt"); 
		// 	File file2 = new File(qcExpTestReportFolder +File.separator+testFilter+File.separator+"Fault Detection Steps.txt"); 			
		// 	Files.copy(file1.toPath(), file2.toPath());
		// }
		// System.out.println("Copying is done.");

	}
	
	public static ArrayList<Integer> getTestExecutions(String fileName) throws IOException{
		File file = new File(fileName);
		List<String> lines = Files.readAllLines(file.toPath());
//		lines.remove(0);  // the first line of the file includes grid information
		ArrayList<Integer> ans = new ArrayList<>(lines.stream()
				.filter(line->line.split("\\s+").length>2)
				.map(line->Integer.parseInt(line.split("\\s+")[2].strip())).toList());
		// the data is saved in the file in a reverse way
		Collections.reverse(ans);
		return ans;
		
	}
	
	public static void reformatInputsOutputs1() throws Exception {
		
		/*
		 * Implementation Challenges:
		 * 1)QuickCheck returns the number of test executions before the failed test case.
		 * 2)noshrink() 'helps' a lot in avoiding to shrink a generator values but it is not guaranteed
		 * 3)When a test is failed in the first try, QuickCheck does not return '0' as 
		 * the number of test executions before failure. It returns '1' instead.
		 * 4) I faced that QC generator commands are not deterministic. The value
		 * that the generators provide can be completed by time. 
		 * For example the part: "?LET(XXX, Wiggling,lists:append(XXX))" that we used in our generator
		 */
		
		String expFolder 	="exp1-SUT3"+File.separator+"G-10-A-5-W-5-D-5-R-100-GenD--SUT-randFilterOrCorrect";
		
		String inpFolder	= expFolder+File.separator+"RunSUTReport"+File.separator+"inputs";
		String outFolder	= expFolder+File.separator+"RunSUTReport"+File.separator+"outputs";		
		String resultFolder	= expFolder+File.separator+"FormattedResults";

		File rfFile = new File(resultFolder);

		if(rfFile.exists()) {	
			//cleaning the folder
			try {
				System.out.println("Cleaning..");
				Files.walk(rfFile.toPath())
					.sorted(Comparator.reverseOrder())
					.map(Path::toFile)
					.forEach(File::delete);
					System.out.println("Cleaning is done.");
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
		
		String[] filterFolders = new String[] {"NoFilter", "F1", "F2", "F3"};			
		int runIndex = 1;
		
		for(String filter:filterFolders) {
			ArrayList<Integer> testNums 		= getTestExecutions(expFolder+File.separator+filter+File.separator+"Raw"+File.separator+"TestsNum.txt");
			ArrayList<Integer> succShrinkNums   = getTestExecutions(expFolder+File.separator+filter+File.separator+"Raw"+File.separator+"ShrinkSteps.txt");
			ArrayList<Integer> failedShrinkNums = getTestExecutions(expFolder+File.separator+filter+File.separator+"Raw"+File.separator+"FailedShrinkSteps.txt");
			
			File stepsFile = new File(resultFolder +File.separator+filter+File.separator+"ExecutedStepsTillCollision");
			stepsFile.getParentFile().mkdirs();
			stepsFile.createNewFile();
			FileWriter stepsWriter = new FileWriter(stepsFile.toString(),true);
			
			for(int faultNum=0;faultNum<testNums.size();faultNum++) {
				
				int totalSteps = 0; // the total number of steps (time unit) up to detection the fault
				
				String faultFolderNew = resultFolder+File.separator+filter+File.separator+"Fault "+ (faultNum+1);
				
				// Fault detection process
				int numOfTestRuns;
				// QuickCheck returns the number of test executions before reaching a failure
				// Logically, if the failure is reached in the first try, QuickCheck should report '0' as this number
				// However, when the test fails in the first try, it reports '1' as this number
				
				if(testNums.get(faultNum)==1) {
					SafeTurtles safeTurtlesCanditate = new SafeTurtles(inpFolder+File.separator+"Run "+ runIndex);
					SafeTurtles safeTurtlesNext 	 = new SafeTurtles(inpFolder+File.separator+"Run "+ (runIndex+1));
					if(haveTheSameStartsAndFaults(safeTurtlesCanditate, safeTurtlesNext))
						numOfTestRuns = 1;
					else
						numOfTestRuns = 2;
				}
				else
					numOfTestRuns = testNums.get(faultNum)+1;
				
				
				for(int i=1;i<=numOfTestRuns;i++,runIndex++) { 				

					File faultDetectionInputs  = new File(faultFolderNew +File.separator+ "FaultDetection"+File.separator+ "Inps.txt");
					File faultDetectionOutputs = new File(faultFolderNew +File.separator+ "FaultDetection"+File.separator+ "Outs.txt");	
					faultDetectionInputs.getParentFile().mkdirs();
					faultDetectionInputs.createNewFile();
					faultDetectionOutputs.createNewFile();

					copyFile("Detection Run "+i+", "+runIndex,inpFolder+File.separator+"Run "+ runIndex, faultDetectionInputs.toString());
					copyFile("Detection Run "+i+", "+runIndex,outFolder+File.separator+"Run "+ runIndex, faultDetectionOutputs.toString()); 
					
					totalSteps+=getExecutedSteps(outFolder+File.separator+"Run "+ runIndex);	
					
					boolean collision = getHasCollision(outFolder+File.separator+"Run "+ runIndex);
					if(i<numOfTestRuns && collision) {
						System.out.println("Error: run more than needed in filter "+ filter+ ", fault "+ (faultNum+1));
					}
				}				
				stepsWriter.write(totalSteps+"\n");

				SafeTurtles previousST   = new SafeTurtles(inpFolder+File.separator+"Run "+ (runIndex-1));
				SafeTurtles currentST 	 = new SafeTurtles(inpFolder+File.separator+"Run "+ runIndex);
				if(!haveTheSameStartsAndFaults(previousST, currentST))
					System.out.println("Error: not shrinking the last test in filter "+ filter+", fault "+ (faultNum+1));

							
				//shrinking process
				for(int i=1;i<=succShrinkNums.get(faultNum)+failedShrinkNums.get(faultNum);i++,runIndex++) {
					File shrinkInputs  = new File(faultFolderNew +File.separator+ "Shrink"+File.separator+ "Inps.txt");
					File shrinkOutputs = new File(faultFolderNew +File.separator+ "Shrink"+File.separator+ "Outs.txt");		
					shrinkInputs.getParentFile().mkdirs();
					shrinkInputs.createNewFile();
					shrinkOutputs.createNewFile();
					
					copyFile("Shrink Run "+i+", "+runIndex,inpFolder+File.separator+"Run "+ runIndex, shrinkInputs.toString());
					copyFile("Shrink Run "+i+", "+runIndex,outFolder+File.separator+"Run "+ runIndex, shrinkOutputs.toString()); 

					// previousST   = new SafeTurtles(inpFolder+File.separator+"Run "+ (runIndex-1));
					// currentST 	 = new SafeTurtles(inpFolder+File.separator+"Run "+ runIndex);
					// if(!haveTheSameStartsAndFaults(previousST, currentST))
					// 	throw new Exception("Error in filter: "+ filter+", fault:"+ faultNum+ " inside shrinking." );
				}

				File currentFile = new File(inpFolder+File.separator+"Run "+ runIndex);
				if(currentFile.exists()){
					previousST   = new SafeTurtles(inpFolder+File.separator+"Run "+ (runIndex-1));
					currentST 	 = new SafeTurtles(inpFolder+File.separator+"Run "+ runIndex);
					if(haveTheSameStartsAndFaults(previousST, currentST))
						System.out.println("Error in copying all shrink files in filter "+ filter+", fault "+ (faultNum+1) );
				}			
			}
			
			stepsWriter.close();
		}
		
		File notExistingRunFile = new File(inpFolder+File.separator+"Run "+ runIndex);
		if(notExistingRunFile.exists())
			throw new Exception("An Error Occured in reformatting input/outputs.");
		
	}
	
	private static int getExecutedSteps(String fileName) throws IOException {
		File myFile = new File(fileName);
		Scanner myReader = new Scanner(myFile);

		int numberOfSteps = -1;
		if (myReader.hasNextLine()) {
			String data = myReader.nextLine();
			if(data.startsWith("#Info#")) {
				numberOfSteps = Integer.parseInt( data.split(",")[0].split(":")[1].strip() );
			}			
		}
		// TODO Auto-generated method stub
		myReader.close();
		return numberOfSteps;
	}

	private static Boolean getHasCollision(String fileName) throws IOException {
		File myFile = new File(fileName);
		Scanner myReader = new Scanner(myFile);

		Boolean collision = null ;
		if (myReader.hasNextLine()) {
			String data = myReader.nextLine();
			if(data.startsWith("#Info#")) {
				myReader.close();
				return (Boolean.parseBoolean( data.split(",")[1].split(":")[1].strip() ));
			}			
		}
		// TODO Auto-generated method stub
		myReader.close();
		return collision;
	}

	public static void copyFile(String title, String sourceFile, String destinationFile) throws IOException {
		FileWriter myWriter = new FileWriter(destinationFile,true);
		
		myWriter.write(title+"\n");
		for (String line: Files.readAllLines(new File(sourceFile).toPath()))
			myWriter.write(line+"\n");
		
		myWriter.write("\n");
		myWriter.close();
	}
	
	public static void saveTestSUTReport(String fileName, ArrayList<ArrayList<Position>> executedPaths) {
		
		boolean collisionFound = false;
		int time;
		
		for(time=1;time<executedPaths.get(0).size();time++) {		
			ArrayList<Position> positionsAtSameTime = new ArrayList<>();
			for(int turtleNum=0;turtleNum<executedPaths.size();turtleNum++) {
				
				Position p = executedPaths.get(turtleNum).get(time);
				if(positionsAtSameTime.contains(p)) {
					collisionFound = true;
					break;
				}
				else
					positionsAtSameTime.add(p);
			}
			if(collisionFound)
				break;
		}
		if(!collisionFound) // time is incremented by naturally exiting the loop
			time--;
		
	    try {
	        FileWriter myWriter = new FileWriter(fileName);
	        
	        myWriter.write("#Info# Executed steps before collision: "+ time+ ", Found collision: "+ collisionFound+ "\n");
	        
	        for(int turtleNum=1;turtleNum<=executedPaths.size();turtleNum++) {
	        	myWriter.write("Turtle "+turtleNum+ " :"+ executedPaths.get(turtleNum-1)+"\n");
	        }
	        myWriter.close();
//	        System.out.println("Successfully wrote to the file.");
	      } catch (IOException e) {
	        System.out.println("An error occurred.");
	        e.printStackTrace();
	      }	
	}
	
	public static void main(String[] args) {
		
		try {
			System.out.println("Starting to reformat input/output..");
			reformatInputsOutputs();
			System.out.println("Reformatting is done.");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		// runServer();
		
//		SafeTurtles safeTurtles = new SafeTurtles("SUT_input.txt");
//		ArrayList<ArrayList<Position>> executedPaths = safeTurtles.runTurtles();
//		
//		if(hasCollision(executedPaths)) {
//			System.out.println("Test Failed: a collision has happended by turtles.");
//			for(ArrayList<Position> path:executedPaths) 
//				System.out.println(path);
//		}
//		else
//			System.out.println("Test is passed successfully.");
//		testSafeTurtles();
	}

}

class Turtle{
	
	private boolean missionCompleted = false;
	public int number;
	public ArrayList<Integer> stepsFault = new ArrayList<>(); 
	// declaring what fault (among {1,2,3}) will be repeated in different steps
	// fault=0 means that the step will be done correctly
	
	private final Position start;
	private final Position goal;
	// the turtles are all out of the board at the beginning
	private Position outOfGridPosition; 
	public Position currentPosition; 

	public Position gridSize;
	
	public ArrayList<Position> plannedNextMoves;
	public ArrayList<Position> executedMoves = new ArrayList<>();
	
	public Turtle(int number, Position gridSize, ArrayList<Position> movementPlan) {
		this.number = number;
		outOfGridPosition = new Position(-number,-number);
		currentPosition = new Position(outOfGridPosition);
		executedMoves.add(currentPosition);
		this.gridSize = gridSize;
		this.plannedNextMoves= movementPlan;
		this.goal = plannedNextMoves.get(plannedNextMoves.size()-1);
		this.start= plannedNextMoves.get(0);	
	}
	
	public Turtle(int number, Position gridSize, Position startPosition, 
			ArrayList<SafeTurtles.movementAction> moves, ArrayList<Integer> stepsFault) {
		this.number = number;
		outOfGridPosition = new Position(-number,-number);
		currentPosition = new Position(outOfGridPosition);
		executedMoves.add(currentPosition);
		this.gridSize = gridSize;
		this.plannedNextMoves= gethPath(gridSize, startPosition, moves);
		this.goal = plannedNextMoves.get(plannedNextMoves.size()-1);
		this.start= plannedNextMoves.get(0);
		this.stepsFault.addAll(stepsFault);
	}
	
	public Turtle(int number, Position gridSize, int randomWaitSteps, int randomDispSteps) {
		this.number = number;
		outOfGridPosition = new Position(-number,-number);
		currentPosition   = new Position(outOfGridPosition);
		executedMoves.add(currentPosition);
		this.gridSize = gridSize;
		this.plannedNextMoves = makeRandomPlan(gridSize, randomWaitSteps, randomDispSteps);
		this.goal = plannedNextMoves.get(plannedNextMoves.size()-1);
		this.start= plannedNextMoves.get(0);
	}
	
	public static ArrayList<Position> makeRandomPlan(Position grid, int randomWaiSteps, int randomDispSteps) {
		Position randomStartPos = new Position(new Random().nextInt(grid.x), new Random().nextInt(grid.y));
		ArrayList<SafeTurtles.movementAction> moves = new ArrayList<>();
		moves.addAll(Collections.nCopies(randomWaiSteps, SafeTurtles.movementAction.nop));
		for(int i=0;i<randomDispSteps;i++) {
			SafeTurtles.movementAction randMove = SafeTurtles.movementAction.values()[ new Random().nextInt(4)];
			moves.add(randMove);
		}
		Collections.shuffle(moves);
		return gethPath(grid,randomStartPos,moves);
	}
	
	public static ArrayList<Position> gethPath(Position grid, Position startPos, ArrayList<SafeTurtles.movementAction> moves) {
		
		ArrayList<Position> path = new ArrayList<Position>();
		path.add(startPos);
		
		for(SafeTurtles.movementAction act:moves) {
			Position lastPosition = path.get(path.size()-1);
				
			Position next = switch (act) {
				case up: 	yield new Position(lastPosition.x, lastPosition.y+1);
				case down: 	yield new Position(lastPosition.x, lastPosition.y-1);
				case left: 	yield new Position(lastPosition.x-1, lastPosition.y);
				case right: yield new Position(lastPosition.x+1, lastPosition.y);
				case nop: 	yield new Position(lastPosition.x, lastPosition.y);						
				default:	throw new IllegalArgumentException("Unexpected Action: " + act);
			};
			if(next.inGrid(grid))
				path.add(next);	
			else
				path.add(lastPosition);
		}				
		return path;
	}
	
	public void replan(Position fromPosition,Position toPosition) {
//		System.out.println("replanning from position:"+ fromPosition+ " to position:"+toPosition);
		int horozontalDistance = toPosition.x - fromPosition.x;
		int verticalDistance   = toPosition.y - fromPosition.y;
		
		ArrayList<SafeTurtles.movementAction> acts = new ArrayList<SafeTurtles.movementAction>();
		
		if(horozontalDistance>0)
			for (int i = 0; i < horozontalDistance; i++)
				acts.add(SafeTurtles.movementAction.right);
		else
			for (int i = 0; i < Math.abs(horozontalDistance); i++)
				acts.add(SafeTurtles.movementAction.left);
		
		if(verticalDistance>0)
			for (int i = 0; i < verticalDistance; i++)
				acts.add(SafeTurtles.movementAction.up);
		else
			for (int i = 0; i < Math.abs(verticalDistance); i++)
				acts.add(SafeTurtles.movementAction.down);
		
		Collections.shuffle(acts);
		
		plannedNextMoves.clear();
		plannedNextMoves.add(fromPosition);
//		System.out.println("current position:"+currentPosition);
//		System.out.println("planned acts:"+ acts);
		for(SafeTurtles.movementAction act:acts) {
			Position lastPosition=plannedNextMoves.get(plannedNextMoves.size()-1);
				
			Position next = switch (act) {
				case up: 	yield new Position(lastPosition.x, lastPosition.y+1);
				case down: 	yield new Position(lastPosition.x, lastPosition.y-1);
				case left: 	yield new Position(lastPosition.x-1, lastPosition.y);
				case right: yield new Position(lastPosition.x+1, lastPosition.y);
				case nop: 	yield new Position(lastPosition.x, lastPosition.y);						
				default:	throw new IllegalArgumentException("Unexpected Action: " + act);
			};
			plannedNextMoves.add(next);			
		}
		
		if(plannedNextMoves.isEmpty()) {// when the current position is the same goal position
			plannedNextMoves.add(currentPosition);
		}
		
//		System.out.println("replanned to: "+ plannedNextMoves);
	}
	
	public Position getNext() {
		if(plannedNextMoves.isEmpty())
			return null;
		return plannedNextMoves.get(0);
	}
	
	public Position getGoal() {
		return goal;
	}
	
	public Position getStart() {
		return start;
	}
	
	public void moveNext() {
		if(missionCompleted) {
			currentPosition = new Position(outOfGridPosition);
			executedMoves.add(currentPosition);
		}
		else {
			Position next = plannedNextMoves.remove(0);
			currentPosition = next;
			executedMoves.add(next);
			
			if(plannedNextMoves.isEmpty())
				missionCompleted=true;
		}
	}
	
	public boolean enteredGrid() {
		return !currentPosition.equals(new Position(outOfGridPosition));
	}
	
	public boolean completedMission() {
		return missionCompleted;
	}
	
}

class Position{
	public int x;
	public int y;
	
	public Position(Position p) {
		this.x = p.x;
		this.y = p.y;
	}
	
	public Position(int x, int y) {
		this.x = x;
		this.y = y;
	}
	
	public Position(String P) { // P in the form of (X,Y)
		String XY = P.replace("(", "").replace(")", "");
		this.x = Integer.parseInt(XY.strip().split(",")[0]);
		this.y = Integer.parseInt(XY.strip().split(",")[1]);
	}
	
	boolean inGrid(Position grid) {
		if(x>=0 && x<grid.x && y>=0 && y<grid.y)
			return true;
		return false;
	}
	
	@Override
	public String toString() {
		return "("+x+","+y+")";
	}
	
	@Override
	public boolean equals(Object obj) {
		if(obj instanceof Position) {
			Position p = (Position) obj;
			return (p.x==this.x && p.y==this.y);
		}
		return false;
	}
}
