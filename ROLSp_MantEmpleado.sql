USE [ROLES]
GO

/****** Object:  StoredProcedure [dbo].[ROLSp_MantEmpleado]    Script Date: 22/08/2023 13:31:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*                          
select TM01FECEGR from rolm01          
          
*/                               
CREATE procedure [dbo].[ROLSp_MantEmpleado]                            
(                            
@i_operacion  varchar(20),                              
@i_compania  int=null,                          
@i_opcion   varchar(20)=null,                          
@i_usuario   varchar(20)=null,                          
@i_maquina   varchar(20)=null,                           
@i_empleado   float=null,                             
@i_ESTADO   varchar(1) = null,                        
@i_xml    xml=null,  
@i_xml_aud xml=null,       
@i_imagen  varbinary(max)=null                       
,@o_error   int=0 output,                          
@o_mensaje   varchar(250) ='' output  ,                        
@o_empleado  int=0 output                        
)                            
as            
declare @w_codigo float,                          
@w_i  int, @w_fecha_proceso datetime             
,@w_estadoa nchar(1), @w_estadon nchar(1),@w_numero_acc float    
, @w_tipo_accion int, @w_observacion_acc nvarchar(300)                     
declare @w_auditoria nchar(1)
, @w_ejecutable nvarchar(30)  
, @w_maquina nvarchar(30)  
, @w_usuario nvarchar(30)  
, @w_base_auditoria nvarchar(60)  
, @w_parametros nvarchar(max)  
, @w_xml_out  xml  
, @w_xml  xml  
, @w_sql  nvarchar(max)  
declare @s_error int, @s_mensaje nvarchar(max) 
SET NOCOUNT ON             
SET NOCOUNT ON                   
 if @i_operacion = 'load_tabla'                                  
begin    
    
 select a.cc_codigo CCosto, a.cc_descripcion Centro_Costo , b.cc_descripcion Padre_CCosto    
 -- select *    
 from SIACDB..tb_plan_CCosto a, SIACDB..tb_plan_CCosto b    
 where a.cc_compania = b.cc_compania    
 and a.cc_CCostpadre = b.cc_codigo    
 and a.cc_compania = @i_compania    
-- and a.cc_movimiento = 'S'    
 and a.cc_codigo = '0010010010001'    
 select 'collection' , 'dte3_ctocto;'    
    
    
end      
  
if @i_operacion = 'query_ruc'                            
begin                            
 select CODIGO = NM01CODEMP                          
 , TIPO_RUC = CM01TIPOID                          
 , RUC = CM01IDENTI                          
 , NOMBRE = CM01NOMBRE                          
 , DIRECCION = CM01DIRECC                          
 , ESTADO = CM01STSEMP                          
 from ROLM01                             
 where NM01CODCIA = @i_compania                            
 and CM01IDENTI like '%' + @i_opcion + '%'                          
 and CM01STSEMP =@i_estado                                        
end            
                         
if @i_operacion = 'query_cod'                            
begin                            
 select CODIGO = NM01CODEMP                          
 , TIPO_RUC = CM01TIPOID                          
 , RUC = CM01IDENTI                          
 , NOMBRE = CM01NOMBRE                          
 , DIRECCION = CM01DIRECC                          
 , ESTADO = CM01STSEMP                          
 from ROLM01                             
 where NM01CODCIA = @i_compania                            
 and convert(varchar(10),NM01CODEMP) like '%' + @i_opcion + '%'                          
 and CM01STSEMP =@i_estado                         
end             
                        
if @i_operacion = 'query_nom'                            
begin                            
 select CODIGO = NM01CODEMP                          
 , TIPO_RUC = CM01TIPOID                          
 , RUC = CM01IDENTI                          
 , NOMBRE = CM01NOMBRE                          
 , DIRECCION = CM01DIRECC                          
 , ESTADO = CM01STSEMP                     
 from ROLM01                             
 where NM01CODCIA = @i_compania                      
 and CM01NOMBRE like '%' + @i_opcion + '%'                          
 and CM01STSEMP =@i_estado                         
end            
                         
if @i_operacion = 'query_tod'                            
begin                            
 select CODIGO = NM01CODEMP                          
 , TIPO_RUC = CM01TIPOID                          
 , RUC = CM01IDENTI                          
 , NOMBRE = CM01NOMBRE                          
 , DIRECCION = CM01DIRECC                          
 , ESTADO = CM01STSEMP                           
 from ROLM01                             
 where NM01CODCIA = @i_compania                                         
 and CM01STSEMP =@i_estado                         
end                    
          
