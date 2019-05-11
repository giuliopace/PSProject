int: nrDays;
int: nrWeeks;
int: slotsPerDay;

% total number of classes
int: nrClasses;

array[1..nrClasses] of int: classes_options;
array[1..nrClasses] of int: classes_idx;

% total number of options, regardless of the class
int: nrOptions = sum(classes_options);
int: max_option = max(classes_options);

array[1..nrOptions, 1..nrWeeks] of bool: classes_weeks;
array[1..nrOptions, 1..nrDays] of bool: classes_days;
array[1..nrOptions, 1..2] of 1..slotsPerDay: classes_days_sd;
array[1..nrOptions] of int: option_penalties;

predicate no_overlap(var int:s1, var int:d1, var int:s2, var int:d2) =
    s1 + d1 <= s2 \/ s2 + d2 <= s1;

% decision variable : which option is picked for each class
array[1..nrOptions] of var 0..max_option-1: picked_options;

% constraint : 
constraint forall(i in 1..nrClasses)(
    0 <= picked_options[i] /\ picked_options[i] <= classes_options[i]-1
);

constraint forall(i in 1..nrClasses)(
    forall(j in 1..nrClasses)(
        forall(w in 1..nrWeeks)(
            forall(d in 1..nrDays)(
                i == j 
            \/  not (classes_weeks[classes_idx[i]+picked_options[i],w] /\ classes_weeks[classes_idx[j]+picked_options[j],w])
            \/  not (classes_days[classes_idx[i]+picked_options[i],d] /\ classes_days[classes_idx[j]+picked_options[j],d])
            \/  no_overlap(
                    classes_days_sd[classes_idx[i]+picked_options[i],1],
                    classes_days_sd[classes_idx[i]+picked_options[i],2],
                    classes_days_sd[classes_idx[j]+picked_options[j],1],
                    classes_days_sd[classes_idx[j]+picked_options[j],2])
            )
        )
    )
);

% sum of penalties
array[1..nrClasses] of var int: classes_penalties;
constraint forall(i in 1..nrClasses)(
    classes_penalties[i] = option_penalties[classes_idx[i]+picked_options[i]]
);

solve minimize sum(classes_penalties);