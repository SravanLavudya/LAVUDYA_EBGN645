
set i "--jellybean colors--" /yellow, blue, green, orange, purple/;
set m "machines" /M1, M2/;

parameter r(i) "--net revenue per color ($/unit)--" /
yellow 1, blue 1.05, green 1.07, orange 0.95, purple 0.9 /;

scalar hbar "hours per machine per week" /40/, prodbar "units per hour per machine" /100/, dev "deviation band" /0.05/;
scalar totalprodbar; totalprodbar = hbar * prodbar;

positive variable Q(m,i) "production per color per machine (units)";
variable profit;

equations eq_objfn, eq_cap(m);

eq_objfn.. profit =e= sum((m,i), Q(m,i)*r(i));
eq_cap(m).. sum(i, Q(m,i)) =l= totalprodbar;

model jellybean /all/;
solve jellybean using lp maximizing profit;

execute_unload 'homework1_2.gdx';

$exit