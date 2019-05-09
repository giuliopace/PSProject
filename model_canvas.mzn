int: nrDays;
int: nrWeeks;
int: slotsPerDay;

% total number of classes
int: nrClasses;

array[1..nrClasses] of int: classes_options;

% total number of options, regardless of the class
int: nrOptions = sum(classes_options);

array[1..nrOptions, 1..(nrWeeks+1)] of int: classes_weeks;
array[1..nrOptions, 1..(nrDays+3)] of int: classes_days;

predicate no_overlap(var int:s1, int:d1, var int:s2, int:d2) =
    s1 + d1 <= s2 \/ s2 + d2 <= s1;

int: max_option = max(classes_options);

% decision variable : which option is picked for each class
array[1..nrClasses] of var 1..max_option: picked_options;

% constraint : 
constraint forall(i in 1..nrClasses)(
    1 <= picked_options[i] /\ picked_options[i] <= classes_options[i]
);

