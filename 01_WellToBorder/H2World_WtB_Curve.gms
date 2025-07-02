********************************************************************************
********************************************************************************
********************************************************************************
Sets
n countries                 /AE, US, AU, CL, OM, SA, MA, NO, TN, DZ/
*
r renewable technologies    /PV, wind_onshore, wind_offshore_A, wind_offshore_B/
*
c resource classes          /0, 1, 2, 3, 4/
*
d distance to shore         /D1, D2, D3, D4, D5, D6, D7/
*
i commodities               /GH2, LH2, NH3/
*
y years                     /2030, 2040/
*
h hours                     /h1*h2190/
*2190

allowedGH2(n)               /MA, NO, TN, DZ/
;

********************************************************************************

Parameters

*Renewable energy sources
cost_r(n,r,y)               Full costs of RES (annualisied capex and opex)
cf_r(h,n,r,c,d)             Monthly capacity factor of renewables in country n
p(n,r,c,d)                  Potential capacity of renewable technology r for given year country n and resource class c in GW

*Electrolyser
cost_e(n,y)                 Full costs of electrolysis (annualisied capex and opex)
eff_e(y)                    Efficiency of electrolysers
cost_desal                  Combines Costs of desal_cost and water transport through pipeline to electrolyzer in EUR per MWh

*conversion
cost_conv(n,i,y)            Full costs of conversion (annualisied capex and opex)
eff_comm(i)                 Efficiency of conversion
eff_comm_new(i,y)           Combined efficiency of eff_comm and q_el_conv 
q_el_comm(i)                Quantity of electricity needed to run the conversion process
q_el_DAC(i,y)               Quantity of electricity needed to run the conversion process

*Storage
cost_batt(n,y)              Full costs of battery storage (annualisied capex and opex)
eff_batt                    Efficiency of battery storage

*Transport
cost_pipe_ex(n,y,d)         Inland pipeline transport costs from production location to harbor in EUR per MWh_H2
cost_pipe_internat(n,i,y)   Pipeline transport costs from production location to harbor in EUR per MWh_H2
cost_ship(n,i)              Shipping costs 

*Others
dem_eu(y)                   European yearly demand in TWh
;

*Read parameters from EXCEL
$onecho > ImportAll.tmp
par=cost_r              Rng=GAMS_Input!B2:AC102       Cdim=1 Rdim=2
par=cost_e              Rng=GAMS_Input!B106:AB131     Cdim=1 Rdim=1
par=cost_conv           Rng=GAMS_Input!B135:AC210     Cdim=1 Rdim=2
par=cost_batt           Rng=GAMS_Input!B214:AB239     Cdim=1 Rdim=1
par=cost_pipe_ex        Rng=International!B96:J246    Cdim=1 Rdim=2
par=cost_pipe_internat  Rng=International!B64:I89     Cdim=1 Rdim=2
par=cost_ship           Rng=International!B21:E46     Cdim=1 Rdim=1
$offecho

$call GDXXRW I=Input_H2World_GAMSINPUT.xlsx O=OutputALL.gdx @ImportAll.tmp
$gdxin OutputALL.gdx
$Load  cost_r, cost_e, cost_conv, cost_pipe_ex, cost_pipe_internat, cost_ship, cost_batt
$offUNDF

$onecho > ImportAll.tmp
par=cf_r                Rng=CF_Import_4H!A1:K512561   Cdim=1 Rdim=4
par=p                   Rng=CAP!A2:J236               Cdim=1 Rdim=3
$offecho

$call GDXXRW I=Input_CF_Import.xlsx O=OutputALL.gdx @ImportAll.tmp
$gdxin OutputALL.gdx
$Load  cf_r, p
$offUNDF
*
*$stop

*ALL is Now in MWh

*Define Parameters
eff_e('2030')           = 0.67              ;  
eff_e('2040')           = 0.69              ;  

cost_desal              = 1.92              ;


eff_comm('NH3')         = 0.85              ;
eff_comm('LH2')         = 0.90              ;
eff_comm('GH2')         = 1.00              ;

q_el_comm('NH3')        = 0.29              ;
q_el_comm('LH2')        = 0.20              ;
q_el_comm('GH2')        = 0.00              ;

eff_comm_new(i,y)       = (eff_e(y) * eff_comm(i))/(1 + q_el_comm(i));

eff_batt                = 0.98              ;

