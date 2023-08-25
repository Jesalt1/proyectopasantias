USE [ROLES]
GO

/****** Object:  StoredProcedure [dbo].[sp_Registrar_Rubros]    Script Date: 24/08/2023 14:11:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 /* _____________________________________________________________________________      
   |    DATOS GENERALES:                                                        |      
   |         PRODUCTO:                          ROLES                      |      
   |         BASE DE DATOS:                     ROLES                          |      
   |         STORE PROCEDURE:                   sp_Registrar_Rubros             |      
   |         FECHA DE CREACION:                 15/julio/2008                     |      
   |____________________________________________________________________________|      
*/      
      
CREATE                                 PROCEDURE [dbo].[sp_Registrar_Rubros]      
(      
      
 @i_operacion  char(10),      
 @i_compania   int=null,      
 @i_codigo  int=null,      
 @i_empleado  int=null,      
 @i_rubro  int=null,      
 @i_anio   int=null,      
 @i_fecha   datetime=null,      
 @i_valor   float=null,      
 @i_estado  char(1)=null,      
 @i_nomemple  char(50)=null,      
 @i_ing_anual  float=null,      
 @i_iess_anual  float=null,      
 @i_ir_cobrado  float=null,      
 @i_meses_proy  int=null,      
 @i_ingresos_otros float=0,      
 @i_gastos_otros  float=0,      
 @i_rebajas_otros float=0,      
 @i_impuesto_otros float=0, 
 ----------------------------------------
 @i_xml_aud xml=null,    
 @i_XML xml=null,      
  @i_usuario nvarchar(30)=null,      
 @i_maquina nvarchar(30)=null,    
 @i_cab_cargas int=0,  
 @i_emf_catastrofica nchar(1)=null, 
  @o_idnumero int =0 output,                

 ----------------------------------------
 @o_cod int =0 output,      
 @o_error int=0 output,      
 @o_mensaje nvarchar(200)='' output      
)      
      
AS       
----------------------------------------
declare @secc int,@w_i int      
     
, @w_ejecutable nvarchar(30)        
, @w_maquina nvarchar(30)        
, @w_usuario nvarchar(30)        
, @w_auditoria  nchar(1)        
, @w_base_auditoria nvarchar(60)        
, @w_parametros nvarchar(max)        
     
, @w_xml_out  xml        
, @w_xml  xml        
, @w_sql  nvarchar(max)        
declare @s_error int, @s_mensaje nvarchar(max)       
if @i_operacion = 'para'        
begin  
 select ISNULL(NT08CARGAIMP,1) carga_imp   
 from rolt08  
 where NT08CODCIA = @i_compania  
end  
------------------------------------------------------------------------
      
if @i_operacion = 'ICAB'      
begin       
      
 BEGIN TRY      
    
      
  select @secc=isnull(max(irecab_codigo),0)+1       
 from tbIR_Cab_RubrosxEmpleado       
 where irecab_compania  = @i_compania      
  and irecab_empleado = @i_empleado      
  and irecab_anio  = @i_anio      
      
      
 INSERT INTO tbIR_Cab_RubrosxEmpleado       
 ( irecab_compania, irecab_codigo, irecab_empleado, irecab_anio,       
   irecab_fecha, irecab_estado, irecab_ing_anual, irecab_apiess_anual,      
   irecab_renta_cobrado, irecab_meses_proy,      
   irecab_ingreso_empleadores, irecab_ded_gas_empleadores,      
   irecab_otras_ded_empleadores, irecab_impuesto_otros                                       
   -----------------------------------------
   ,irecab_cargas,irecab_emf_catastrofica 
   ---------------------------------------
 )       
       
 VALUES       
 ( @i_compania, @secc, @i_empleado, @i_anio,       
   @i_fecha, @i_estado,  @i_ing_anual, @i_iess_anual, @i_ir_cobrado,       
   @i_meses_proy,      
   @i_ingresos_otros , @i_gastos_otros,       
   @i_rebajas_otros, @i_impuesto_otros 
   ----------------------------------
 ,@i_cab_cargas,@i_emf_catastrofica 
   -------------------------------------
  )      
        
  set @o_error=0            
  set @o_cod=@secc            
  set @o_mensaje='Transaccion Ok..'           
 end try      
 begin catch      
   set @o_cod=0           
   set @o_error=1            
      set @o_mensaje='Error Al Guardar la transaccion.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'           
 end catch       
      
 UPDATE tbIR_Cab_RubrosxEmpleado       
    set irecab_estado  = 'I'       
 where irecab_compania  = @i_compania       
  and irecab_empleado = @i_empleado      
  and irecab_anio  = @i_anio      
  and irecab_codigo <>@i_codigo      
