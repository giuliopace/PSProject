% general variables ###########################################################################################################
int: nrDays;
int: nrWeeks;
int: slotsPerDay;

% total number of classes, students and rooms
int: nrClasses;
int: nrStudents;
int: nrRooms;

% index helpers
array[1..nrClasses] of int: classes_options;
array[1..nrClasses] of int: classes_idx;

array[1..nrRooms+1] of int: rooms_unav_cnt;
array[1..nrRooms+1] of int: rooms_unav_idx;

array[1..nrClasses] of int: classes_rooms_cnt;
array[1..nrClasses] of int: classes_rooms_idx;


% total number of options, regardless of the class
int: nrOptions = sum(classes_options);

% total number of options, regardless of the class
int: nrClassesRooms = sum(classes_rooms_cnt);

% total number of room unavailabilities
int: nrUnavs = sum(rooms_unav_cnt);

% input data ##################################################################################################################

% input data for classes options
array[1..nrOptions, 1..nrWeeks] of bool: classes_weeks_input;
array[1..nrOptions, 1..nrDays] of bool: classes_days_input;
array[1..nrOptions, 1..2] of 1..slotsPerDay: classes_slots_input;
array[1..nrOptions] of int: classes_penalties_input;

% input data for rooms available to a class
array[1..nrClassesRooms, 1..2] of int: classes_rooms_input;

% input data for room capacities
array[1..nrRooms] of int: room_capacities_input;

% input data for room unavaibilities
array[1..nrUnavs, 1..nrWeeks] of bool: rooms_unav_weeks_input;
array[1..nrUnavs, 1..nrDays] of bool: rooms_unav_days_input;
array[1..nrUnavs, 1..2] of 1..slotsPerDay: rooms_unav_slots_input;

% input data for travel time between rooms
array[1..nrRooms, 1..nrRooms] of int: travel_adj_mat_input;


% decision variables #########################################################################################################
array[1..nrClasses, 1..nrDays] of var bool: classes_days;           % assignment of day schedule for each class
array[1..nrClasses, 1..nrWeeks] of var bool: classes_weeks;         % assignment of week schedule for each class
array[1..nrClasses, 1..nrStudents] of var bool: classes_students;   % assignment of enrolled students for each class
array[1..nrClasses] of var 1..nrRooms: classes_room;                % room assignment for each class
array[1..nrClasses] of var 0..slotsPerDay: classes_start;           % start time assignment for each class
array[1..nrClasses] of var 0..slotsPerDay: classes_duration;        % duration assignment for each class
array[1..nrClasses] of var int: classes_option_penalties;           % penalty for each option
array[1..nrClasses] of var int: classes_room_penalties;             % penalty for each room


% predicates ##################################################################################################################

% no overlapping class
predicate no_overlap(var int:s1, var int:d1, var int:s2, var int:d2) =
    s1 + d1 <= s2 \/ s2 + d2 <= s1;


% constraints #################################################################################################################

% class assigned to one of its possible room
constraint forall(i in 1..nrClasses)(
    % if the class doesn't need a room => we set its room to be "nrRooms+1"
    (classes_rooms_cnt[i] == 0 /\ classes_room[i] == nrRooms+1) 
    \/ 
    % otw assign one of the possible rooms
    exists(r in classes_rooms_idx[i]..(classes_rooms_idx[i]+classes_rooms_cnt[i]-1)) ( 
        classes_room[i] == classes_rooms_input[r,1]
        /\ classes_room_penalties[i] == classes_rooms_input[r,2]
    )
);

%+rooms_unav_cnt[classes_room[i]]-1
% check if room is available on time assignement
constraint forall (i in 1..nrClasses)(
    classes_room[i] == nrRooms+1
    \/
    %forall (unav in rooms_unav_idx[classes_room[i]]..(rooms_unav_idx[classes_room[i]]+rooms_unav_cnt[classes_room[i]]-1))(
    forall (unav in 0..-1)(
        forall(w in 1..nrWeeks)(
            forall(d in 1..nrDays)(
            not (classes_weeks[i,w] /\ rooms_unav_weeks_input[unav,w])
            \/  not (classes_days[i,d] /\ rooms_unav_days_input[unav,d])
            \/  no_overlap(
                    classes_start[i],
                    classes_duration[i],
                    rooms_unav_slots_input[unav, 1],
                    rooms_unav_slots_input[unav, 2])
            )
        )
    )
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
		            /\ classes_option_penalties[i] == classes_penalties_input[o]
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
            \/ classes_room[i] == nrRooms+1
            \/ classes_room[j] == nrRooms+1
            \/  not (classes_room[i] == classes_room[j])
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

% each student only attends classes in exactly 1 configuration of a course
constraint forall(s in 1..nrStudents)(
    forall(c1 in 1..nrClasses)(
        forall(c2 in 1..nrClasses)(
            c1 == c2
            \/ not (classes_students[c1,s]
            \/ not (classes_students[c2,s]
            \/ not (class_hierarchy_input[c1,4] == class_hierarchy_input[c2,4])
            \/ not (class_hierarchy_input[c1,3] == class_hierarchy_input[c2,3])
        )
    )
);

% each parent of a class must be attended as well if the child class will be attended
constraint forall(s in 1..nrStudents)(
    forall(c in 1..nrClasses)(
        not (classes_students[c,s])
        \/ classes_students[class_hierarchy_input[c,1],s]
    )
);


% objective function ##########################################################################################################
solve minimize sum(classes_option_penalties)+sum(classes_room_penalties);
