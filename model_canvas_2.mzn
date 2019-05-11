int: nrDays;
int: nrWeeks;
int: slotsPerDay;

% total number of classes, students and rooms
int: nrClasses;
int: nrStudents;
int: nrRooms;

array[1..nrClasses] of int: classes_options;
array[1..nrClasses] of int: classes_idx;

% total number of options, regardless of the class
int: nrOptions = sum(classes_options);

% input data
array[1..nrOptions, 1..nrWeeks] of bool: classes_weeks_input;
array[1..nrOptions, 1..nrDays] of bool: classes_days_input;
array[1..nrOptions, 1..2] of 1..slotsPerDay: classes_slots_input;

% decision variable : which option is picked for each class
array[1..nrClasses, 1..nrDays] of var bool: classes_days; % assignment of day schedule for each class
array[1..nrClasses, 1..nrWeeks] of var bool: classes_weeks; % assignment of week schedule for each class
array[1..nrClasses, 1..nrStudents] of var bool: classes_students; % assignment of enrolled students for each class
array[1..nrClasses] of var 0..nrRooms: classes_room; % room assignment for each class
array[1..nrClasses] of var 0..slotsPerDay: classes_start; % start time assignment for each class
array[1..nrClasses] of var 0..slotsPerDay: classes_duration; % duration assignment for each class


% predicates ##################################################################################################################

% no overlapping class
predicate no_overlap(var int:s1, var int:d1, var int:s2, var int:d2) =
    s1 + d1 <= s2 \/ s2 + d2 <= s1;


% constraints #################################################################################################################

% room assigment can only be between 0 and nrRooms
constraint forall(i in 1..nrClasses)(
    classes_room[i] >= 0 /\ classes_room[i] <= nrRooms
);

% check if schedule assignment is possible
constraint forall(i in 1..nrClasses) (
    exists(o in classes_idx[i]..(classes_idx[i]+classes_options[i]-1)) (
        forall(w in 1..nrWeeks) (
            forall(d in 1..nrDays) (
                classes_weeks[i,w] == classes_weeks_input[o,w] 
                /\ classes_days[i,d] == classes_days_input[o,d]
                /\ classes_start[i] == classes_slots_input[o,1]
                /\ classes_duration[i] == classes_slots_input[o,2]
            )
        )
    )
);

% no class overlaps with another
constraint forall(i in 1..nrClasses)(
    forall(j in 1..nrClasses)(
        forall(w in 1..nrWeeks)(
            forall(d in 1..nrDays)(
                i == j 
            \/  not (classes_weeks[i,w] /\ classes_weeks[j,w])
            \/  not (classes_days[i,d] /\ classes_days[j,d])
            \/  no_overlap(
                    classes_start[i],
                    classes_duration[i],
                    classes_start[j],
                    classes_duration[j])
            )
        )
    )
);

solve satisfy;