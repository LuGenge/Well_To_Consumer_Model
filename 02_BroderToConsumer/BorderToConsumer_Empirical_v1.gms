***********************************************************************
***********************************************************************

* Definition der Sets
Sets
    i  'Commodities'                                    /NH3, LH2, GH2/
    y  'Years'                                          /2030, 2040/
*$onText
j / basicchem_ineos, basicchem_basf, basicchem_skw, basicchem_yara, 
       fuel_rhine_ludwigshafen, power_Altbach, power_SchwarzePumpe, power_Leipzig, 
       fcv_berlin, fcv_muenchen, feedstock_steel_38239, feedstock_chemical_50389, 
       feedstock_chemical_04564, feedstock_refinery_84489 /
*$offText
*    j                                                   /Dist300Dem1000/
    k  'Transport modes'                                /truck, rail, pipe/
    a  'Desired products'                               /GH2, NH3/
        valid_comb(i,k) 'Valid combinations of commodities and transport modes';

* Define valid combinations
valid_comb('NH3', 'truck') = yes;
valid_comb('NH3', 'rail')  = yes;
valid_comb('NH3', 'pipe')  = yes;
valid_comb('LH2', 'truck') = yes;
valid_comb('LH2', 'rail')  = yes;
valid_comb('GH2', 'pipe')  = yes;
;

***********************************************************************
* Parameters for distance and demand
Parameters
    p(i,y)                              '€/MWh - Optimized price of commodity at the border derived from marginal costs of the last supplier in year y'
    c_TankLoc(i)                        '€/MWh - Local storage costs for each commodity i at the consumer site j'
    c_ReConv(i,y,a)                     '€/MWh - Combined costs of conversion and reconversion processes of the commodity i to the desired product a in year y'
    c_StorConv(i,y,a)
    c_Trans(i,k,j)                      '€ - Full costs of transporting commodities (annualized CAPEX and OPEX) for each commodity i, transport mode k, and consumer site j'
    sf_i(i)
    dem(y,j,a)                            'MWh - Yearly demand of each consumer site j and desired product a in year y'
    cap_eff(i,k,j)                      'MWh - Yearly efficient transport capacity per trailer depending on commodity i, transport mode k, and consumer site j'
    eff_Consumer(i,a)                   'MWi/MWi - Overall efficiency of the consumer sites j supply chain depending on the commodity i and the desired product a'
    eff_Trans(i)                        'MWi/MWi - Transport efficiency of each commodity i'
    eff_TankLoc                         'MWi/MWi - Local storage tank efficiency for each commodity i'
    eff_ReConv(i,a)                     'MWi/MWi - Combined efficiency of reconversion and conversion processes for each commodity i to produce the desired product a'
    cap_ctr_ratio(i,k,j)
;

* Read parameters from EXCEL

$onecho > ImportAll.tmp
par=c_Trans             Rng=Empirical!B769:E866       Cdim=0 Rdim=3
par=cap_eff             Rng=Empirical!B1850:E1947     Cdim=0 Rdim=3
par=dem                 Rng=Empirical!B2391:E2418     Cdim=0 Rdim=3
$offecho

$call GDXXRW I=Input_H2World.xlsx O=OutputALL.gdx @ImportAll.tmp
$gdxin OutputALL.gdx
$Load  c_Trans, cap_eff, dem
$offUNDF
*
* Initialize Parameters

* Initialize the price
p('NH3','2030')             = 141.51;
p('NH3','2040')             = 123.03;
p('LH2','2030')             = 167;
p('LH2','2040')             = 137;
p('GH2','2030')             = 98.69;
p('GH2','2040')             = 84.37;

* Initialize the local storage tanks
c_TankLoc('NH3')         = 0.16;
c_TankLoc('LH2')         = 1.70;
c_TankLoc('GH2')         = 0.00;

sf_i('NH3')                 = 1;
sf_i('LH2')                 = 1;
sf_i('GH2')                 = 1;

