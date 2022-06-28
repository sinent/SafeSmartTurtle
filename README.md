
# **SafeSmartTurtle**
This project is implemented mainly for doing two experiments in the area of testing grid-based multiagent systems. In our testing approach, we first require test engineers to define high-level locality-based test selection constraints. Then, concrete test cases are generated based on the given constraints for testing the system under test (SUT).

## Experiment I
This experiment is designed to compare the efficiency of random and locality-based filtered random testing approaches in testing grid-based multiagent systems. The SUT of our experiment inlcudes a few environment-aware turtles moving autonomously on a grid. Each turtle has a starting and goal point in the grid and a planned path to approach its goal. These turtles are expected to avoid collisions with the other turtles while moving. *turtlesworld.erl* and *turtlesworld2* are two implemented versions of this system with different decision making methods for the turtles. However, both of these versions are intentionally implemented with some weaknesses so that the collisions between turtles can be observed in both of the cases. For doing our experiments, we use  *turtlesworld2* which provides a bit smarter decision making for the turtles.

For generating random test inputs for our SUT, we use **QuickCheck**. QuickCheck provides a couple of items in its report at the end of testing an SUT. The following items are of our interest in the experiements:
* **numtests**: this is the number of generated test inputs that are accepted to be executed on the SUT till reaching the failure
* **discards**: this is the number of generated test inputs that are discarded by test selection constraint (i.e., not executed on SUT) till reaching the failure
* **shrinksteps**: this is the number of successful shrink steps that QuickCheck takes to reach the most shrunk input from a failed test input
* **failed_shrinksteps**: this is the number of failed shrink steps that QuickCheck takes to reach the most shrunk input from a failed test input

For conducting our experiemnt, we implement "*experiment1*" function in the erlang module "*turtle_nop.erl*". This function takes a few paramters, which is properly documented in the code. It is executed in the same fashion of calling a simple Erlang function, for example, by moving to EShell,
```console
sina@ITE:~$ erl
Erlang/OTP 23 [erts-11.1.8] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [hipe] [dtrace]

Eshell V11.1.8  (abort with ^G)
1> 
```
and then compliling the modules and invoking the *experiment1* function with the required parameters. By default, if this function is invoked with all default arguments,

```console
sina@ITE:~$ erl
Erlang/OTP 23 [erts-11.1.8] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [hipe] [dtrace]

Eshell V11.1.8  (abort with ^G)
1> cover:compile_directory().
[{ok,turtle_nop},
 {ok,turtlesworld2},
 {ok,filehelper},
 {ok,turtlesworld},
 {ok,statisticshelper},
 {ok,turtle_eqc}]
 2> turtle_nop:experiment1().
```
the experiment is made on 50 $\times$ 50 grid, with 5 turtles, each having 5 displacement and 5 waiting steps, including no test selection filter and also three defined filters F1, F2 and F3, and the experiment results are saved in corresponding folders. In each case, the average of the results and the quartile of the data are provided along with raw experimental results.

## Experiment II
This experiment is designed to compare the efficiency of filtered random testing and constraint solving in generating selective test cases. In order to that, we use QuickCheck for generating filtered random test cases and Z3 solver for constraint solving. We implement "*experiment2*" function in the Erlang module "*qcFilterPerformance.erl*" for measuring the performance of filtered random testing and the main method of the python module "*z3GenPerformance</span>.py*" for measuring the performance of constraint solving approach. Changing the constraint, grid size, number of agents, path length, and some other parameters is possible within these functions. By executing these functions, the generated inputs and the time of generating them are saved in the corresponding folder of this experiment. For each test configuration, the experiment result is saved in a file with a name reflecting the test configuration. The file names of the experiment results have the prefix "**G**-g-**A**-a-**W**-w-**D**-d-**I**-i-**R**-r-**T**-t" which contains the experiment results for a test configuration where:
* 'g' is the grid size (g $\times$ g) 
* 'a' is the number of agents
* 'w' is the number of waiting steps of each agent
* 'd' is the number of displacement steps of each agent
* 'i' is the number of generated inputs in each try
* 'r' is the number of repeats of the same experiment
*  't' is the time out (in seconds) used for generating a test input

