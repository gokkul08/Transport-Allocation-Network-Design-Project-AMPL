#.mod file-Annamalai Gokkul Natarajan
# This represents the Set of points, and set of links within the points
set points;
set LinksFormed within {p1 in points, p2 in points: p1 <> p2}; 
# Number of time intervals in a day
param LastValue > 0 integer; 
# Set of time intervals in a day - 1 represents 12 am and so on
set TimeInterval := 1..LastValue;   
# (p1,t1,p2,t2) of this set represents a taxi that leaves point p1 at time t1 and arrives at point p2 at time t2
set Timing within
      {p1 in points, t1 in TimeInterval,
       p2 in points, t2 in TimeInterval: (p1,p2) in LinksFormed};




#Demand Parameters for the project

# Maximum number of cars in one Number of a train
param Number > 0 integer;
 # For each Timings for the taxi, the smallest number of drivers/cars that can meet demand                      

param demand {Timing} > 0;
                       
# Minimum number of cars/drivers required to satisfy demand
param low {(p1,t1,p2,t2) in Timing} := ceil(demand[p1,t1,p2,t2]);

# Maximum number of cars alloted on a link or path:2 if demand is for less than one car; otherwise, lesser of number of cars needed to hold twice the demand, and number of cars in minimum number of Numbers needed                        

param high {(p1,t1,p2,t2) in Timing}

   := max (2, min (ceil(2*demand[p1,t1,p2,t2]),
                   Number*ceil(demand[p1,t1,p2,t2]/Number) ));

                        


# Distance Parameter Values

param Distance {LinksFormed} >= 0 default 0.0;

#Inter-Point distance: distance[p1,p2] is miles between points p1 and p2
param distance {(p1,p2) in LinksFormed} > 0
   := if Distance[p1,p2] > 0 then Distance[p1,p2] else Distance[p2,p1];

                  


#Variables
# U[p,t] is the number of unused cars stored at point p in the interval beginning at time t

var U 'cars stored' {points,TimeInterval} >= 0;
                        
# x[p1,t1,p2,t2] is the number of cars assigned to the link that leaves p1 at t1 and arrives in p2 at t2
var X 'cars on the path' {Timing} >= 0;
                        



#Objectives

   # Number of cars in the system: sum of unused cars and cars in lot during the LastValue time interval of the day

minimize cars:
       sum {p in points} U[p,LastValue] +
       sum {(p1,t1,p2,t2) in Timing: t2 < t1} X[p1,t1,p2,t2];

                     
# Total cars run by all links/paths in a day

minimize miles:
       sum {(p1,t1,p2,t2) in Timing} distance[p1,p2] * X[p1,t1,p2,t2];

                        


#Constraints

# For every point and time:unused cars in the present interval must equal unused cars in the previous interval, plus cars just arriving in trains, minus cars just leaving the paths

account {p in points, t in TimeInterval}:

  U[p,t] = U[p, if t > 1 then t-1 else LastValue] +

      sum {(p1,t1,p,t) in Timing} X[p1,t1,p,t] -
      sum {(p,t,p2,t2) in Timing} X[p,t,p2,t2];

# For each Timings of a path: number of cars must meet demand, but must not be so great that unnecessary numbers are run                       

satisfy {(p1,t1,p2,t2) in Timing}:

       low[p1,t1,p2,t2] <= X[p1,t1,p2,t2] <= high[p1,t1,p2,t2];

                      
