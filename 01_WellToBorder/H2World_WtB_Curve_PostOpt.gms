* Initialize sets
* Definition der Sets für Commodities und Jahre
Sets
   i       Commodities        /NH3, GH2, LH2/
   y       Years              /2030, 2040/
   n       countries          /AE, US, AU, CL, OM, SA, MA, NO, TN, DZ/
   r       renewable techs    /PV, wind_onshore, wind_offshore_A/
   c       resource classes   /2, 3, 4/
   d       distance to shore  /D1, D2, D3/
   h       hours              /h1*h2190/
   
;

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

$onMulti

* GH2 2030 
$gdxin "C:\Users\HP_Genge\Desktop\H2World_20231018\04_AmmoniaPaper\WellToBorder\Result_H2Worl_WtB_20250116_GH2_2030.gdx"
$load n r c d i y h 
$load cost_r cost_e cost_conv cost_batt cost_pipe_ex cost_pipe_internat cost_ship cf_r p eff_e cost_desal eff_comm eff_comm_new q_el_comm q_el_DAC eff_batt dem_eu 
$load CAP_R CAP_BATT CAP_E CAP_COMM Q_EL Q_COMM SOC_BATT Q_BATT_OUT Q_BATT_IN TC

* GH2 2040 
$gdxin "C:\Users\HP_Genge\Desktop\H2World_20231018\04_AmmoniaPaper\WellToBorder\Result_H2Worl_WtB_20250116_GH2_2040.gdx"
$load n r c d i y h 
$load cost_r cost_e cost_conv cost_batt cost_pipe_ex cost_pipe_internat cost_ship cf_r p eff_e cost_desal eff_comm eff_comm_new q_el_comm q_el_DAC eff_batt dem_eu 
$load CAP_R CAP_BATT CAP_E CAP_COMM Q_EL Q_COMM SOC_BATT Q_BATT_OUT Q_BATT_IN TC

* LH2 2030 
$gdxin "C:\Users\HP_Genge\Desktop\H2World_20231018\04_AmmoniaPaper\WellToBorder\Result_H2Worl_WtB_20250116_LH2_2030.gdx"
$load n r c d i y h 
$load cost_r cost_e cost_conv cost_batt cost_pipe_ex cost_pipe_internat cost_ship cf_r p eff_e cost_desal eff_comm eff_comm_new q_el_comm q_el_DAC eff_batt dem_eu 
$load CAP_R CAP_BATT CAP_E CAP_COMM Q_EL Q_COMM SOC_BATT Q_BATT_OUT Q_BATT_IN TC

* LH2 2040 
$gdxin "C:\Users\HP_Genge\Desktop\H2World_20231018\04_AmmoniaPaper\WellToBorder\Result_H2Worl_WtB_20250116_LH2_2040.gdx"
$load n r c d i y h 
$load cost_r cost_e cost_conv cost_batt cost_pipe_ex cost_pipe_internat cost_ship cf_r p eff_e cost_desal eff_comm eff_comm_new q_el_comm q_el_DAC eff_batt dem_eu 
$load CAP_R CAP_BATT CAP_E CAP_COMM Q_EL Q_COMM SOC_BATT Q_BATT_OUT Q_BATT_IN TC

* NH3 2030 
$gdxin "C:\Users\HP_Genge\Desktop\H2World_20231018\04_AmmoniaPaper\WellToBorder\Result_H2Worl_WtB_20250116_NH3_2030.gdx"
$load n r c d i y h 
$load cost_r cost_e cost_conv cost_batt cost_pipe_ex cost_pipe_internat cost_ship cf_r p eff_e cost_desal eff_comm eff_comm_new q_el_comm q_el_DAC eff_batt dem_eu 
$load CAP_R CAP_BATT CAP_E CAP_COMM Q_EL Q_COMM SOC_BATT Q_BATT_OUT Q_BATT_IN TC

* NH3 2040 
$gdxin "C:\Users\HP_Genge\Desktop\H2World_20231018\04_AmmoniaPaper\WellToBorder\Result_H2Worl_WtB_20250116_NH3_2040.gdx"
$load n r c d i y h 
$load cost_r cost_e cost_conv cost_batt cost_pipe_ex cost_pipe_internat cost_ship cf_r p eff_e cost_desal eff_comm eff_comm_new q_el_comm q_el_DAC eff_batt dem_eu 
$load CAP_R CAP_BATT CAP_E CAP_COMM Q_EL Q_COMM SOC_BATT Q_BATT_OUT Q_BATT_IN TC

$offMulti

* Nach dem Einlesen aller Dateien und nachdem das Modell gelöst wurde (die .l Werte vorliegen),
* führen wir nun die angefragten Berechnungen durch:

*execute_unload 'check.gdx'
*$stop