if @i_operacion = 'Query'                            
begin                            
 select                           
 isnull(CM01TIPOID,'C') as tipo_id                          
 , isnull(CM01IDENTI,'') as ruc                          
 , isnull(CM01NOMBRE,'') as nombre                 
 , isnull(CM01DIRECC,'') as direccion                          
 , isnull(CM01TELEFO,'') as telefono                          
 , CM01SEXO as sexo       
 , isnull(CM01ESTCIV,'S') as estado_civil                          
 , isnull(CM01LUGNAC,'') as lugar_nac                          
 , isnull(TM01FECNAC,'19000101') as fecha_nac                          
 , isnull(CM01NACION,'') as idnacionalidad                          
 , isnull((select CT05NOMNAC from ROLT05 where CT05CODNAC = CM01NACION) ,'')as nacionalidad                          
 , isnull(NM01CODTIT,'') as idtitulo                          
 , isnull((select CT06NOMTIT from ROLT06 where NT06CODTIT = NM01CODTIT),'') as titulo                          
 , isnull(NM01CODEST,'') as idestudio                          
 , isnull((select CT07NOMEST from ROLT07 where NT07CODEST = NM01CODEST),'') as estudio                                       
 , isnull(CM01CDIESS,'') as carnet_iess                          
 , isnull(TM01FECING,'19000101') as fecha_ing                          
 , isnull(TM01FECEGR,'19000101') as fecha_egreso                          
 , isnull(CM01CUENTA,'') as cuenta   
 , isnull(NM01CEDCTA,'') as cedcta                       
 , isnull(CM01TIPCTA,'N') as tipoCta                          
 , CM01DEPCTA as depcta                          
 , NM01CODDEP as iddepartamento                          
 , (select CT02NOMDEP from ROLT02                          
 where NT02CODCIA = NM01CODCIA                          
 and NT02CODDEP = NM01CODDEP) as departamento                          
 ,  CM01SECTOR as idsector                          
 , (select ct12sector from ROLT12 where CT12CODIGO = CM01SECTOR) as sector                          
 , NM01CODCAR as idcargo                          
 , isnull((select CT04NOMCAR from ROLT04 where  NT04CODCIA = NM01CODCIA and NT04CODDEP = NM01CODDEP and NT04CODCAR =  NM01CODCAR),'') as cargo                                          
 , isnull(CM01TIPLIQ,'M') as tipo_liq                          
 , isnull(CM01STSEMP,'A') as estado                          
 , isnull(CM01BENEFI,'S') as beneficio                          
 , isnull(NM01SDOBAS,0) as sueldo                          
 , isnull(NM01MOVIL,0) as transporte                          
 , isnull(NM01SDOEXTRA,0) as extra  
 , isnull(ROL_ALIMENTACION,0) as alimentacion                        
 , isnull(CM01CLASE,'N') as clase                          
 , isnull(CM01CODACT,'') as  sector2                          
 , isnull(( Select CT11CONCEPTO From ROLT11 where CT11CODIGO = CM01CODACT),'') as sectorial                          
 , isnull(CM01TIPOSANGRE,'') as tipo_sangre                           
 , isnull(NM01CEDMILITAR,'') as ced_militar                        
 , isnull(NM01MATRICULAPORT,'') as mat_portuaria                          
 , isnuLL(CM01RELACION,'N') as relacion              
 , ISNULL(NM01CODCIU,'') AS COD_CIUDAD              
 , ISNULL(ROL_DISCAPACIDAD,0) AS DISCAPACIDAD            
 , isnull(TM01FECTERCONTRATO,'19000101') as terminoC           
 ,isnull(ROL_PORDISCAPACIDAD,0) as por_discapacidad          
 ,isnull(ROL_CAT_IR,'A') as tipo_ir          
 ,isnull(ROL_COD_BIO,'') as biometrico            
 ,isnull(ROL_CODCARGO,'') as cod_cargo          
 , ISNULL(ROL_CONTACTO,'') as contacto        
 , ISNULL(ROL_OBSERVACION,'') as observacion        
 , isnull(FONRES_LEGAL_ROL,'S') as paga_fon_res        
 , isnull(CM01CTACONTA,'') as ctacble      
 , ISNULL(NM01PERPRUEBA,'S') as aprueba      
 , ISNULL(NM01APLLIMT,'N') as abono     
 ,  NM01FOTO as foto    
  , isnull(CM01EMAIL,'') as email   
  , isnull(NM01PAGOTRO,'N') as pago_adicional  
  , ISNULL(NM01EMFCAT,'N') emf_catastrofica  
   , '0010010010001'  as ctrocto  
-- select *             
 from ROLM01                             
 where NM01CODCIA = @i_compania                            
 AND NM01CODEMP = @i_empleado                            
 and CM01STSEMP =@i_estado                         
end                 
if @i_operacion = 'CargaF'                            
begin            
 select CM03INDICA as tipoF,CM03NOMBRE as nombreF,isnull(TM03FECNAC,'19000101') as fechanF,          
 CM03SEXO as sexoF,CM03ESTADO as estadoF,NM03SECUEN as   SecueF           
 , isnull(TM03APORTA,'N') as aporta
 ---------SE AGREGAN NUEVAS COLUMNAS AQUI
 , ISNULL(CM03UTILIDAD,'N') utilidad, ISNULL(CM03IMPRENT,'N') imp_renta, ISNULL(CM03CATASTROFICA,'N') catastrofica  
 --isnull(CM03IMPRENT,'N') as aplica, isnull(CM03CATASTROFICA,'N') as catastrofica       
 -- select *          
 from ROLM03          
 where  NM03CODCIA =@i_compania  AND  NM03CODEMP=@i_empleado          
 order by NM03SECUEN          
end          
if @i_operacion = 'delete'                            
begin             
  
if exists(select top 1 1 from vw_rep_cuentas_cobrar_pendiente_det where compania = @i_compania and  empleado = @i_empleado and pendiente > 0 )  
begin  
  set @o_error =1                                 
  set @o_mensaje = 'Empleado: Posee Cuentas por Cobrar Pendiente....verifique........'  
  return 0                                   
end  
                                       
 SET XACT_ABORT ON                            
 begin tran dlt                                  
 Begin Try                            
  update ROLM01                          
  set CM01STSEMP = 'I'                           
  from ROLM01                          
  where NM01CODCIA = @i_compania                          
  and NM01CODEMP =  @i_empleado                        
 End try                                                                 
 Begin Catch                                   
  set @o_error =1                                 
  set @o_mensaje = 'Error al Inactivar Empleado........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
  rollback tran dlt                          
  return 0                                   
 End Catch          
       
                               
 set @o_error =0                                    
 set @o_mensaje = 'Registro se Inactivo Correctamente '                          
 commit tran dlt                             
 SET XACT_ABORT OFF                                
 return 0                                                                             
end                                
        
        
        
                      
if @i_operacion in ('insert','update')                          
begin    
-- select * from siacdb..PAR_Parametro_General
-- alter table ROL_Parametros add pa_auditoria nchar(1)
-- update ROL_Parametros set pa_auditoria = 'S' 
SET NOCOUNT ON   
 if exists(   
 ( select 1 from SIACDB..PAR_Parametro_General   
 where gr_clave = @i_compania and gr_default_auditoria= 'S'  
 and exists(select 1 from ROL_Parametros where pa_compania = @i_compania AND pa_auditoria = 'S')  
 )  
 )  
 begin  
 set @w_auditoria = 'S'  
 end  
 else  
 begin  
 set @w_auditoria = 'N'  
 end  
             
 select @w_fecha_proceso = TT08FECPRO     
 from ROLT08    
 where NT08CODCIA = @i_compania    
  -- select * from TEMP_ROLMM01  
  -- alter table TEMP_ROLMM01 add pago_otro nchar(1)  
 delete from TEMP_ROLMM01                          
 where compania = @i_compania                          
 and usuario = @i_usuario                          
 and maquina = @i_maquina           
           
 delete from  TEMP_CARGAS          
 where compania = @i_compania                          
 and usuario = @i_usuario                          
 and maquina = @i_maquina           
     -- select * from TEMP_ROLMM01                   
    -- select  * from rolm01              
 -- select * from TEMP_ROLMM01           
 -- select * from TEMP_CARGAS          
Begin Try      
 EXEC sp_xml_preparedocument @w_i OUTPUT, @i_XML              
-- select * from TEMP_ROLMM01         
-- alter table TEMP_ROLMM01 add per_prueba nchar(1) null, aplica_bono nchar(1) null       
-- alter table TEMP_ROLMM01 drop column NM01APLLIMT nchar(1) null, NM01APLLIMT nchar(1) null       
-- alter table rolm01 add ROL_DISCAPACIDAD char(1) null       
-- select ROL_DISCAPACIDAD ,por_discapacidad   ,* from rolm01      
-- select * from TEMP_ROLMM01      
-- alter table TEMP_ROLMM01 add email nvarchar(300)    
-- alter table rolm01 add CM01EMAIL nvarchar(300) null    
-- alter table TEMP_ROLMM01 add alimentacion float null   
-- alter table TEMP_ROLMM01 add cedcta nvarchar(30) null   

