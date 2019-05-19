% general variables ###########################################################################################################
int: nrDays;
int: nrWeeks;
int: slotsPerDay;

% total number of classes, students and rooms
int: nrClasses;
int: nrStudents;
int: nrRooms;
int: nrCourses;                                                                                                                   % NEW
int: nrConfigs;                                                                                                                   % NEW

% index helpers
array[1..nrClasses] of int: classes_options;
array[1..nrClasses] of int: classes_idx;

array[1..nrRooms+1] of int: rooms_unav_cnt;
array[1..nrRooms+1] of int: rooms_unav_idx;

array[1..nrClasses] of int: classes_rooms_cnt;
array[1..nrClasses] of int: classes_rooms_idx;

array[1..nrConfigs] of int: configs_cnt;                                                                                          % NEW
array[1..nrConfigs] of int: configs_idx;                                                                                          % NEW

array[1..nrStudents] of int: student_pref_cnt;                                                                                    % NEW
array[1..nrStudents] of int: student_pref_idx;                                                                                    % NEW

% total number of options, regardless of the class
int: nrOptions = sum(classes_options);

% total number of options, regardless of the class
int: nrClassesRooms = sum(classes_rooms_cnt);

% total number of room unavailabilities
int: nrUnavs = sum(rooms_unav_cnt);

% total number of subparts
int: nrSubparts = sum(configs_cnt);                                                                                               % NEW

% total number of subparts
int: nrPref = sum(student_pref_cnt);                                                                                              % NEW


% input data ##################################################################################################################

% input data for classes options
array[1..nrOptions, 1..nrWeeks] of bool: classes_weeks_input;
array[1..nrOptions, 1..nrDays] of bool: classes_days_input;
array[1..nrOptions, 1..2] of 1..slotsPerDay: classes_slots_input;
array[1..nrOptions] of int: classes_penalties_input;

% input data for class hierarchy
array[1..nrClasses, 1..4] of int: class_hierarchy_input;                                                                          % NEW

% input data for class limits
array[1..nrClasses] of int: class_limit_input;                                                                                    % NEW

% input data for course preferences of each student            
array[1..nrPref] of int: student_pref_input;                                                                                      % NEW

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

% input for distributional constraints


int: nrSameStart;
int: nrSameStart_distrib;
array[1..nrSameStart] of int: SameStart_idx;
array[1..nrSameStart] of int: SameStart_cnt;
array[1..nrSameStart] of bool: SameStart_required;
array[1..nrSameStart] of int: SameStart_penalty;
array[1..nrSameStart_distrib] of int: SameStart_distrib_input;


int: nrSameTime;
int: nrSameTime_distrib;
array[1..nrSameTime] of int: SameTime_idx;
array[1..nrSameTime] of int: SameTime_cnt;
array[1..nrSameTime] of bool: SameTime_required;
array[1..nrSameTime] of int: SameTime_penalty;
array[1..nrSameTime_distrib] of int: SameTime_distrib_input;


int: nrDifferentTime;
int: nrDifferentTime_distrib;
array[1..nrDifferentTime] of int: DifferentTime_idx;
array[1..nrDifferentTime] of int: DifferentTime_cnt;
array[1..nrDifferentTime] of bool: DifferentTime_required;
array[1..nrDifferentTime] of int: DifferentTime_penalty;
array[1..nrDifferentTime_distrib] of int: DifferentTime_distrib_input;


int: nrSameDays;
int: nrSameDays_distrib;
array[1..nrSameDays] of int: SameDays_idx;
array[1..nrSameDays] of int: SameDays_cnt;
array[1..nrSameDays] of bool: SameDays_required;
array[1..nrSameDays] of int: SameDays_penalty;
array[1..nrSameDays_distrib] of int: SameDays_distrib_input;


int: nrDifferentDays;
int: nrDifferentDays_distrib;
array[1..nrDifferentDays] of int: DifferentDays_idx;
array[1..nrDifferentDays] of int: DifferentDays_cnt;
array[1..nrDifferentDays] of bool: DifferentDays_required;
array[1..nrDifferentDays] of int: DifferentDays_penalty;
array[1..nrDifferentDays_distrib] of int: DifferentDays_distrib_input;


int: nrSameWeeks;
int: nrSameWeeks_distrib;
array[1..nrSameWeeks] of int: SameWeeks_idx;
array[1..nrSameWeeks] of int: SameWeeks_cnt;
array[1..nrSameWeeks] of bool: SameWeeks_required;
array[1..nrSameWeeks] of int: SameWeeks_penalty;
array[1..nrSameWeeks_distrib] of int: SameWeeks_distrib_input;


