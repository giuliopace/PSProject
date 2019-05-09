% Use this editor as a MiniZinc scratch book
include "globals.mzn";

enum DAYS;
enum ROOMS;
enum TIMES;
constraint assert(card(DAYS) * card(ROOMS) * card(TIMES) == card(talks), "Number of slots must match number of talks");

enum talks;
enum people;

array[people, talks] of 0..4: pref;
array[DAYS, TIMES, ROOMS] of var talks: sched;

constraint alldifferent (d in DAYS, t in TIMES, r in ROOMS) (sched[d, t, r]);

array[people] of var int: score;
constraint forall(p in people) (
  score[p] = sum([if exists (r in ROOMS) (pref[p, sched[d, t, r]] = 4) 
       then 1 else 0 endif | d in DAYS, t in TIMES] 
   )
);

solve maximize sum(score);

output 
 ["SCORE: \(sum(score)) \n\n"] ++
 [show(sched[d, t, r]) ++ " " ++ 
   if r == card(ROOMS) then if t == card(TIMES) then "\n\n" else "\n" endif else "" endif | d in DAYS, t in TIMES, r in ROOMS];