-- alter table TEMP_ROLMM01  drop column CM01CEDCTA
  
-- alter table TEMP_ROLMM01 add CM01CEDCTA nvarchar(30)
-- select * from TEMP_ROLMM01
 insert into TEMP_ROLMM01                          
 (                          
 compania,  usuario, maquina,  opcion,  empleado,  tipo_id,                          
 ruc,   nombre,  direccion,  telefono, estado_civil, sexo,                          
 lugar_nac,  fecha_nac, nacionalidad, titulo,  codest,   codact,                          
 carnet_iess, fecha_ing, fecha_egreso, cuenta,  tipoCta,  depcta,                          
 departamento, sector,  cargo,   tipo_liq, estado,   beneficio,                          
 sueldo,  extra,  transporte,  sector2, clase,   tipo_sangre,         
 ced_militar,   mat_portuaria,relacion,COD_CIUDAD,DISCAPACIDAD,terminoC             
 , por_discapacidad,tipo_ir,biometrico,cod_cargo                       
 , contacto, observacion, paga_fon_res        
 , ctacble,per_prueba,aplica_bono    
  ,email, pago_otro, alimentacion, cedcta
, login_,emf_catastrofica 
 )                          
 select  idcompania,  usuario, maquina,  opcion,  empleado,  tipo_id,                          
 ruc,   nombre,  direccion,  telefono, estado_civil, sexo,                          
 lugar_nac,  fecha_nac, nacionalidad, titulo,  codest,   codact,                          
 carnet_iess, fecha_ing, fecha_egreso, cuenta,  tipoCta,  depcta,                          
 departamento, sector,  cargo,   tipo_liq, estado,   beneficio,                          
 sueldo,  extra,  transporte,  sector2, clase,   tipo_sangre,                          
 ced_militar, mat_portuaria,relacion,COD_CIUDAD,DISCAPACIDAD,terminoC          
 , por_discapacidad,tipo_ir,biometrico,cod_cargo          
 , contacto ,observacion,paga_fon_res       
 ,ctacble,per_prueba,aplica_bono      
  ,email ,pago_adicional, alimentacion , cedcta   
     , login_,emf_catastrofica 
  FROM OpenXML(@w_i,'/EMPLEADO/DATOS')                                  
 WITH (                                    
 idcompania  int,                          
 usuario   varchar(30),                                    
 maquina   varchar(50),                                     
 opcion  varchar(20),                          
 empleado float,                          
 tipo_id varchar(1),                          
 ruc  varchar(15),                          
 nombre  varchar(400),                          
 direccion varchar(300),                          
 telefono varchar(50),                          
 estado_civil varchar(20),                          
 sexo  varchar(2),                          
 lugar_nac varchar(20),                          
 fecha_nac datetime,                          
 nacionalidad varchar(3),                          
 titulo  int,                          
 codest  varchar(40),                          
 codact  varchar(40),                          
 carnet_iess varchar(40),                          
 fecha_ing datetime,                          
 fecha_egreso datetime,                           
 cuenta    varchar(25),                          
 tipoCta   varchar(3),                          
 depcta    char(1) ,                          
 departamento int,                          
 sector    int,                          
 cargo    int,                             
 tipo_liq   char(1),                          
 estado    char(1),                          
 beneficio   char(1),                          
 sueldo    float,                          
 extra    float,                          
 transporte   float,                          
 sector2 varchar(25),                          
 clase  char(2),                          
 tipo_sangre VARchar(10),                          
 ced_militar varchar(20),                          
 mat_portuaria varchar(20),                          
 relacion varchar(1)              
 ,COD_CIUDAD varchar(20)            
 ,DISCAPACIDAD varchar(1)              
 ,terminoC  datetime            
 , por_discapacidad float          
 , tipo_ir char(2)          
 ,biometrico varchar(30)          
 ,cod_cargo varchar(30)          
 ,contacto varchar(max)        
 ,observacion varchar(max)        
 , paga_fon_res char(1)        
 , ctacble nvarchar(30)      
 ,per_prueba nchar(1)      
 ,aplica_bono nchar(1)     
 ,email nvarchar(2000)     
 , pago_adicional nchar(1)  
 , alimentacion float
 , cedcta nvarchar(30)
    ,login_ nvarchar(50)  
 , emf_catastrofica nchar(1)  
 )            
 -- select * from TEMP_CARGAS          
 INSERT INTO [dbo].[TEMP_CARGAS]          
           ([compania]          
           ,[usuario]          
           ,[maquina]          
           ,[empleado]          
           ,[secuencia]          
           ,[parentesco]          
           ,[nombre]          
           ,[fecha]          
           ,[sexo]          
           ,[aporta]          
			,estado 
			, utilidad,imp_retencion,catastrofica)          
     select idcompania,  usuario, maquina          
     ,empleado,secuencia,parentesco          
     ,nombre,fecha,sexo,aporta,estado
	  , utilidad,imp_retencion,catastrofica    
                       
      FROM OpenXML(@w_i,'/EMPLEADO/DATOS/CARGA')                                  
 WITH (                  
  idcompania  int  '../@idcompania',                          
     usuario   varchar(30) '../@usuario',                                    
     maquina   varchar(50) '../@maquina',           
  empleado float '../@empleado',           
  secuencia int,          
  parentesco char(1),          
  nombre varchar(350),          
  fecha datetime,          
  sexo char(1),          
  aporta char(2),      
  estado char(1)          
 
 ,utilidad nchar(1),imp_retencion nchar(1),catastrofica nchar(1) 
          
 )           
 EXEC sp_xml_removedocument @w_i       
     
 End try                                                                 
 Begin Catch            
  set @o_empleado=0                                 
  set @o_error =1                                    
  set @o_mensaje = 'Error al  Empleado........' --+ ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
                            
  return 0                                   
 End Catch      
end                          
                        
