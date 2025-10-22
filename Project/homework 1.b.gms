set i /site1, site2, site3/;
set s /s1, s2/;
set t /t1*t20/;

parameter H(i,s) "Tailing Temperature (°C) T is not working here"
/
site1.s1 80
site1.s2 70
site2.s1 85
site2.s2 75
site3.s1 90
site3.s2 65
/;


parameter E(s) "efficiency of energy conversion"
/
s1 0.85,
s2 0.80
/;

parameter Price(t) "electricity price ($/MWh)"
/
t1*t20 30
/ ;

parameter WaterUse(i,s) "water usage per scenario at each site (m3)"
/
site1.s1 100,
site1.s2 120,
site2.s1 90,
site2.s2 110,
site3.s1 95,
site3.s2 105
/;

parameter WaterLimit(i) "maximum allowed water usage per site (m3)"
/
site1 110,
site2 100,
site3 100
/;


binary variable X(i,s)      "1 scenario is selected for site i";
positive variable P(i,s,t)  "power output at site i, scenario s, time t";
positive variable R(i,s,t) "revenue from energy generation";
variable Energy_total       "total energy recovered (MWh)";
variable Revenue_total      "total revenue ($)";


equation 
eq_power_output(i,s,t) "define power output",
eq_energy_total        "total energy recovered",
eq_scenario_limit(i)   "only one scenario per site",
eq_revenue_calc(i,s,t) "revenue calculation",
eq_revenue_total       "total revenue",
eq_water_limit(i)      "environmental constraint: water usage"
;

eq_power_output(i,s,t).. 
P(i,s,t) =e= H(i,s) * E(s) * X(i,s);

eq_energy_total..
Energy_total =e= sum((i,s,t), P(i,s,t));

eq_scenario_limit(i)..
sum(s, X(i,s)) =l= 1;

eq_revenue_calc(i,s,t)..
R(i,s,t) =e= P(i,s,t) * Price(t);

eq_revenue_total..
Revenue_total =e= sum((i,s,t), R(i,s,t));

eq_water_limit(i)..
sum(s, WaterUse(i,s) * X(i,s)) =l= WaterLimit(i);

model energy_model 
/eq_power_output, eq_energy_total, eq_scenario_limit,
eq_revenue_calc, eq_revenue_total, eq_water_limit/;


solve energy_model using mip maximizing Energy_total;


display Energy_total.l, Revenue_total.l, X.l, P.l, R.l;

execute_unload 'energy_recovery.gdx';

$exit
