USE [ROLES]
GO

/****** Object:  StoredProcedure [dbo].[ROLSp_Impuesto_Renta]    Script Date: 24/08/2023 14:55:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                      
                                        
CREATE procedure [dbo].[ROLSp_Impuesto_Renta]                                        
(                                        
                                         
 @i_compania  int=null,                                          
 @i_empleado  int=null,                                        
 @i_fecha   datetime=null,                                        
 @i_tipo_liq  char(1)=null,                                        
 @o_IR    float=null Output,                                         
 @o_IRC    float=null Output                                          
,@o_gastos  float=null Output                                           
,@o_ingreso float=0 output                                
,@o_alimentacion float = 0 output                                
,@o_gastos_p float=0 output                                
,@o_aporte_seg float=0 output                                
,@o_base float=0 output                                 
,@o_frac_bas float=0 output                                
,@o_imp_fra_bas float=0 output                                
,@o_imp_fra_exe float=0 output                                
,@o_exedente float=0 output                                
,@o_res_exedente float=0 output                                
,@o_impuesto_causado float=0 output    
---------------------------------------------
, @o_impuesto_limite float=0 output     
---------------------------------------------
,@o_ir_cobrado float=0 output                                
,@o_mes float=0 output                              
,@o_horas_extras float=0 output                             
,@o_ban_gasto char(1)='' output                        
,@o_utilidad float=0 output     
------------------------------------------------
,@o_limite_credito_g float=0 output      
,@o_limite_gastos float=0 output       
,@o_limite_cred_parcial float=0 output    
 ----------------------------------------------                                       
)                                        
as                                        
declare @w_anio int                                          
, @w_mes int                                        
, @w_por_iess float                                        
, @w_tope_gasto float                                        
, @w_ban_gasto int                                        
, @w_sueldo_A float                                        
, @w_alimentacion_A float                                        
, @w_horas_extras_A float                                        
, @w_comisiones_A float                                        
, @w_Subingreso_A float                                        
, @w_ingreso_A float                                        
, @w_IR_A float                                        
, @w_comedor_A float                                        
, @w_sueldo float                                        
, @w_alimentacion float                                        
, @w_horas_extras float                                        
, @w_comisiones float                                        
, @w_comedor float                                        
, @w_sueldo_P float                                        
, @w_alimentacion_P float                                        
                                        
,@w_ingreso_otros float                                        
,@w_deducion_otros float                                        
,@w_rebajas_otros float                                        
,@w_impuestos_otros float                                        
, @w_GastosAnual float                                        
, @w_GastosAnualneto float                                        
                                        
, @w_fechaIngreso datetime                                        
, @w_beneficio char(1)                                        
, @w_relacion char(1)                                        
, @w_categoria char(1)                                        
, @w_mes_pro int                                        
, @w_mes_pro_f int                                        
                                        
, @w_IRPagadoxEmpledor float                                        
, @w_Ingreso_Anual_Neto  float                                        
, @w_Ingreso_Anual_Total float                                       
, @w_IESS float                                        
, @w_gastos_A float               
, @w_Base_Calculo float                                        
, @w_Fraccion_Basica  float                                        
, @w_Imp_Fraccion_Basica float                                        
, @w_Imp_Fraccion_Exedente float                                        
, @w_Exedente float                                        
, @w_Res_Exedente float                                        
, @w_Impuesto_causado float                                        
, @w_Impuesto_causado_real float                                        
, @w_vacaciones float                                        
, @w_vacaciones_A float                    
, @w_IR float                                          
, @w_IMPC_asumido float                                        
, @w_IMPC_asumidoP float                                        
, @w_IR_COBRADO float                                        
, @w_sSql nvarchar(max)                                        
, @w_parametro nvarchar(max)                                         
, @w_meses_IR int                                      
, @w_factor int                                    
, @w_adicional float                                  
, @w_adicional_a float                                 
, @w_horas_extras_P float                             
, @w_comedor_p float                        
, @w_utilidad float                   
, @w_fecha_his datetime               
, @w_fecha_qui datetime               
              
, @w_sueldo_his float,@w_sueldo_act float              
, @w_alimentacion_his float, @w_alimentacion_act float              
, @w_horas_extras_his float,@w_horas_extras_act float              
, @w_comisiones_his float , @w_comisiones_act float              
, @w_vacaciones_his float, @w_vacaciones_act float              
, @w_comedor_his float, @w_comedor_act float               
, @w_adicional_his float, @w_adicional_act float             



--------------------------------------------------
,  @w_por_d1 float  
, @w_limite_gastos float , @w_impuesto_renta_xp float      
, @w_limite_credito_gastos float, @w_credito_gastos float   , @w_limite_cred_parcial float , @w_limite_cred_his float , @w_gastos float    
-- Definicion de variables 2023  
,@w_numero_carga int,@w_limite_rebaja float, @w_tipo_carga int  
  
, @w_gastos_his float      
set @w_por_d1 = 10   
------------------------------------------------------------------------
                        
/*                                        
                                        
Asignacion de Parametros Principales                                        
                                        
*/                
--select substring(convert(nvarchar(10),getdate(),112),1,6)              
set @w_fecha_his = substring(convert(nvarchar(30),@i_fecha,112),1,6) + '01'              
set @w_fecha_qui    = substring(convert(nvarchar(30),@i_fecha,112),1,6) + '15'                                 
set @w_anio = year(@i_fecha)     
set  @w_mes  = month(@i_fecha)                                     
SELECT  @w_por_iess = NT08APIESS 

--------------------------------------
, @w_tipo_carga  = NT08CARGAIMP  
-----------------------------------------
                                    
FROM  ROLT08                             
WHERE NT08CODCIA = @i_compania                                          
                                         