end       
if @i_operacion = 'UCAB'      
begin
 BEGIN TRY   

update tbIR_Cab_RubrosxEmpleado
set irecab_fecha= @i_fecha
, irecab_ing_anual = @i_ing_anual
, irecab_apiess_anual = @i_iess_anual
, irecab_renta_cobrado = @i_ir_cobrado
, irecab_meses_proy=   @i_meses_proy    
, irecab_ingreso_empleadores= @i_ingresos_otros
, irecab_ded_gas_empleadores= @i_gastos_otros
, irecab_otras_ded_empleadores= @i_rebajas_otros
, irecab_impuesto_otros = @i_impuesto_otros
-----------------------------------------------
 ,irecab_cargas = @i_cab_cargas,
 irecab_emf_catastrofica =@i_emf_catastrofica  
 ------------------------------------------------------
where irecab_compania  = @i_compania       
  and irecab_empleado = @i_empleado      
  and irecab_anio  = @i_anio      
  and irecab_codigo = @i_codigo  
  
  set @o_error=0            
  --set @o_cod=@secc            
  set @o_mensaje='Transaccion Ok..'           
 end try      
 begin catch      
  -- set @o_cod=0           
   set @o_error=1            
      set @o_mensaje='Error Al Guardar la transaccion.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'           
 end catch         
end      
if @i_operacion = 'IDET'      
begin       
 UPDATE tbIR_Det_RubrosxEmpleado       
    set iredet_estado  = 'I'       
 where iredet_compania  = @i_compania       
  and iredet_empleado = @i_empleado      
  and iredet_anio  = @i_anio      
  and iredet_codigo <>@i_codigo      
      
 --*************************************************      
      
 INSERT INTO tbIR_Det_RubrosxEmpleado       
 ( iredet_compania, iredet_codigo, iredet_empleado, iredet_anio,       
 iredet_rubro, iredet_fecha, iredet_valor, iredet_estado )       
       
 VALUES       
 ( @i_compania, @i_codigo, @i_empleado, @i_anio, @i_rubro,       
   @i_fecha, @i_valor, @i_estado )      
end       
      
      
if @i_operacion = 'DELDET'      
begin       
begin try      
    DELETE tbIR_Det_RubrosxEmpleado       
 where iredet_compania  = @i_compania       
  and iredet_empleado = @i_empleado      
  and iredet_anio  = @i_anio      
  and iredet_codigo =@i_codigo      
        
     set @o_error=0            
  set @o_cod=@i_codigo              set @o_mensaje='Transaccion Ok..'           
end try      
begin catch      
  set @o_cod=0           
   set @o_error=1            
      set @o_mensaje='Error Al Guardar la transaccion.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'           
end catch      
end       
      
if @i_operacion = 'IDET2'      
begin       
 INSERT INTO tbIR_Det_RubrosxEmpleado       
 ( iredet_compania, iredet_codigo, iredet_empleado, iredet_anio,       
 iredet_rubro, iredet_fecha, iredet_valor, iredet_estado )       
       
 VALUES       
 ( @i_compania, @i_codigo, @i_empleado, @i_anio, @i_rubro,       
   @i_fecha, @i_valor, @i_estado )      
end       
      
