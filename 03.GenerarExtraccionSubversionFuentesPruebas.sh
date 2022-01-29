## +---------------------------------------------------------------------------+
## |                                                                           |
## | PROGRAM: 03.GenerarExtraccionSubversionFuentesPruebas.sh                  |
## |                                                                           |
## | USAGE  : 03.GenerarExtraccionSubversionFuentesPruebas.sh                  |
## |                                                                           |
## |                                                                           |
## | Description:                                                              |
## |                                                                           |
## |  Genera el script de extraccion del sistema de control de versiones       |
## |  Subversion para un entorno de desarrollo concreto: DESA/TEST/PROD        |
## |                                                                           |
## |  Errores:                                                                 |
## |           1-19  :                                                         |
## |           20-39 :                                                         |
## |           40-59 :                                                         |
## |                                                                           |
## |                                                                           |
## | CODIGN HISTORY___________________________________________________________ |
## |                                                                           |
## | Developer Date (YYYY/MM/DD) Description                                   |
## | --------- ----------------- --------------------------------------------- |
## | JR        2022/01/26        Creacion                                      |
## +---------------------------------------------------------------------------+



. /home/oracle/scripts/env_weblogic

export C="xxx"
export PATH=$PATH:/oraapp/oracle/product/Middleware/bin/
export ORACLE_HOME=/oraapp/oracle/product/Middleware
export RZR=`echo $C | base64 -d`
export TNS_ADMIN=/oraapp/oracle/product/FrDomainProN1/config/fmwconfig/
export U=xxx


sqlplus -s $U/$RZR@BD <<EOF
@03.GenerarExtraccionSubversionFuentesPruebas.sql
EOF
