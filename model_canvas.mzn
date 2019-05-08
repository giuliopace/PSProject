int nrDays;
int nrWeeks;
int slotsPerDay;

int nrClasses = length();

predicate no_overlap(var int:s1, int:d1, var int:s2, int:d2) =
    s1 + d1 <= s2 \/ s2 + d2 <= s1;

% decision variable : which option is picked for each class