int: nrDifferentWeeks;
int: nrDifferentWeeks_distrib;
array[1..nrDifferentWeeks] of int: DifferentWeeks_idx;
array[1..nrDifferentWeeks] of int: DifferentWeeks_cnt;
array[1..nrDifferentWeeks] of bool: DifferentWeeks_required;
array[1..nrDifferentWeeks] of int: DifferentWeeks_penalty;
array[1..nrDifferentWeeks_distrib] of int: DifferentWeeks_distrib_input;


int: nrSameRoom;
int: nrSameRoom_distrib;
array[1..nrSameRoom] of int: SameRoom_idx;
array[1..nrSameRoom] of int: SameRoom_cnt;
array[1..nrSameRoom] of bool: SameRoom_required;
array[1..nrSameRoom] of int: SameRoom_penalty;
array[1..nrSameRoom_distrib] of int: SameRoom_distrib_input;


int: nrDifferentRoom;
int: nrDifferentRoom_distrib;
array[1..nrDifferentRoom] of int: DifferentRoom_idx;
array[1..nrDifferentRoom] of int: DifferentRoom_cnt;
array[1..nrDifferentRoom] of bool: DifferentRoom_required;
array[1..nrDifferentRoom] of int: DifferentRoom_penalty;
array[1..nrDifferentRoom_distrib] of int: DifferentRoom_distrib_input;


int: nrOverlap;
int: nrOverlap_distrib;
array[1..nrOverlap] of int: Overlap_idx;
array[1..nrOverlap] of int: Overlap_cnt;
array[1..nrOverlap] of bool: Overlap_required;
array[1..nrOverlap] of int: Overlap_penalty;
array[1..nrOverlap_distrib] of int: Overlap_distrib_input;


int: nrNotOverlap;
int: nrNotOverlap_distrib;
array[1..nrNotOverlap] of int: NotOverlap_idx;
array[1..nrNotOverlap] of int: NotOverlap_cnt;
array[1..nrNotOverlap] of bool: NotOverlap_required;
array[1..nrNotOverlap] of int: NotOverlap_penalty;
array[1..nrNotOverlap_distrib] of int: NotOverlap_distrib_input;


int: nrSameAttendees;
int: nrSameAttendees_distrib;
array[1..nrSameAttendees] of int: SameAttendees_idx;
array[1..nrSameAttendees] of int: SameAttendees_cnt;
array[1..nrSameAttendees] of bool: SameAttendees_required;
array[1..nrSameAttendees] of int: SameAttendees_penalty;
array[1..nrSameAttendees_distrib] of int: SameAttendees_distrib_input;


int: nrPrecedence;
int: nrPrecedence_distrib;
array[1..nrPrecedence] of int: Precedence_idx;
array[1..nrPrecedence] of int: Precedence_cnt;
array[1..nrPrecedence] of bool: Precedence_required;
array[1..nrPrecedence] of int: Precedence_penalty;
array[1..nrPrecedence_distrib] of int: Precedence_distrib_input;


int: nrWorkDay;
int: nrWorkDay_distrib;
array[1..nrWorkDay] of int: WorkDay_idx;
array[1..nrWorkDay] of int: WorkDay_cnt;
array[1..nrWorkDay] of bool: WorkDay_required;
array[1..nrWorkDay] of int: WorkDay_penalty;
array[1..nrWorkDay] of int: WorkDay_distrib_input;
array[1..nrWorkDay_distrib] of int: WorkDay_nr1;


int: nrMinGap;
int: nrMinGap_distrib;
array[1..nrMinGap] of int: MinGap_idx;
array[1..nrMinGap] of int: MinGap_cnt;
array[1..nrMinGap] of bool: MinGap_required;
array[1..nrMinGap] of int: MinGap_penalty;
array[1..nrMinGap] of int: MinGap_distrib_input;
array[1..nrMinGap_distrib] of int: MinGap_nr1;


int: nrMaxDays;
int: nrMaxDays_distrib;
array[1..nrMaxDays] of int: MaxDays_idx;
array[1..nrMaxDays] of int: MaxDays_cnt;
array[1..nrMaxDays] of bool: MaxDays_required;
array[1..nrMaxDays] of int: MaxDays_penalty;
array[1..nrMaxDays] of int: MaxDays_distrib_input;
array[1..nrMaxDays_distrib] of int: MaxDays_nr1;


