set i "--bakery items--" /roll, croissant, bread/;

parameter r(i) "--$/item revenue per unit sold--"
/
roll 2.25,
croissant 5.5,
bread 10
/;

parameter c(i) "--$/item cost per unit sold--"
/
roll 1.5,
croissant 2,
bread 5
/;

parameter h(i) "--hours/item hours per unit sold--"
/
roll 1.5,
croissant 2.25,
bread 5
/;

scalar hbar "--hours total hours per week--" /40/;

* margin per unit = revenue - cost (clarifies the objective; leaves solution unchanged)
parameter m(i) "$/item margin";
m(i) = r(i) - c(i) ;

positive variable X(i) "units sold/produced";

variable profit;

equations
eq_objfn "objective function",
eq_hourlimit "total time constraint",
eq_combo "combo constraint";

eq_objfn.. profit =e= sum(i, m(i) * X(i)) ;
eq_hourlimit.. sum(i, h(i) * X(i)) =l= hbar ;
* production hours <= available hours

* Letter B - optional combo constraint (keep default disabled)
scalar sw_combo /%combo%/ ;  
eq_combo$sw_combo.. X("roll") =g= X("croissant") ;

model benny /all/;
solve benny using lp maximizing profit ;

* save results and show key outputs
execute_unload 'homeworkQ1.gdx' ;



$exit