if @i_operacion = 'insert'                          
begin                                     
                          
 select @w_codigo = max(NM01CODEMP) + 1                          
 from ROLM01           
 where NM01CODCIA =@i_compania           
                         
 set @w_codigo = isnull(@w_codigo,0)                          
                          
 SET XACT_ABORT ON                            
 begin tran ins                                  
 Begin Try            
 -- alter table ROLM01 add NM01CODCIU nvarchar(20) null    
 -- select top 10 * from ROLM01                      
  INSERT INTO ROLM01                          
  (                          
  NM01CODCIA, NM01CODEMP, CM01TIPOID, CM01IDENTI, CM01NOMBRE, --1                          
  CM01DIRECC, CM01TELEFO, CM01SEXO, CM01ESTCIV, CM01LUGNAC, TM01FECNAC, CM01NACION, NM01CODTIT,--2                          
  NM01CODEST, CM01CODACT, CM01CDIESS, TM01FECING, TM01FECEGR, CM01CUENTA, CM01TIPCTA, --3                          
  CM01DEPCTA, NM01CODDEP, NM01CODSEC, NM01CODCAR, NM01NUMCAR, CM01TIPLIQ, CM01STSEMP, --4                          
  CM01BENEFI, NM01SDOBAS, NM01SDOCON, NM01SDOFAS, NM01TRANSP, NM01COMSPI, CM01COMSPI, --5                          
  NM01COMICC, NM01BONIFI, NM01HORSOB, NM01PORSOB, NM01VALSOB, NM01VALICC, NM01RETACT,--6                           
  NM01IESSQF, NM01IESSHP, NM01PRESTA, NM01ANTICI, NM01MULTAS, NM01DESCTO, NM01CCCOMI, --7                          
  NM01CCACRE, NM01CCVARS, NM01CXC001, NM01CXC002, NM01CXC003, NM01CXC004, NM01CXC005,--8                           
  NM01INGRES, NM01EGRESO, NM01SDOPAR, NM01APIESS, NM01IESSPT, NM01SDOFIN, NM01SDOAUX,--9                           
  NM01DIASTB, CM01FLGVAC, NM01DIAVAC, CM01FLGFLT, NM01DIAFLT, CM01TIPFLT, CM01FLGEMB, --10                          
  NM01NUMVAC, NM01ING001, NM01ING002, NM01ING003, NM01ING004, NM01ING005, NM01HORSOB2, --11                          
  NM01PORSOB2, NM01VALSOB2, CM01FACTURA, CM01CHEQUE, CM01COMENT, CM01CLASE, CM01SECTOR,--12                           
  CM01RELACION, NM01SDOEXTRA, NM01SFEXTRA, NM01MOVIL, NM01DEBITOS, NM01RETENCION, NM01FOTO, --13                          
  NM01CEDMILITAR, NM01MATRICULAPORT, TM01FECTERCONTRATO, CM01TIPOSANGRE, NM01ITEM01, NM01ITEM02,--14                           
  NM01ITEM03, NM01ITEM04, NM01ITEM05, NM01ITEM06, NM01ITEM07, NM01ITEM08, NM01ITEM09, NM01ITEM10,--15                           
  NM01CXC006, NM01CXC007, NM01CXC008, NM01CXC009, NM01CXC010, NM01ING006, NM01ING007, NM01ING008,--16                           
  NM01ING009, NM01ING010, NM01EGRQUI, NM01IFRABAS, NM01IFRAEXC, NM01PROVD3, NM01PROVD4, NM01BASEIMP, --17                          
  NM01RETFRABAS, NM01VACACIONES,CM01FLAGMENFR,NM01FONRES,NM01FONRESMES--18   
  ,CM01FLAGQUIN,T_APORTE,ROL_ICA,CAT_CONT,ROL_GASTOS,NM01HORSOB3, NM01PORSOB3,NM01VALSOB3,NM01IMPREN--19   
  ,NM01OBSERV, ROL_BASE, ROL_PORRET, ROL_VALRET, ROL_PORRETIVA, ROL_VALRETIVA,ROL_BASEIVA, ROL_IVA, ROL_SOBRANTIVA --20  
  ,ROL_ALIMENTACION,FONRES_ROL,FONRES_LEGAL_ROL,ROL_IMPC_ASUMIDO, ROL_CAT_IR, ROL_APIESS,ROL_APADIESS,ROL_APPORIESS --21  
  ,ROL_NoCargas,ROL_USUARIO,ROL_COD_BIO, ROL_CODCARGO, ROL_DISCAPACIDAD, ROL_proyecto,ROL_sector,ROL_actividad,ROL_subactividad --22                          
  ,ROL_PORDISCAPACIDAD,ROL_XIII,ROL_XIV,ROL_XIII_VM,ROL_XIV_VM,ROL_XIII_BASE,ROL_XIV_BASE,CM01CTACONTA,CM01CUENTA2,CM01TIPCTA2    --23    
  ,ROL_VAC_BASE,NM01SECAP,NM01IECE,ROL_FR_BASE,ROL_FR_DIAS, ROL_CONTACTO,ROL_OBSERVACION,NM01CODCIU,ROL_APIESS_BASE,ROL_APPATRONAL_BASE   --24  
  , NM01PERPRUEBA,NM01APLLIMT,NM01LIQVACA,ROL_XIV_DIAS,NM01COMEDOR,NM01IINGRESOS,NM01IALIMENTACION,NM01ITOTALING,NM01IGASTOS,NM01IEXEDENTE  --25  
  , NM01IRESEXEDENTE, NM01IIMPCAU, NM01IIRCOB, NM01IIMPCAUR,NM01IMES, NM01ISEGURO,NM01PRESGAST, NM01IHORAEXT, NM01APIIESS, NM01APAIESS ,NM01UTILIDAD, NM01CXC011 --26  
  ,NM01BASESOL,CM01EMAIL,NM01PAGOTRO,NM01DIASDS,NM01IMPRENASU    -- 27 
  , NM01CEDCTA,NM01SDOBE, NM01SDESLEY
  ,NM01LOGIN,NM01EMFCAT     
  )                   
  -- select * from ROLM01         
  Select                          
  compania,  @w_codigo, tipo_id, ruc, nombre,                            
  direccion, telefono, sexo, estado_civil,lugar_nac,  fecha_nac, nacionalidad, titulo,                          
  codest, sector2, carnet_iess,fecha_ing, null, cuenta,  tipoCta,                          
  depcta, departamento,sector,cargo,0,tipo_liq, estado,                           
  beneficio, sueldo, 0,0,0,0,'N',--5                          
  0,0,0,0,0,0,0,--6                          
  0,0,0,0,0,0,0,--7                          
  0,0,0,0,0,0,0,--8                          
  0,0,0,0,0,0,0,--9                          
  0,0,0,0,0,0,'N',--10                          
  0,0,0,0,0,0,0,--11                          
  0,0,'','','',clase,sector,--12                          
  relacion,extra,null,transporte,0,0,null, --13                          
  ced_militar,mat_portuaria,terminoC,tipo_sangre,0,0,--14                          
  0,0,0,0,0,0,0,0,--15                          
  0,0,0,0,0,0,0,0,--16                   
  0,0,0,0,0,0,0,0,--17                          
  0,0,'S',0,0--18                 
  , 'N',0,0,0,0,0,0,0,0 --19  
  ,'',0,0,0,0,0,0,12,0 --20  
  ,alimentacion,'N',paga_fon_res,0, tipo_ir, 0,0,0 --21  
  ,0,usuario,biometrico ,cod_cargo,DISCAPACIDAD,'','','','' --22  
  ,por_discapacidad,'N','N',0,0,0,0,ctacble,'',''    -- 23           
  ,0,0,0,0,0,contacto,observacion,COD_CIUDAD,0,0  --24   
  ,per_prueba,aplica_bono,0,0,0,0,0,0,0,0  --25     
  ,0,0,0,0,0,0,'N',0,0,0,0,0  --26  
  ,0,email,pago_otro,0,0  
  , cedcta ,0,0     
  ,login_,emf_catastrofica  
  -- select *  
  from TEMP_ROLMM01                          
  where compania= @i_compania                          
  and usuario = @i_usuario                          
  and maquina = @i_maquina                              
 End try                                                                 
 Begin Catch            
  set @o_empleado=0                                 
  set @o_error =1                                    
  set @o_mensaje = 'Error al Insertar Empleado........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
  rollback tran ins                          
  return 0                                   
 End Catch    
 Begin Try   
 insert into ROL_Fondo_Reserva_Mensual  
 (fr_compania, fr_empleado,fr_fechai,fr_fechaf,fr_mensual)  
 select compania,@w_codigo, '19000101','19000101','S'   
 from TEMP_ROLMM01                          
 where compania= @i_compania                          
 and usuario = @i_usuario                          
 and maquina = @i_maquina  
 End try                                                                 
 Begin Catch            
  set @o_empleado=0                                 
  set @o_error =1                                    
  set @o_mensaje = 'Error al Insertar Empleado Tabla de reserva........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
  rollback tran ins                          
  return 0                                   
 End Catch   
                
 Begin Try          
 -- select * from ROLM03          
     insert into  ROLM03           
  (NM03CODCIA, NM03CODEMP, NM03SECUEN, CM03NOMBRE, TM03FECNAC, CM03SEXO, CM03INDICA, CM03ESTADO,TM03APORTA
  ,CM03UTILIDAD,CM03IMPRENT,CM03CATASTROFICA
  )          
  select           
         compania,empleado,secuencia,nombre,fecha,sexo,parentesco,estado,aporta
		  ,utilidad,imp_retencion,catastrofica     
  from TEMP_CARGAS          
  where compania= @i_compania                          
  and usuario = @i_usuario                          
  and maquina = @i_maquina           
 End try             
 Begin Catch            
  set @o_empleado=0                                 
  set @o_error =1                                    
  set @o_mensaje = 'Error al Insertar Cargas Empleado........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'             
  rollback tran ins                          
  return 0                                   
 End Catch             
          
 set @o_error =0                                    
 set @o_mensaje = 'Empleado se Guardo Correctamente '                       
 set @o_empleado =  @w_codigo                      
 commit tran ins                                  
 SET XACT_ABORT OFF 
 
 
 
 if @w_auditoria = 'S'  