select @w_tope_gasto = md_valor                                           
from tbIR_Monto_Deducion                                          
where md_compania = @i_compania                                          
and md_anio =@w_anio                                     
and md_tipo =1                                        
                                        
 
 ------------------------------------------------------------------------
 -----VERIFICA SI EXISTE AL MENOS UN CAMPO VALIDO COMO CARGA FAMILIARES
 if @w_tipo_carga = 1  
begin  
  if exists( select top 1 1  
  from ROLM03  
  where NM03CODCIA = 1  
  and NM03CODEMP = 505  
  and CM03ESTADO = 'A'  
  and isnull(CM03IMPRENT,'N') = 'S'   
  and ISNULL(CM03CATASTROFICA,'N')='S'  
  )  
  begin  
   if exists( select top 1 1  
   from ROLM03  
   where NM03CODCIA = 1  
   and NM03CODEMP = 505  
   and CM03ESTADO = 'A'  
   and isnull(CM03IMPRENT,'N') = 'S'   
   and ISNULL(CM03CATASTROFICA,'N')='S'  
   )  
   ----------------AQUI EMPIEZA A HACER LA SUMA DEL NUMERO DE CARGAS QUE POSEE UN USUARIOS/EMPLEADO
   begin  
    set @w_numero_carga = 99  
   end  
   else  
   begin  
    select @w_numero_carga = case when COUNT(1) >=5 then 5 else COUNT(1) end  
    from ROLM03  
    where NM03CODCIA = @i_compania  
    and NM03CODEMP = @i_empleado  
    and CM03ESTADO = 'A'  
    and isnull(CM03IMPRENT,'N') = 'S'  
   end  
  end  
  else  
  begin  
   set @w_numero_carga = 0  
  end  
  
end  
else  
begin  
  if exists(  
  select top 1 1    
  from tbIR_Cab_RubrosxEmpleado  
  where irecab_compania = @i_compania  
  and irecab_anio = @w_anio  
  and irecab_empleado = @i_empleado  
  and irecab_estado ='A'  
  )  
  begin  
    if exists(  
    select top 1 1    
    from tbIR_Cab_RubrosxEmpleado  
    where irecab_compania = @i_compania  
    and irecab_anio = @w_anio  
    and irecab_empleado = @i_empleado  
    and irecab_estado ='A'  
    and isnull(irecab_emf_catastrofica,'N')='S'  
    )  
    begin  
     set @w_numero_carga = 99  
    end  
    else  
    begin  
     select @w_numero_carga = isnull(irecab_cargas,0)  
     from tbIR_Cab_RubrosxEmpleado  
     where irecab_compania = @i_compania  
     and irecab_anio = @w_anio  
     and irecab_empleado = @i_empleado  
     and irecab_estado ='A'  
    end  
  
  end  
  else  
  begin  
   set @w_numero_carga = 0  
  end  
  
end  
      
select @w_limite_rebaja = cr_valor,@w_por_d1 = cr_por_rebaja  
-- select *
from ROL_Parametro_Cargas_Reb      
where cr_compania = @i_compania  
and cr_num_carga = @w_numero_carga  
  ---------------------------------------------------------------------------------------



/*                                        
Sueldo                                        
Alimentacion                                        
Horas Extras                                        
Comisiones                                        
                          
select * from ROLH01                                      
                                      
  select * from                                   
  tbIR_Monto_Deducion                                    
                                       
Historico                                        
                                      
                                      
    
*/                                        
                                        
 --set @w_comisiones_A = 0                                        
 --set @w_vacaciones_A = 0                                        
                                        