int: nrMaxDayLoad;
int: nrMaxDayLoad_distrib;
array[1..nrMaxDayLoad] of int: MaxDayLoad_idx;
array[1..nrMaxDayLoad] of int: MaxDayLoad_cnt;
array[1..nrMaxDayLoad] of bool: MaxDayLoad_required;
array[1..nrMaxDayLoad] of int: MaxDayLoad_penalty;
array[1..nrMaxDayLoad] of int: MaxDayLoad_distrib_input;
array[1..nrMaxDayLoad_distrib] of int: MaxDayLoad_nr1;


int: nrMaxBreaks;
int: nrMaxBreaks_distrib;
array[1..nrMaxBreaks] of int: MaxBreaks_idx;
array[1..nrMaxBreaks] of int: MaxBreaks_cnt;
array[1..nrMaxBreaks] of bool: MaxBreaks_required;
array[1..nrMaxBreaks] of int: MaxBreaks_penalty;
array[1..nrMaxBreaks] of int: MaxBreaks_distrib_input;
array[1..nrMaxBreaks] of int: MaxBreaks_nr1;
array[2..nrMaxBreaks_distrib] of int: MaxBreaks_nr2;


int: nrMaxBlock;
int: nrMaxBlock_distrib;
array[1..nrMaxBlock] of int: MaxBlock_idx;
array[1..nrMaxBlock] of int: MaxBlock_cnt;
array[1..nrMaxBlock] of bool: MaxBlock_required;
array[1..nrMaxBlock] of int: MaxBlock_penalty;
array[1..nrMaxBlock] of int: MaxBlock_distrib_input;
array[1..nrMaxBlock] of int: MaxBlock_nr1;
array[2..nrMaxBlock_distrib] of int: MaxBlock_nr2;

% decision variables ##########################################################################################################
array[1..nrClasses, 1..nrDays] of var bool: classes_days;           % assignment of day schedule for each class
array[1..nrClasses, 1..nrWeeks] of var bool: classes_weeks;         % assignment of week schedule for each class
array[1..nrClasses, 1..nrStudents] of var bool: classes_students;   % assignment of enrolled students for each class
array[1..nrClasses] of var 1..nrRooms: classes_room;                % room assignment for each class
array[1..nrClasses] of var 0..slotsPerDay: classes_start;           % start time assignment for each class
array[1..nrClasses] of var 0..slotsPerDay: classes_duration;        % duration assignment for each class
array[1..nrClasses] of var 0..100: classes_option_penalties;           % penalty for each option
array[1..nrClasses] of var 0..100: classes_room_penalties;             % penalty for each room
array[1..nrSubparts, 1..nrStudents] of var bool: subparts_students; % assignment of enrolled students for each subpart            % NEW

array[1..nrSameStart] of var 0..10: SameStart_dec_penalty;
array[1..nrSameTime] of var 0..10: SameTime_dec_penalty;
array[1..nrDifferentTime] of var 0..10: DifferentTime_dec_penalty;
array[1..nrSameDays] of var 0..10: SameDays_dec_penalty;
array[1..nrDifferentDays] of var 0..10: DifferentDays_dec_penalty;
array[1..nrSameWeeks] of var 0..10: SameWeeks_dec_penalty;
array[1..nrDifferentWeeks] of var 0..10: DifferentWeeks_dec_penalty;
array[1..nrSameRoom] of var 0..10: SameRoom_dec_penalty;
array[1..nrDifferentRoom] of var 0..10: DifferentRoom_dec_penalty;
array[1..nrOverlap] of var 0..10: Overlap_dec_penalty;
array[1..nrNotOverlap] of var 0..10: NotOverlap_dec_penalty;
array[1..nrSameAttendees] of var 0..10: SameAttendees_dec_penalty;
array[1..nrPrecedence] of var 0..10: Precedence_dec_penalty;
array[1..nrWorkDay] of var 0..10: WorkDay_dec_penalty;
array[1..nrMinGap] of var 0..10: MinGap_dec_penalty;
array[1..nrMaxDays] of var 0..10: MaxDays_dec_penalty;
array[1..nrMaxDayLoad] of var 0..10: MaxDayLoad_dec_penalty;
array[1..nrMaxBreaks] of var 0..10: MaxBreaks_dec_penalty;
array[1..nrMaxBlock] of var 0..10: MaxBlock_dec_penalty;

% predicates ##################################################################################################################

% no overlapping class
predicate no_overlap(var int:s1, var int:d1, var int:s2, var int:d2) =
    s1 + d1 <= s2 \/ s2 + d2 <= s1;
  
% no overlapping class incl. travel time                                                                                          % NEW
predicate no_overlap_time(var int:s1, var int:d1, var int:s2, var int:d2, var int:t) =
    s1 + d1 + t <= s2 \/ s2 + d2 + t <= s1;
 
  