begin  
   
    EXEC sp_xml_preparedocument @w_i OUTPUT, @i_xml_aud  
     select @w_ejecutable = ejecutable  
     , @w_maquina = maquina  
     , @w_usuario = usuario  
     from OpenXML(@w_i,'/AUDITORIA/PARAMETROS')                
     WITH ( compania  int ,ejecutable nvarchar(30)  
     , usuario nvarchar(30), maquina nvarchar(30)  
     )    
    EXEC sp_xml_removedocument @w_i   
   
      
  select @w_base_auditoria = gr_base_auditoria   
  from siacdb..PAR_Parametro_General  
  where gr_clave = @i_compania  
    
  set @w_xml = (select '@aplicativo' = @w_ejecutable   
  , '@maquina' = @w_maquina  
  , '@usuario' = @w_usuario  
  ,(  
   select '@id'= id ,'@valor' = valor   
   from (  
   select id = 1  
   ,valor = @i_compania   
   union all  
   select id = 2  
   ,valor = @w_codigo  
   ) c  
   FOR XML PATH('atributo'), type  
  )  
  from tb_empresa  
  where em_codigo = 1  
  FOR XML PATH('parametro'), ROOT('xml')  
  )  
   
  set @w_sql = ' exec ' + @w_base_auditoria + '.dbo.AUDSp_Auditoria @i_operacion = ''insxml''  
  , @i_compania = ' + convert(nchar(10),@i_compania)  
  + ' , @i_ensamblado = ' + CHAR(39) + @w_ejecutable + CHAR(39)  
  + ' , @i_usuario  = ' + CHAR(39) + @w_usuario + CHAR(39)  
  + ' , @i_maquina = ' + CHAR(39) + @w_maquina + CHAR(39)  
  + ' , @i_accion = ''INS''  
  , @i_parametro = ' + CHAR(39) + convert(nvarchar(max),@w_xml) + CHAR(39)  
  + ' , @o_error = @x_error output  
  , @o_mensaje = @x_mensaje output'  
  set @w_parametros = ' @x_error int output, @x_mensaje nvarchar(10) output '  
  EXECUTE sp_executesql @w_sql, @w_parametros,@x_error = @s_error output,@x_mensaje = @s_mensaje output   
    
    
end  
       
 
                                
 return 0                                       
end                          
                           
if @i_operacion = 'Update'                            
begin            
    
select @w_estadoa = isnull(a.CM01STSEMP,'A')    
from ROLM01 a,TEMP_ROLMM01 b    
  where a.NM01CODCIA = b.compania                          
  and a.NM01CODEMP =  b.empleado                          
  and compania= @i_compania                          
  and usuario = @i_usuario                          
  and maquina = @i_maquina       
      
  select @w_estadon = estado    
  from TEMP_ROLMM01     
  where compania= @i_compania                          
  and usuario = @i_usuario                          
  and maquina = @i_maquina    
    
if @w_estadon= 'I'  
begin  
if exists(select top 1 1 from vw_rep_cuentas_cobrar_pendiente_det a, TEMP_ROLMM01 b where a.compania = b.compania and a.empleado = b.empleado  
and  b.compania= @i_compania                          
  and b.usuario = @i_usuario                          
  and b.maquina = @i_maquina    
and a.pendiente > 0 )  
begin  
  set @o_empleado=0    
  set @o_error =1                                 
  set @o_mensaje = 'Empleado: Posee Cuentas por Cobrar Pendiente....verifique........'  
  return 0                                   
