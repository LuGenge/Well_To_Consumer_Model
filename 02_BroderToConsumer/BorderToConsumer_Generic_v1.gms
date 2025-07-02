***********************************************************************
***********************************************************************

* Definition der Sets
Sets
    i  'Commodities'                                    /NH3, LH2, GH2/
    y  'Years'                                          /2030, 2040/
*2040
*$onText
    j  'Empirical locations'
                                                        /Dist5Dem10, Dist5Dem20, Dist5Dem40, Dist5Dem100, Dist5Dem200
                                                        Dist5Dem400, Dist5Dem1000, Dist5Dem2000, Dist5Dem4000, Dist5Dem10000
                                                        Dist100Dem10, Dist100Dem20, Dist100Dem40, Dist100Dem100, Dist100Dem200
                                                        Dist100Dem400, Dist100Dem1000, Dist100Dem2000, Dist100Dem4000, Dist100Dem10000
                                                        Dist200Dem10, Dist200Dem20, Dist200Dem40, Dist200Dem100, Dist200Dem200
                                                        Dist200Dem400, Dist200Dem1000, Dist200Dem2000, Dist200Dem4000, Dist200Dem10000
                                                        Dist300Dem10, Dist300Dem20, Dist300Dem40, Dist300Dem100, Dist300Dem200
                                                        Dist300Dem400, Dist300Dem1000, Dist300Dem2000, Dist300Dem4000, Dist300Dem10000
                                                        Dist400Dem10, Dist400Dem20, Dist400Dem40, Dist400Dem100, Dist400Dem200
                                                        Dist400Dem400, Dist400Dem1000, Dist400Dem2000, Dist400Dem4000, Dist400Dem10000
                                                        Dist500Dem10, Dist500Dem20, Dist500Dem40, Dist500Dem100, Dist500Dem200
                                                        Dist500Dem400, Dist500Dem1000, Dist500Dem2000, Dist500Dem4000, Dist500Dem10000
                                                        Dist600Dem10, Dist600Dem20, Dist600Dem40, Dist600Dem100, Dist600Dem200
                                                        Dist600Dem400, Dist600Dem1000, Dist600Dem2000, Dist600Dem4000, Dist600Dem10000
                                                        Dist700Dem10, Dist700Dem20, Dist700Dem40, Dist700Dem100, Dist700Dem200
                                                        Dist700Dem400, Dist700Dem1000, Dist700Dem2000, Dist700Dem4000, Dist700Dem10000
                                                        Dist800Dem10, Dist800Dem20, Dist800Dem40, Dist800Dem100, Dist800Dem200
                                                        Dist800Dem400, Dist800Dem1000, Dist800Dem2000, Dist800Dem4000, Dist800Dem10000
                                                        Dist900Dem10, Dist900Dem20, Dist900Dem40, Dist900Dem100, Dist900Dem200
                                                        Dist900Dem400, Dist900Dem1000, Dist900Dem2000, Dist900Dem4000, Dist900Dem10000 /
*$offText
*    j                                                   /Dist700Dem20, Dist700Dem40/
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
    dem(j,a)                            'MWh - Yearly demand of each consumer site j and desired product a in year y'
    cap_eff(i,k,j)                      'MWh - Yearly efficient transport capacity per trailer depending on commodity i, transport mode k, and consumer site j'
    eff_Consumer(i,a)                   'MWi/MWi - Overall efficiency of the consumer sites j supply chain depending on the commodity i and the desired product a'
    eff_Trans(i)                        'MWi/MWi - Transport efficiency of each commodity i'
    eff_TankLoc                         'MWi/MWi - Local storage tank efficiency for each commodity i'
    eff_ReConv(i,a)                     'MWi/MWi - Combined efficiency of reconversion and conversion processes for each commodity i to produce the desired product a'
    cap_ctr_ratio(i,k,j)
;

* Read parameters from EXCEL


$onecho > ImportAll.tmp
par=c_Trans             Rng=Inland_DE!B830:E1430      Cdim=0 Rdim=3
par=cap_eff             Rng=Inland_DE!B1912:E2511     Cdim=0 Rdim=3
par=dem                 Rng=Inland_DE!C2517:E2716     Cdim=0 Rdim=2
$offecho

