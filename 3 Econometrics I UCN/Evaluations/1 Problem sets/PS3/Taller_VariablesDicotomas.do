/*Taller de econometría para entregar el 19/11/2013*/
clear all
cd "C:\Users\Usuario\Desktop\Maestria_Ciencia_Regional\Working_Papers\Papers\Proyecto_UCN"
use "DEMRE_2006_stata.dta"
describe
/*La idea es tratar de explicar el desempeño en matematicas de los estudiantes de secundaria en Chile en el año 2011*/
keep  matematica sexo nacionalidad grupo_dependencia estado_civil codigo_region promedio_notas ingreso_bruto_familiar 
*********************************************************
* Variables a utilizar:
* y=matematica (variable dependiente) va de 0 a 850, indica el puntaje sacado en matematicas en la PSU
* x1=sexo (1=hombre, 0=mujer)
* x2=nacionalidad (1=chileno, 0=extranjero)
* x3=grupo_dependencia (1=particular pagado, 2=particular subvencionado, 3=municipal)
* x7=estado civil (1=soltero, 2=casado, 3=separado, 4=viudo)
* x4=codigo_region (indica la region donde esta ubicado su colegio de egreso)
* x5=promedio_notas (indica el promedio de notas del estudiante en la enseñanza media)
* x6=ingreso_bruto_familiar 1= 0 a 278.000; 2= de 278.001 a 834.000; 3= de 834.001 a 1.400.000; 4= de 1.400.000 a 1.950.000; 5= >= a 2.500.000  
**********************************************************
drop if grupo_dependencia==0
drop if estado_civil==0
drop if codigo_region==0
drop if ingreso_bruto_familiar==6

/*Resultados comparando a nivel regional con Santiago y en escala de ingresos con los que más ganan*/
regress matematica i.sexo i.nacionalidad i.grupo_dependencia i.estado_civil ib13.codigo_region promedio_notas ib5.ingreso_bruto_familiar, beta