end  
end       
if @w_auditoria = 'S'  
 begin  
 --select 'ok1' 
 --print '0' 
    EXEC sp_xml_preparedocument @w_i OUTPUT, @i_xml_aud  
     select @w_ejecutable = ejecutable  
     , @w_maquina = maquina  
     , @w_usuario = usuario  
     from OpenXML(@w_i,'/AUDITORIA/PARAMETROS')                
     WITH ( compania  int ,ejecutable nvarchar(30)  
     , usuario nvarchar(30), maquina nvarchar(30)  
     )    
    EXEC sp_xml_removedocument @w_i   
   
  --  select @w_ejecutable, @w_maquina,@w_usuario  
  select @w_base_auditoria = gr_base_auditoria   
  from siacdb..PAR_Parametro_General  
  where gr_clave = @i_compania  
    
  set @w_xml = (select '@aplicativo' = @w_ejecutable   
  , '@maquina' = @w_maquina  
  , '@usuario' = @w_usuario  
  ,(  
   select '@id'= id ,'@valor' = valor   
   from (  
   select id = 1  
   ,valor = @i_compania   
   union all  
   select id = 2  
   ,valor = @i_empleado  
   ) c  
   FOR XML PATH('atributo'), type  
  )  
  from tb_empresa  
  where em_codigo = 1  
  FOR XML PATH('parametro'), ROOT('xml')  
  )  
  --select @w_xml  
    
     set @w_sql = ' exec ' + @w_base_auditoria + '.dbo.AUDSp_Auditoria @i_operacion = ''rexml''  
  , @i_compania = ' + convert(nchar(10),@i_compania)  
  + ' , @i_ensamblado = ' + CHAR(39) + @w_ejecutable + CHAR(39)  
  + ' , @i_usuario  = ' + CHAR(39) + @w_usuario + CHAR(39)  
  + ' , @i_maquina = ' + CHAR(39) + @w_maquina + CHAR(39)  
  + ' , @i_parametro = ' + CHAR(39) + convert(nvarchar(max),@w_xml) + CHAR(39)  
  + ' , @o_xml = @x_xml output '  
  set @w_parametros = ' @x_xml xml output '  
  EXECUTE sp_executesql @w_sql, @w_parametros,@x_xml = @w_xml_out output   
  --select @w_xml_out  
 end 
    -- print '1'                                             
 SET XACT_ABORT ON                            
 begin tran upd                                  
 Begin Try                            
  update ROLM01                          
  set CM01TIPOID = tipo_id                          
  , CM01IDENTI = ruc                          
  , CM01NOMBRE = nombre                          
  , CM01DIRECC = direccion                          
  , CM01TELEFO = telefono                          
  , CM01SEXO = sexo                          
  , CM01ESTCIV = estado_civil                          
  , CM01LUGNAC = lugar_nac                          
  , TM01FECNAC = fecha_nac                          
  , CM01NACION = nacionalidad                          
  , NM01CODTIT = titulo                          
  , NM01CODEST = codest                          
  , CM01CODACT = sector2                
  , CM01CDIESS = carnet_iess                          
  , TM01FECING = fecha_ing                          
  , TM01FECEGR = fecha_egreso                          
  , CM01CUENTA = cuenta                          
  , CM01TIPCTA = tipoCta                          
  , CM01DEPCTA = depcta                          
  , NM01CODDEP = departamento                          
  , NM01CODSEC = sector                      
  , NM01CODCAR = cargo                          
  --, NM01NUMCAR =                           
  , CM01TIPLIQ = tipo_liq                          
  , CM01STSEMP = estado                          
  , CM01BENEFI = beneficio                          
  , NM01SDOBAS = sueldo                          
  , NM01MOVIL = transporte                          
  , NM01SDOEXTRA = extra                          
  , CM01CLASE = clase                          
  , CM01SECTOR =  sector                
  , CM01TIPOSANGRE = tipo_sangre                          
  ,NM01CEDMILITAR = ced_militar                          
  , NM01MATRICULAPORT = mat_portuaria                          
  , CM01RELACION = relacion              
 -- select * from ROLM01      
  ,NM01CODCIU =COD_CIUDAD              
  ,ROL_DISCAPACIDAD=DISCAPACIDAD         
  --ROL_DISCAPACIDAD, NM01CODCIU           
--   select ROL_DISCAPACIDAD ,ROL_PORDISCAPACIDAD   ,* from rolm01      
  ,TM01FECTERCONTRATO= terminoC            
  ,ROL_PORDISCAPACIDAD = por_discapacidad          
  ,ROL_CAT_IR=tipo_ir          
  ,ROL_COD_BIO=biometrico          
  ,ROL_CODCARGO=cod_cargo          
  ,ROL_CONTACTO = contacto        
  ,ROL_OBSERVACION=observacion        
  ,FONRES_LEGAL_ROL =  paga_fon_res       
  ,CM01CTACONTA = ctacble        
  ,NM01PERPRUEBA =  per_prueba      
  ,NM01APLLIMT = aplica_bono      
   ,CM01EMAIL = email   
   ,NM01PAGOTRO = pago_otro    
,ROL_ALIMENTACION =  alimentacion 
, NM01CEDCTA = cedcta
,NM01EMFCAT = emf_catastrofica  
, NM01LOGIN = login_
  from ROLM01,TEMP_ROLMM01                          
  where NM01CODCIA = compania                          
  and NM01CODEMP =  empleado                          
  and compania= @i_compania                          
  and usuario = @i_usuario                          
  and maquina = @i_maquina                          
               
               
  update ROLM01 set TM01FECEGR=null          
  where TM01FECEGR='1900-01-01 00:00:00'          
 End try                                                                 
 Begin Catch               
  set @o_empleado=0                                
  set @o_error =1                                    
  set @o_mensaje = 'Error 1 al Actualizar Empleado........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
  rollback tran upd                          
  return 0                                   
 End Catch              
     
 if not exists(    
 select 1    
from ROL_Accion_Personal a,TEMP_ROLMM01 b    
  where a.ap_compania = b.compania                          
  and a.ap_empleado =  b.empleado                          
  and compania= @i_compania                          
  and usuario = @i_usuario                          
  and maquina = @i_maquina       
  and ap_fecha = @w_fecha_proceso    
  and (@w_estadoa != @w_estadon)    
  and (@w_estadon = 'I' and a.ap_tipo_accion = 21) or (@w_estadon = 'A' and a.ap_tipo_accion = 22)    
 ) --and (@w_estadoa != @w_estadon) and (@w_estadon = 'I')    
 begin    
   if (@w_estadoa != @w_estadon)     
   begin    
    if @w_estadon = 'I'    
    begin    
   set @w_tipo_accion = 21    
   set @w_observacion_acc = 'ANULACION/SALIDA DE EMPLEADO '    
    end    
    else    
    begin    
    set @w_tipo_accion = 22    
   set @w_observacion_acc = 'RE-INGRESO DE EMPLEADO '      
    end    
   select @w_numero_acc = max(ap_numero) + 1    
   from ROL_Accion_Personal a,TEMP_ROLMM01 b    
    where a.ap_compania = b.compania                          
    and a.ap_empleado =  b.empleado                          
    and compania= @i_compania                          
    and usuario = @i_usuario                          
    and maquina = @i_maquina      
    set @w_numero_acc = isnull(@w_numero_acc,1)    
   INSERT INTO ROL_Accion_Personal(    
   ap_compania,  ap_empleado,  ap_numero,  ap_tipo_accion,   ap_fecha,  ap_fecha_rige    
   ,ap_fecha_ingreso, ap_observacion,  ap_estado,  ap_aplicado)    
   select compania, empleado,   @w_numero_acc, @w_tipo_accion,   @w_fecha_proceso, @w_fecha_proceso    
   ,fecha_ing,   @w_observacion_acc,'A', 'N'    
    from TEMP_ROLMM01     
    where compania= @i_compania                          
    and usuario = @i_usuario                          
    and maquina = @i_maquina    
      
      
   end    
 end       
       
 if exists ( select 1 from TEMP_ROLMM01 where compania= @i_compania                          
  and usuario = @i_usuario                          
  and maquina = @i_maquina       
  and isnull(fecha_egreso, '19000101') != '19000101'             
  )            
 begin      
       
  Begin Try        
        