$call GDXXRW I=Input_H2World.xlsx O=OutputALL.gdx @ImportAll.tmp
$gdxin OutputALL.gdx
$Load  c_Trans, cap_eff, dem
$offUndf

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
dem(j,a)            = dem(j,a) * 1/scale;
cap_eff(i,k,j)      = cap_eff(i,k,j) * 1/scale;
c_StorConv(i,y,a)   = (c_TankLoc(i) + c_ReConv(i,y,a));
c_Trans(i,k,j)      = c_Trans(i,k,j) / scale;
p(i,y)              = p(i,y);

cap_ctr_ratio(i,k,j)= c_Trans(i,k,j) / (cap_eff(i,k,j) + 1);



***********************************************************************
* Definition der Variablen
Variables
    Total_Cost                      'Total cost across all dimensions'
    TC_CONSUMER(i,y,k,j,a)          '€/MWh - Total cost in year y at the consumer site j for the desired product a'

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
        Total_Cost         =e= sum((i,y,k,j,a), TC_CONSUMER(i,y,k,j,a));

* Objective function: Minimization of total costs
Objective_Function(i,y,k,j,a)..
        TC_CONSUMER(i,y,k,j,a) =e= C_PR(i,y,k,j,a) + C_TR(i,y,k,j,a) + C_CS(i,y,k,j,a);

Procurement_Cost(i,y,k,j,a)..
        C_PR(i,y,k,j,a) =e= Q_PR(i,y,k,j,a)*p(i,y)   ;     

Inland_Transport_Cost(i,y,k,j,a)..
        C_TR(i,y,k,j,a)   =e= I_TR(i,y,k,j,a) * c_Trans(i,k,j) * sf_i(i);
    
Transport_Capacity_Constraint(i,y,k,j,a).. 
        I_TR(i,y,k,j,a) * cap_eff(i,k,j)=g= Q_TR(i,y,k,j,a);

Procurement_Constraint(i,y,k,j,a)..
        Q_TR(i,y,k,j,a) =l= Q_PR(i,y,k,j,a);

Facility_Cost(i,y,k,j,a)..
        C_CS(i,y,k,j,a) =e= c_StorConv(i,y,a) * Q_TR(i,y,k,j,a);

* Demand satisfaction constraint
Demand_Satisfaction(i,y,k,j,a)$(valid_comb(i,k))..      
        dem(j,a)        =l= Q_TR(i,y,k,j,a) * eff_Consumer(i,a);


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
    Report_Procurement_Cost(i,y,k,j,a)          '€/MWh - Beschaffungskosten pro Kombination i, y, j, a'
    Report_Transport_Cost(i,y,k,j,a)            '€/MWh - Transportkosten pro Kombination i, y, k, j, a'
    Report_Conversion_Cost(i,y,k,j,a)           '€/MWh - Speicher- und Umwandlungskosten pro Kombination i, y, k, j, a'
    Report_Total_Cost(i,y,k,j,a)                '€/MWh - Summe pro Kombination i, y, k, j, a'
    Report_Min_Cost(i,y,k,j,a)  'Parameter für die günstigste Kombination inklusive Sets i und k'
    Report_Min_Cost_Combination(y,j,a)
    ;
Set
    Report_Min_Set(i,y,k,j,a) 'Set für die günstigste Kombination von i, k je (y, j, a)'
    ;

* Berechnung der Beschaffungskosten
Report_Procurement_Cost(i,y,k,j,a)$(Q_PR.l(i,y,k,j,a) > 0) = 
    Q_PR.l(i,y,k,j,a) * p(i,y) /  dem(j,a);

* Berechnung der Transportkosten
Report_Transport_Cost(i,y,k,j,a)$(Q_TR.l(i,y,k,j,a) > 0) = 
    C_TR.l(i,y,k,j,a) / (dem(j,a));

* Berechnung der Speicher- und Umwandlungskosten
Report_Conversion_Cost(i,y,k,j,a)$(Q_TR.l(i,y,k,j,a) > 0) = 
    C_CS.l(i,y,k,j,a) / (dem(j,a));

* Berechnung der Gesamtkosten pro Kombination
Report_Total_Cost(i,y,k,j,a) = TC_CONSUMER.l(i,y,k,j,a) / dem(j,a);

* Bestimmung der minimalen Kostenkombination
Report_Min_Cost_Combination(y,j,a)$(dem(j,a) > 0) = smin((i,k)$(valid_comb(i,k) and Q_TR.l(i,y,k,j,a) > 0), Report_Total_Cost(i,y,k,j,a));
Report_Min_Set(i,y,k,j,a)$(valid_comb(i,k) and C_TR.l(i,y,k,j,a) > 0 and Report_Total_Cost(i,y,k,j,a) = Report_Min_Cost_Combination(y,j,a)) = yes;

