
set i "--jellybean colors--" /yellow, blue, green, orange, purple/;
set m "machines" /M1, M2/;
alias (i,j) ;

parameter r(i) "--net revenue per color ($/unit)--" /
yellow 1, blue 1.05, green 1.07, orange 0.95, purple 0.9 /;

scalar hbar "hours per machine per week" /40/, prodbar "units per hour per machine" /100/, dev "deviation band" /0.05/;
scalar totalprodbar; totalprodbar = hbar * prodbar;

positive variable 
Q(m,i) "production per color per machine (units)",
P(i) "total production for each color";
variable profit;


equations eq_objfn, eq_cap(m),eq_P(i),eq_upper(i,j), eq_lower(i,j);

eq_objfn.. profit =e= sum((m,i), Q(m,i)*r(i));
eq_cap(m).. sum(i, Q(m,i)) =l= totalprodbar;
eq_P(i).. P(i) =e= sum(m, Q(m,i));
eq_upper(i,j).. P(i) =l= (1+dev)*P(j);
eq_lower(i,j).. P(i) =g= (1-dev)*P(j);

model jellybean /all/;
solve jellybean using lp maximizing profit;

execute_unload 'homework1_2c.gdx';

$exit