--********************************************************************************************************        
--****************************************** Decimo Tercero  *********************************************        
--********************************************************************************************************         
-- select convert(nvarchar(20),getdate(),112)      
declare @w_ingresos  float, @w_fondo_reserva float, @w_tipo_liq nvarchar(1) , @dias_fr int      
      
 set @w_ingresos  = 0        
 select @w_fecha_proceso = substring(convert(nvarchar(20),TM01FECEGR,112),1,6)+'15'       
 , @w_tipo_liq= CM01TIPLIQ       
 -- select *      
 from ROLM01      
 where NM01CODCIA = @i_compania                          
 and NM01CODEMP =  @i_empleado        
      
 update rolh01        
 set NH01PROVD3 = 0        
 ,ROL_XIII_VM = 0        
 ,ROL_XIII_BASE =0        
 , NH01PROVD4 = 0        
 ,ROL_XIV_BASE = 0         
 , ROL_XIV_VM=0        
 , ROL_XIV_DIAS = 0       
 where nh01codcia = @i_compania        
 and nh01codemp = @i_empleado       
 and TH01FECPRO= @w_fecha_proceso      
       
 exec RolSp_Ingreso_Beneficios            
  @i_compania = @i_compania        
  , @i_tipo = 3            
  , @i_empleado = @i_empleado        
  , @i_estado = 'I'       
  , @i_fecha = @w_fecha_proceso         
  , @O_Ingreso = @w_ingresos output         
  , @i_usuario = @i_usuario        
  , @i_maquina = @i_maquina        
       
   update rolh01          
   set Nh01PROVD3 = (@w_Ingresos/12)        
   , ROL_XIII_BASE=@w_Ingresos       
   , NH01VACACIONES = (@w_Ingresos/24)        
   , ROL_VAC_BASE = @w_Ingresos       
   where Nh01CODCIA = @i_compania        
   and nh01codemp = @i_empleado       
   and TH01FECPRO= @w_fecha_proceso      
   AND isnull(ROL_XIII,'N') = 'N'         
       
  update rolh01       
  set ROL_XIV_DIAS =       
  (case when CH01TIPFLT not in('A') and CH01FLGEMB in('N') then         
  isnull(NH01DIASTB,0) + isnull(NH01DIAVAC,0)            
  when CH01TIPFLT not in('A') and CH01FLGEMB in('S') then 15        
  else NH01DIASTB      
  end  )      
  where Nh01CODCIA = @i_compania        
   and nh01codemp = @i_empleado       
   and TH01FECPRO= @w_fecha_proceso      
   AND isnull(ROL_XIV,'N') ='N'      
   update rolh01       
   set NH01PROVD4 = (select NT08XIV/360 from rolt08 where NT08CODCIA=Nh01CODCIA) * ROL_XIV_DIAS      
   , ROL_XIV_BASE = (select NT08XIV from rolt08 where NT08CODCIA=Nh01CODCIA)      
   where Nh01CODCIA = @i_compania        
   and nh01codemp = @i_empleado       
   and TH01FECPRO= @w_fecha_proceso      
   AND isnull(ROL_XIV,'N') ='N'      
         
    exec RolSp_Fondo_Reserva        
     @i_compania = @i_compania        
   , @i_empleado  = @i_empleado      
   , @i_estado = 'I'        
   , @i_tipo_liq = @w_tipo_liq        
   , @i_usuario = @i_usuario        
   , @i_maquina = @i_maquina        
   , @i_fecha = @w_fecha_proceso        
   , @i_FR = @w_fondo_reserva output        
   , @o_ingreso = @w_Ingresos output        
   , @o_dias = @dias_fr output        
         
         
   update rolh01      
   set NH01FONRES = @w_fondo_reserva        
 , ROL_FR_BASE= @w_Ingresos        
 , ROL_FR_DIAS = @dias_fr       
   where Nh01CODCIA = @i_compania        
   and nh01codemp = @i_empleado       
   and TH01FECPRO= @w_fecha_proceso      
   and  isnull(CH01FLAGMENFR,'N') = 'N'        
   and  exists( select 1 from ROL_Periodo_Trabajo where pt_compania = @i_compania and pt_empleado = @i_empleado and pt_status = 'E' )                      
       
  --select * from rolm01      
  --where year(TM01FECEGR) = 2016       
  --and day(TM01FECEGR) between 16 and 31      
               
  End try                                                                 
 Begin Catch               
  set @o_empleado=0                                
  set @o_error =1                                    
  set @o_mensaje = 'Error al Actualizar Empleado:........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
  rollback tran upd                          
  return 0                                   
 End Catch                   
              
 end       
       
              
 Begin Try          
     -- select * from ROLM03      
           
     delete  ROLM03           
  from ROLM03 a, TEMP_ROLMM01 b          
  where NM03CODCIA = b.compania          
  and  NM03CODEMP = b.empleado          
  and compania= @i_compania                          
  and usuario = @i_usuario                          
  and maquina = @i_maquina             
          
            
 End try             
 Begin Catch            
  set @o_empleado=0                                 
  set @o_error =1                                    
  set @o_mensaje = 'Error al Eliminar Cargas Empleado........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
  rollback tran upd                          
  return 0                                   
 End Catch             
          
          
 Begin Try          
 -- select * from ROLM03          
 -- select * from TEMP_CARGAS N          
     insert into  ROLM03           
  (NM03CODCIA, NM03CODEMP, NM03SECUEN, CM03NOMBRE, TM03FECNAC, CM03SEXO, CM03INDICA, TM03APORTA,CM03ESTADO
  ,CM03UTILIDAD,CM03IMPRENT,CM03CATASTROFICA )          
  select           
         compania,empleado,secuencia,nombre,fecha,sexo,parentesco,aporta,estado
		 ,utilidad,imp_retencion,catastrofica
  from TEMP_CARGAS          
  where compania= @i_compania                          
  and usuario = @i_usuario                          
  and maquina = @i_maquina           
 End try             
 Begin Catch            
  set @o_empleado=0                                 
  set @o_error =1                                    
  set @o_mensaje = 'Error al Insertar Cargas Empleado1........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
  rollback tran upd                          
  return 0                                   
 End Catch             
          
    
