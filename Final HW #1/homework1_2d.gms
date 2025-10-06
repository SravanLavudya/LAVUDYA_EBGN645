
set i "--jellybean colors--" /yellow, blue, green, orange, purple/;
set m "machines" /M1, M2/;
set v(m,i) "valid combinations of machine and colors";

v("M1","yellow") = yes;
v("M1","blue") = yes;
v("M1","green") = yes;
v("M2","yellow") = yes;
v("M2","orange") = yes;
v("M2","purple") = yes;

parameter r(i) "--net revenue per color ($/unit)--" /
yellow 1, blue 1.05, green 1.07, orange 0.95, purple 0.9 /;

scalar hbar "hours per machine per week" /40/, prodbar "units per hour per machine" /100/, dev "deviation band" /0/;
scalar totalprodbar; totalprodbar = hbar * prodbar;

positive variable 
Q(m,i) "production per color per machine (units)",
P(i) "total production for each color";
variable profit;


equations eq_objfn, eq_cap(m),eq_P(i);

eq_objfn.. profit =e= sum((m,i)$v(m,i), Q(m,i)*r(i));
eq_cap(m).. sum(i$v(m,i), Q(m,i)) =l= totalprodbar;
eq_P(i).. P(i) =e= sum(m$v(m,i), Q(m,i));


model jellybean /all/;
solve jellybean using lp maximizing profit;

execute_unload 'homework1_2d.gdx';

$exit