eff_Trans('NH3')            = 1;
eff_Trans('LH2')            = 0.99;
eff_Trans('GH2')            = 1;

eff_TankLoc                 = 1;

eff_ReConv('NH3','NH3')     = 1;
eff_ReConv('LH2','NH3')     = 0.95 * 0.85;
eff_ReConv('GH2','NH3')     = 0.85;
eff_ReConv('NH3','GH2')     = 0.78;
eff_ReConv('LH2','GH2')     = 0.95;
eff_ReConv('GH2','GH2')     = 1;

eff_Consumer(i,a)           = eff_Trans(i) * eff_TankLoc * eff_ReConv(i,a);

c_ReConv('NH3', '2030', 'NH3') = 0;
c_ReConv('LH2', '2030', 'NH3') = 33;
c_ReConv('GH2', '2030', 'NH3') = 26;
c_ReConv('NH3', '2030', 'GH2') = 8;
c_ReConv('LH2', '2030', 'GH2') = 6;
c_ReConv('GH2', '2030', 'GH2') = 0;
c_ReConv('NH3', '2040', 'NH3') = 0;
c_ReConv('LH2', '2040', 'NH3') = 32;
c_ReConv('GH2', '2040', 'NH3') = 27;
c_ReConv('NH3', '2040', 'GH2') = 7;
c_ReConv('LH2', '2040', 'GH2') = 5;
c_ReConv('GH2', '2040', 'GH2') = 0;

*execute_unload 'check.gdx';
*$stop
Scalar 
    scale / 1000000 /;
    
*Scaling
dem(y,j,a)          = dem(y,j,a) * 1/scale;
cap_eff(i,k,j)      = cap_eff(i,k,j) * 1/scale;
c_StorConv(i,y,a)   = (c_TankLoc(i) + c_ReConv(i,y,a));
c_Trans(i,k,j)      = c_Trans(i,k,j) / scale;
p(i,y)              = p(i,y);

cap_ctr_ratio(i,k,j)= c_Trans(i,k,j) / (cap_eff(i,k,j) + 1);




***********************************************************************
* Definition der Variablen
Variables
    Total_Cost                  'Total cost across all dimensions'
    TC_CONSUMER(i,y,k,j,a)         '€/MWh - Total cost in year y at the consumer site j for the desired product a'

Positive Variables
    C_TR(i,y,k,j,a)               '€/MWh - Costs of inland transport from import node to consumer site j, for each commodity i, year y, and transport mode k'
    C_CS(i,y,k,j,a)
    C_PR(i,y,k,j,a)
    Q_TR(i,y,k,j,a)               'MWh - Quantity transported for each commodity i, in year y, transport mode k, and consumer site j'
    Q_PR(i,y,k,j,a)                 'Quantity of procured commodity at the border'

Integer Variables
    I_TR(i,y,k,j,a)                   'Integer number of transport units eg trailers'    
;

***********************************************************************
* Mathematische Formeln in GAMS
Equations
    Total_Cost_Definition
    Objective_Function
    Procurement_Cost
    Inland_Transport_Cost
    Transport_Capacity_Constraint
    Procurement_Constraint
    Facility_Cost
    Demand_Satisfaction
;

Total_Cost_Definition..
Total_Cost =e= sum((i,y,k,j,a)$(valid_comb(i,k) and c_Trans(i,k,j) <> 0 and cap_eff(i,k,j) <> 0)
, TC_CONSUMER(i,y,k,j,a));

Objective_Function(i,y,k,j,a)$(valid_comb(i,k) and c_Trans(i,k,j) <> 0 and cap_eff(i,k,j) <> 0)
..
TC_CONSUMER(i,y,k,j,a) =e= C_PR(i,y,k,j,a) + C_TR(i,y,k,j,a) + C_CS(i,y,k,j,a);