Parameters
    Report_Q_COMM(n,r,c,i,y,d)       "Total commodity production in MWh"
    LCOC_Electricity(n,r,c,i,y,d)    "Costs of electricity"
    LCOC_Battery(n,r,c,i,y,d)        "Cost of battery storage"
    LCOC_Electrolysis(n,r,c,i,y,d)   "Cost of electrolysis"
    LCOC_Conversion(n,r,c,i,y,d)     "Cost of conversion"
    LCOC_InlandPipeEx(n,r,c,i,y,d)   "Cost of inland pipeline export"
    LCOC_InterPipe(n,r,c,i,y,d)      "Cost of international pipelines"
    LCOC_Ship(n,r,c,i,y,d)           "Cost of shipping"
    LCOC_Border(n,r,c,i,y,d)         "Marginal cost for each combination"
    price(i,y)                       "Maximum marginal cost per commodity and year"
    Total_CF_R(n,r,c,d)
;

* Effizienz für conversion anpassen, falls nicht bereits geschehen
eff_comm_new(i,y) = eff_comm(i)*eff_e(y);

Report_Q_COMM(n,r,c,i,y,d)  = sum(h, Q_COMM.l(h,n,r,c,i,y,d)) * 1000;

LCOC_Electricity(n,r,c,i,y,d)   = ((cost_r(n,r,y) * CAP_R.l(n,r,c,i,y,d)*1000) / (Report_Q_COMM(n,r,c,i,y,d) + 1e-6));
LCOC_Battery(n,r,c,i,y,d)       = ((cost_batt(n,y)*CAP_BATT.l(n,r,c,i,y,d)*1000)/(Report_Q_COMM(n,r,c,i,y,d)+1e-6));
LCOC_Electrolysis(n,r,c,i,y,d)  = ((cost_e(n,y)*CAP_E.l(n,r,c,i,y,d)*1000) 
                                   + (cost_desal*Report_Q_COMM(n,r,c,i,y,d)/eff_comm_new(i,y))) 
                                   / (Report_Q_COMM(n,r,c,i,y,d)+1e-6);
LCOC_Conversion(n,r,c,i,y,d)    = ((cost_conv(n,i,y)*CAP_COMM.l(n,r,c,i,y,d)*1000)/(Report_Q_COMM(n,r,c,i,y,d)+1e-6));
LCOC_InlandPipeEx(n,r,c,i,y,d)  = ((cost_pipe_ex(n,y,d)*Report_Q_COMM(n,r,c,i,y,d)/eff_comm_new(i,y)) 
                                   / (Report_Q_COMM(n,r,c,i,y,d)+1e-6));
LCOC_InterPipe(n,r,c,i,y,d)     = ((cost_pipe_internat(n,i,y)*Report_Q_COMM(n,r,c,i,y,d)/eff_comm_new(i,y)) 
                                   / (Report_Q_COMM(n,r,c,i,y,d)+1e-6));
LCOC_Ship(n,r,c,i,y,d)          = ((cost_ship(n,i)*Report_Q_COMM(n,r,c,i,y,d))/(Report_Q_COMM(n,r,c,i,y,d)+1e-6));

LCOC_Border(n,r,c,i,y,d) =
                            (
                                (cost_r(n,r,y)*CAP_R.l(n,r,c,i,y,d)*1000)
                              + (cost_batt(n,y)*CAP_BATT.l(n,r,c,i,y,d)*1000)
                              + (cost_e(n,y)*CAP_E.l(n,r,c,i,y,d)*1000)
                              + (cost_conv(n,i,y)*CAP_COMM.l(n,r,c,i,y,d)*1000)
                              + (cost_desal*Report_Q_COMM(n,r,c,i,y,d)/eff_comm_new(i,y))
                              + (cost_pipe_ex(n,y,d)*Report_Q_COMM(n,r,c,i,y,d)/eff_comm_new(i,y))
                              + (cost_pipe_internat(n,i,y)*Report_Q_COMM(n,r,c,i,y,d)/eff_comm_new(i,y))
                              + (cost_ship(n,i)*Report_Q_COMM(n,r,c,i,y,d))
                            ) / (Report_Q_COMM(n,r,c,i,y,d) + 1e-6);


* Bestimme maximalen Grenzkostenpreis über alle Länder, Ressourcenklassen, etc.
price(i,y) = smax((n,r,c,d), LCOC_Border(n,r,c,i,y,d));

* Berechnung der Summe der Kapazitätsfaktoren über Stunden
Total_CF_R(n,r,c,d) = sum(h, cf_r(h,n,r,c,d)) * 4;

* Abschließend können wir die berechneten Parameter erneut ausgeben, wenn gewünscht:
execute_unload 'PostOpt_ImportPrice.gdx';