if @w_estadon= 'A'  
begin   
 	Begin Try   

	--- select * from TEMP_ROLMM01
	 if exists(select 1 from TEMP_ROLMM01 b where compania= @i_compania                          
				and usuario = @i_usuario                          
				and maquina = @i_maquina
				and paga_fon_res = 'S')
     begin
		if not exists(select 1 
				from ROL_Fondo_Reserva_Mensual a, TEMP_ROLMM01 b 
				where a.fr_compania = b.compania
				and a.fr_empleado = b.empleado
				and compania= @i_compania                          
				and usuario = @i_usuario                          
				and maquina = @i_maquina
				and paga_fon_res = 'S'
				)
		begin
			insert into ROL_Fondo_Reserva_Mensual  
			(fr_compania, fr_empleado,fr_fechai,fr_fechaf,fr_mensual)  
			select compania,empleado, '19000101','19000101','S'   
			from TEMP_ROLMM01                          
			where compania= @i_compania                          
			and usuario = @i_usuario                          
			and maquina = @i_maquina 
		end

		if exists(select 1 
		from ROL_Fondo_Reserva_Mensual a, TEMP_ROLMM01 b 
		where a.fr_compania = b.compania
		and a.fr_empleado = b.empleado
		and compania= @i_compania                          
		and usuario = @i_usuario                          
		and maquina = @i_maquina
		and paga_fon_res = 'S'
		)
		begin
				update ROL_Fondo_Reserva_Mensual
				set fr_fechai= '19000101'
				,fr_fechaf = '19000101'
				,fr_mensual = 'S'
				from ROL_Fondo_Reserva_Mensual a, TEMP_ROLMM01 b 
				where a.fr_compania = b.compania
				and a.fr_empleado = b.empleado
				and compania= @i_compania                          
				and usuario = @i_usuario                          
				and maquina = @i_maquina
		end
	  end
	 else
	 begin
				delete ROL_Fondo_Reserva_Mensual
			    from ROL_Fondo_Reserva_Mensual a, TEMP_ROLMM01 b 
				where a.fr_compania = b.compania
				and a.fr_empleado = b.empleado
				and compania= @i_compania                          
				and usuario = @i_usuario                          
				and maquina = @i_maquina

	 end 	
	End try                                                                 
	Begin Catch            
		set @o_empleado=0                                 
		set @o_error =1                                    
		set @o_mensaje = 'Error al Insertar Empleado Tabla de reserva........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
		rollback tran upd                          
	return 0                                   
	End Catch       

end	 
	      
          
          
 set @o_empleado=@i_empleado                        
 set @o_error =0                                    
 set @o_mensaje = 'Empleado se actualizo Correctamente '                          
 commit tran upd                             
 SET XACT_ABORT OFF    
 --print 'up3'

 if @w_auditoria = 'S'  
 begin  
    set @w_sql = ' exec ' + @w_base_auditoria + '.dbo.AUDSp_Auditoria @i_operacion = ''insxml''  
  , @i_compania = ' + convert(nchar(10),@i_compania)  
  + ' , @i_ensamblado = ' + CHAR(39) + @w_ejecutable + CHAR(39)  
  + ' , @i_usuario  = ' + CHAR(39) + @w_usuario + CHAR(39)  
  + ' , @i_maquina = ' + CHAR(39) + @w_maquina + CHAR(39)  
   + ' , @i_accion = ''UPD''  
  , @i_xml = ' + CHAR(39) + convert(nvarchar(max),@w_xml_out) + CHAR(39)  
  + ' , @i_parametro = ' + CHAR(39) + convert(nvarchar(max),@w_xml) + CHAR(39)  
  + ' , @o_error = @x_error output  
  , @o_mensaje = @x_mensaje output'  
  set @w_parametros = ' @x_error int output, @x_mensaje nvarchar(300) output'  
  EXECUTE sp_executesql @w_sql, @w_parametros,@x_error = @s_error output,@x_mensaje = @s_mensaje output    
  --select @s_error,@s_mensaje   
 end  
 --print 'up4'
                             
 return 0                                                                            
end                          
if @i_operacion in ('upd_imag')                          
begin     
 SET XACT_ABORT ON                            
 begin tran upd                                  
 Begin Try     
    update  ROLM01    
    set NM01FOTO = @i_imagen    
    -- alter table rolm01 alter column NM01FOTO varbinary(max)    
  where NM01CODCIA = @i_compania                          
  and NM01CODEMP =  @i_empleado                          
      
 End try             
 Begin Catch            
  set @o_empleado=0                                 
  set @o_error =1                                    
  set @o_mensaje = 'Error al Insertar Imagen Empleado........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
  rollback tran upd                          
  return 0                                   
 End Catch      
    
 set @o_empleado=@i_empleado                        
 set @o_error =0                                    
 set @o_mensaje = 'Empleado se actualizo imagen Correctamente '           
 commit tran upd                             
 SET XACT_ABORT OFF                                
 return 0     
end                        
if @i_operacion = 'deleteCF'                            
begin                                                            
 SET XACT_ABORT ON                            
 begin tran dlt                                  
 Begin Try                            
  delete             
  from ROLM03                          
  where NM03CODCIA = @i_compania                          
  and NM03CODEMP =  @i_empleado                        
 End try                      
 Begin Catch                                   
  set @o_error =1                                    
  set @o_mensaje = 'Error al Borar Cargas Familiares........' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                                    
  rollback tran dlt                          
  return 0                                   
 End Catch          
                               
 set @o_error =0                                    
 set @o_mensaje = 'Registros de Carga familiar Borrados correctamente'                          
 commit tran dlt                             
 SET XACT_ABORT OFF                                
 return 0                                                                             
end 
GO

