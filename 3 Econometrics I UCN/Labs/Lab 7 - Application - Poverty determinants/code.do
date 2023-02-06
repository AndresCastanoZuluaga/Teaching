clear all
cd "C:\Users\Usuario\Desktop\Maestria_Ciencia_Regional\Cursos_Dictados\UCN\Econometria I_2013-2\Ayudantías\Ayudantía7"
insheet using "Datos_Ayudantia.txt"
rename codigo comuna2
save "datos_sinim.dta", replace
*Combinando bases de datos
merge 1:1 comuna2 using "datos2011.dta" 
describe
gen part_pea_sec_prima=(pea_sec_prima/pea)*100
gen part_pea_sec_secun=(pea_sec_secun/pea)*100
gen part_pea_sec_ter=(pea_sec_ter/pea)*100
local variables = "pct_pob_pobre part_urb densi part_pea_sec_ter part_pea_sec_secun part_pea_sec_prima totalgrande part_pym  part_micro sxh esc exper tdoc" 
foreach j of local variables{
gen ln_`j'=ln(`j')
}

*Modelo Normal
regress pct_pob_pobre part_urb densi part_pea_sec_ter part_pea_sec_secun part_pea_sec_prima ///
totalgrande part_pym  part_micro sxh esc exper tdoc
*Modelo Estandarizado
regress pct_pob_pobre part_urb densi part_pea_sec_ter part_pea_sec_secun part_pea_sec_prima ///
totalgrande part_pym  part_micro sxh esc exper tdoc
*Modelo log-log
regress ln_pct_pob_pobre ln_part_urb ln_densi ln_part_pea_sec_ter ln_part_pea_sec_secun ln_part_pea_sec_prima ///
ln_totalgrande ln_part_pym  ln_part_micro ln_sxh ln_esc ln_exper ln_tdoc
*Modelo log-lin
regress ln_pct_pob_pobre part_urb densi part_pea_sec_ter part_pea_sec_secun part_pea_sec_prima ///
totalgrande part_pym  part_micro sxh esc exper tdoc
*Modelo lin-log
regress pct_pob_pobre ln_part_urb ln_densi ln_part_pea_sec_ter ln_part_pea_sec_secun ln_part_pea_sec_prima ///
ln_totalgrande ln_part_pym  ln_part_micro ln_sxh ln_esc ln_exper ln_tdoc
