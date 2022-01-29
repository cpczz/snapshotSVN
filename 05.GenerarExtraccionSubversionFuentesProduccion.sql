/* +---------------------------------------------------------+
   | Script que consulta la tabla TSUSVNP para la generacion |
   | del script encargado de volcar a directorio los fuentes |
   | correspondientes con el ENTORNO deseado                 |
   +---------------------------------------------------------+
*/
set head off feed off pages 0 trimspool off verify off termout off echo off lines 200
alter session set nls_date_format='YYYYMMDD_HH24MISS';

define SALIDA = "Extraer_Fuentes.SUBVERSION" (CHAR) ;
define ENTORNO = "PRODUCCION" (CHAR);
define FECHA = &_DATE ;

alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';

spool &FECHA..&SALIDA..&ENTORNO..sh 
-- spool 20181103.Extraer_FMB.SUBVERSION.DESARROLLO.sh

select 'set -x ' from dual;
select 'mkdir -p ./Fuentes-PROD ' from dual;

with 
desarrollo as (
  select substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2)) as ProgramaFuente
        ,max(revision) as Version
        ,entorno
        ,cod_url as Rama
		,cod_repositorio
  from tsusvnp
  where entorno = 'Desarrollo'
  group by substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2))
          ,entorno
          ,cod_url
		  ,cod_repositorio
),
prueba as (
  select substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2)) as ProgramaFuente
        ,max(revision) as Version
        ,entorno
        ,cod_url as Rama
		,cod_repositorio
  from tsusvnp
  where entorno = 'Prueba'
  group by substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2))
          ,entorno
          ,cod_url
		  ,cod_repositorio
),
produccion as (
  select substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2)) as ProgramaFuente
        ,max(revision) as Version
        ,entorno
        ,cod_url as Rama
		,cod_repositorio
  from tsusvnp
  where entorno = 'Produccion'
  group by substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2))
          ,entorno
          ,cod_url
		  ,cod_repositorio
),
librerias as (
select D.ProgramaFuente as LibreriaFuente, D.entorno as Desarrollo, D.Version as VersionDesarrollo, P.entorno as Prueba, P.Version as VersionPrueba, E.Entorno as Produccion, E.Version as VersionProduccion, D.Rama as RamaDesarrollo, P.Rama as RamaPruebas, E.Rama as RamaProduccion, D.cod_repositorio
from desarrollo D, prueba P, produccion E
where D.ProgramaFuente like '%pll' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
),
menus as (
select D.ProgramaFuente as MenuFuente, D.entorno as Desarrollo, D.Version as VersionDesarrollo, P.entorno as Prueba, P.Version as VersionPrueba, E.Entorno as Produccion, E.Version as VersionProduccion, D.Rama as RamaDesarrollo, P.Rama as RamaPruebas, E.Rama as RamaProduccion, D.cod_repositorio
from desarrollo D, prueba P, produccion E
where D.ProgramaFuente like '%mmb' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
),
pantallas as (
select D.ProgramaFuente as PantallaFuente, D.entorno as Desarrollo, D.Version as VersionDesarrollo, P.entorno as Prueba, P.Version as VersionPrueba, E.Entorno as Produccion, E.Version as VersionProduccion, D.Rama as RamaDesarrollo, P.Rama as RamaPruebas, E.Rama as RamaProduccion, D.cod_repositorio
from desarrollo D, prueba P, produccion E
where D.ProgramaFuente like '%fmb' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
),
informes as (
select D.ProgramaFuente as InformeFuente, D.entorno as Desarrollo, D.Version as VersionDesarrollo, P.entorno as Prueba, P.Version as VersionPrueba, E.Entorno as Produccion, E.Version as VersionProduccion, D.Rama as RamaDesarrollo, P.Rama as RamaPruebas, E.Rama as RamaProduccion, D.cod_repositorio
from desarrollo D, prueba P, produccion E
where D.ProgramaFuente like '%rdf' and D.Rama not like '%RDF_BATCH%' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
),
informes_batch as (
select D.ProgramaFuente as InformeFuente, D.entorno as Desarrollo, D.Version as VersionDesarrollo, P.entorno as Prueba, P.Version as VersionPrueba, E.Entorno as Produccion, E.Version as VersionProduccion, D.Rama as RamaDesarrollo, P.Rama as RamaPruebas, E.Rama as RamaProduccion, D.cod_repositorio
from desarrollo D, prueba P, produccion E
where D.ProgramaFuente like '%rdf' and D.Rama  like '%RDF_BATCH%' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
),
olb as (
select D.ProgramaFuente as InformeFuente, D.entorno as Desarrollo, D.Version as VersionDesarrollo, P.entorno as Prueba, P.Version as VersionPrueba, E.Entorno as Produccion, E.Version as VersionProduccion, D.Rama as RamaDesarrollo, P.Rama as RamaPruebas, E.Rama as RamaProduccion, D.cod_repositorio
from desarrollo D, prueba P, produccion E
where D.ProgramaFuente like '%olb'
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
),
ControlDeVersiones as (
select * from pantallas
union all
select * from menus
union all
select * from librerias
union all
select * from informes
union all
select * from informes_batch
union all
select * from olb
order by 1
),
ControlDeVersionesSoloBatch as (
select * from informes_batch
),
ControlDeVersionesSinBatch as (
select * from pantallas
union all
select * from menus
union all
select * from librerias
union all
select * from informes
union all
select * from olb
order by 1
)
-- DELTA Desarrollo + DELTA Produccion
select CASE WHEN versionproduccion is null
            THEN 'svn export --username UsuarioSubversion --password PasswordUsuarioSubversion --revision '||versiondesarrollo||' ' ||cod_repositorio||RamaDesarrollo||' Fuentes-PROD'
            ELSE 'svn export --username UsuarioSubversion --password PasswordUsuarioSubversion --revision '||versionproduccion||' ' ||cod_repositorio||RamaProduccion||' Fuentes-PROD'
       END as extraer
from ControlDeVersionesSinBatch;

spool off   