Report_Min_Cost(i,y,k,j,a)$(Report_Min_Set(i,y,k,j,a)) = Report_Min_Cost_Combination(y,j,a);

***********************************************************************
* Analyse der Verteilung von Konsumenten j pro Jahr, Produkt a und Transportmodus k
***********************************************************************
Parameters
    Report_Distribution(y,a,k)              '% - Verteilung der Konsumenten j pro Jahr, Produkt a und Transportmodus k'
    Total_Consumers(y,a)                    'Anzahl der Gesamtkonsumenten pro Jahr und Produkt a'
    Report_Transport_Use(i,y,k,j,a)         'Anzahl der genutzten Transporteinheiten I_TR pro Konsument j, Jahr y, Produkt a und Modus k'
    ;

* Berechnung der Gesamtkonsumentenanzahl pro Jahr und Produkt a
Total_Consumers(y,a) = sum(j, sum(i, sum(k$(Report_Min_Cost(i,y,k,j,a) > 0), 1)));

* Berechnung der Verteilung
Report_Distribution(y,a,k) = 
    100 * sum(j, sum(i, (Report_Min_Cost(i,y,k,j,a) > 0))) / Total_Consumers(y,a);

* Berechnung der genutzten Transporteinheiten pro Konsument
Report_Transport_Use(i,y,k,j,a)$(I_TR.l(i,y,k,j,a) > 0) = I_TR.l(i,y,k,j,a);


***********************************************************************
* Erweiterung der Post-Optimierungen: Berechnung der durchschnittlichen Veränderung
* der Kosten von Report_Min_Cost(i, y, k, j, a) zwischen 2030 und 2040
* und des Anteils der Transportkosten sowie Beschaffungskosten an den minimalen Gesamtkosten
* sowie einer erweiterten Verteilung der Konsumenten
***********************************************************************

Parameters
    Avg_Cost_Change(a) 'Durchschnittliche Veränderung der Kosten zwischen 2030 und 2040'
    Transport_Cost_Share(i,y,k,j,a) 'Anteil der Transportkosten an den minimalen Gesamtkosten'
    Procurement_Cost_Share(i,y,k,j,a) 'Anteil der Beschaffungskosten an den minimalen Gesamtkosten'
    Avg_Procurement_Cost_Share(a) 'Durchschnittlicher Anteil der Beschaffungskosten über a'
    Total_Procurement_Cost_Share 'Durchschnittlicher Anteil der Beschaffungskosten über alle Dimensionen'
    Report_Distribution_Share(i,y,a) 'Anteil von i pro y, a und k an den minimalen Gesamtkosten'
    ;

* Berechnung der durchschnittlichen Veränderung
Avg_Cost_Change(a) = 
    sum((i,k,j)$(Report_Min_Cost(i,'2030',k,j,a) > 0 and Report_Min_Cost(i,'2040',k,j,a) > 0), 
    (Report_Min_Cost(i,'2040',k,j,a) - Report_Min_Cost(i,'2030',k,j,a)) / Report_Min_Cost(i,'2030',k,j,a) * 100) / 
    sum((i,k,j)$(Report_Min_Cost(i,'2030',k,j,a) > 0 and Report_Min_Cost(i,'2040',k,j,a) > 0), 1);

* Berechnung des Anteils der Transportkosten an den minimalen Gesamtkosten
Transport_Cost_Share(i,y,k,j,a)$(Report_Min_Cost(i,y,k,j,a) > 0) = 
    Report_Transport_Cost(i,y,k,j,a) / Report_Min_Cost(i,y,k,j,a) * 100;

* Berechnung des Anteils der Beschaffungskosten an den minimalen Gesamtkosten
Procurement_Cost_Share(i,y,k,j,a)$(Report_Min_Cost(i,y,k,j,a) > 0) = 
    Report_Procurement_Cost(i,y,k,j,a) / Report_Min_Cost(i,y,k,j,a) * 100;

* Durchschnittlicher Anteil der Beschaffungskosten nur über a
Avg_Procurement_Cost_Share(a) = 
    sum((i,y,k,j)$(Report_Min_Cost(i,y,k,j,a) > 0), Procurement_Cost_Share(i,y,k,j,a)) / 
    sum((i,y,k,j)$(Report_Min_Cost(i,y,k,j,a) > 0), 1);