Procurement_Cost(i,y,k,j,a)..
C_PR(i,y,k,j,a) =e= Q_PR(i,y,k,j,a)*p(i,y);

Inland_Transport_Cost(i,y,k,j,a)$(valid_comb(i,k) and c_Trans(i,k,j) <> 0 and cap_eff(i,k,j) <> 0)
..
C_TR(i,y,k,j,a) =e= I_TR(i,y,k,j,a) * c_Trans(i,k,j) * sf_i(i);

Transport_Capacity_Constraint(i,y,k,j,a)$(valid_comb(i,k) and c_Trans(i,k,j) <> 0 and cap_eff(i,k,j) <> 0)
..
I_TR(i,y,k,j,a) * cap_eff(i,k,j) =g= Q_TR(i,y,k,j,a);

Procurement_Constraint(i,y,k,j,a)..
Q_TR(i,y,k,j,a) =l= Q_PR(i,y,k,j,a);

Facility_Cost(i,y,k,j,a)$(valid_comb(i,k) and c_Trans(i,k,j) <> 0 and cap_eff(i,k,j) <> 0)
..
C_CS(i,y,k,j,a) =e= c_StorConv(i,y,a) * Q_TR(i,y,k,j,a);

Demand_Satisfaction(i,y,k,j,a)$(valid_comb(i,k) and c_Trans(i,k,j) <> 0 and cap_eff(i,k,j) <> 0)
..
dem(y,j,a) =l= Q_TR(i,y,k,j,a) * eff_Consumer(i,a);



model H2World_WTT_Distribution /
    Total_Cost_Definition,
    Objective_Function,
    Procurement_Cost,
    Inland_Transport_Cost,
    Transport_Capacity_Constraint,
    Procurement_Constraint,
    Facility_Cost,
    Demand_Satisfaction
/

;

option solver = CPLEX;
option optcr = 0; 

solve H2World_WTT_Distribution using MIP minimizing Total_Cost ;

***********************************************************************
* Berechnung der Kostenkomponenten und Ausgabe
***********************************************************************
Parameters
    Report_Procurement_Cost(i,y,k,j,a)    '€/MWh - Beschaffungskosten pro Kombination i, y, j, a'
    Report_Transport_Cost(i,y,k,j,a)    '€/MWh - Transportkosten pro Kombination i, y, k, j, a'
    Report_Conversion_Cost(i,y,k,j,a)   '€/MWh - Speicher- und Umwandlungskosten pro Kombination i, y, k, j, a'
    Report_Total_Cost(i,y,k,j,a)            '€/MWh - Gesamtkosten für jede Kombination von y, j, a'
    ;
Set
    Report_Min_Combination_Set(i,y,k,j,a) 'Set für die günstigste Kombination von i, k je (y, j, a)'
    ;

* Berechnung der Beschaffungskosten
Report_Procurement_Cost(i,y,k,j,a)$(Q_PR.l(i,y,k,j,a) > 0) = 
    Q_PR.l(i,y,k,j,a) * p(i,y) / dem(y,j,a);

* Berechnung der Transportkosten
Report_Transport_Cost(i,y,k,j,a)$(Q_TR.l(i,y,k,j,a) > 0) = 
    C_TR.l(i,y,k,j,a) / dem(y,j,a);

* Berechnung der Speicher- und Umwandlungskosten
Report_Conversion_Cost(i,y,k,j,a)$(Q_TR.l(i,y,k,j,a) > 0) = 
    C_CS.l(i,y,k,j,a) / dem(y,j,a);

* Gesamtkosten für jede Kombination (y, j, a)
Report_Total_Cost(i,y,k,j,a)$(dem(y,j,a) > 0) = TC_CONSUMER.l(i,y,k,j,a) / dem(y,j,a);