% student conflict
predicate student_conflict(var int:c1, var int:c2, var int:s) =                                                                   % NEW
    exists(w in 1..nrWeeks)(
        exists(d in 1..nrDays)(
            classes_students[c1,s]
            /\ classes_students[c2,s]
            /\ (classes_weeks[c1,w] == classes_weeks[c2,w])
            /\ (classes_days[c1,d] == classes_days[c2,d])
            /\ (not (no_overlap(classes_start[c1], classes_duration[c1], classes_start[c2], classes_duration[c2]))
                \/ not (no_overlap_time(classes_start[c1], classes_duration[c1], classes_start[c2], classes_duration[c2],       travel_adj_mat_input[classes_room[c1],classes_room[c2]])))
        )
    );


% constraints #################################################################################################################


% ensure that all penalties are positive
constraint forall(i in 1..nrClasses)(
    classes_option_penalties[i] >=0
);

constraint forall (i in 1..nrClasses)(
    classes_room_penalties[i] >=0
);

constraint forall(i in 1..nrSameStart)(
    SameStart_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrSameTime)(
    SameTime_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrDifferentTime)(
    DifferentTime_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrSameDays)(
    SameDays_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrDifferentDays)(
    DifferentDays_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrSameWeeks)(
    SameWeeks_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrDifferentWeeks)(
    DifferentWeeks_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrSameRoom)(
    SameRoom_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrDifferentRoom)(
    DifferentRoom_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrOverlap)(
    Overlap_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrNotOverlap)(
    NotOverlap_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrSameAttendees)(
    SameAttendees_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrPrecedence)(
    Precedence_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrWorkDay)(
    WorkDay_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrMinGap)(
    MinGap_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrMaxDays)(
    MaxDays_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrMaxDayLoad)(
    MaxDayLoad_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrMaxBreaks)(
    MaxBreaks_dec_penalty[i] >= 0
);