* Durchschnittlicher Anteil der Beschaffungskosten über alle Dimensionen
Total_Procurement_Cost_Share = 
    sum((i,y,k,j,a)$(Report_Min_Cost(i,y,k,j,a) > 0), Procurement_Cost_Share(i,y,k,j,a)) / 
    sum((i,y,k,j,a)$(Report_Min_Cost(i,y,k,j,a) > 0), 1);

***********************************************************************
* Export der erweiterten Ergebnisse zur weiteren Analyse
***********************************************************************
execute_unload 'output_report_all.gdx', Report_Procurement_Cost, Report_Transport_Cost,
    Report_Conversion_Cost, Report_Total_Cost, Report_Min_Cost, Avg_Cost_Change, Transport_Cost_Share, 
    Procurement_Cost_Share, Avg_Procurement_Cost_Share, Total_Procurement_Cost_Share, Report_Distribution, 
    Total_Consumers, Report_Transport_Use;

***********************************************************************
***********************************************************************
* Erweiterung: Berechnung der effektiven Auslastung
***********************************************************************

* Berechnung der effektiven Auslastung
Parameters Effective_Load(i,y,k,j,a) 'Effektive Auslastung';
Effective_Load(i,y,k,j,a)$(I_TR.l(i,y,k,j,a) > 0) =
    Q_TR.l(i,y,k,j,a) / (I_TR.l(i,y,k,j,a) * cap_eff(i,k,j));

* Datenexport zur Analyse
*execute_unload 'Effective_Load_Analysis.gdx', Effective_Load;

Parameters
Possible_Procurement(y,i,a)
Possible_StorConv(y,i,a)
;

Possible_Procurement(y,i,a) = p(i,y) / eff_Consumer(i,a);
Possible_StorConv(y,i,a) = c_StorConv(i,y,a) / eff_Consumer(i,a); 

Parameters
    Min_Transport_Cost(y,i,a)    'Minimale Transportkosten für jede Kombination aus Jahr y, Commodity i und Produkt a'
    Max_Transport_Cost(y,i,a)    'Maximale Transportkosten für jede Kombination aus Jahr y, Commodity i und Produkt a';

* Berechnung der minimalen Transportkosten für jede Kombination aus y, i, a
Min_Transport_Cost(y,i,a) = smin((k,j)$(Report_Transport_Cost(i,y,k,j,a) > 0), Report_Transport_Cost(i,y,k,j,a));

* Berechnung der maximalen Transportkosten für jede Kombination aus y, i, a
Max_Transport_Cost(y,i,a) = smax((k,j)$(Report_Transport_Cost(i,y,k,j,a) > 0), Report_Transport_Cost(i,y,k,j,a));

***********************************************************************
* Export der Resultate zur weiteren Analyse
***********************************************************************
execute_unload 'Results_BtC.gdx';
*$stop
*$onText
***********************************************************************
* Ergebnisse speichern für Grafiken
***********************************************************************
execute_unload 'Output.gdx', Report_Transport_Use, Report_Distribution, Report_Procurement_Cost, Report_Transport_Cost,
                                    Report_Conversion_Cost, Report_Total_Cost, Report_Min_Cost, Effective_Load;

*$stop
$onecho >out.tmp

    par=Report_Transport_Use                rng=Report_Transport_Use!A2                 rdim=5 cdim=0
    par=Report_Distribution                 rng=Report_Distribution!A2                  rdim=3 cdim=0
    par=Report_Procurement_Cost             rng=Report_Procurement_Cost!A2              rdim=5 cdim=0
    par=Report_Transport_Cost               rng=Report_Transport_Cost!A2                rdim=5 cdim=0
    par=Report_Conversion_Cost              rng=Report_Conversion_Cost!A2               rdim=5 cdim=0
    par=Report_Total_Cost                   rng=Report_Cost_Consumer!A2                 rdim=5 cdim=0
    par=Report_Min_Cost                     rng=Report_Min_Cost!A2                      rdim=5 cdim=0
    par=Effective_Load                      rng=Effective_Load!A2                       rdim=5 cdim=0


$offecho


EXECUTE 'gdxxrw Output.gdx o=01_Results_BtC_Ammonia_All.xlsx  @out.tmp';
*$offText
***********************************************************************

$stop