*Adjusted to 3000 TWh for the supply curve 
dem_eu('2030')          = 3000              ; 
dem_eu('2040')          = 3000              ;

*Actual European mean demands used to compute the import prices
$onText
dem_eu('2025')          = 28.5              ;
dem_eu('2030')          = 306               ; 
dem_eu('2035')          = 583.5             ;
dem_eu('2040')          = 861               ;
dem_eu('2045')          = 958.5             ;
dem_eu('2050')          = 1056              ;
$offText

Parameter
epsilon / 1e-3 /; 
      
*execute_unload 'check.gdx'
*$stop  


********************************************************************************
Variable
TC                              Total minimum cost of Ammonia per year
;

Positive variables
CAP_R(n,r,c,i,y,d)              Capacity of renewable energy sources
CAP_BATT(n,r,c,i,y,d)           Capacity of battery storage
CAP_E(n,r,c,i,y,d)              Capacity of electrolysers
CAP_COMM(n,r,c,i,y,d)           Capacity of Conversion plant

Q_EL(h,n,r,c,i,y,d)             Electricity production MWh
Q_COMM(h,n,r,c,i,y,d)           Commodity production in MWh

SOC_BATT(h,n,r,c,i,y,d)         State of charge of the storage s MWh
Q_BATT_OUT(h,n,r,c,i,y,d)       Electricity output from battery MWh
Q_BATT_IN(h,n,r,c,i,y,d)        Electricity input from battery MWh
;
*$stop

********************************************************************************
******************************************************************************
Equations
******************************************************************************
******************************************************************************

* Objective: Minimize total system cost
eqObj                          "Objective function: Minimize total costs"

* General constraints related to commodity flows
eqForbiddenGH2Comm             "No GH2 commodity flow allowed in restricted nodes"
eqForbiddenGH2El               "No GH2 electricity flow allowed in restricted nodes"
eqTotalDemand                  "Total supplied commodity must meet EU demand"
eqNoCrossCountryFlow           "Disallow cross-border flows from Q_COMM to Q_EL"

* Electricity production constraints
eqEnergyBalance                "Energy balance linking Q_COMM, Q_EL, Q_BATT_IN, and Q_BATT_OUT"
eqRESCapacityBound             "Renewable production limited by installed capacity and CF"
eqRESCapLink                   "Link renewable capacity variable to parameter p"
eqElecCapacityBound            "Ensure electricity production <= installed capacity"
eqCommCapacityBound            "Ensure commodity production <= installed converter capacity"
eqMinLocalProduction           "Enforce minimum local production if RES capacity is installed"

* Battery storage constraints
eqBatteryInit                  "Initialize battery state of charge in first hour"
eqBatteryInBound               "Battery charging limited by battery capacity"
eqBatteryOutBound              "Battery discharging limited by battery capacity"
eqBatteryCapacityBound         "SOC limited by max battery capacity"
eqBatteryStateUpdate           "State of charge update equation across time steps"
;
******************************************************************************
* Equation Definitions
******************************************************************************

eqObj..    TC =e= 
   sum((n,r,c,i,y,d), (
      (cost_r(n,r,y)/1000            * CAP_R(n,r,c,i,y,d))
    + (cost_batt(n,y)/1000           * CAP_BATT(n,r,c,i,y,d))
    + (cost_e(n,y)/1000              * CAP_E(n,r,c,i,y,d))
    + (cost_conv(n,i,y)/1000         * CAP_COMM(n,r,c,i,y,d))
    + (cost_desal/1000               * (sum(h, Q_COMM(h,n,r,c,i,y,d))/eff_comm(i)))
    + (cost_pipe_ex(n,y,d)/1000      * (sum(h, Q_COMM(h,n,r,c,i,y,d))/eff_comm(i)))
    + (cost_pipe_internat(n,i,y)/1000 * sum(h, Q_COMM(h,n,r,c,i,y,d)))
    + (cost_ship(n,i)/1000           * sum(h, Q_COMM(h,n,r,c,i,y,d)))
   ))
;

eqForbiddenGH2Comm(h,n,r,c,i,y,d)$(not allowedGH2(n))..   
   Q_COMM(h,n,r,c,'GH2',y,d) =e= 0
;

eqForbiddenGH2El(h,n,r,c,i,y,d)$(not allowedGH2(n))..     
   Q_EL(h,n,r,c,'GH2',y,d)   =e= 0
;

