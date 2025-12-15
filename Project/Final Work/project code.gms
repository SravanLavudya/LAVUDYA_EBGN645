
$call csv2gdx "C:/Users/srava/Downloads/Global_mining/MRDS_top100.csv" output="C:/Users/srava/Downloads/Global_mining/MRDS_top100.gdx" id=mrds index=1 values=2..8 useHeader=Y
$ifE errorlevel<>0 $abort 'CSV conversion failed';

Set
    Dim1 "Raw site set from GDX"
    Dim2 "Raw field names from GDX";

Parameter mrds(Dim1,Dim2) "Full imported table";

$gdxin "C:/Users/srava/Downloads/Global_mining/MRDS_top100.gdx"
$load Dim1 Dim2 mrds
$gdxin

* Model domains as subsets of GDX domain sets
Set
    i(Dim1) "Mine sites (model domain)" /#Dim1/
    f(Dim2) "Fields (model domain)"     /#Dim2/;

display i, f;

Parameter
    Heat(i)       "Heat (from CSV, units as given)"
    Eff(i)        "Conversion efficiency (fraction)"
    WaterUse(i)   "Water use per site"
    WaterLimit(i) "Maximum allowable water use per site"
    SysSize(i)    "Maximum system size (capacity cap)"
    CAPEX(i)      "CAPEX in USD (not used in objective here)"
    OPEX(i)       "OPEX in USD/year (not used in objective here)";

Heat(i)       = mrds(i,"Heat");
Eff(i)        = mrds(i,"Efficiency");
WaterUse(i)   = mrds(i,"WaterUse");
WaterLimit(i) = mrds(i,"WaterLimit");
SysSize(i)    = mrds(i,"SystemSize");
CAPEX(i)      = mrds(i,"CAPEX_USD");
OPEX(i)       = mrds(i,"OPEX_USD");

display Heat, SysSize, CAPEX;

*step 1

Set t "Time periods (years)" / t1*t20 /;

Scalar
    hoursPerYear "Hours per period (assumed yearly)" / 8760 /;

Positive Variable
    x(i)   "Fraction of site built (0–1, relaxed binary)"
    K(i)   "Installed capacity at site i (MW)"
    P(i,t) "Power/energy produced at site i in period t (MWh)";

Variable
    Energy_total "Total energy recovered across all sites and periods (MWh)";

* Bound x between 0 and 1 (continuous, not binary)
x.up(i) = 1;

Equation
    cap_limit_lp(i)       "Capacity cap: K(i) <= SysSize(i) * x(i)"
    cap_to_energy_lp(i,t) "Capacity to energy: P(i,t) <= K(i)*hoursPerYear"
    heat_limit_lp(i,t)    "Heat availability: P(i,t) <= Heat(i)*Eff(i)*x(i)"
    water_limit_lp(i)     "Water limit: WaterUse(i)*x(i) <= WaterLimit(i)"
    objEnergy_lp          "Energy objective: total energy";

cap_limit_lp(i)..       K(i)      =L= SysSize(i) * x(i);
cap_to_energy_lp(i,t).. P(i,t)    =L= K(i) * hoursPerYear;
heat_limit_lp(i,t)..    P(i,t)    =L= Heat(i) * Eff(i) * x(i);
water_limit_lp(i)..     WaterUse(i)*x(i) =L= WaterLimit(i);

objEnergy_lp..
    Energy_total =E= sum((i,t), P(i,t));

Model TailingsLP / cap_limit_lp, cap_to_energy_lp, heat_limit_lp, water_limit_lp, objEnergy_lp /;

Solve TailingsLP using lp maximizing Energy_total;

display Energy_total.l;

Parameter
    xLP(i)   "Site build fraction (LP solution)"
    KLP(i)   "Installed capacity (MW, LP solution)";

xLP(i) = x.l(i);
KLP(i) = K.l(i);

display xLP, KLP;

*step 2
Scalar alpha "Nonlinear penalty coefficient on capacity^2" / 0.01 /;

Positive Variable
    x_nl(i)   "Fraction of site built (0–1, NLP version)"
    K_nl(i)   "Installed capacity at site i (MW, NLP)"
    P_nl(i,t) "Power/energy produced at site i in period t (MWh, NLP)";

Variable
    Energy_total_nl "Total energy recovered (NLP)";

x_nl.up(i) = 1;

Equation
    cap_limit_nl(i)
    cap_to_energy_nl(i,t)
    heat_limit_nl(i,t)
    water_limit_nl(i)
    objEnergy_nl;

cap_limit_nl(i)..       K_nl(i)      =L= SysSize(i) * x_nl(i);
cap_to_energy_nl(i,t).. P_nl(i,t)    =L= K_nl(i) * hoursPerYear;

* NONLINEAR heat constraint with diminishing returns in K_nl
heat_limit_nl(i,t)..    
    P_nl(i,t) =L= Heat(i) * Eff(i) * x_nl(i) - alpha * sqr(K_nl(i));

water_limit_nl(i)..     
    WaterUse(i) * x_nl(i) =L= WaterLimit(i);

objEnergy_nl..
    Energy_total_nl =E= sum((i,t), P_nl(i,t));

Model TailingsNLP / cap_limit_nl, cap_to_energy_nl, heat_limit_nl, water_limit_nl, objEnergy_nl /;

Solve TailingsNLP using nlp maximizing Energy_total_nl;

display Energy_total_nl.l;

Parameter
    xNLP(i)  "Site build fraction (NLP solution)"
    KNLP(i)  "Installed capacity (MW, NLP solution)";

xNLP(i) = x_nl.l(i);
KNLP(i) = K_nl.l(i);

display xNLP, KNLP;

execute_unload "final_energy_recovery_mrds.gdx";
$exit