***********************************************************************
* Verteilung von Konsumenten und Transportmodi
***********************************************************************
Parameters
    Report_Distribution(y,a,k)          '% - Verteilung der Konsumenten j pro Jahr, Produkt a und Transportmodus k'
    Total_Consumers(y,a)                'Anzahl der Gesamtkonsumenten pro Jahr und Produkt a'
    Report_Transport_Use(i,y,k,j,a)     'Anzahl der genutzten Transporteinheiten pro Kombination'
    Report_Distribution_i(y,a,k,i)
    ;

* Berechnung der Gesamtkonsumentenanzahl
Total_Consumers(y,a) = sum(j$(dem(y,j,a) > 0), 1);

* Berechnung der Verteilung
Report_Distribution(y,a,k) = 
    100 * sum(j$(dem(y,j,a) > 0), sum(i, (Q_TR.l(i,y,k,j,a) > 0))) / Total_Consumers(y,a);
    
Report_Distribution_i(y,a,k,i) = 
    100 * sum(j$(dem(y,j,a) > 0), (Q_TR.l(i,y,k,j,a) > 0)) / Total_Consumers(y,a);

* Berechnung der genutzten Transporteinheiten
Report_Transport_Use(i,y,k,j,a)$(I_TR.l(i,y,k,j,a) > 0) = I_TR.l(i,y,k,j,a);

***********************************************************************
* Erweiterung: Kosten- und Transportanalysen
***********************************************************************
Parameters
    Avg_Cost_Change(i,k,a)                  'Durchschnittliche Veränderung der Kosten zwischen 2030 und 2040'
    Transport_Cost_Share(i,y,k,j,a)     'Anteil der Transportkosten an den Gesamtkosten'
    Procurement_Cost_Share(i,y,k,j,a)  'Anteil der Beschaffungskosten an den Gesamtkosten'
    Avg_Procurement_Cost_Share(y,a)
    Count(y,a)
    ;

* Durchschnittliche Kostenänderung berechnen
*Avg_Cost_Change(i,k,a) =
*    sum(j$(dem(y,j,a) > 0), 
*        (Report_Total_Cost(i,'2040',k, j, a) - Report_Total_Cost(i,'2030', k,j, a)) /
*        Report_Total_Cost(i,'2030', k,j, a) * 100) /
*    sum(j$(Report_Total_Cost(i,'2030', k,j, a) > 0), 1);

* Anteil der Transportkosten an den Gesamtkosten
Transport_Cost_Share(i,y,k,j,a)$(Report_Total_Cost(i,y,k,j,a) > 0 and Q_TR.l(i,y,k,j,a) > 0) = 
    Report_Transport_Cost(i,y,k,j,a) / Report_Total_Cost(i,y,k,j,a) * 100;

* Anteil der Beschaffungskosten an den Gesamtkosten
Procurement_Cost_Share(i,y,k,j,a)$(Report_Total_Cost(i,y,k,j,a) > 0 and Q_PR.l(i,y,k,j,a) > 0) = 
    Report_Procurement_Cost(i,y,k,j,a) / Report_Total_Cost(i,y,k,j,a) * 100;

* Compute the average procurement cost share across valid (k,j) pairs
Count(y,a) = sum((i,k,j)$(Report_Total_Cost(i,y,k,j,a) > 0 and Q_PR.l(i,y,k,j,a) > 0), 1);

Avg_Procurement_Cost_Share(y,a)$(Count(y,a) > 0) =
    sum((i,k,j)$(Report_Total_Cost(i,y,k,j,a) > 0 and Q_PR.l(i,y,k,j,a) > 0), Procurement_Cost_Share(i,y,k,j,a)) / Count(y,a);

***********************************************************************
* Erweiterung: Speicherung mehrfacher Einträge (Transportmodi)
***********************************************************************
Parameters
    Report_Trans_Eff(i,y,k,j,a) 'Transporteffizienz Q_TR > 0'
    Report_DoubleIK(i,y,k,j,a)  'Markierung mehrfacher Einträge';
    