if @i_operacion='C2'      
begin       

 select B.ir_codigo,B.ir_descripcion, isnull(A.iredet_valor,0) as valor ,Tipo=B.ir_tipo     
 , tope_rubro = isnull(B.ir_tope,0) 
 -- select *
 from  tbIR_RubrosGastos B left join tbIR_Det_RubrosxEmpleado A  on A.iredet_compania=B.ir_compania       
   and A.iredet_rubro =B.ir_codigo and A.iredet_estado='A' and A.iredet_empleado=@i_empleado      
 where B.ir_compania =@i_compania      
  and B.ir_estado='A'      
      
     select md_tipo, md_valor      
   from tbIR_Monto_Deducion         
   where md_compania = @i_compania      
   and md_anio = @i_anio 

   select count(1) count1
   from tbIR_RubrosGastos
   where ir_compania = @i_compania
   and ir_tipo = 1

   select 'collection' ,'detalle;resumen;no;tabla' 

 /*    
 select B.ir_codigo,B.ir_descripcion, isnull(A.iredet_valor,0) as valor ,Tipo=B.ir_tipo     
 from  tbIR_RubrosGastos B left join tbIR_Det_RubrosxEmpleado A  on A.iredet_compania=B.ir_compania       
   and A.iredet_rubro =B.ir_codigo and A.iredet_estado='A' and A.iredet_empleado=101      
 where B.ir_compania =1      
  and B.ir_estado='A'      
*/      
      
end       
      
if @i_operacion='C2AN'      
begin       
-- select * from tbIR_RubrosGastos
 select B.ir_codigo,B.ir_descripcion, isnull(A.iredet_valor,0) as valor ,Tipo=B.ir_tipo 
 , tope_rubro = isnull(B.ir_tope,0) 
 from  tbIR_RubrosGastos B left join tbIR_Det_RubrosxEmpleado A  on A.iredet_compania=B.ir_compania       
   and A.iredet_rubro =B.ir_codigo and A.iredet_estado='A' and A.iredet_empleado=@i_empleado      
 where B.ir_compania =@i_compania      
  and B.ir_estado='A' and A.iredet_anio =@i_anio      
     
   select md_tipo, md_valor      
   from tbIR_Monto_Deducion         
   where md_compania = @i_compania      
   and md_anio = @i_anio 

   select count(1) count1
   from tbIR_RubrosGastos
   where ir_compania = @i_compania
   and ir_tipo = 1

   select 'collection' ,'detalle;resumen;no,tabla'      
/*    
    
 select B.ir_codigo,B.ir_descripcion, isnull(A.iredet_valor,0) as valor ,Tipo=B.ir_tipo      
 from  tbIR_RubrosGastos B left join tbIR_Det_RubrosxEmpleado A  on A.iredet_compania=B.ir_compania       
   and A.iredet_rubro =B.ir_codigo and A.iredet_estado='A' and A.iredet_empleado=101      
 where B.ir_compania =1      
  and B.ir_estado='A' and A.iredet_anio =2013      
*/      
      
end       
      
if @i_operacion='C3'      
begin       
 select *       
 from  tbIR_Cab_RubrosxEmpleado       
 where  irecab_compania  =@i_compania      
        and   irecab_empleado =@i_empleado      
end       
      
if @i_operacion='C4'      
begin       
 select         
   irecab_fecha, irecab_estado, irecab_ing_anual, irecab_apiess_anual,      
   irecab_renta_cobrado, irecab_meses_proy,      
   isnull(irecab_ingreso_empleadores,0) as ingresos_otros       
   , isnull(irecab_ded_gas_empleadores,0) as gastos_otros ,      
   isnull(irecab_otras_ded_empleadores,0) as rebajas_otros ,      
   isnull(irecab_impuesto_otros,0) as impuestos_otros         
 from  tbIR_Cab_RubrosxEmpleado       
 where  irecab_compania  = @i_compania      
        and   irecab_empleado = @i_empleado      
  and   irecab_codigo = @i_codigo      
  and   irecab_anio = @i_anio      
