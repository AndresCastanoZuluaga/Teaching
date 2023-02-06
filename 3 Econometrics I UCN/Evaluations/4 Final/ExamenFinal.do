clear all
cd "C:\Users\Usuario\Desktop\Maestria_Ciencia_Regional\Cursos_Dictados\UCN\Econometria I_2013-2\Examenes\Parcial2"
insheet using "Datos_ExamenFinal.txt", clear

**********************************************
*Modelo 1 regresión normal
***********************************************
local log="vship  emp  pay invest energy equip"
foreach i of local log {
gen l_`i'=ln(`i')
}

reg vship emp pay invest energy equip, beta
return list
estimates store Original

reg l_vship l_emp l_pay l_invest l_energy l_equip 
return list
estimates store Log_Log

reg l_vship emp pay invest energy equip 
return list
estimates store Log_Lin

reg vship l_emp l_pay l_invest l_energy l_equip 
return list
estimates store Lin_Log

estimates table Original Log_Log Log_Lin Lin_Log, b se p stats(N r2 r2_o r2_b r2_w sigma_u sigma_e rho) b(%7.4f)