* Transporteffizienz berechnen
Report_Trans_Eff(i,y,k,j,a)$(Q_TR.l(i,y,k,j,a) > 0) = dem(y,j,a) / Q_TR.l(i,y,k,j,a);

* Hilfsparameter zur Markierung mehrfacher Einträge
Parameters
    Multi_Transport_Count(y,j,a) 'Anzahl der aktiven Kombinationen von i,k für jede (y,j,a)';

* Berechnung der Anzahl aktiver Kombinationen
Multi_Transport_Count(y,j,a) = 
    sum((i,k)$(Q_TR.l(i,y,k,j,a) > 0), 1);

* Markierung mehrfacher Einträge, wenn mehr als eine Kombination aktiv ist
Report_DoubleIK(i,y,k,j,a)$(Multi_Transport_Count(y,j,a) > 1 and Q_TR.l(i,y,k,j,a) > 0) = 1;

* Berechnung der effektiven Auslastung
Parameters Effective_Load(y,j,a) 'Effektive Auslastung';
Effective_Load(y,j,a)$(sum((i,k), I_TR.l(i,y,k,j,a)) > 0) =
    sum((i,k), Q_TR.l(i,y,k,j,a)) / sum((i,k),(I_TR.l(i,y,k,j,a) * cap_eff(i,k,j)));


Parameters
Possible_Procurement(y,i,a)
Possible_StorConv(y,i,a)
;

Possible_Procurement(y,i,a) = p(i,y) / eff_Consumer(i,a);

Possible_StorConv(y,i,a) = c_StorConv(i,y,a)

Parameters
    Min_Transport_Cost(y,i,a)    'Minimale Transportkosten für jede Kombination aus Jahr y, Commodity i und Produkt a'
    Max_Transport_Cost(y,i,a)    'Maximale Transportkosten für jede Kombination aus Jahr y, Commodity i und Produkt a';

* Berechnung der minimalen Transportkosten für jede Kombination aus y, i, a
Min_Transport_Cost(y,i,a) = smin((k,j)$(Report_Transport_Cost(i,y,k,j,a) > 0), Report_Transport_Cost(i,y,k,j,a));

* Berechnung der maximalen Transportkosten für jede Kombination aus y, i, a
Max_Transport_Cost(y,i,a) = smax((k,j)$(Report_Transport_Cost(i,y,k,j,a) > 0), Report_Transport_Cost(i,y,k,j,a));


execute_unload 'Results_BtC_Opt_EmpALL.gdx';

***********************************************************************
* Export der Ergebnisse
***********************************************************************
*$onText

execute_unload 'output_results.gdx', Report_Total_Cost, Report_Transport_Use, Report_Procurement_Cost,
    Report_Transport_Cost, Report_Conversion_Cost, Avg_Cost_Change, Transport_Cost_Share,
    Procurement_Cost_Share, Report_Distribution, Total_Consumers, Report_Trans_Eff, Report_DoubleIK, Effective_Load;

*$stop
$onecho >out.tmp

    par=Report_Transport_Use                rng=Report_Transport_Use!A2                 rdim=5 cdim=0
    par=Report_Distribution                 rng=Report_Distribution!A2                  rdim=3 cdim=0
    par=Report_Procurement_Cost             rng=Report_Procurement_Cost!A2              rdim=5 cdim=0
    par=Report_Transport_Cost               rng=Report_Transport_Cost!A2                rdim=5 cdim=0
    par=Report_Conversion_Cost              rng=Report_Conversion_Cost!A2               rdim=5 cdim=0
    par=Report_Total_Cost                   rng=Report_Total_Cost!A2                    rdim=5 cdim=0
    par=Effective_Load                      rng=Effective_Load!A2                       rdim=3 cdim=0

$offecho


EXECUTE 'gdxxrw output_results.gdx o=01_Results_BtC_Ammonia_Opt_Empirical.xlsx  @out.tmp';

*$offtext
$stop