constraint forall(i in 1..nrMaxBlock)(
    MaxBlock_dec_penalty[i] >= 0
);


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
    exists(o in classes_idx[i]..(classes_idx[i]+classes_options[i]-1))(
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
            (c1 == c2)
            \/ not (classes_students[c1,s])
            \/ not (classes_students[c2,s])
            \/ not (class_hierarchy_input[c1,4] == class_hierarchy_input[c2,4])
            \/ (class_hierarchy_input[c1,3] == class_hierarchy_input[c2,3])
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

% each class of a subpart enrolls the student to the respective subpart                                                             % NEW
constraint forall(s in 1..nrStudents)(
    forall(c in 1..nrClasses)(
        not (classes_students[c,s])
        \/ subparts_students[class_hierarchy_input[c,2],s]
    )
);


% each subpart can only be attended if there exists some class which is attended                                                    % NEW
constraint forall(s in 1..nrStudents)(
    forall(sp in 1..nrSubparts)(
        not (subparts_students[sp,s])
        \/ exists(c in 1..nrClasses)(
            classes_students[c,s]
            /\ class_hierarchy_input[c,2] == sp
        )
    )
);


% each student has to take at least 1 class in each subpart of a config                                                             % NEW
constraint forall(s in 1..nrStudents)(
    forall(c in 1..nrClasses)(
        forall(sp in configs_idx[class_hierarchy_input[c,3]]..configs_idx[class_hierarchy_input[c,3]]+configs_cnt[class_hierarchy_input[c,3]]-1)(
            subparts_students[sp,s]
            \/ not (classes_students[c,s])
        )
    )
);

% class limit >= number of students enrolled to the class                                                                           % NEW
constraint forall(c in 1..nrClasses)(
    class_limit_input[c] >= sum (s in 1..nrStudents)(classes_students[c,s])
);


% every course on the preference list of students has to be taken                                                                   % NEW
constraint forall(s in 1..nrStudents)(
    forall(pref in student_pref_idx[s]..student_pref_idx[s]+student_pref_cnt[s]-1)(
        exists(c in 1..nrClasses)(
            classes_students[c,s]
            /\ class_hierarchy_input[c,4] == student_pref_input[pref]
        )
    )
);


% distributional constraints ###################################################################################################

% sameStart | constraint ∨ (¬req ∧ penalty)  
constraint forall(i in 1..nrSameStart)(
    forall(c1 in SameStart_idx[i]..SameStart_idx[i]+SameStart_cnt[i]-1)(
        forall(c2 in SameStart_idx[i]..SameStart_idx[i]+SameStart_cnt[i]-1)(
            c1 == c2
            \/ classes_start[SameStart_distrib_input[c1]] == classes_start[SameStart_distrib_input[c2]]
        )
    )
    \/
    (
        not (SameStart_required[i]) 
        /\ SameStart_penalty[i] == SameStart_dec_penalty[i]
    )
);

% sameTime
constraint forall(i in 1..nrSameTime)(
    forall(c1 in SameTime_idx[i]..SameTime_idx[i]+SameTime_cnt[i]-1)(
        forall(c2 in SameTime_idx[i]..SameTime_idx[i]+SameTime_cnt[i]-1)(
            c1 == c2
            \/ (classes_start[SameTime_distrib_input[c1]] <= classes_start[SameTime_distrib_input[c2]]
                /\ classes_start[SameTime_distrib_input[c2]] + classes_duration[SameTime_distrib_input[c2]] <= classes_start[SameTime_distrib_input[c1]] + classes_duration[SameTime_distrib_input[c1]])
            \/ (classes_start[SameTime_distrib_input[c2]] <= classes_start[SameTime_distrib_input[c1]]
                /\ classes_start[SameTime_distrib_input[c1]] + classes_duration[SameTime_distrib_input[c1]] <= classes_start[SameTime_distrib_input[c2]] + classes_duration[SameTime_distrib_input[c2]])
        )
    )
    \/
    (
        not (SameTime_required[i]) 
        /\ SameTime_penalty[i] == SameTime_dec_penalty[i]
    )
);

% differentTime
constraint forall(i in 1..nrDifferentTime)(
    forall(c1 in DifferentTime_idx[i]..DifferentTime_idx[i]+DifferentTime_cnt[i]-1)(
        forall(c2 in DifferentTime_idx[i]..DifferentTime_idx[i]+DifferentTime_cnt[i]-1)(
            c1 == c2
            \/ (classes_start[DifferentTime_distrib_input[c1]] <= classes_start[DifferentTime_distrib_input[c2]])
            \/ (classes_start[DifferentTime_distrib_input[c2]] <= classes_start[DifferentTime_distrib_input[c1]])
        )
    )
    \/
    (
        not (DifferentTime_required[i]) 
        /\ DifferentTime_penalty[i] == DifferentTime_dec_penalty[i]
    )
);

% sameDays
constraint forall(i in 1..nrSameDays)(
    exists(c1 in SameDays_idx[i]..SameDays_idx[i]+SameDays_cnt[i]-1)(
        forall(c2 in SameDays_idx[i]..SameDays_idx[i]+SameDays_cnt[i]-1)(
            forall(d in 1..nrDays)(
                c1 == c2
                \/ not (classes_days[SameDays_distrib_input[c2],d]) \/ classes_days[SameDays_distrib_input[c1],d]
            )
        )
    )
    \/
    (
        not (SameDays_required[i]) 
        /\ SameDays_penalty[i] == SameDays_dec_penalty[i]
    )
);

% differentDays
constraint forall(i in 1..nrDifferentDays)(
    forall(c1 in DifferentDays_idx[i]..DifferentDays_idx[i]+DifferentDays_cnt[i]-1)(
        forall(c2 in DifferentDays_idx[i]..DifferentDays_idx[i]+DifferentDays_cnt[i]-1)(
            forall(d in 1..nrDays)(
                c1 == c2
                \/ not (classes_days[DifferentDays_distrib_input[c2],d] == classes_days[DifferentDays_distrib_input[c1],d])
            )
        )
    )
    \/
    (
        not (DifferentDays_required[i]) 
        /\ DifferentDays_penalty[i] == DifferentDays_dec_penalty[i]
    )
);

% sameWeeks
constraint forall(i in 1..nrSameWeeks)(
    exists(c1 in SameWeeks_idx[i]..SameWeeks_idx[i]+SameWeeks_cnt[i]-1)(
        forall(c2 in SameWeeks_idx[i]..SameWeeks_idx[i]+SameWeeks_cnt[i]-1)(
            forall(w in 1..nrWeeks)(
                c1 == c2
                \/ not (classes_weeks[SameWeeks_distrib_input[c2],w]) \/ classes_weeks[SameWeeks_distrib_input[c1],w]
            )
        )
    )
    \/
    (
        not (SameWeeks_required[i]) 
        /\ SameWeeks_penalty[i] == SameWeeks_dec_penalty[i]
    )
);

% differentWeeks
constraint forall(i in 1..nrDifferentWeeks)(
    forall(c1 in DifferentWeeks_idx[i]..DifferentWeeks_idx[i]+DifferentWeeks_cnt[i]-1)(
        forall(c2 in DifferentWeeks_idx[i]..DifferentWeeks_idx[i]+DifferentWeeks_cnt[i]-1)(
            forall(w in 1..nrWeeks)(
                c1 == c2
                \/ not (classes_weeks[SameWeeks_distrib_input[c2],w] == classes_weeks[SameWeeks_distrib_input[c1],w])
            )
        )
    )
    \/
    (
        not (DifferentWeeks_required[i]) 
        /\ DifferentWeeks_penalty[i] == DifferentWeeks_dec_penalty[i]
    )
);

% overlap
constraint forall(i in 1..nrOverlap)(
    forall(c1 in Overlap_idx[i]..Overlap_idx[i]+Overlap_cnt[i]-1)(
        forall(c2 in Overlap_idx[i]..Overlap_idx[i]+Overlap_cnt[i]-1)(
            forall(w in 1..nrWeeks)(
                forall(d in 1..nrDays)(
                    (classes_start[Overlap_distrib_input[c2]] < classes_start[Overlap_distrib_input[c1]]+classes_duration[Overlap_distrib_input[c1]])
                    /\ (classes_start[Overlap_distrib_input[c1]] < classes_start[Overlap_distrib_input[c2]]+classes_duration[Overlap_distrib_input[c2]])
                    /\ (classes_days[Overlap_distrib_input[c1],d] == classes_days[Overlap_distrib_input[c2],d])
                    /\ (classes_weeks[Overlap_distrib_input[c1],w] == classes_weeks[Overlap_distrib_input[c2],w])
                )
            )
        )
    )
    \/
    (
        not (Overlap_required[i]) 
        /\ Overlap_penalty[i] == Overlap_dec_penalty[i]
    )
);

% not overlap
constraint forall(i in 1..nrNotOverlap)(
    forall(c1 in NotOverlap_idx[i]..NotOverlap_idx[i]+NotOverlap_cnt[i]-1)(
        forall(c2 in NotOverlap_idx[i]..NotOverlap_idx[i]+NotOverlap_cnt[i]-1)(
            forall(w in 1..nrWeeks)(
                forall(d in 1..nrDays)(
                    c1 == c2
                    \/ (not ((classes_start[NotOverlap_distrib_input[c2]] < classes_start[NotOverlap_distrib_input[c1]]+classes_duration[NotOverlap_distrib_input[c1]])
                    /\ (classes_start[NotOverlap_distrib_input[c1]] < classes_start[NotOverlap_distrib_input[c2]]+classes_duration[NotOverlap_distrib_input[c2]])
                    /\ (classes_days[NotOverlap_distrib_input[c1],d] == classes_days[NotOverlap_distrib_input[c2],d])
                    /\ (classes_weeks[NotOverlap_distrib_input[c1],w] == classes_weeks[NotOverlap_distrib_input[c2],w])))
                )
            )
        )
    )
    \/
    (
        not (NotOverlap_required[i]) 
        /\ NotOverlap_penalty[i] == NotOverlap_dec_penalty[i]
    )
);

% sameRoom
constraint forall(i in 1..nrSameRoom)(
    forall(c1 in SameRoom_idx[i]..SameRoom_idx[i]+SameRoom_cnt[i]-1)(
        forall(c2 in SameRoom_idx[i]..SameRoom_idx[i]+SameRoom_cnt[i]-1)(
            classes_room[SameRoom_distrib_input[c1]] == classes_room[SameRoom_distrib_input[c2]]
        )
    )
    \/
    (
        not (SameRoom_required[i]) 
        /\ SameRoom_penalty[i] == SameRoom_dec_penalty[i]
    )
);

% differentRoom
constraint forall(i in 1..nrDifferentRoom)(
    forall(c1 in DifferentRoom_idx[i]..DifferentRoom_idx[i]+DifferentRoom_cnt[i]-1)(
        forall(c2 in DifferentRoom_idx[i]..DifferentRoom_idx[i]+DifferentRoom_cnt[i]-1)(
            c1 == c2
            \/ not (classes_room[DifferentRoom_distrib_input[c1]] == classes_room[DifferentRoom_distrib_input[c2]])
        )
    )
    \/
    (
        not (DifferentRoom_required[i]) 
        /\ DifferentRoom_penalty[i] == DifferentRoom_dec_penalty[i]
    )
);

% sameAttendees
constraint forall(i in 1..nrSameAttendees)(
    forall(c1 in SameAttendees_idx[i]..SameAttendees_idx[i]+SameAttendees_cnt[i]-1)(
        forall(c2 in SameAttendees_idx[i]..SameAttendees_idx[i]+SameAttendees_cnt[i]-1)(
            c1 == c2
            \/ (classes_start[SameAttendees_distrib_input[c1]]+classes_duration[SameAttendees_distrib_input[c1]]+travel_adj_mat_input[classes_room[SameAttendees_distrib_input[c1]],classes_room[SameAttendees_distrib_input[c2]]] <= classes_start[SameAttendees_distrib_input[c2]])
            \/ (classes_start[SameAttendees_distrib_input[c2]]+classes_duration[SameAttendees_distrib_input[c2]]+travel_adj_mat_input[classes_room[SameAttendees_distrib_input[c2]],classes_room[SameAttendees_distrib_input[c1]]] <= classes_start[SameAttendees_distrib_input[c1]])
            \/ forall(w in 1..nrWeeks)(
                  forall(d in 1..nrDays)(
                      not (classes_days[SameAttendees_distrib_input[c1],d] == classes_days[SameAttendees_distrib_input[c2],d])
                      \/ not (classes_weeks[SameAttendees_distrib_input[c1],w] == classes_weeks[SameAttendees_distrib_input[c2],w])
                  )
            )
        )
    )
    \/
    (
        not (SameAttendees_required[i]) 
        /\ SameAttendees_penalty[i] == SameAttendees_dec_penalty[i]
    )
);


% Precedence
constraint forall(i in 1..nrPrecedence)(
    forall(c1 in Precedence_idx[i]..Precedence_idx[i]+Precedence_cnt[i]-1)(
        forall(c2 in Precedence_idx[i]..Precedence_idx[i]+Precedence_cnt[i]-1)(
            c1 >= c2 % we are only interested in the constraints where c1 < c2
            \/
            % start some week before
            min(w in 1..nrWeeks)(w+bool2int(not classes_weeks[Precedence_distrib_input[c1],w])*nrWeeks) 
            < min(w in 1..nrWeeks)(w+bool2int(not classes_weeks[Precedence_distrib_input[c2],w])*nrWeeks)
            \/ % or
            (
                % start the same week
                min(w in 1..nrWeeks)(w+bool2int(not classes_weeks[Precedence_distrib_input[c1],w])*nrWeeks) 
                == min(w in 1..nrWeeks)(w+bool2int(not classes_weeks[Precedence_distrib_input[c2],w])*nrWeeks)
                /\ % and
                (
                    % start some day before
                    min(d in 1..nrDays)(d+bool2int(not classes_days[Precedence_distrib_input[c1],d])*nrDays) 
                    < min(d in 1..nrDays)(d+bool2int(not classes_days[Precedence_distrib_input[c2],d])*nrDays)
                    \/ % or
                    (   
                        % start the same day
                        min(d in 1..nrDays)(d+bool2int(not classes_days[Precedence_distrib_input[c1],d])*nrDays) 
                        == min(d in 1..nrDays)(d+bool2int(not classes_days[Precedence_distrib_input[c2],d])*nrDays)
                        /\
                        % and the class 1 finishes before class 2 starts
                        classes_start[Precedence_distrib_input[c1]]+classes_duration[Precedence_distrib_input[c1]]
                        <= classes_start[Precedence_distrib_input[c2]]
                    )
                )
            )
        )
    )
    \/
    (
        not (Precedence_required[i]) 
        /\ Precedence_penalty[i] == Precedence_dec_penalty[i]
    )
);

% WorkDay
constraint forall(i in 1..nrWorkDay)(
    forall(c1 in WorkDay_idx[i]..WorkDay_idx[i]+WorkDay_cnt[i]-1)(
        forall(c2 in WorkDay_idx[i]..WorkDay_idx[i]+WorkDay_cnt[i]-1)(
            c1 == c2
            \/
            forall(w in 1..nrWeeks)(
                forall(d in 1..nrDays)(
                    (not (classes_weeks[WorkDay_distrib_input[c1],w] /\ classes_weeks[WorkDay_distrib_input[c2],w]))
                    \/
                    (not (classes_days[WorkDay_distrib_input[c1],d] /\ classes_days[WorkDay_distrib_input[c2],d]))
                    \/
                    (max(classes_start[WorkDay_distrib_input[c1]], classes_start[WorkDay_distrib_input[c2]])
                     - min(classes_start[WorkDay_distrib_input[c1]]+classes_duration[WorkDay_distrib_input[c1]],
                       classes_start[WorkDay_distrib_input[c2]]+classes_duration[WorkDay_distrib_input[c2]]) <= WorkDay_nr1[i])
                )
            )
        )
    )
    \/
    (
        not (WorkDay_required[i]) 
        /\ WorkDay_penalty[i] == WorkDay_dec_penalty[i]
    )
);

% MinGap
constraint forall(i in 1..nrMinGap)(
    forall(c1 in MinGap_idx[i]..MinGap_idx[i]+MinGap_cnt[i]-1)(
        forall(c2 in MinGap_idx[i]..MinGap_idx[i]+MinGap_cnt[i]-1)(
            c1 == c2
            \/
            forall(w in 1..nrWeeks)(
                forall(d in 1..nrDays)(
                    (not (classes_weeks[MinGap_distrib_input[c1],w] /\ classes_weeks[MinGap_distrib_input[c1],w]))
                    \/
                    (not (classes_days[MinGap_distrib_input[c1],d] /\ classes_days[MinGap_distrib_input[c1],d]))
                    \/
                    (classes_start[MinGap_distrib_input[c1]]+classes_duration[MinGap_distrib_input[c1]]+MinGap_nr1[i] <= classes_start[MinGap_distrib_input[c2]])
                    \/
                    (classes_start[MinGap_distrib_input[c2]]+classes_duration[MinGap_distrib_input[c2]]+MinGap_nr1[i] <= classes_start[MinGap_distrib_input[c1]])
                )
            )
        )
    )
    \/
    (
        not (MinGap_required[i]) 
        /\ MinGap_penalty[i] == MinGap_dec_penalty[i]
    )
);

% MaxDays
constraint forall(i in 1..nrMaxDays)(
    sum(d in 1..nrDays)(
        bool2int(
            exists(c in MaxDays_idx[i]..MaxDays_idx[i]+MaxDays_cnt[i]-1)(
                classes_days[MaxDays_distrib_input[c],d]
            )
        )
    ) <= MaxDays_nr1[i]
    \/
    (
        not (MaxDays_required[i]) 
        /\ MaxDays_dec_penalty[i] == (MaxDays_penalty[i] 
        % in case of soft constraint, we multiply the penalty by the number of day violating the constraint
          * (
                sum(d in 1..nrDays)(
                    bool2int(
                        exists(c in MaxDays_idx[i]..MaxDays_idx[i]+MaxDays_cnt[i]-1)(
                            classes_days[MaxDays_distrib_input[c],d]
                        )
                    )
                ) - MaxDays_nr1[i]
            )
        )
    )
);

% MaxDayLoad
constraint forall(i in 1..nrMaxDayLoad)(
    forall(w in 1..nrWeeks)(
        forall(d in 1..nrDays)(
            sum(c in MaxDayLoad_idx[i]..MaxDayLoad_idx[i]+MaxDayLoad_cnt[i]-1)
            (
                classes_duration[MaxDayLoad_distrib_input[c]]
            ) <= MaxDayLoad_nr1[i]
        )
    )
    \/
    (
        not (MaxDayLoad_required[i]) 
        /\ MaxDayLoad_penalty[i] == ((MaxDayLoad_dec_penalty[i]
          * (
              % in case of soft constraint we multiply the penalty by the number of slots
              % exceeding the max load over the semester
              sum(w in 1..nrWeeks)(
                sum(d in 1..nrDays)(
                  max(
                    sum(c in MaxDayLoad_idx[i]..MaxDayLoad_idx[i]+MaxDayLoad_cnt[i]-1)
                    (
                        classes_duration[MaxDayLoad_distrib_input[c]]
                    ) - MaxDayLoad_nr1[i]
                    ,0)
                )
              )
            )
        ) / nrWeeks )
    )
);



% objective function ##########################################################################################################
solve minimize sum(classes_option_penalties)+sum(classes_room_penalties)+sum(SameStart_dec_penalty)+sum(SameTime_dec_penalty)+sum(DifferentTime_dec_penalty)+sum(SameDays_dec_penalty)+sum(DifferentDays_dec_penalty)+sum(SameWeeks_dec_penalty)+sum(DifferentWeeks_dec_penalty)+sum(SameRoom_dec_penalty)+sum(DifferentRoom_dec_penalty)+sum(Overlap_dec_penalty)+sum(NotOverlap_dec_penalty)+sum(SameAttendees_dec_penalty)+sum(Precedence_dec_penalty)+sum(WorkDay_dec_penalty)+sum(MinGap_dec_penalty)+sum(MaxDays_dec_penalty)+sum(MaxDayLoad_dec_penalty)+sum(MaxBreaks_dec_penalty)+sum(MaxBlock_dec_penalty);
