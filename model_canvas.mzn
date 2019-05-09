int: nrDays;
int: nrWeeks;
int: slotsPerDay;

% total number of classes
int: nrClasses;

array[1..nrClasses] of int: classes_options;

% total number of options, regardless of the class
int: nrOptions = sum(classes_options);

array[1..nrOptions, 1..nrWeeks] of bool: classes_weeks;
array[1..nrOptions, 1..nrDays] of bool: classes_days;
array[1..nrOptions, 1..2] of 1..slotsPerDay: classes_days_sd;

predicate no_overlap(var int:s1, var int:d1, var int:s2, var int:d2) =
    s1 + d1 <= s2 \/ s2 + d2 <= s1;

int: max_option = max(classes_options);

% decision variable : which option is picked for each class
array[1..nrClasses] of var 1..max_option: picked_options;

% constraint : 
constraint forall(i in 1..nrClasses)(
    0 <= picked_options[i] /\ picked_options[i] <= classes_options[i]+1
);

constraint forall(i in 1..nrClasses)(
    forall(j in 1..nrClasses)(
        forall(w in 1..nrWeeks)(
            forall(d in 1..nrDays)(
                i == j 
            \/  not (classes_weeks[i+picked_options[i],w] /\ classes_weeks[j+picked_options[j],w])
            \/  not (classes_days[i+picked_options[i],d] /\ classes_days[j+picked_options[j],d])
            \/  no_overlap(
                    classes_days_sd[i+picked_options[i],1],
                    classes_days_sd[i+picked_options[i],2],
                    classes_days_sd[j+picked_options[j],1],
                    classes_days_sd[j+picked_options[j],2])
            )
        )
    )
)