eqTotalDemand(i,y)..           
   sum((h,n,r,c,d), Q_COMM(h,n,r,c,i,y,d)) =e= dem_eu(y)*1000
;

eqNoCrossCountryFlow(h,n,r,c,i,y,d)..
   Q_COMM(h,n,r,c,i,y,d) =l= Q_EL(h,n,r,c,i,y,d)
;


******************************************************************************
* Electricity Production
******************************************************************************

* Energy balance: Q_COMM = (Q_EL - Q_BATT_IN + Q_BATT_OUT) * eff_comm_new
eqEnergyBalance(h,n,r,c,i,y,d)..
   Q_COMM(h,n,r,c,i,y,d) =e= (Q_EL(h,n,r,c,i,y,d) - Q_BATT_IN(h,n,r,c,i,y,d) + Q_BATT_OUT(h,n,r,c,i,y,d)) * eff_comm_new(i,y)
;

* Renewable production bound by installed capacity and capacity factors
eqRESCapacityBound(h,n,r,c,i,y,d)..
   Q_EL(h,n,r,c,i,y,d) =l= CAP_R(n,r,c,i,y,d)*cf_r(h,n,r,c,d)*8760/card(h)
;

* Link renewable capacity variable to parameter p
eqRESCapLink(n,r,c,i,y,d)..
   CAP_R(n,r,c,i,y,d) =l= p(n,r,c,d)
;

* Electricity production limited by installed electricity capacity
eqElecCapacityBound(h,n,r,c,i,y,d)..
   Q_COMM(h,n,r,c,i,y,d)/eff_e(y) =l= CAP_E(n,r,c,i,y,d)*8760/card(h)
;

* Commodity production limited by installed converter capacity
eqCommCapacityBound(h,n,r,c,i,y,d)..
   Q_COMM(h,n,r,c,i,y,d)/eff_comm(i) =l= CAP_COMM(n,r,c,i,y,d)*8760/card(h)
;

* Enforce that if there is RES capacity, there should be some local production
eqMinLocalProduction(n,r,c,i,y,d)..
   sum(h, Q_COMM(h,n,r,c,i,y,d)) =g= epsilon*CAP_R(n,r,c,i,y,d)
;


******************************************************************************
* Storage: Battery Constraints
******************************************************************************

* Initialize battery state of charge
eqBatteryInit(h,n,r,c,i,y,d)$(ord(h) eq 1)..
   SOC_BATT(h,n,r,c,i,y,d) =e= 0
;

* Battery charging limited by battery capacity
eqBatteryInBound(h,n,r,c,i,y,d)..
   Q_BATT_IN(h,n,r,c,i,y,d) =l= CAP_BATT(n,r,c,i,y,d)*8760/card(h)
;

* Battery discharging limited by battery capacity
eqBatteryOutBound(h,n,r,c,i,y,d)..
   Q_BATT_OUT(h,n,r,c,i,y,d) =l= CAP_BATT(n,r,c,i,y,d)*8760/card(h)
;

* SOC limited by max battery capacity (6 hours storage equivalent)
eqBatteryCapacityBound(h,n,r,c,i,y,d)..
   SOC_BATT(h,n,r,c,i,y,d) =l= CAP_BATT(n,r,c,i,y,d)*8760/card(h)*6
;

* SOC update from previous timestep, considering battery efficiency
eqBatteryStateUpdate(h,n,r,c,i,y,d)$(ord(h) gt 1)..
   SOC_BATT(h,n,r,c,i,y,d) =e= SOC_BATT(h-1,n,r,c,i,y,d)
                             + Q_BATT_IN(h,n,r,c,i,y,d)*eff_batt
                             - Q_BATT_OUT(h,n,r,c,i,y,d)/eff_batt
;


******************************************************************************
* Model Definition
******************************************************************************
model H2World_WTT /
   eqObj,

   eqForbiddenGH2Comm,
   eqForbiddenGH2El,
   eqTotalDemand,
   eqNoCrossCountryFlow,

   eqEnergyBalance,
   eqRESCapacityBound,
   eqRESCapLink,
   eqElecCapacityBound,
   eqCommCapacityBound,
   eqMinLocalProduction,

   eqBatteryInit,
   eqBatteryInBound,
   eqBatteryOutBound,
   eqBatteryCapacityBound,
   eqBatteryStateUpdate
/;
*$stop
option solver = CPLEX;

solve H2World_WTT using LP minimizing TC;

execute_unload 'Result_WtB.gdx'
$stop  