end       
if @i_operacion='C4T'      
begin       
 select         
   irecab_fecha, irecab_estado, irecab_ing_anual, irecab_apiess_anual,      
   irecab_renta_cobrado, irecab_meses_proy,      
   isnull(irecab_ingreso_empleadores,0) as ingresos_otros       
   , isnull(irecab_ded_gas_empleadores,0) as gastos_otros ,      
   isnull(irecab_otras_ded_empleadores,0) as rebajas_otros ,      
   isnull(irecab_impuesto_otros,0) as impuestos_otros,irecab_codigo   
   --------------------------------------------------------
  ,isnull(irecab_cargas,0) cargas , 
   isnull(irecab_emf_catastrofica,'N') emf_catastrofica  
   --------------------------------------------------------
 from  tbIR_Cab_RubrosxEmpleado       
 where  irecab_compania  = @i_compania      
        and   irecab_empleado = @i_empleado      
  --and   irecab_codigo = @i_codigo      
  and   irecab_anio = @i_anio      
  and   irecab_estado = 'A'       
 /*    
 select         
   irecab_fecha, irecab_estado, irecab_ing_anual, irecab_apiess_anual,      
   irecab_renta_cobrado, irecab_meses_proy,      
   isnull(irecab_ingreso_empleadores,0) as ingresos_otros       
   , isnull(irecab_ded_gas_empleadores,0) as gastos_otros ,      
   isnull(irecab_otras_ded_empleadores,0) as rebajas_otros ,      
   isnull(irecab_impuesto_otros,0) as impuestos_otros,*    
 from  tbIR_Cab_RubrosxEmpleado       
 where  irecab_compania  = 1      
        and   irecab_empleado = 1001    
    
  and   irecab_anio = 2016      
*/      
end       
      
if @i_operacion='QN' --sp para calcular el código secuencial de la transacción      
begin      
 select max(irecab_codigo) as Total       
 from tbIR_Cab_RubrosxEmpleado       
 where irecab_compania  = @i_compania      
  and irecab_empleado = @i_empleado      
  and irecab_anio  = @i_anio      
end      
      
if @i_operacion = 'D'      
begin      
      
 delete tbIR_Det_RubrosxEmpleado      
 where iredet_compania  = @i_compania      
        and iredet_codigo = @i_codigo      
  and iredet_empleado = @i_empleado      
  and iredet_anio  = @i_anio      
       
 delete tbIR_Cab_RubrosxEmpleado      
 where irecab_compania  = @i_compania      
        and irecab_codigo = @i_codigo      
  and irecab_empleado = @i_empleado      
  and irecab_anio  = @i_anio      
        
end       
      
      
if @i_operacion = 'CE2' --consulta de empleados      
begin      
      
 SELECT NM01CODEMP, CM01NOMBRE  from  ROLM01      
 where NM01CODCIA =@i_compania      
       and NM01CODEMP =@i_empleado      
end      
      
      
if @i_operacion = 'CE3' --consulta de empleados      
begin      
      
 SELECT irecab_empleado        
 from  tbIR_Cab_RubrosxEmpleado      
 where  irecab_compania  = @i_compania      
        and irecab_anio  = @i_anio      
  and irecab_empleado = @i_empleado      
end      
      
      
if @i_operacion = 'CAPIESS' --consulta de porcentaje de aporte al iess      
begin      
      
 SELECT NT08APIESS       
 FROM ROLT08       
 WHERE NT08CODCIA = @i_compania      
/*    
 SELECT NT08APIESS       
 FROM ROLT08       
 WHERE NT08CODCIA = 1      
*/     
end      
      
/*      
if @i_operacion = 'CIRCOBRO' --consulta de IR cobrado hasta el momento      
begin      
      
 SELECT SUM(NH01RETENCION) as IR_COBRADO      
 FROM ROLH01      
 WHERE NH01CODCIA = @i_compania      
  AND NH01CODEMP = @i_empleado      
  AND YEAR(TH01FECPRO) = @i_anio      
end      
*/      
      
if @i_operacion = 'CING' --consulta de ingresos del empleado (sueldo + alimentacion)      
begin      
      
 SELECT NM01SDOBAS,       
  ROL_ALIMENTACION,       
  NM01ING003,       
  NM01ING004,       
  NM01VALSOB,       
  NM01VALSOB2,       
  NM01VALSOB3   FROM ROLM01       
 WHERE NM01CODCIA = @i_compania and      
  NM01CODEMP = @i_empleado      
