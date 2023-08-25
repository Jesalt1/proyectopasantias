




alter table ROLT08 add NT08CARGAIMP int 
alter table ROLM03 add CM03UTILIDAD nchar(1), CM03IMPRENT nchar(1),CM03CATASTROFICA nchar(1)
alter table ROLM01 add NM01LOGIN nvarchar(50), NM01EMFCAT nchar(1)
alter table TEMP_ROLMM01 add login_ nvarchar(50), emf_catastrofica nchar(1)
alter table TEMP_CARGAS add utilidad nchar(1), imp_retencion nchar(1), catastrofica nchar(1)
alter table tbIR_Cab_RubrosxEmpleado add irecab_cargas integer, irecab_emf_catastrofica nchar(1)

update ROLM03 
set CM03UTILIDAD = 'S'
, CM03IMPRENT = 'N'
, CM03CATASTROFICA = 'N'

update ROLM01
set NM01LOGIN = ''
, emf_catastrofica = 'N'

update tbIR_Cab_RubrosxEmpleado
set irecab_cargas = 0
, irecab_emf_catastrofica = 'N'