set @w_sSql = ' select @ou_valor = sum(' + (SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 3) + ')'                                        
set @w_sSql = @w_sSql +  ' , @ou_valor1 = sum(' + (SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 4) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor2 = sum(' + isnull((SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 5),0) + ')'                                        
set @w_sSql = @w_sSql + ' from ROLH01'                                         
set @w_sSql = @w_sSql + ' where NH01CODCIA  = @in_compania '                                        
set @w_sSql = @w_sSql + ' and NH01CODEMP = @in_empleado '                                         
set @w_sSql = @w_sSql + ' and year(TH01FECPRO) =  @in_anio'                                
set @w_sSql = @w_sSql + ' and TH01FECPRO < @in_fecha'                                         
SET @w_parametro = '@in_compania int,@in_empleado int,@in_anio int,@in_fecha datetime, @ou_valor float OUTPUT, @ou_valor1 float OUTPUT, @ou_valor2 float OUTPUT '                          
EXECUTE sp_executesql @w_sSql , @w_parametro, @in_compania = @i_compania, @in_empleado = @i_empleado,@in_anio=@w_anio,@in_fecha = @w_fecha_his, @ou_valor = @w_horas_extras_A OUTPUT                                        
, @ou_valor1 = @w_comisiones_A OUTPUT, @ou_valor2 = @w_vacaciones_A OUTPUT                             
--select @w_sSql                                  
/*                          
-- select * from ROL_Campos_Impuesto_Renta                              
select @w_horas_extras_A =SUM(isnull(NH01VALSOB,0) + isnull(NH01VALSOB2,0) +  isnull(NH01VALSOB3,0))                                        
 ,@w_comisiones_A = 0                                        
 ,@w_vacaciones_A = 0                                        
  from ROLH01                                          
  where NH01CODCIA  = @i_compania                                     
  and NH01CODEMP = @i_empleado                                           
  and year(TH01FECPRO) =  @w_anio                                          
  and TH01FECPRO < @i_fecha                                         
*/                                        
                                        
                                        
set @w_sSql = ' select @ou_valor = sum(' + (SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 1) + ')'                                        
set @w_sSql =  @w_sSql + ' , @ou_valor1 = sum(' + (SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 2) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valorC = sum(' + isnull((SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 6),0) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor7 = sum(' + isnull((SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 7),0) + ')'                                        
                                       
set @w_sSql = @w_sSql + ' from ROLH01'                                         
set @w_sSql = @w_sSql + ' where NH01CODCIA  = @in_compania '                                        
set @w_sSql = @w_sSql + ' and NH01CODEMP = @in_empleado '                                         
set @w_sSql = @w_sSql + ' and year(TH01FECPRO) =  @in_anio'                                        
set @w_sSql = @w_sSql + ' and TH01FECPRO < @in_fecha'                                         
SET @w_parametro = '@in_compania int,@in_empleado int,@in_anio int,@in_fecha datetime, @ou_valor float OUTPUT, @ou_valor1 float OUTPUT,@ou_valorC float OUTPUT, @ou_valor7 float output'                                         
EXECUTE sp_executesql @w_sSql , @w_parametro, @in_compania = @i_compania, @in_empleado = @i_empleado,@in_anio=@w_anio,@in_fecha = @w_fecha_his, @ou_valor = @w_sueldo_A OUTPUT                                        
, @ou_valor1 = @w_alimentacion_A OUTPUT   , @ou_valorC = @w_comedor_A OUTPUT , @ou_valor7 = @w_adicional_a   output                                   
                                   
       set @w_horas_extras_A = ISNULL(@w_horas_extras_A,0)                     
       set @w_comisiones_A = ISNULL(@w_comisiones_A,0)                          
       set @w_vacaciones_A = ISNULL(@w_vacaciones_A,0)                          
       set @w_sueldo_A = ISNULL(@w_sueldo_A,0)                             
       set @w_alimentacion_A = ISNULL(@w_alimentacion_A,0)                          
       set @w_comedor_A = ISNULL(@w_comedor_A,0)                    
       set @w_adicional_a = ISNULL(@w_adicional_a,0)                     
    --select @w_sueldo_A                     
/*                                        
  select                                           
   @w_sueldo_A  = sum(isnull(NH01SDOFAS,0))                                          
  , @w_alimentacion_A = 0 --sum(isnull(NM01ING001,0))                                          
  from ROLH01                                        
  where NH01CODCIA  = @i_compania                                           
  and NH01CODEMP = @i_empleado                                           
  and year(TH01FECPRO) =  @w_anio                                          
  and TH01FECPRO < @i_fecha                                         
*/                                        
    
    
   select @w_IR_COBRADO = SUM(ISNULL(NH01IMPREN,0))                                            
  from ROLH01                                          
  where NH01CODCIA  = @i_compania                                           
  and NH01CODEMP = @i_empleado                                           
  and year(TH01FECPRO) =  @w_anio                                          
  and TH01FECPRO < @i_fecha                                        
                                        
set @w_horas_extras_A = isnull(@w_horas_extras_A,0)                                        
set @w_comisiones_A = isnull(@w_comisiones_A,0)                                        
set @w_sueldo_A = isnull(@w_sueldo_A ,0)                                        
set @w_alimentacion_A = isnull(@w_alimentacion_A,0)                                       
                                 
set @w_IR_COBRADO = isnull(@w_IR_COBRADO,0)                                    
set @w_comisiones_A = ISNULL(@w_comisiones_A,0)                                      
set @w_vacaciones_A= ISNULL(@w_vacaciones_A,0)                                
set @w_comedor_A = ISNULL(@w_comedor_A,0)                             
                            
if @w_IR_COBRADO < 0                                             
 begin                                             
 set @w_IR_COBRADO = 0                                            
 end                                         
                                        
-- isnull(NM01VALSOB3,0) +                                        
                                        
/*                                        
Sueldo                                        
Alimentacion                                        
Horas Extras                                        
Comisiones                                        
                                        
Actual                                        
                                      
-- select * from ROL_Campos_Impuesto_Renta                                      
select case when CM01FLGVAC = 'S' then 0 else 1 end ,* from ROLM01                       
select char(39)                                    
*/                      
                                      
-- select * from ROL_Campos_Impuesto_Renta                    
                                      
set @w_sSql = ' select @ou_valor = (  case when CM01FLGVAC =' + char(39) + 'N' + char(39) + ' then ' + (SELECT cf_campo_actual FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 1) + ' else (NM01SDOBAS/2) end )'               
   
   
      
        
          
-- select * from ROL_Campos_Impuesto_Renta            
                  
set @w_sSql = @w_sSql +  ' , @ou_valor1 = (' + (SELECT cf_campo_actual FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 2) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor2 = (' + (SELECT cf_campo_actual FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 3) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor3 = (' + (SELECT cf_campo_actual FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 4) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor4 = (' + isnull((SELECT cf_campo_actual FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 5),0) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor5 = (' + isnull((SELECT cf_campo_actual FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 6),0) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor7 = (' + isnull((SELECT cf_campo_actual FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 7),0) + ')'                                        
set @w_sSql = @w_sSql + ' from ROLM01'                                         
set @w_sSql = @w_sSql + ' where NM01CODCIA  = @in_compania '                                        
set @w_sSql = @w_sSql + ' and NM01CODEMP = @in_empleado '                                 
                                        
SET @w_parametro = '@in_compania int,@in_empleado int, @ou_valor float OUTPUT, @ou_valor1 float OUTPUT,@ou_valor2 float OUTPUT,@ou_valor3 float OUTPUT,@ou_valor4 float OUTPUT,@ou_valor5 float OUTPUT,@ou_valor7 float output'                                
  
    
      
       
          
EXECUTE sp_executesql @w_sSql , @w_parametro, @in_compania = @i_compania, @in_empleado = @i_empleado, @ou_valor = @w_sueldo_act OUTPUT                                        
, @ou_valor1 = @w_alimentacion_act OUTPUT, @ou_valor2 = @w_horas_extras_act OUTPUT, @ou_valor3 = @w_comisiones_act OUTPUT, @ou_valor4 = @w_vacaciones_act OUTPUT                                       
, @ou_valor5 = @w_comedor_act OUTPUT , @ou_valor7 = @w_adicional_act output                                    
              
SET @w_sueldo_act= isnull(@w_sueldo_act,0)                 
set @w_alimentacion_act = isnull(@w_alimentacion_act,0)              
set @w_horas_extras_act = isnull(@w_horas_extras_act,0)              
set @w_comisiones_act = isnull(@w_comisiones_act,0)                
set @w_vacaciones_act = isnull(@w_vacaciones_act,0)                       
set @w_comedor_act = ISNULL(@w_comedor_act ,0)               
set @w_adicional_act = ISNULL(@w_adicional_act,0)              
-- select * from ROLH01              
set @w_sSql = ' select @ou_valor = (  case when CH01FLGVAC =' + char(39) + 'N' + char(39) + ' then ' + (SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 1) + ' else (NH01SDOBAS/2) end )'             
  
    
      
        
          
            
                    
set @w_sSql = @w_sSql +  ' , @ou_valor1 = (' + (SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 2) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor2 = (' + (SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 3) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor3 = (' + (SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 4) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor4 = (' + isnull((SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 5),0) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor5 = (' + isnull((SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 6),0) + ')'                                        
set @w_sSql = @w_sSql + ' , @ou_valor7 = (' + isnull((SELECT cf_campo_historico FROM ROL_Campos_Impuesto_Renta where cf_compania = @i_compania and  cf_clave = 7),0) + ')'                                        
set @w_sSql = @w_sSql + ' from ROLH01'                                         
set @w_sSql = @w_sSql + ' where NH01CODCIA  = @in_compania '                                        
set @w_sSql = @w_sSql + ' and NH01CODEMP = @in_empleado '                                 
set @w_sSql = @w_sSql + ' and year(TH01FECPRO) =  @in_anio'                                        
set @w_sSql = @w_sSql + ' and TH01FECPRO = @in_fecha'                                         
SET @w_parametro = '@in_compania int,@in_empleado int,@in_anio int,@in_fecha datetime, @ou_valor float OUTPUT, @ou_valor1 float OUTPUT,@ou_valor2 float OUTPUT,@ou_valor3 float OUTPUT,@ou_valor4 float OUTPUT,@ou_valor5 float OUTPUT,@ou_valor7 float output 
  
   
'      
        
          
            
                 
EXECUTE sp_executesql @w_sSql , @w_parametro, @in_compania = @i_compania, @in_empleado = @i_empleado,@in_anio=@w_anio,@in_fecha = @w_fecha_qui, @ou_valor = @w_sueldo_his OUTPUT                                        
, @ou_valor1 = @w_alimentacion_his OUTPUT, @ou_valor2 = @w_horas_extras_his OUTPUT, @ou_valor3 = @w_comisiones_his OUTPUT, @ou_valor4 = @w_vacaciones_his OUTPUT                                       
, @ou_valor5 = @w_comedor_his OUTPUT , @ou_valor7 = @w_adicional_his output                                    
      
        
              
SET @w_sueldo_his= isnull(@w_sueldo_his,0)                 
set @w_alimentacion_his = isnull(@w_alimentacion_act,0)              
set @w_horas_extras_his = isnull(@w_horas_extras_his,0)              
set @w_comisiones_his = isnull(@w_comisiones_his,0)                
set @w_vacaciones_his = isnull(@w_vacaciones_his,0)                       
set @w_comedor_his= ISNULL(@w_comedor_his ,0)               
set @w_adicional_his = ISNULL(@w_adicional_his,0)              
              
if day(@i_fecha) = 15               
begin              
 set @w_sueldo = @w_sueldo_act * 2              
 set @w_alimentacion = @w_alimentacion_act * 2              
 set @w_horas_extras = @w_horas_extras_act * 2              
 set @w_comisiones = @w_comisiones_act  * 2              
 set @w_vacaciones = @w_vacaciones_act * 2     
 set @w_comedor = @w_comedor_act * 2              
 set @w_adicional = @w_adicional_act * 2              
end              
else              
begin              
 set @w_sueldo = @w_sueldo_act + @w_sueldo_his              
 set @w_alimentacion = @w_alimentacion_act + @w_alimentacion_his              
 set @w_horas_extras = @w_horas_extras_act + @w_horas_extras_his              
 set @w_comisiones = @w_comisiones_act + @w_comisiones_his              
 set @w_vacaciones = @w_vacaciones_act + @w_vacaciones_his              
 set @w_comedor = @w_comedor_act + @w_comedor_his              
 set @w_adicional = @w_adicional_act +  @w_adicional_his              
end              
    
SET @w_sueldo= isnull(@w_sueldo,0)                 
set @w_alimentacion = isnull(@w_alimentacion,0)              
set @w_horas_extras = isnull(@w_horas_extras,0)              
set @w_comisiones = isnull(@w_comisiones,0)                
set @w_vacaciones = isnull(@w_vacaciones,0)                       
set @w_comedor= ISNULL(@w_comedor ,0)               
set @w_adicional = ISNULL(@w_adicional,0)    

 --select @w_sueldo,@w_sueldo_act, @w_sueldo_A                      
/*                                        
 select   @w_sueldo  = isnull(NM01SDOFAS,0)                                          
  , @w_alimentacion = 0                                         
  , @w_horas_extras =  isnull(NM01VALSOB,0) + isnull(NM01VALSOB2,0)                                           
  , @w_comisiones  = isnull(NM01CCCOMI,0)                                        
  , @w_vacaciones = 0                                        
                                         
  , @w_fechaIngreso = TM01FECING                       
  , @w_beneficio = CM01BENEFI                                          
  , @w_relacion = CM01RELACION                                          
  , @w_categoria = CAT_CONT                                          
 from ROLM01                                          
 where NM01CODCIA = @i_compania                                          
 and NM01CODEMP = @i_empleado                                          
 */                                        
  select   @w_fechaIngreso = TM01FECING                                           
  , @w_beneficio = CM01BENEFI                                          
  , @w_relacion = CM01RELACION                                          
  , @w_categoria = ROL_CAT_IR --CAT_CONT                              
 from ROLM01                                          
 where NM01CODCIA = @i_compania                                          
 and NM01CODEMP = @i_empleado                                          
                                        
                       
/*                                        
Presentacion  Gastos                                        
y Asugnacion de Valores de Gastos Prensentados                                        
*/                                        
                                        
 SELECT                                               
 @w_ban_gasto = 1                                          
 FROM  tbIR_Cab_RubrosxEmpleado                                          
 WHERE irecab_compania =@i_compania                                          
 AND irecab_empleado = @i_empleado                                          
 AND irecab_anio = @w_anio                                          
 AND irecab_estado = 'A'                                          
 set @w_ban_gasto = isnull(@w_ban_gasto,0)                                   
                                         
--if @w_ban_gasto = 1                                        
--begin            -- select @w_mes_pro = irecab_meses_proy                                        
-- FROM  tbIR_Cab_RubrosxEmpleado                                          
-- WHERE irecab_compania =@i_compania                                          
-- AND irecab_empleado = @i_empleado                                          
-- AND irecab_anio = @w_anio                                          
-- AND irecab_estado = 'A'                                          
--end                                        
--else                                        
--begin                                        
--    select @w_mes_pro = 12                                         
--end                                        
set @w_mes_pro = ((@w_anio-year(@w_fechaIngreso))*12+12-month(@w_fechaIngreso)) +1                                          
 if @w_mes_pro > 12  set @w_mes_pro=12                                            
 set @w_meses_IR= ((@w_anio-year(@w_fechaIngreso))*12+@w_mes-month(@w_fechaIngreso)) + 1                                              
 if @w_meses_IR > @w_mes                                            
     set @w_meses_IR= @w_mes                                           
 set @w_meses_IR  = @w_meses_IR - 1                                         
                                            
                                      
 --select  @w_mes_pro , @w_meses_IR                                       
set @w_mes_pro_f = @w_mes_pro - @w_meses_IR                                         
   --   select  @w_mes_pro ,@w_meses_IR,@w_mes_pro_f                                    
--if (month(@i_fecha) = 12 and day(@i_fecha)>12)                                      
--set @w_mes_pro_f = 0.5                                    
  --    select @w_mes_pro_f  ,@w_mes_pro , @w_meses_IR                                  
if @w_ban_gasto = 1                                        
begin                                        
 SELECT                                              
    @w_ingreso_otros = isnull(irecab_ingreso_empleadores,0)                                          
   , @w_deducion_otros = isnull(irecab_ded_gas_empleadores,0)                               
   , @w_rebajas_otros  = isnull(irecab_otras_ded_empleadores,0)                                          
   , @w_impuestos_otros = isnull(irecab_impuesto_otros,0)                                          
   FROM  tbIR_Cab_RubrosxEmpleado                                          
   WHERE irecab_compania = @i_compania                                          
   AND irecab_empleado = @i_empleado                                          
   AND irecab_anio = @w_anio                               
   AND irecab_estado = 'A'                                         
                                        
                                        
   SELECT @w_GastosAnual = sum(isnull(iredet_valor,0))                                           
   FROM tbIR_Det_RubrosxEmpleado                                          
   WHERE iredet_compania  = @i_compania                            
    and iredet_empleado = @i_empleado                                          
    and iredet_anio  = @w_anio                                          
    and iredet_estado ='A'
-----------------------------------------------------------
 -- Aumento Solo 3edad y Discapacidad 2022 
	and iredet_rubro in
	(                                
    select ir_codigo         
 -- select *      
    from tbIR_RubrosGastos                                
    where ir_compania=  iredet_compania                                
    and ir_tipo in (2,3)                                
    and ir_estado = 'A'                                
    ) 
------------------------------------------------------------
    and iredet_codigo in
    (                                          
    SELECT irecab_codigo                                           
    FROM tbIR_Cab_RubrosxEmpleado                                           
    WHERE irecab_compania  = iredet_compania                                         
     and irecab_empleado = iredet_empleado                                          
     and irecab_anio  = iredet_anio                                          
     and irecab_estado = 'A'                                          
                                          
    )                                           
   SELECT @w_GastosAnualneto = sum(isnull(iredet_valor,0))                                           
   FROM tbIR_Det_RubrosxEmpleado                                          
   WHERE iredet_compania  = @i_compania                                          
    and iredet_empleado = @i_empleado                                          
    and iredet_anio  = @w_anio                                          
    and iredet_estado ='A'                                          
    and iredet_rubro in                                           
    (                                          
    select ir_codigo                                          
    from tbIR_RubrosGastos                                          
    where ir_compania=  iredet_compania                                          
    and ir_tipo  =1                                          
    and ir_estado = 'A'                                          
 )                                          
    and iredet_codigo in                                           
    (                                          
    SELECT irecab_codigo                           
	FROM tbIR_Cab_RubrosxEmpleado                                           
    WHERE irecab_compania  = iredet_compania                                          
     and irecab_empleado = iredet_empleado                                          
     and irecab_anio  = iredet_anio              
     and irecab_estado = 'A'                                          
                                          
    )                                            
end                                        
else                                        
begin                                        
 set @w_ingreso_otros = 0                                          
 set @w_deducion_otros = 0                                        
 set @w_rebajas_otros  = 0                                         
 set @w_impuestos_otros = 0                                          
 set @w_GastosAnual = 0                                        
 set @w_GastosAnualneto = 0                                        
end                                         
                                       
  set @w_ingreso_otros = isnull(@w_ingreso_otros ,0)                                          
 set @w_deducion_otros = ISNULL(@w_deducion_otros,0)                                       
 set @w_rebajas_otros  = ISNULL(@w_rebajas_otros,0)                                         
 set @w_impuestos_otros = ISNULL(@w_impuestos_otros,0)                                          
 set @w_GastosAnual = ISNULL(@w_GastosAnual,0)                                        
 set @w_GastosAnualneto = ISNULL(@w_GastosAnualneto,0)                                        
                                        
/*                                        
Recuperar                                        
*/                                        
 -- EXISTS                                        
if @w_categoria ='C'                                        
begin                                        
                                        
                                        
 select @w_IR_A =sum( A.ROL_IMPC_ASUMIDO)                                          
 from ROLH01 A                                          
 where A.NH01CODCIA  = @i_compania                                           
 and A.NH01CODEMP = @i_empleado                                           
 and year(A.TH01FECPRO) =  @w_anio                                          
 and A.TH01FECPRO <                                         
 ( select top 1 min(B.TH01FECPRO)                                          
   from ROLH01 B                                             
          where B.NH01CODCIA =@i_compania                                          
   and B.NH01CODEMP = @i_empleado                                           
   and year(B.TH01FECPRO) =  @w_anio                                          
   and CAT_CONT in ('C')                                          
 )                                        
                                        
 select @w_IRPagadoxEmpledor = sum(isnull(NH01RETFRABAS,0))                                    
 from ROLH01 B                                        
 where B.NH01CODCIA =@i_compania                                        
 and B.NH01CODEMP = @i_empleado                                  
 and year(B.TH01FECPRO) =  @w_anio                                        
 and CAT_CONT in ('C')                                          
    set @w_IRPagadoxEmpledor = isnull(@w_IRPagadoxEmpledor,0)                                        
end                                  
else                                        
begin                                        
  select @w_IR_A =sum( A.NH01IMPREN+a.NH01IMPRENASU )                                          
  from ROLH01 A                                          
  where A.NH01CODCIA  = @i_compania                                           
  and A.NH01CODEMP = @i_empleado                                           
  and year(A.TH01FECPRO) =  @w_anio                                          
  and A.TH01FECPRO < @w_fecha_his                                     
     set @w_IRPagadoxEmpledor = 0                                        
     --and CAT_CONT = ''                                        
end                                        
  
set @w_IR_A = ISNULL(@w_IR_A,0)                      
--select @w_sueldo, @w_mes_pro_f                                       
set @w_sueldo_P =  @w_sueldo  * @w_mes_pro_f

---------------SE COMENTO LO QUE NO SE USA----------------
set @w_alimentacion_P = @w_alimentacion --* @w_mes_pro_f                             
set @w_horas_extras_P = @w_horas_extras --* @w_mes_pro_f                             
set @w_comedor_p = @w_comedor --* @w_mes_pro_f      
---------------------------------------------------------
 -- select @w_sueldo_P, @w_sueldo  , @w_mes_pro_f                                     
                                    
set @w_sueldo_P = ISNULL(@w_sueldo_P,0)                            
set @w_alimentacion_P = ISNULL(@w_alimentacion_P,0)                             
set @w_horas_extras_P = ISNULL(@w_horas_extras_P,0)                            
set @w_comedor_p = ISNULL(@w_comedor_p,0)                            
 /*                      
  --- utilidad ---                      
  adicional                      
 */                            
-- sp_help ROLW03                   
set @w_utilidad = 0                      
if exists (                      
select 1                      
from ROLW03                      
where NW03CODCIA = @i_compania                        
and NW03CODEMP = @i_empleado                      
and (year(FECHACALCULO) + 1)=  year(@i_fecha)                       
)                      
begin                      
 select @w_utilidad = isnull(TOTALGANAR,0)                      
 from ROLW03                      
 where NW03CODCIA = @i_compania                        
 and NW03CODEMP = @i_empleado                      
 and (year(FECHACALCULO) + 1)=  year(@i_fecha)                       
end                      
else                      
begin                      
 set @w_utilidad = 0                      
end                      
                      
set @w_utilidad = ISNULL(@w_utilidad,0)                      
     
 ---select @w_sueldo_A,     @w_sueldo_P                                   
set @w_Ingreso_Anual_Neto =  ( @w_sueldo_A + @w_horas_extras_A  + @w_comisiones_A + @w_adicional_a  )                                         
+ ( @w_sueldo_P + @w_horas_extras_P  + @w_comisiones + @w_adicional + @w_vacaciones_A + @w_vacaciones)                                         
    -- select @w_Ingreso_Anual_Neto                                   
--select @w_sueldo_A ,@w_horas_extras_A ,@w_comisiones_A ,@w_alimentacion_A ,@w_vacaciones_A ,@w_comedor_A                                   
 --select @w_sueldo_P , @w_horas_extras ,@w_comisiones , @w_alimentacion_P , @w_vacaciones , isnull(@w_comedor,0)                                  
      -- @w_alimentacion_P + @w_alimentacion_A+@w_comedor_A +  isnull(@w_comedor,0)                       
  
  --------------------------------------------COMENTADO---------------------------
--select @w_Ingreso_Anual_Neto ,@w_sueldo_A,  @w_horas_extras_A , @w_comisiones_A , @w_adicional_a adc ,     @w_sueldo_P ,@w_horas_extras_P  , @w_comisiones , @w_adicional , @w_vacaciones_A , @w_vacaciones   
--------------------------------------------------------------------------------------
                                     
set @w_Ingreso_Anual_Total = ( @w_sueldo_A + @w_horas_extras_A  + @w_comisiones_A + @w_alimentacion_A + @w_vacaciones_A + @w_comedor_A + @w_adicional_a)                                         
+ ( @w_sueldo_P + @w_horas_extras_P  + @w_comisiones + @w_alimentacion_P + @w_vacaciones + isnull(@w_comedor_p,0)  +@w_adicional )                                         
 + @w_utilidad                   
 --********************            
 --********SELECT******          
 --++++++++++++++++++++          
 --********************          
          
--select  @w_sueldo  , @w_mes_pro_f            
--, @w_sueldo_A sueldoA, @w_horas_extras_A horaextraA, @w_comisiones_A as comisionA,@w_vacaciones_A vacacionA , @w_comedor_A comedorA,@w_adicional_a adicionalA          
--,@w_sueldo_P sueldoP, @w_horas_extras_P horaextraP, @w_comisiones comisiones, @w_alimentacion_P alimentacionp, @w_vacaciones as vacaciones, @w_comedor_p comedorp , @w_adicional adicional          
--    select @w_Ingreso_Anual_Total      
                                    
 if @w_categoria in ('B','D')                                           
  set @w_IESS = 0                                          
 else    
  set @w_IESS =  round(((@w_Ingreso_Anual_Neto * @w_por_iess)/100),2)                                          
set @w_IESS = isnull(@w_IESS,0)                                        
      --select @w_IESS                          
set @w_gastos_A = @w_GastosAnual + @w_deducion_otros        
                                         
 --select @w_GastosAnual , @w_deducion_otros ,@w_IESS ,@w_categoria               
      
 --if @w_GastosAnualneto  > @w_tope_gasto                                          
 --   set @w_gastos_A = @w_tope_gasto                            
                                         
set @w_gastos_A = @w_gastos_A + @w_rebajas_otros                                          
set @w_Base_Calculo =  @w_Ingreso_Anual_Total - @w_IESS - @w_gastos_A           
--select @w_Ingreso_Anual_Total , @w_IESS , @w_gastos_A   ,@w_Base_Calculo                              
--select @w_Ingreso_Anual_Total ,@w_IESS ,@w_gastos_A                                      
  --  select @w_Base_Calculo                                  
    -- select * from retencion where rt_anio = 2017                                  
  --select @w_Base_Calculo                                    
select                                           
    @w_Fraccion_Basica = isnull(rt_fraccionbasica,0)                                         
  , @w_Imp_Fraccion_Basica = isnull(rt_impuestofrabas,0)                                        
  , @w_Imp_Fraccion_Exedente = isnull(rt_impuestofraexc,0)                   
  -- select *                                      
  from retencion                                          
  where rt_codcia = @i_compania                       
  and rt_anio = @w_anio                                          
  and @w_Base_Calculo BETWEEN rt_fraccionbasica AND rt_excesofrabas                                  
  --  select @w_Fraccion_Basica,@w_Imp_Fraccion_Basica,@w_Imp_Fraccion_Exedente,@w_Base_Calculo                                    
                                        
 set @w_Exedente = @w_Base_Calculo - @w_Fraccion_Basica                                          
 set @w_Res_Exedente = ((@w_Exedente * @w_Imp_Fraccion_Exedente) / 100)                                           
 set @w_Impuesto_causado = @w_Imp_Fraccion_Basica + @w_Res_Exedente                                       
              -- select * from retencion                      
    --select @w_Base_Calculo @w_Fraccion_Basica fraccion_basica, 
	
	-----------------------------NUEVOS CALCULOS A REALIZAR----------------------------------
	set @w_limite_gastos = 0      
 set @w_credito_gastos = 0      
 set @w_limite_credito_gastos = 0      
  --select  @w_GastosAnualneto , @w_canasta_basica    
    
 if  @w_GastosAnualneto <= @w_limite_rebaja  
   
    set @w_limite_gastos = @w_GastosAnualneto      
 else      
    set @w_limite_gastos = @w_limite_rebaja  
   
set @w_credito_gastos = ((@w_limite_gastos * @w_por_d1)  * 0.01)   
  
  
-- select @w_limite_gastos LG, @w_credito_gastos CG    
       
  if @w_Impuesto_causado <=  @w_credito_gastos      
     set @w_limite_credito_gastos = @w_Impuesto_causado      
   else       
     set @w_limite_credito_gastos = @w_credito_gastos      
      
  set @w_impuesto_renta_xp = @w_Impuesto_causado - @w_limite_credito_gastos 
	-------------------------------------------------------------------
if (@w_categoria in ('B','C'))                            
begin                                       
  set @w_Impuesto_causado_real =  @w_Impuesto_causado -  @w_impuestos_otros                    
end                            
ELSE                                        
begin                            
--if (@w_IR_A > @w_Impuesto_causado)                            
  --set @w_Impuesto_causado_real =  @w_Impuesto_causado - @w_impuestos_otros                               
  --else              
  --select 2                            
  set @w_Impuesto_causado_real =  @w_Impuesto_causado - @w_IR_A - @w_impuestos_otros                               
end                   
 --  select  @w_Impuesto_causado_real ,  @w_Impuesto_causado , @w_IR_A , @w_impuestos_otros                        
                                       
  --select @w_IR_A                                    
-- select @w_Impuesto_causado_real                                      
--   select @w_IR_A                                  
/*if @i_tipo_liq = 'Q'                                        
   if day(@i_fecha) > 16                                        
      set @w_mes_pro_f = (@w_mes_pro_f * 2) - 1                                        
   else                                        
      set @w_mes_pro_f = (@w_mes_pro_f * 2)                                         
*/                                   
--select @w_Impuesto_causado_real                   
set @w_IR = @w_Impuesto_causado_real / @w_mes_pro_f          
if @w_IR < 0                                            
   set @w_IR = 0         
                                        
set @w_IMPC_asumido =0                                             
IF @w_categoria in ('B','C')                                           
begin                                          
  set @w_IMPC_asumido = @w_Impuesto_causado                                        
  set @w_Ingreso_Anual_Total = @w_Base_Calculo                                        
  set @w_Base_Calculo = @w_Ingreso_Anual_Total + @w_IMPC_asumido                                    
  set @w_Ingreso_Anual_Neto = @w_Ingreso_Anual_Neto +  @w_IMPC_asumido       
  --select @w_Ingreso_Anual_Total , @w_IMPC_asumido                                  
   select                         
     @w_Fraccion_Basica = isnull(rt_fraccionbasica,0)                                          
   , @w_Imp_Fraccion_Basica = isnull(rt_impuestofrabas,0)                                          
   , @w_Imp_Fraccion_Exedente = isnull(rt_impuestofraexc,0)                                          
   from retencion                                          
   where rt_codcia = @i_compania                                          
   and rt_anio = @w_anio              
   and @w_Base_Calculo BETWEEN rt_fraccionbasica AND rt_excesofrabas                                         
  set @w_Exedente = @w_Base_Calculo - @w_Fraccion_Basica            
  set @w_Res_Exedente = ((@w_Exedente * @w_Imp_Fraccion_Exedente) / 100)                                           
  set @w_Impuesto_causado = @w_Imp_Fraccion_Basica + @w_Res_Exedente                                        
  --select @w_Impuesto_causado                                    
                                        
 if @w_categoria ='C'                                        
 begin                                        
   select @w_IR_A =sum( A.NH01RETFRABAS)                                          
   from ROLH01 A                                          
   where A.NH01CODCIA  = @i_compania                                           
   and A.NH01CODEMP = @i_empleado                                           
   and year(A.TH01FECPRO) =  @w_anio                                          
   and A.TH01FECPRO <                                         
   ( select top 1 min(B.TH01FECPRO)                                          
     from ROLH01 B                                             
      where B.NH01CODCIA =@i_compania                                          
     and B.NH01CODEMP = @i_empleado                                           
     and year(B.TH01FECPRO) =  @w_anio                                          
     and CAT_CONT in ('C')                                          
   )                                        
                                        
   set @w_IR_A = @w_IR_A + @w_IRPagadoxEmpledor                                     
                                            
 end                                        
    set @w_Impuesto_causado_real =  @w_Impuesto_causado - @w_IR_A                                         
 set @w_IR = @w_Impuesto_causado_real / @w_mes_pro_f                                        
    set @w_IMPC_asumidoP = @w_IMPC_asumido / @w_mes_pro_f                                       
                                         
end                      
--select @w_Impuesto_causado_real                                        
  -- select @w_Impuesto_causado                                    
  --select @w_IR                                  
 if @w_IR < 0                                            
    set @w_IR = 0                                          
    if @i_tipo_liq = 'M' set @w_factor = 1                                        
    if @i_tipo_liq = 'Q' set @w_factor = 2                                        
    if @i_tipo_liq = 'S' set @w_factor = 4                                        
        --          select @w_IR    ,@w_mes_pro_f                   
    set @o_IR = @w_IR / @w_factor                                        
    set @o_IRC = (@w_IMPC_asumidoP / (@w_mes_pro_f * @w_factor))                                        
                                     
                                      -- Traer Gastos 2022--      
   select @w_gastos_his = sum(ROL_GASTOS)     
   , @w_limite_cred_his = sum(isnull(NH01LICMREG,0))      
   from rolh01      
   where NH01CODCIA =@i_compania      
   and NH01CODEMP = @i_empleado      
   and year(TH01FECPRO) =  @w_anio      
   and month(TH01FECPRO) < month(@i_fecha)      
   set @w_gastos_his = isnull(@w_gastos_his,0)      
   set @w_limite_cred_his = isnull(@w_limite_cred_his,0)    
    
       
   -- Fin Traer Gastos 2022--            

   --------------------------------------------------------------
if @w_limite_credito_gastos = 0     
    set  @w_limite_cred_parcial= 0    
 else     
    set @w_limite_cred_parcial = (((@w_limite_credito_gastos / 12) * month(@i_fecha)) -  @w_limite_cred_his)  /   @w_factor    
 if @w_GastosAnual = 0    
   set @w_gastos= 0    
 else    
 set @w_gastos=(((@w_GastosAnual / 12) * month(@i_fecha)) -  @w_gastos_his)  /   @w_factor    
    
 set @o_gastos= @w_gastos
 --------------------------------------------------------------
  set @o_IR = round(isnull(@o_IR,0),2)   
 set @o_IRC = round(ISNULL(@o_IRC,0)    ,2)                                  
 set @o_gastos = ISNULL(@o_gastos,0)                                      
 set @o_ingreso = round(isnull(@w_Ingreso_Anual_Neto,0)-(@w_horas_extras_A + @w_horas_extras_P),2)                                
 set @o_alimentacion = (@w_alimentacion_P + @w_alimentacion_A+@w_comedor_A +  isnull(@w_comedor_p,0))                                
 set @o_gastos_p = isnull(@w_GastosAnual,0)                                 
 set @o_aporte_seg = isnull(@w_IESS,0)                                 
 set @o_base = isnull(@w_Base_Calculo,0)                                
 set @o_frac_bas = isnull(@w_Fraccion_Basica,0)                                
 set @o_imp_fra_bas = isnull(@w_Imp_Fraccion_Basica,0)                                
 set @o_imp_fra_exe = isnull(@w_Imp_Fraccion_Exedente,0)                                
 set @o_exedente = round(isnull(@w_Exedente,0),2)                         
 set @o_res_exedente = round(isnull(@w_Res_Exedente,0),2)                                 
 set @o_impuesto_causado = round(isnull(@w_Impuesto_causado,0),2)                                        
 set @o_ir_cobrado= isnull(@w_IR_A,0)                                     
 set @o_mes = ISNULL(@w_mes_pro_f,0)                              
 set @o_horas_extras = (@w_horas_extras_A + @w_horas_extras_P)                            
 set @o_ban_gasto = case when @w_ban_gasto = 1 then 'S' else 'N' end                      
 set @o_utilidad = @w_utilidad 

 ---------------------------------------
  set @o_limite_gastos = @w_limite_gastos      
 set @o_limite_credito_g = @w_limite_credito_gastos       
 set @o_impuesto_limite = round(isnull(@w_impuesto_renta_xp,0),2)     
 set @o_limite_cred_parcial = @w_limite_cred_parcial
 ------------------------------------------------------
GO