end      
      
if @i_operacion = 'CFECING' --consulta de ingresos del empleado (sueldo + alimentacion)      
begin      
      
 SELECT TM01FECING       
 FROM ROLM01       
 WHERE NM01CODCIA = @i_compania and      
  NM01CODEMP = @i_empleado      
end      
      
      
if @i_operacion = 'CIRCOB' --consulta de IR Cobrado en el año      
begin      
      
 SELECT SUM(NH01IMPREN) as IR      
 FROM ROLH01       
 WHERE NH01CODCIA = @i_compania and      
  NH01CODEMP = @i_empleado and      
  YEAR(TH01FECPRO)= @i_anio      
end      
      
  if @i_operacion = 'insert'       
begin       
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
      
 select @secc=isnull(max(irecab_codigo),0)+1                 
 from tbIR_Cab_RubrosxEmpleado                 
 where irecab_compania  = @i_compania                
 and irecab_empleado = @i_empleado                
 and irecab_anio  = @i_anio        
      
 set @secc = isnull(@secc,1)      
      
 SET XACT_ABORT ON                        
 begin tran trans            
 begin try        
  UPDATE tbIR_Cab_RubrosxEmpleado                 
  set irecab_estado  = 'I'                 
  where irecab_compania  = @i_compania                 
  and irecab_empleado = @i_empleado                
  and irecab_anio  = @i_anio                
  and irecab_codigo != @secc       
  and irecab_estado ='A'      
      
  UPDATE tbIR_Det_RubrosxEmpleado                 
  set iredet_estado  = 'I'                 
  where iredet_compania  = @i_compania                 
  and iredet_empleado = @i_empleado                
  and iredet_anio  = @i_anio                
  and iredet_codigo != @secc      
  and iredet_estado = 'A'      
 EXEC sp_xml_preparedocument @w_i OUTPUT, @i_XML         
      
  -- select * from tbIR_Cab_RubrosxEmpleado    
   INSERT INTO tbIR_Cab_RubrosxEmpleado(       
   irecab_compania,  irecab_codigo,  irecab_empleado, irecab_anio      
   ,irecab_fecha,   irecab_estado,  irecab_ing_anual, irecab_apiess_anual      
   ,irecab_renta_cobrado, irecab_meses_proy, irecab_ingreso_empleadores, irecab_ded_gas_empleadores      
   ,irecab_otras_ded_empleadores, irecab_impuesto_otros   
   ---------------------------------------------------------------------------------------
   ,irecab_cargas, irecab_emf_catastrofica
   ---------------------------------------------------------------------------------------
   )       
   select       
   compania,    @secc,    empleado,   anio      
   ,fecha,     estado,    ing_anual,   iess_anual      
   ,ir_cobrado,   mes_proy,   ing_otro_emple,  gas_otro_emple      
   ,otras_reba_otro_emple, ir_otro_emple      
   ,cargas,emf_catastrofica
   FROM OpenXML(@w_i,'/GTOPER/CAB')                     
   WITH (                    
   compania  int    , usuario   nvarchar(30)  ,maquina   nvarchar(30) , empleado float         
   ,anio  int, fecha datetime, estado nchar(1), ing_anual float,iess_anual float, ir_cobrado float         
   ,mes_proy int, ing_otro_emple float, gas_otro_emple float, otras_reba_otro_emple float       
   ,ir_otro_emple float, codigo float, 
   -------------------------------------------------------------------------------
   cargas int,emf_catastrofica nchar(1)       
   --------------------------------------------------------------------------------
   ) a      
   where compania= @i_compania      
   and usuario = @i_usuario      
   and maquina = @i_maquina      
      
    INSERT INTO tbIR_Det_RubrosxEmpleado(       
    iredet_compania,  iredet_codigo,  iredet_empleado,  iredet_anio      
    ,iredet_rubro,   iredet_fecha,  iredet_valor,   iredet_estado )      
   select       
   compania,    @secc,    empleado,    anio      
   ,gasto_personal,  fecha,    valor,     estado      
   FROM OpenXML(@w_i,'/GTOPER/CAB/DET')                     
   WITH (                    
   compania  int  '../@compania', usuario   nvarchar(30) '../@usuario' ,maquina   nvarchar(30) '../@maquina'      
   ,empleado float '../@empleado',anio  int '../@anio',fecha datetime '../@fecha', estado nchar(1) '../@estado'       
   , codigo float '../@codigo'      
   , gasto_personal int, valor float      
   ) a      
   where compania= @i_compania      
   and usuario = @i_usuario      
   and maquina = @i_maquina      
 EXEC sp_xml_removedocument @w_i           
 end try            
  Begin Catch                       
   set @o_idnumero = 0                   
   set @o_error =1                        
   set @o_mensaje = 'Gtos Personal:  Error al Guardar Datos.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                        
   rollback tran trans            
   return 0                       
  End Catch       
 set @o_idnumero =   @secc      
 set @o_error =0                         
 set @o_mensaje = 'Gtos Personal:  Guardado Correctamente  '           
 commit tran trans                      
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
  from SIACDB..PAR_Parametro_General        
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
   ,valor = @secc      
    union all      
   select id = 3        
   ,valor = @i_empleado      
   union all    
   select id = 4        
   ,valor = @i_anio      
        
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
if @i_operacion = 'update'       
begin       
    
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
         
 if @w_auditoria = 'S'        
 begin        
 --select 'ok1'        
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
  from SIACDB..PAR_Parametro_General         
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
   ,valor = @i_codigo      
    union all      
   select id = 3        
   ,valor = @i_empleado      
   union all    
   select id = 4        
   ,valor = @i_anio      
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
     
 SET XACT_ABORT ON                        
 begin tran trans            
 begin try        
        
      
  delete       
  -- select *      
  from tbIR_Det_RubrosxEmpleado                 
  where iredet_compania  = @i_compania                 
  and iredet_empleado = @i_empleado                
  and iredet_anio  = @i_anio                
  and iredet_codigo = @i_codigo      
        
 EXEC sp_xml_preparedocument @w_i OUTPUT, @i_XML         
      
   update tbIR_Cab_RubrosxEmpleado      
   set irecab_fecha  = fecha      
   ,irecab_estado = estado      
   ,irecab_ing_anual = ing_anual      
   ,irecab_apiess_anual = iess_anual      
   ,irecab_renta_cobrado = ir_cobrado      
   ,irecab_meses_proy = mes_proy      
   ,irecab_ingreso_empleadores = ing_otro_emple      
   , irecab_ded_gas_empleadores = gas_otro_emple      
   ,irecab_otras_ded_empleadores = otras_reba_otro_emple      
   ,irecab_impuesto_otros =    ir_otro_emple  
   ------------------------------------------------------------------------------------
   ,irecab_cargas = cargas
   ,irecab_emf_catastrofica = emf_catastrofica 
   ------------------------------------------------------------------------------------
   FROM tbIR_Cab_RubrosxEmpleado a      
   , OpenXML(@w_i,'/GTOPER/CAB')                     
   WITH (                    
   compania  int    , usuario   nvarchar(30)  ,maquina   nvarchar(30) , empleado float         
   ,anio  int, fecha datetime, estado nchar(1), ing_anual float,iess_anual float, ir_cobrado float         
   ,mes_proy int, ing_otro_emple float, gas_otro_emple float, otras_reba_otro_emple float       
   ,ir_otro_emple float, codigo float  
   ------------------------------------------------------------------------------------
   ,cargas int,  emf_catastrofica nchar(1)    
   ------------------------------------------------------------------------------------
   ) b      
   where a.irecab_compania = b.compania      
   and a.irecab_anio = b.anio      
   and a.irecab_empleado = b.empleado      
   and a.irecab_codigo = b.codigo      
   and compania= @i_compania      
   and usuario = @i_usuario      
   and maquina = @i_maquina      
      
    INSERT INTO tbIR_Det_RubrosxEmpleado(       
    iredet_compania,  iredet_codigo,  iredet_empleado,  iredet_anio      
    ,iredet_rubro,   iredet_fecha,  iredet_valor,   iredet_estado )      
   select       
   compania,    codigo,    empleado,    anio      
   ,gasto_personal,  fecha,    valor,     estado      
   FROM OpenXML(@w_i,'/GTOPER/CAB/DET')                     
   WITH (                    
   compania  int  '../@compania', usuario   nvarchar(30) '../@usuario' ,maquina   nvarchar(30) '../@maquina'      
   ,empleado float '../@empleado',anio  int '../@anio',fecha datetime '../@fecha', estado nchar(1) '../@estado'       
   , codigo float '../@codigo'      
   , gasto_personal int, valor float      
   ) a      
   where compania= @i_compania      
   and usuario = @i_usuario      
   and maquina = @i_maquina      
 EXEC sp_xml_removedocument @w_i           
 end try            
  Begin Catch                       
   set @o_idnumero = 0                   
   set @o_error =1                        
   set @o_mensaje = 'Gtos Personal:  Error al Actualizar Datos.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                        
   rollback tran trans            
   return 0                       
  End Catch       
 set @o_idnumero =   @i_codigo      
 set @o_error =0                         
 set @o_mensaje = 'Gtos Personal:  Actualizado Correctamente  '           
 commit tran trans                      
 SET XACT_ABORT OFF     
     
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
    
 return 0          
      
      
