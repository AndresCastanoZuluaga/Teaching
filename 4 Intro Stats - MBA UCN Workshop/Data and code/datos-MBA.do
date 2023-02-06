/*******************************************************************************************************************************
Este do file construye las tablas para verificar que sectores son mas intensivos en conocimiento y cuales no,
con el fin de clasificar las actividas CIUU de a base de inicios de impuestos internos en categorías relevantes para el estudio
*******************************************************************************************************************************/
clear all
set memory 500m
**Directorio-Profesor**
cd "/Users/Andres/Dropbox/Personal/Software/Tutoriales/Stata-Ayudas/Probit_UCN"
use casen2011.dta

*************************************************************************
/* PARTE 1:
CONTRUIMOS TABLAS PARA DETERMINAR CUALES SON LOS SECTORES MÁS INTENSIVOS EN CONOCIMIENTO
*************************************************************************/
keep region comuna rama1 oficio1 esc 
tab oficio1 rama1 , freq col /*esta tabla indica en que sectores está la mayor cantidad de trabajadores profesionales, cientificos y demás*/ 
tab rama1  oficio1, freq row /*esta tabla indica en que sectores está la mayor cantidad de trabajadores profesionales, cientificos y demás*/ 
bysort oficio1: summ esc  /*esta tabla verifica que los profesionales son los que tienen en promedio mayor escolaridad*/
tab oficio1
tab rama1  

