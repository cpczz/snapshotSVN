/* +---------------------------------------------------------+
   | Script que consulta la tabla TSUSVNP para la generacion |
   | del script encargado de volcar a directorio los fuentes |
   | correspondientes con el ENTORNO deseado                 |
   +---------------------------------------------------------+
*/
set head off feed off pages 0 trimspool off verify off termout off echo off lines 200
alter session set nls_date_format='YYYYMMDD_HH24MISS';

define SALIDA = "Extraer_Fuentes_BATCH.SUBVERSION" (CHAR) ;
define ENTORNO = "DESARROLLO" (CHAR);
define FECHA = &_DATE ;

alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';

spool &ENTORNO..&SALIDA..&FECHA..sh 
-- spool 20181103.Extraer_FMB.SUBVERSION.DESARROLLO.sh

select 'set -x ' from dual;
select 'mkdir -p ./FuentesBatch-DESA ' from dual;

with 
ficherosWL11PROD as (
  select fecha as FechaServidorWL11PROD,
         substr(directorio,instr(directorio,'/',1,3)+1,length(directorio)-instr(directorio,'/',1,3)) as ProgramaServidorWL11PROD,
         directorio as DirectorioWL11PROD
  from CASUE.TSUFRW1E
),
desarrollo as ( 
  select * from (
  select cod_repositorio
        ,cod_url as Rama
        ,substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2)) as ProgramaFuente
		,revision
        ,fecha
		,cod_usuario
		,entorno
		,first_value(revision) ignore nulls OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, entorno, revision desc) as Version
		,first_value(fecha)    ignore nulls OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, entorno, fecha    desc) as FechaVersion
		,row_number() OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, revision desc, entorno) as RN
  from tsusvnp
  where entorno = 'Desarrollo'
  order by cod_url, revision desc ) where RN = 1 
),
desarrolloCorte as ( 
  select * from (
  select cod_repositorio
        ,cod_url as Rama
        ,substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2)) as ProgramaFuente
		,revision
        ,fecha
		,cod_usuario
		,entorno
		,first_value(revision) ignore nulls OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, entorno, revision asc) as Version
		,first_value(fecha)    ignore nulls OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, entorno, fecha    asc) as FechaVersion
		,row_number() OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, revision desc, entorno) as RN
  from tsusvnp
  where entorno = 'Desarrollo' -- and fecha <= to_date('20190101','YYYYMMDD')
  order by cod_url, revision desc ) where RN = 1
),
prueba as (
  select * from (
  select cod_repositorio
        ,cod_url as Rama
        ,substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2)) as ProgramaFuente
		,revision
        ,fecha
		,cod_usuario
		,entorno
		,first_value(revision) ignore nulls OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, entorno, revision desc) as Version
		,first_value(fecha)    ignore nulls OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, entorno, fecha    desc) as FechaVersion
		,row_number() OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, revision desc, entorno) as RN
  from tsusvnp
  where entorno = 'Prueba'
  order by cod_url, revision desc ) where RN = 1
),
produccion as (
  select * from (
  select cod_repositorio
        ,cod_url as Rama
        ,substr(cod_url,instr(cod_url,'/',1,2)+1,length(cod_url)-instr(cod_url,'/',1,2)) as ProgramaFuente
		,revision
        ,fecha
		,cod_usuario
		,entorno
		,first_value(revision) ignore nulls OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, entorno, revision desc) as Version
		,first_value(fecha)    ignore nulls OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, entorno, fecha    desc) as FechaVersion
		,row_number() OVER (PARTITION BY cod_url, entorno ORDER BY cod_url, revision desc, entorno) as RN
  from tsusvnp
  where entorno = 'Produccion'
  order by cod_url, revision desc ) where RN = 1
),
librerias as (
select D.ProgramaFuente as LibreriaFuente
      ,D.entorno        as Desarrollo
	  ,D.Version        as VersionDesarrollo
	  ,D.FechaVersion   as FechaVersionDesarrollo
	  ,P.entorno        as Prueba
	  ,P.Version        as VersionPrueba
	  ,P.FechaVersion   as FechaVersionPruebas
	  ,E.Entorno        as Produccion
	  ,E.Version        as VersionProduccion
	  ,E.FechaVersion   as FechaVersionProduccion
	  ,D.Rama           as RamaDesarrollo
	  ,P.Rama           as RamaPruebas
	  ,E.Rama           as RamaProduccion
	  ,X.entorno        as DesarrolloCorte
	  ,X.Version        as VersionDesarrolloCorte
	  ,X.FechaVersion   as FechaVersionDesarrolloCorte
	  ,D.cod_repositorio
from desarrollo D, prueba P, produccion E, desarrolloCorte X
where D.ProgramaFuente like '%pll' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
  and X.ProgramaFuente    = D.ProgramaFuente
),
menus as (
select D.ProgramaFuente as MenuFuente
      ,D.entorno        as Desarrollo
	  ,D.Version        as VersionDesarrollo
	  ,D.FechaVersion   as FechaVersionDesarrollo
	  ,P.entorno        as Prueba
	  ,P.Version        as VersionPrueba
	  ,P.FechaVersion   as FechaVersionPruebas
	  ,E.Entorno        as Produccion
	  ,E.Version        as VersionProduccion
	  ,E.FechaVersion   as FechaVersionProduccion
	  ,D.Rama           as RamaDesarrollo
	  ,P.Rama           as RamaPruebas
	  ,E.Rama           as RamaProduccion
	  ,X.entorno        as DesarrolloCorte
	  ,X.Version        as VersionDesarrolloCorte
	  ,X.FechaVersion   as FechaVersionDesarrolloCorte
	  ,D.cod_repositorio
from desarrollo D, prueba P, produccion E, desarrolloCorte X
where D.ProgramaFuente like '%mmb' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
  and X.ProgramaFuente    = D.ProgramaFuente
),
pantallas as (
select D.ProgramaFuente as PantallaFuente
      ,D.entorno        as Desarrollo
	  ,D.Version        as VersionDesarrollo
	  ,D.FechaVersion   as FechaVersionDesarrollo
	  ,P.entorno        as Prueba
	  ,P.Version        as VersionPrueba
	  ,P.FechaVersion   as FechaVersionPruebas
	  ,E.Entorno        as Produccion
	  ,E.Version        as VersionProduccion
	  ,E.FechaVersion   as FechaVersionProduccion
	  ,D.Rama           as RamaDesarrollo
	  ,P.Rama           as RamaPruebas
	  ,E.Rama           as RamaProduccion
	  ,X.entorno        as DesarrolloCorte
	  ,X.Version        as VersionDesarrolloCorte
	  ,X.FechaVersion   as FechaVersionDesarrolloCorte
	  ,D.cod_repositorio
from desarrollo D, prueba P, produccion E, desarrolloCorte X
where D.ProgramaFuente like '%fmb' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
  and X.ProgramaFuente    = D.ProgramaFuente  
),
informes as (
select D.ProgramaFuente as InformeFuente
      ,D.entorno        as Desarrollo
	  ,D.Version        as VersionDesarrollo
	  ,D.FechaVersion   as FechaVersionDesarrollo
	  ,P.entorno        as Prueba
	  ,P.Version        as VersionPrueba
	  ,P.FechaVersion   as FechaVersionPruebas
	  ,E.Entorno        as Produccion
	  ,E.Version        as VersionProduccion
	  ,E.FechaVersion   as FechaVersionProduccion
	  ,D.Rama           as RamaDesarrollo
	  ,P.Rama           as RamaPruebas
	  ,E.Rama           as RamaProduccion
	  ,X.entorno        as DesarrolloCorte
	  ,X.Version        as VersionDesarrolloCorte
	  ,X.FechaVersion   as FechaVersionDesarrolloCorte
	  ,D.cod_repositorio
from desarrollo D, prueba P, produccion E, desarrolloCorte X
where D.ProgramaFuente like '%rdf' and D.Rama not like '%RDF_BATCH%' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
  and X.ProgramaFuente    = D.ProgramaFuente
),
informes_batch as (
select D.ProgramaFuente as InformeFuente
      ,D.entorno        as Desarrollo
	  ,D.Version        as VersionDesarrollo
	  ,D.FechaVersion   as FechaVersionDesarrollo
	  ,P.entorno        as Prueba
	  ,P.Version        as VersionPrueba
	  ,P.FechaVersion   as FechaVersionPruebas
	  ,E.Entorno        as Produccion
	  ,E.Version        as VersionProduccion
	  ,E.FechaVersion   as FechaVersionProduccion
	  ,D.Rama           as RamaDesarrollo
	  ,P.Rama           as RamaPruebas
	  ,E.Rama           as RamaProduccion
	  ,X.entorno        as DesarrolloCorte
	  ,X.Version        as VersionDesarrolloCorte
	  ,X.FechaVersion   as FechaVersionDesarrolloCorte
	  ,D.cod_repositorio
from desarrollo D, prueba P, produccion E, desarrolloCorte X
where D.ProgramaFuente like '%rdf' and D.Rama  like '%RDF_BATCH%' 
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
  and X.ProgramaFuente    = D.ProgramaFuente
),
olb as (
select D.ProgramaFuente as OlbFuente
      ,D.entorno        as Desarrollo
	  ,D.Version        as VersionDesarrollo
	  ,D.FechaVersion   as FechaVersionDesarrollo
	  ,P.entorno        as Prueba
	  ,P.Version        as VersionPrueba
	  ,P.FechaVersion   as FechaVersionPruebas
	  ,E.Entorno        as Produccion
	  ,E.Version        as VersionProduccion
	  ,E.FechaVersion   as FechaVersionProduccion
	  ,D.Rama           as RamaDesarrollo
	  ,P.Rama           as RamaPruebas
	  ,E.Rama           as RamaProduccion
	  ,X.entorno        as DesarrolloCorte
	  ,X.Version        as VersionDesarrolloCorte
	  ,X.FechaVersion   as FechaVersionDesarrolloCorte
	  ,D.cod_repositorio
from desarrollo D, prueba P, produccion E, desarrolloCorte X
where D.ProgramaFuente like '%olb'
  and P.ProgramaFuente (+)= D.ProgramaFuente
  and E.ProgramaFuente (+)= D.ProgramaFuente
  and X.ProgramaFuente    = D.ProgramaFuente
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
-- DELTA Desarrollo
select 'svn export --username UsuarioSubversion --password PasswordUsuarioSubversion --revision '||versiondesarrollo||' ' ||cod_repositorio||RamaDesarrollo||' Fuentes-DESA' as extraer from ControlDeVersionesSoloBatch;


spool off   