end      
if @i_operacion = 'query'      
begin      
 select irecab_codigo codigo      
 , irecab_fecha fecha          
 , irecab_ing_anual  ing_anual          
 , irecab_apiess_anual iess_anual          
 , irecab_renta_cobrado ir_cobrado          
 , irecab_meses_proy meses_proy              
 , irecab_ingreso_empleadores ingresos_otros          
 , irecab_ded_gas_empleadores gastos_otros   
 , irecab_otras_ded_empleadores rebajas_otros          
 , irecab_impuesto_otros impuesto_otros  
 -------------------------------------------------------------------------------------------
 ,isnull(irecab_cargas,0) cargas , isnull(irecab_emf_catastrofica,'N') emf_catastrofica  
 --------------------------------------------------------------------------------------------
 from tbIR_Cab_RubrosxEmpleado      
 where irecab_compania  = @i_compania                 
 and irecab_empleado = @i_empleado                
 and irecab_anio  = @i_anio                
 --and irecab_codigo = @i_codigo        
 and irecab_estado ='A'      
      
      
 select codigo,descripcion, valor, tipo      
 , tope_rubro      
 from (      
 select  B.ir_codigo codigo,B.ir_descripcion descripcion, isnull(A.iredet_valor,0)  valor ,B.ir_tipo  tipo             
 ,isnull(B.ir_tope,0) tope_rubro       
 from tbIR_Det_RubrosxEmpleado a , tbIR_RubrosGastos b      
 where a.iredet_compania=b.ir_compania                 
    and a.iredet_rubro =b.ir_codigo      
 and iredet_compania  = @i_compania                 
 and iredet_empleado = @i_empleado                
 and iredet_anio  = @i_anio         
 and a.iredet_estado='A'      
 union all      
 select ir_codigo codigo, ir_descripcion descripcion, 0 valor, ir_tipo  tipo        
 , isnull(ir_tope,0) tope_rubro       
 from tbIR_RubrosGastos       
 where ir_compania = @i_compania      
 and ir_estado = 'A'      
 and ir_codigo not in (      
 select  iredet_rubro      
 from tbIR_Det_RubrosxEmpleado       
 where  iredet_compania  = @i_compania                 
 and iredet_empleado = @i_empleado                
 and iredet_anio  = @i_anio         
 and iredet_estado='A'      
 )      
 ) x      
 order by codigo      
 --and iredet_codigo = @i_codigo        
      
   select md_tipo tipo, md_valor   valor      
  -- select *      
   from tbIR_Monto_Deducion                   
   where md_compania = @i_compania                
   and md_anio = @i_anio         
         
    select count(1) count1          
   from tbIR_RubrosGastos          
   where ir_compania = @i_compania          
   and ir_tipo = 1          
      
  select 'collection' ,'cab;det;res;no;tabla'      
      
end     
      
GO

