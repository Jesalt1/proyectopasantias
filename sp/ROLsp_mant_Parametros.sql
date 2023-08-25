USE [ROLES]
GO

/****** Object:  StoredProcedure [dbo].[ROLSp_Mant_Parametros]    Script Date: 24/08/2023 14:10:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[ROLSp_Mant_Parametros]      
(      
@i_operacion  varchar(20)      
,@NT08CODCIA  integer=null       
,@TT08FECPRO  datetime=null      
,@NT08SALMVG  float=null      
,@NT08CMSPIA  float=null      
,@NT08CMSPIB  float=null      
,@NT08TRANSP  float=null      
,@NT08BONIFI  float=null      
,@NT08APIESS  float=null      
,@NT08IESSPT  float=null      
,@NT08ASECAP  float=null      
,@NT08APIECE  float=null      
,@NT08PORICC  float=null      
,@CT08CODACT  nvarchar(20)=''      
,@CT08IDENTI  nvarchar(20)=''      
,@CT08REPRES  nvarchar(50)=''      
,@CT08ASUMEIESS  nvarchar(1)=''      
,@NT08PORRETEN  float=null      
,@NT08PORIVA  float=null      
,@NT08XIV   float=null      
,@NT08PORC1   float=null      
,@NT08PORC2   float=null      
,@NT08VALORBANCO float=null      
,@CT08UTILIDAD  char(1)=''      
,@NT08CTASALARIO char(20)=''      
,@NT08CTACOMPONENTE char(20)=''      
,@NT08IESSPAT  char(20)=''      
,@NT08DEC3   char(20)=''      
,@NT08DEC4   char(20)=''      
,@NT08VAC   char(20)=''      
,@NT08RESERVA  char(20)=''      
,@NTPORRESERVA  float=8.33      
,@NT08FECHAIXIV  datetime=null      
,@NT08FECHAFXIV  datetime=null      
,@NT08FECHAIXIII datetime=null      
,@NT08FECHAFXIII datetime=null      
,@NT08APADIESS  float=null      
,@NT08DIASPRUEBA float=null      
,@NT08Usuario  nvarchar(25)=''      
,@NT08BLOQUEO  int=null      
,@NT08PROVSUEL  char(1)=null      
,@NT08CONTBENE char(1)=null    
,@NT08CONTSUELDO char(1)=null    
,@NT08CTASECAP varchar(30)=null    
,@NT08CTAIECE  varchar(30)=null    
--, @NT08TOIESS  float=null  
--,@NT08ESIEES float=null  
  
,@NT08POREMB float=null              
,@NT08DEFAULTCORTE int=null            
,@NT08BLOQCORTE nchar(1)=null       
,@NT08MAXSUELDO float=null   
,@NT08CARGAIMP int=null  
,@i_xml_aud xml=null  
,@o_error   int=0 output      
,@o_mensaje   varchar(500)='' output      
)      
as      
  declare @w_auditoria nchar(1)    
, @w_ejecutable nvarchar(30)      
, @w_maquina nvarchar(30)      
, @w_usuario nvarchar(30)      
, @w_base_auditoria nvarchar(60)      
, @w_parametros nvarchar(max)      
, @w_xml_out  xml      
, @w_xml  xml      
, @w_sql  nvarchar(max)   
, @w_i int  
declare @s_error int, @s_mensaje nvarchar(max)     
-- select * from ROLT08    
-- alter table ROLT08 add NT08TOIESS float,NT08ESIEES float    
-- alter table ROLT08 drop column nt08iessptp 17.6  
-- update ROLT08 set NT08TOIESS = 21.6, NT08ESIEES=17.6  
  
if @i_operacion = 'consultar'      
begin      
 select NT08CODCIA, TT08FECPRO, NT08SALMVG, NT08CMSPIA, NT08CMSPIB, NT08TRANSP, NT08BONIFI, NT08APIESS, NT08IESSPT,    
  NT08ASECAP, NT08APIECE, NT08PORICC, CT08CODACT, CT08IDENTI, CT08REPRES, CT08ASUMEIESS, NT08PORRETEN, NT08PORIVA,    
  NT08XIV, NT08PORC1, NT08PORC2, isnull(NT08VALORBANCO,0) as NT08VALORBANCO, CT08UTILIDAD, NT08CTASALARIO, NT08CTACOMPONENTE, NT08IESSPAT    
  ,NT08DEC3, NT08DEC4, NT08VAC, NT08RESERVA,ISNULL(NTPORRESERVA,0) as NTPORRESERVA, NT08FECHAIXIV, NT08FECHAFXIV, NT08FECHAIXIII    
  ,NT08FECHAFXIII,NT08APADIESS,NT08DIASPRUEBA,NT08Usuario,NT08BLOQUEO,NT08PROVSUEL, NT08PORCTA1, NT08PORCTA2    
,NT08CONTBENE,NT08CONTSUELDO,isnull(NT08CTASECAP,'')  as NT08CTASECAP   
,isnull(NT08CTAIECE,'') as NT08CTAIECE --, ISNULL(NT08TOIESS,0) total_iess, ISNULL(NT08ESIESS,0) espe_iess     
, isnull(NT08POREMB,0) as NT08POREMB                        
, isnull(NT08DEFAULTCORTE,2) as NT08DEFAULTCORTE               
, isnull(NT08BLOQCORTE,'N') as NT08BLOQCORTE      
, isnull(NT08MAXSUELDO,0) as NT08MAXSUELDO 
, isnull(NTPORRESERVA,0) NTPORRESERVA
, isnuLL(NT08CARGAIMP,1) NT08CARGAIMP    
-- select *  
 from ROLT08 where NT08CODCIA=@NT08CODCIA      
end      
      
if @i_operacion = 'update'      
begin      
 SET NOCOUNT ON      
 if exists(       
 ( select 1 from SIACDB..PAR_Parametro_General     
 where gr_clave = @NT08CODCIA and gr_default_auditoria= 'S'    
 and exists(select 1 from ROL_Parametros where pa_compania = @NT08CODCIA AND pa_auditoria = 'S')       
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
  where gr_clave = @NT08CODCIA 
  set @w_xml = (select '@aplicativo' = @w_ejecutable       
  , '@maquina' = @w_maquina      
  , '@usuario' = @w_usuario      
  ,(      
   select '@id'= id ,'@valor' = valor       
   from (      
   select id = 1      
   ,valor = @NT08CODCIA       
   --union all      
   --select id = 2      
   --,valor = @i_empleado      
   ) c      
   FOR XML PATH('atributo'), type      
  )      
  -- select *
  from tb_empresa      
  where em_codigo = 1      
  FOR XML PATH('parametro'), ROOT('xml')      
  )      
  --select @w_xml      
        
     set @w_sql = ' exec ' + @w_base_auditoria + '.dbo.AUDSp_Auditoria @i_operacion = ''rexml''      
  , @i_compania = ' + convert(nchar(10),@NT08CODCIA)      
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
  update ROLT08      
  set TT08FECPRO =@TT08FECPRO,      
  NT08SALMVG=@NT08SALMVG,      
  NT08CMSPIA=@NT08CMSPIA,      
  NT08CMSPIB=@NT08CMSPIB,      
  NT08TRANSP=@NT08TRANSP,      
  NT08BONIFI=@NT08BONIFI,      
  NT08APIESS=@NT08APIESS,      
  NT08IESSPT=@NT08IESSPT,      
  NT08ASECAP=@NT08ASECAP,      
  NT08APIECE=@NT08APIECE,      
  NT08PORICC=@NT08PORICC,      
  CT08CODACT=@CT08CODACT,      
  CT08IDENTI=@CT08IDENTI,      
  CT08REPRES=@CT08REPRES,      
  CT08ASUMEIESS=@CT08ASUMEIESS,      
  NT08PORRETEN=@NT08PORRETEN,      
  NT08PORIVA=@NT08PORIVA,      
  NT08XIV=@NT08XIV,      
  NT08PORC1=@NT08PORC1,      
  NT08PORC2=@NT08PORC2,      
  NT08VALORBANCO=@NT08VALORBANCO,      
  CT08UTILIDAD=@CT08UTILIDAD,      
  NT08CTASALARIO=@NT08CTASALARIO,      
  NT08CTACOMPONENTE=@NT08CTACOMPONENTE,      
  NT08IESSPAT=@NT08IESSPAT,      
  NT08DEC3=@NT08DEC3,      
  NT08DEC4=@NT08DEC4,      
  NT08VAC=@NT08VAC,      
  NT08RESERVA=@NT08RESERVA,      
  NTPORRESERVA=@NTPORRESERVA,      
  NT08FECHAIXIV=@NT08FECHAIXIV,      
  NT08FECHAFXIV=@NT08FECHAFXIV,      
  NT08FECHAIXIII=@NT08FECHAIXIII,      
  NT08FECHAFXIII=@NT08FECHAFXIII,      
  NT08APADIESS=@NT08APADIESS,      
  NT08DIASPRUEBA=@NT08DIASPRUEBA,      
  NT08Usuario=@NT08Usuario,      
  NT08BLOQUEO=@NT08BLOQUEO,      
  NT08PROVSUEL = @NT08PROVSUEL      
  ,NT08CONTBENE = @NT08CONTBENE    
,NT08CONTSUELDO = @NT08CONTSUELDO    
,NT08CTASECAP = @NT08CTASECAP     
,NT08CTAIECE  = @NT08CTAIECE    
--,NT08TOIESS = @NT08TOIESS   
--,NT08ESIESS = @NT08ESIEES       
,NT08POREMB = @NT08POREMB             
,NT08DEFAULTCORTE = @NT08DEFAULTCORTE             
,NT08BLOQCORTE = @NT08BLOQCORTE    
,NT08MAXSUELDO = @NT08MAXSUELDO    
  ,NT08CARGAIMP =@NT08CARGAIMP  
  where NT08CODCIA = @NT08CODCIA  
  -- alter table ROLT08 add  NT08DEFAULTCORTE int,NT08BLOQCORTE nchar(1),NT08MAXSUELDO float   
 end try      
 Begin Catch                          
  set @o_error =1                  
  set @o_mensaje = 'Error al Actualizar Registros...Consulte con sistemas..' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                  
  rollback tran trans      
  return 0                 
 End Catch        
       
 set @o_error =0                   
 set @o_mensaje = 'Transacción Actualizada Correctamente'      
 commit tran ins                
 SET XACT_ABORT OFF   
  
  
if @w_auditoria = 'S'      
 begin      
    set @w_sql = ' exec ' + @w_base_auditoria + '.dbo.AUDSp_Auditoria @i_operacion = ''insxml''      
  , @i_compania = ' + convert(nchar(10),@NT08CODCIA)      
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
if @i_operacion = 'def_corte'                  
begin                  
 select isnull(NT08DEFAULTCORTE,2) as default_ --case when isnull(NT08BLOQCORTE,0) = 0 then 'N' else 'S' end         
 ,isnull(NT08BLOQCORTE,'N')  as bloqueo            
 from ROLT08 where NT08CODCIA=@NT08CODCIA                  
end             
            
if @i_operacion = 'blo_corte'                  
begin                  
 select case when isnull(NT08BLOQCORTE,0) = 0 then 'N' else 'S' end as bloqueo            
 from ROLT08 where NT08CODCIA=@NT08CODCIA                  
end         
if @i_operacion = 'bloqueo_rol'                  
begin                  
 select case when isnull(NT08BLOQUEO,0) = 0 then 'N' else 'S' end as bloqueo            
 from ROLT08 where NT08CODCIA=@NT08CODCIA                  
end           
if @i_operacion = 'fec_proc'      
begin      
 select TT08FECPRO as fecha       
 from ROLT08 where NT08CODCIA=@NT08CODCIA      
end      
if @i_operacion = 'fec_xiii'      
begin      
 select NT08FECHAIXIII as fechai , NT08FECHAFXIII as fechaf      
 from ROLT08       
 where NT08CODCIA=@NT08CODCIA      
end      
if @i_operacion = 'fec_xiv'      
begin      
 select NT08FECHAIXIV as fechai , NT08FECHAFXIV as fechaf      
 from ROLT08       
 where NT08CODCIA=@NT08CODCIA      
end      
      
      
      
--declare @w_clave float      
      
--if @i_operacion = 'insert'      
--begin      
-- SET NOCOUNT ON       
-- select @w_clave = max(NT07CODEST) + 1      
-- from ROLT07      
      
-- set @w_clave = ISNULL(@w_clave,1)      
-- SET XACT_ABORT ON                  
-- begin tran trans      
-- begin try      
-- INSERT INTO ROLT07      
--           (NT07CODEST, CT07NOMEST, ESTADO)      
--     VALUES      
--     (      
--   @w_clave, @i_descripcion,@i_estado      
--  )      
--    end try      
-- Begin Catch                 
-- -- set @o_clave = 0             
--  set @o_error =1                  
--  set @o_mensaje = 'Error al Guardar Registros...Consulte con sistemas..' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                  
--  rollback tran trans      
--  return 0                 
-- End Catch        
-- --set @o_clave =       
-- set @o_error =0                   
-- set @o_mensaje = 'Transacción Registrada Correctamente Reg.# ' + CONVERT(varchar(10),@w_clave)      
-- commit tran ins                
-- SET XACT_ABORT OFF              
-- return 0           
--end      
--if @i_operacion = 'search'      
--begin      
-- select isnull(NT07CODEST,1) as clave, isnull(CT07NOMEST,'') as descripcion      
-- , ISNULL(ESTADO,'A') as estado      
-- from ROLT07      
       
--end      
--if @i_operacion = 'query'      
--begin      
-- select isnull(NT07CODEST,1) as clave, isnull(CT07NOMEST,'') as descripcion      
--, ISNULL(ESTADO,'A') as estado      
-- from ROLT07      
-- where NT07CODEST = @i_clave      
--end      
      
      
      
      
--if @i_operacion = 'anular'      
--begin      
-- SET NOCOUNT ON       
-- SET XACT_ABORT ON                  
-- begin tran trans      
-- begin try      
       
-- update ROLT07      
-- set  ESTADO = 'I'      
-- where NT07CODEST = @i_clave      
       
--   end try      
-- Begin Catch                 
               
--  set @o_error =1                  
--  set @o_mensaje = 'Error al Anular Registros...Consulte con sistemas..' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                  
--  rollback tran trans      
--  return 0                 
-- End Catch        
       
-- set @o_error =0                   
-- set @o_mensaje = 'Transacción Anulada Correctamente Reg# ' + CONVERT(varchar(10),@i_clave)      
-- commit tran ins                
-- SET XACT_ABORT OFF              
-- return 0            
--end
GO