/*************************************************************************************************
PARTE 2: 
PROCESAMIENTO  DE LOS INICIOS DE EMPRESAS TENIENDO EN CUENTA CATEGORÍA (PRIMERA O SEGUNDA) Y RAMA
*************************************************************************************************/
clear all 
************
*Directorios
************
*********
*GENERAL*
*********
global general = "/Users/Andres/Dropbox/Papers/Paper-Felix-Gianni" 
**************
* ADICIONALES*
**************
global datos = "${general}/Datos"
global datosproc = "${general}/Datos/procesados"
global programas = "${general}/Programas"
global resultados = "${general}/Resultados"
**************************************************************************************************
*Lectura y guardado de los datos de los datos de inicios de empresas (2002-2014) a nivel sectorial
**************************************************************************************************
cd "${datos}/procesados"
insheet using "inicios-sectorial-2002-2012.txt",clear
drop if comuna==.
tab comuna if categoria==1
tab comuna if categoria==2
rename comuna id_comuna
reshape long inicios, i(categoria region id_comuna sector) j(year) 
tab sector_name
/*borramos los inicios con con multiples rubros y lo que no reportan rubro*/
drop if sector==19 | sector==20
/*dejamos solo los inicios de primera categoria*/
drop if categoria==2
/*se borran inicios que no reportaron comuna*/
drop if id_comuna==9999 | id_comu==99999
/*recodificamos los sectores en 4 categorías: 1. sector primario, 2. sector industrial, 3. sector servicios with high knowledge y 4. sector servicios with low knowledge */
gen sector2=0
replace sector2=1 if sector==1 | sector==2 | sector==3    
replace sector2=2 if sector==4 | sector==5                
replace sector2=3 if sector==6 | sector==7 | sector==8  | sector==9 | sector==10 | sector==12 | sector==18 | sector==17 
replace sector2=4 if sector==11 | sector==13 | sector==14 | sector==15 | sector==16                         
tab sector2
label define sector2 1 "Inicios en el sector primario" 2 "Inicios en el sector secundario" 3 "Inicios en el sector terciario (low knowledge)" 4 "Inicios en el sector terciario (high knowledge)", replace
label values sector2 sector2 
tab sector2
collapse (sum) inicios,  by(year region id_comuna sector2)
sort id_comuna year sector2
reshape wide inicios, i(year region id_comuna) j(sector2)
/*generamos una variable que indica el total de inicios*/
egen inicios_total=rowtotal(inicios1 inicios2 inicios3 inicios4)
*******************************************************
/*realizamos el merge con las distintas base de datos*/
*******************************************************
merge m:m id_comuna year using "conexiones_internet_fijo_comunal_mensual_2007-2015-otra.dta", nogenerate
merge m:1 id_comuna year using "Start-ups_Mauro.dta", nogenerate
*drop index inicios v7-v23
merge m:m id_comuna year using "Datos_Juan_Chile.dta", nogenerate
*drop region2 provincia sex edad ph15_29 pmj chsol2 gini_sah gini_smh atk_sah atk_smh theil_sah theil_smh ///
*dmcs rbv rbs rbf rvh rav rlh rln rbf2 hrt ls lsl lsg hmc vlc admcs arbv arbs arbf arvh arav arlh arln arbf2 ///
*ahrt als alsl alsg ahmc avlc id empresas
merge m:m id_comuna year using "base-comunal-2007-2013.dta", nogenerate /*esta base contiene la información de bancos*/
*drop porc_pob_pobre pob_rural pob_urbana
merge m:m id_comuna year using "BANCOS_2005_2010-Felix.dta", nogenerate
*drop comuna
*drop if year==2014
*drop if year==2000
merge m:m id_comuna year using "diversi-2.dta", nogenerate
merge m:m id_comuna year using "especia.dta", nogenerate 
merge m:m id_comuna year using "competencia_porter.dta", nogenerate 
merge m:m id_comuna year using "empresas-comuna-2005-2013.dta", nogenerate 
merge m:m id_comuna year using "pea-2005-2012-oyarzo.dta", nogenerate
*drop pea_mauro comuna_mapa
preserve
insheet using "Panel_comunal_2001-2012.txt", clear
rename codigo id_comuna
*save "Panel_comunal_2001-2012.dta", replace
restore
merge m:m id_comuna year using "Panel_comunal_2001-2012.dta", nogenerate
*drop totemp totpym totmicro totalgrande part_pym part_micro 
merge m:m id_comuna year using "${datosproc}/educacion-comunal-2004-2014.dta", nogenerate
/*merge con los nuevos indicadores de competencia y especialización a 17 y 4 sectores*/
merge m:m id_comuna year using "${datosproc}/espe_17y4_sectores.dta", nogenerate
merge m:m id_comuna year using "${datosproc}/compe_17y4_sectores.dta", nogenerate
/*FIN MERGE*/
keep if year==2011
keep  region provincia id_comuna comuna inicios_total esc educ1 educ2 educ3 tdoc ne porc_pob_pobre ///
ventas ntrab remu docentes_total_em mat_total_em colegios_em rbv hmc population pea pob_tot urb1 urb_rimisp1 exten_km2
*rbv son robos con violencia e intimidación
*hmc son homicidios
*replace 
merge 1:1 id_comuna using "/Users/Andres/Dropbox/UCN/Cursos_Dictados/UCN/10. MBA-Estadistica/datos/salario.dta"
keep if _merge==3
drop provincia
replace pob_tot= pob_tot/1000 /*para dejar la población en miles de habitantes*/
replace pea= pea/1000 /*para dejar la pea en miles de habitantes*/
replace educ1= educ1*100 /*para mostrar el porcentaje de población con educación primaria*/
replace educ2= educ2*100 /*para representar el porcetaje de población con educación secundaria*/
replace educ3= educ3*100 /*para representar el porcetaje de población con educación terciaria*/
replace tdoc= tdoc*100   /*para representar la tasa de desempleo*/
replace ne=ne/1000 /*para representar el numero de empresas en la comuna en miles*/
replace ventas=ventas/1000000 /*para representar las ventas en millones de uf*/
replace ntrab=ntrab/1000 /*para expresar los trabajadores en miles*/
replace remu=remu/1000000 /*para expresar las remuneraciones en millones de uf*/
replace yopraj=yopraj/1000 /*para expresar el salario en miles*/
export excel  using "/Users/Andres/Dropbox/UCN/Cursos_Dictados/UCN/10. MBA-Estadistica/datos/base_comunal.xlsx", replace  firstrow(variables)

collapse (summ) inicios_total rvb hmc population ne ventas ntrab remu docentes_total_em



*******************************************
/*para construir la media de los salarios*/
******************************************* 
clear all
set memory 500m
**Directorio-Profesor**
cd "/Users/Andres/Dropbox/Personal/Software/Tutoriales/Stata-Ayudas/Probit_UCN"
use casen2011.dta
collapse (mean) yopraj,  by(comuna)
format yopraj %12.1f
rename comuna id_comuna
save "/Users/Andres/Dropbox/UCN/Cursos_Dictados/UCN/10. MBA-Estadistica/datos/salario.dta", replace
