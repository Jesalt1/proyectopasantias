USE [SIACDB_P]
GO
/****** Object:  StoredProcedure [dbo].[FACSp_Mant_XML_FACTURAFastFood]    Script Date: 05/12/2023 09:32:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[FACSp_Mant_XML_FACTURAFastFood]              
(              
@i_compania int              
,@i_sucursal int              
,@i_XML    xml        
,@i_totservicio float=0      
,@i_porentservicio float=0           
,@i_usuario varchar(40)=null              
,@i_maquina varchar(40)=null   
,@i_sProforma char(1)='N'  
,@i_Proforma int =0  
,@o_idfactura float output              
--,@o_iddevolucion float output            
,@o_error int output              
,@o_mensaje varchar(600)output              
)as               
declare @w_xml xml , @w_i int, @w_observacion varchar(250)              
declare @w_producto float              
, @w_idproducto float            
, @w_cantidad float              
, @w_stock float              
, @w_stock_n float              
, @w_tipo_prod int  
, @w_tipo_prod_dos int              
, @w_Man_Lote char(1)              
, @w_lote varchar(15)              
, @w_signo char(1)              
, @w_semana int              
, @w_detprod varchar(250)              
, @w_det varchar(150)              
, @count float              
, @NoReg float              
, @count2 float              
, @NoReg2 float              
, @No_sec float            
, @w_idFactura float              
, @w_idconcepto int              
, @w_idcompania int              
, @w_idsucursal int              
, @w_tipocbteVta int              
, @w_idFacturaImp float              
, @w_error int              
, @w_mensaje varchar(600)              
, @w_fecha_guia datetime             
, @w_maneja_dosi char(2)            
, @w_observacion_nc varchar(250)             
declare @w_tipo_cobro int  , @w_iddevolucion_fact float , @w_gen_nc char(1)            
, @w_idcobro float , @w_fact_devo float, @w_idnc float, @w_empleado  float            
, @w_ctanc varchar(20),@w_tipo_nc int, @w_secuencia int            
, @w_valor float , @w_idcliente float,@w_noesruc varchar(3)            
, @w_ptoemi int  , @w_turno float , @w_tipogen int         
set @w_idconcepto  = 3              
--set @w_xml = @i_XML              
set @w_semana = 1              
--set @w_error = 0              
--set @w_mensaje =''     
  
declare @w_NewNumeroExtNew as nvarchar(9)  
declare @w_SerieNew as nvarchar(6)       
declare @w_idSeriefact as nvarchar(6)  
  
declare @w_RucEmpresa nvarchar(15)  
declare @w_Ambiente int  
declare @w_Emision int   

declare @w_ruc varchar(13)
declare @w_total  float
  
select @w_RucEmpresa= em_ruc,  
@w_Ambiente=em_ambiente,  
@w_Emision=em_emision   
from tb_empresa  
where em_codigo=@i_compania      
           
 EXEC sp_xml_preparedocument @w_i OUTPUT, @i_XML              
 -- *****************************************************************************              
 --******************Declaracion de tablas Temporales WOM ****************************              
 --******************************************************************************              
  
 -- ALTER TABLE TEMPcab_pos ADD vt_FechaHoraReg DATETIME        
 SET NOCOUNT ON              
              
 -- select * from TEMPdet_pos  where vt_usuario = 'ADMIN'          
 -- select * from TEMPdet_pos_dos            
 -- select * from TEMPcab_pos            
 -- select * from TEMPDet_FormaCobro            
 delete from TEMPdet_pos              
 where vt_compania = @i_compania              
 and vt_usuario = @i_usuario              
 and vt_maquina = @i_maquina              
            
 delete from TEMPdet_pos_dos              
 where vt_compania = @i_compania              
 and vt_usuario = @i_usuario              
 and vt_maquina = @i_maquina              
  
/*  
 select * from TEMPcab_pos  
 select * from tbcab_pos  
  
*/  
 delete from TEMPcab_pos              
 where vt_compania = @i_compania              
 and vt_usuario = @i_usuario              
 and vt_maquina = @i_maquina              
  
 delete from TEMPDet_FormaCobro            
 where cb_compania = @i_compania                     
 and cb_usuario = @i_usuario            
 and cb_maquina =@i_maquina     
          
 -- *****************************************************************************              
 --**************  Registro de tablas temporales  WOM   ****************************              
 --******************************************************************************              
 -- alter table TEMPcab_pos add vt_email varchar(300) null              
 -- alter table TEMPcab_pos add vt_turno float null              
 -- alter table TEMPcab_pos add vt_fecha_inicio datetime null          
 -- select * from TEMPcab_pos          
 insert into TEMPcab_pos              
 (              
 vt_compania  , vt_sucursal       , vt_fecha    , vt_maquina              
 , vt_vendedor ,  vt_cliente        , vt_base_coniva, vt_base_siniva              
 , vt_subtotal ,  vt_descuento      , vt_iva        , vt_total             
 , vt_estado  ,  vt_contabilizado  , vt_tipo_venta , vt_plazo              
 , vt_fech_venc ,  vt_desc_pront_pago, vt_saldo      , vt_numeroext              
 , vt_seguro  ,  vt_flete          , vt_retencion  , vt_observacion              
 , vt_tipo  , vt_tipoDoc         , vt_Doc     , vt_usuario              
 , vt_t_venta , vt_refrendo     , vt_No_transporte,vt_No_fue                  
 , vt_centro  , vt_contabilizadoInve, vt_consignatario,vt_notify                
 --, vt_peso_neto, vt_peso_bruto                   
 , vt_anio_embarque, vt_embarque              
 , vt_semana   , vt_Orden_Compra  , vt_Guia_Remision, vt_Guia_Despacho              
 , vt_serie   , vt_autorizacion    , vt_fecha_vencimiento, vt_hora              
 , vt_ptoemision, vt_tipo_cobro             
 , vt_cedula , vt_nombre, vt_direccion, vt_telefono            
 , vt_email, vt_FechaHoraReg, vt_fecha_inicio,vt_TipoGen,vt_PIva, vt_idiva,vt_tipo_identificacion            
 )                                      
 SELECT IdCompania , IdSucursal     , fecha     , maquina              
 ,  IdVendedor , IdCliente        , baseiva    , basecero              
 ,  subtotal   , descuento     , IVA     , total              
 ,  estado   , contabilizado   , tipo_vta    , plazo              
 ,  fecha_ven  , desc_pron_pago     , saldo     , factura              
 ,  seguro   , flete      , retencion    , observacion              
 ,  tipo    , tipo_doc     , documento     , usuario              
 ,  tipo_tvta   , refrendo     , no_Transporte , no_fue              
 ,  centro   , 'N'       , consignatario , notify                          
 , anio_emb      , embarque               
 ,  semana   , orden_compra    , guia_remision , guia_desp              
 ,  serie      , autorizacion       , fecha_cad    , CONVERT(char(10),getdate() ,108)              
 , ptoemision , tipo_cobro            
 , cedula , nombre, direccion, telefono            
 , email , getdate()   ,fecha_inicio ,tGeneracion,PIva, IdIva, Tipo_Cliente       
 FROM OpenXML(@w_i,'/VENTA/FACTURA')               
 WITH (              
 IdCompania int, IdSucursal int                   , fecha datetime,              
 IdVendedor int, IdCliente float, baseiva float, basecero float,              
 subtotal   float, descuento float, IVA  float, total float,              
 estado char(2), contabilizado char(1),tipo_vta char(4),plazo float,              
 fecha_ven datetime,desc_pron_pago float,saldo float,factura varchar(15),              
 seguro     float, flete float,   retencion float, observacion varchar(500),              
 tipo varchar(10), tipo_doc float,  documento float, usuario varchar(15),              
 tipo_tvta  int,   refrendo varchar(20), no_Transporte varchar(10),no_fue varchar(10) ,              
 centro      int,  consignatario varchar(250), notify varchar(250),              
 -- peso_neto float,  peso_bruto float,            
 anio_emb float  , embarque float,              
 semana float,  orden_compra varchar(20),  guia_remision varchar(20), guia_desp varchar(20),              
 serie varchar(10), autorizacion varchar(10), fecha_cad datetime, maquina varchar(40)            
 , ptoemision int, tipo_cobro int , cedula varchar(15), nombre varchar(250),            
 direccion varchar(250), telefono varchar(50),email varchar(300),fecha_inicio datetime ,tGeneracion int, PIva float , IdIva int  
 , Tipo_Cliente char(1)        
 )              
                          
 -- select * from TEMPcab_pos              
 insert into TEMPdet_pos              
 (                    
 vt_compania,   vt_sucursal, vt_secuencia,   idClave                 
 , vt_codigo_producto, vt_cantidad, vt_valor  ,  vt_descuento                     
 , vt_iva,    vt_estado,  vt_costo,  vt_costo_Promedio                    
 , vt_S_iva,   vt_pesoNeto, vt_pesoBruto, vt_PorDescuento              
 , vt_TotalDescuento, vt_lote,  vt_cliente,  vt_detalle              
 , vt_detalle2,   vt_ManLote,  vt_tipo_prod, vt_fecha              
 , vt_usuario,   vt_maquina,  vt_numguia               
 , vt_ruta,    vt_generador, vt_centro,  vt_tipo_guia              
 , vt_hacienda             
 , vt_medico , vt_por_ret             
 )                                
 SELECT IdCompania,     IdSucursal,  secuencia,      ROW_NUMBER() OVER(ORDER BY IdProducto)              
 ,IdProducto,     cantidad,     valor,      descuento              
 ,ivap,      estado,   costo,   costo_promedio               
 ,man_iva,     0,    0,    por_desc              
 ,total_desc,     lote,   IdCliente,  detalle              
 ,'',       man_lote,  prop_tipo,  fecha               
 ,usuario,     maquina,   guia              
 ,ruta,      generador,  centro,   tipo_guia               
 ,hacienda               
 ,medico , por_ret            
 FROM OpenXML(@w_i,'/VENTA/FACTURA/DETALLE')               
 WITH (          
 IdCompania  int  '../@IdCompania',              
 IdSucursal  int  '../@IdSucursal',              
 secuencia  float   '@secuencia',              
 IdProducto  float   '@IdProducto',              
 cantidad  float   '@cantidad',              
 valor   float '@valor',              
 descuento  float   '@descuento',              
 ivap   float   '@ivap',              
 estado   char(1) '../@estado',              
 costo   float   '@costo',              
 costo_promedio float   '@costo_promedio',              
 man_Iva   char(1) '@man_iva',              
 por_desc  float   '@por_desc',              
 total_desc  float   '@total_desc',             
 lote   varchar(50) '@lote',              
 IdCliente  float    '../@IdCliente',              
 man_lote  char(2) '@man_lote',              
 prop_tipo  int  '@prop_tipo',              
 fecha   datetime '../@fecha',              
 usuario   varchar(30) '../@usuario',              
 maquina   varchar(30) '../@maquina',              
 detalle   varchar(500) '@detalle',              
 guia   varchar(20) '@guia',              
 ruta   varchar(100) '@ruta',              
 generador  varchar(100) '@generador',              
 tipo_guia  int '@tipo_guia',              
 centro   int '@centro',              
 hacienda  varchar(50) '@hacienda',              
 medico    float  '@medico',             
 por_ret   float  '@por_ret'            
 )        
         
 -- select * from tbdet_FormaCobro            
 insert into TEMPDet_FormaCobro            
 (            
 cb_compania, cb_sucursal, cb_usuario,    cb_maquina,  cb_numero,            
 cb_tipo,  cb_secuencia, cb_cod_formaPago,  cb_fecha_cobro,            
 cb_fecha_cancela,cb_valor,  cb_Banco,    cb_cuenta,            
 cb_NumCheque, cb_estado,  cb_num_tarj,   cb_des_tarj,            
 cb_tipo_abono, cb_Cobrador, cb_EDocumento,   cb_observacion,            
 cb_tipNota,  cb_fact_devo, cb_nota                      
 )            
 SELECT IdCompania,     IdSucursal,  usuario,    maquina, 0  ,            
 'F',   secuencia, forma_pago,    fecha_cobro,            
 fecha_cancelacion,valor,  banco,    cuenta,            
 referencia,  estado,  numero_tarjeta,   tarjeta,            
 'CRE',   cobrador, 'N',     ' Cobro ' + observacion ,            
 tipo_nc ,  fact_devo ,NotaC                                     
 FROM OpenXML(@w_i,'/VENTA/FACTURA/DET_COBRO')               
 WITH (              
 IdCompania  int  '../@IdCompania',              
 IdSucursal  int  '../@IdSucursal',             
 usuario   varchar(30) '../@usuario',     
 maquina   varchar(30) '../@maquina',              
 estado char(1)   '@estado',            
 secuencia  int '@secuencia',            
 forma_pago  int   '@forma_pago',            
 fecha_cobro  datetime '@fecha_cobro',              
 fecha_cancelacion datetime '@fecha_cancelacion',            
 valor   float '@valor',              
 banco  varchar(30) '@banco',            
 cuenta  varchar(30)   '@cuenta',              
 referencia   varchar(20)   '@referencia',             
 numero_tarjeta  varchar(30)   '@numero_tarjeta',              
 tarjeta  varchar(30)   '@tarjeta',              
 cobrador  int  '@cobrador',            
 observacion varchar(500) '../@observacion',            
 tipo_nc int '@tipo_nc',            
 fact_devo float '@fact_devo',  
 NotaC float '@NotaC'                
 )             
            
 EXEC sp_xml_removedocument @w_i              
                         
 update TEMPdet_pos            
 set vt_costo = pr_costo_promedio            
 ,vt_costo_Promedio =  pr_costo_promedio            
 from TEMPdet_pos, tbProdsucu            
 where  vt_compania = pr_compania            
 and vt_sucursal = pr_sucursal            
 and vt_codigo_producto = pr_clave            
 and vt_compania = @i_compania              
 and vt_sucursal= @i_sucursal              
 and vt_usuario = @i_usuario              
 and vt_maquina = @i_maquina             
            
 -- select * from TEMPdet_pos_dos where vt_codigo_producto = 3138            
 insert into TEMPdet_pos_dos        
 (                    
 vt_compania,   vt_sucursal, vt_secuencia,   idClave                 
 , vt_codigo_producto,vt_clave, vt_cantidad, vt_valor  ,  vt_descuento                     
 , vt_iva,    vt_estado,  vt_costo,  vt_costo_Promedio                    
 , vt_S_iva,   vt_pesoNeto, vt_pesoBruto, vt_PorDescuento              
 , vt_TotalDescuento, vt_lote,  vt_cliente,  vt_detalle              
 , vt_detalle2,   vt_ManLote,  vt_tipo_prod, vt_fecha              
 , vt_usuario,   vt_maquina,  vt_numguia               
 , vt_ruta,    vt_generador, vt_centro, vt_tipo_guia              
 , vt_hacienda             
 , vt_medico , vt_por_ret             
 )                    
 -- B.pd_CodElemento            
 select            
 vt_compania,   vt_sucursal, vt_secuencia,   ROW_NUMBER() OVER(ORDER BY B.pd_compania)                 
 , vt_codigo_producto, pd_CodElemento , (vt_cantidad * pd_Cantidad), C.pr_precio_publico  , 0 vt_descuento                     
 , 0 vt_iva,    vt_estado, C.pr_costo_promedio , C.pr_costo_promedio                     
 , D1.pr_iva ,  0 vt_pesoNeto,0 vt_pesoBruto, 0 vt_PorDescuento              
 , 0 vt_TotalDescuento, vt_lote,  vt_cliente,  vt_detalle              
 , vt_detalle2,D1.pr_lote vt_ManLote, D1.pr_tipo , vt_fecha              
 , vt_usuario,   vt_maquina,  vt_numguia               
 , vt_ruta,    vt_generador, vt_centro,  vt_tipo_guia              
 , vt_hacienda             
 , vt_medico , vt_por_ret             
 -- select * from TEMPdet_pos  where vt_usuario = 'ADMIN'          
 -- select * from tbprodosifi     
 -- select * from tbProdsucu         
 -- select * from tbproducto  
 FROM TEMPdet_pos A, tbprodosifi B, tbProdsucu C , tbproducto D , tbproducto D1           
 where   A.vt_compania = D.pr_compania              
 and A.vt_codigo_producto = D.pr_clave            
 and A.vt_compania = B.pd_compania              
 and A.vt_codigo_producto = B.pd_codigoProd             
 and B.pd_compania = D1.pr_compania  
 and B.pd_CodElemento = D1.pr_clave  
 and B.pd_compania  = C.pr_compania            
 and B.pd_CodElemento = C.pr_clave            
 and C.pr_sucursal = @i_sucursal  
 and A.vt_compania = @i_compania              
 and A.vt_sucursal= @i_sucursal              
 and A.vt_tipo_prod in (2,3)  
 and isnull(D.pr_ManejaDocificacion,'N') = 'S'            
 and A.vt_usuario = @i_usuario              
 and A.vt_maquina = @i_maquina              
 order by vt_codigo_producto      
         
 --SELECT * FROM TEMPcab_pos              
 --SELECT * FROM TEMPdet_pos           
 -- sp_help tbFac_Caja_Pos     
        
 select  @w_turno = cp_secuencia           
 from TEMPcab_pos , tbFac_Caja_Pos              
 where vt_compania =  cp_compania          
 and vt_sucursal = cp_sucursal          
 and vt_ptoemision = cp_ptoemision          
 and vt_usuario = cp_usuario          
 and CP_CERRADO = 'N'          
 and cp_tipo = 1          
 and  vt_compania = @i_compania              
 and vt_usuario = @i_usuario              
 and vt_maquina = @i_maquina               
 and vt_sucursal = @i_sucursal          
          
 if isnull(@w_turno,0) = 0           
 begin          
  set @o_idfactura = 0            
  --set @o_iddevolucion =0            
  set @o_error =1              
  set @o_mensaje = 'No existe Apertura de Turno para el Usuario ' + @i_usuario + '...Verifique '              
  return 0              
 end          
          
 update TEMPcab_pos          
 set vt_turno = @w_turno          
 where  vt_compania = @i_compania              
 and vt_usuario = @i_usuario              
 and vt_maquina = @i_maquina           
 and vt_sucursal = @i_sucursal          
          
 set @NoReg = ISNULL((SELECT COUNT(*) FROM TEMPdet_pos where vt_usuario = @i_usuario and vt_maquina = @i_maquina ),0)              
 set @NoReg = isnull(@NoReg ,0)              
 if @NoReg = 0               
 begin              
  set @o_idfactura = 0            
  --set @o_iddevolucion =0            
  set @o_error =1              
  set @o_mensaje = 'No existe detalle de Factura...Verifique '              
  return 0              
 end              
              
          
/*	WOM	   */
select  @w_ruc = vt_cedula,
        @w_total = vt_total
from TEMPcab_pos , tbFac_Caja_Pos              
 where vt_compania =  cp_compania          
 and vt_sucursal = cp_sucursal          
 and vt_ptoemision = cp_ptoemision          
 and vt_usuario = cp_usuario          
 and CP_CERRADO = 'N'          
 and cp_tipo = 1          
 and  vt_compania = @i_compania              
 and vt_usuario = @i_usuario              
 and vt_maquina = @i_maquina               
 and vt_sucursal = @i_sucursal 

 if @w_ruc = '9999999999999' and @w_total > 50
 begin              
  set @o_idfactura = 0            
  set @o_error =1              
  set @o_mensaje = 'Factura consumidor final Mayor que 50 dolares...Verifique '              
  return 0              
 end              
 
/* WOM */


 -- *****************************************************************************              
 --**************  Validacion de asignacion de Dosificado ***********************              
 --******************************************************************************             
 -- select * from TEMPVal_DodProducto  
 -- select * from tbproducto             
 delete from TEMPVal_DodProducto               
 where compania = @i_compania              
 and sucursal = @i_sucursal               
 and maquina = @i_maquina              
 and usuario = @i_usuario        
 -- select * from tbproducto         
 if EXISTS (            
 select 1             
 FROM TEMPdet_pos  A,tbproducto B            
 where A.vt_compania= B.pr_compania              
 and A.vt_codigo_producto=B.pr_clave            
 and A.vt_compania = @i_compania             
 and A.vt_sucursal= @i_sucursal             
 and A.vt_usuario = @i_usuario             
 and A.vt_maquina = @i_maquina             
 and A.vt_tipo_prod = 2             
 and B.pr_ManejaDocificacion = 'S'            
 )              
 begin                        
  INSERT INTO TEMPVal_DodProducto(compania,sucursal,usuario,maquina,idClave,detalle,stock)              
  select A.vt_compania, A.vt_sucursal, A.vt_usuario,A.vt_maquina,ROW_NUMBER() OVER(ORDER BY A.vt_codigo_producto)              
  ,ltrim(rtrim(B.pr_codigo)) + '-' + B.pr_descripcion,              
  0            
  -- select * from tbproducto  
  FROM TEMPdet_pos A,tbproducto B            
  where A.vt_compania= B.pr_compania              
  and A.vt_codigo_producto=B.pr_clave            
  and A.vt_compania = @i_compania              
  and A.vt_sucursal= @i_sucursal              
  and A.vt_tipo_prod = 2              
  and A.vt_usuario = @i_usuario              
  and A.vt_maquina = @i_maquina              
  and B.pr_ManejaDocificacion = 'S'            
  and B.pr_clave not in            
  (            
  select distinct pd_codigoProd              
  from tbprodosifi            
  where pd_compania = A.vt_compania            
  )            
            
  set @NoReg = ISNULL((SELECT COUNT(*) FROM TEMPVal_DodProducto where compania=@i_compania and  sucursal=@i_sucursal and usuario=@i_usuario and maquina=@i_maquina),0)              
  set @count = 1              
  set @w_detprod=''              
  while @NoReg > 0 and  @count <=@NoReg              
  begin              
   select @w_det = ' Producto no Dosificado ' + detalle              
   from TEMPVal_DodProducto              
   where compania=@i_compania               
   and sucursal=@i_sucursal               
   and usuario=@i_usuario              
   and maquina = @i_maquina              
   and idClave = @count              
  
   set @w_detprod = @w_detprod + @w_det + char(13)              
   set @count = @count + 1              
  end              
  if @NoReg > 0               
  begin              
   set @o_error =1              
   set @o_mensaje =  @w_detprod              
   return 0              
  end                         
 end            
                    
 -- select * from TEMPVal_Producto              
 delete from TEMPVal_Producto               
 where compania = @i_compania              
 and sucursal = @i_sucursal               
 and maquina = @i_maquina              
 and usuario = @i_usuario               
  
 delete from TEMPVal_DodProducto               
 where compania = @i_compania              
 and sucursal = @i_sucursal               
 and maquina = @i_maquina              
 and usuario = @i_usuario               
              
 --DECLARE @TProducto TABLE(idClave INT IDENTITY(1,1) NOT NULL ,detalle varchar(500), stock float )              
 -- *****************************************************************************              
 --**************  Validacion de Existencia de Stock ****************************              
 --******************************************************************************              
 if EXISTS             
 (            
 select 1            
 FROM TEMPdet_pos  A,tbproducto B            
 where A.vt_compania= B.pr_compania              
 and A.vt_codigo_producto=B.pr_clave            
 and A.vt_compania = @i_compania             
 and A.vt_sucursal= @i_sucursal             
 and A.vt_usuario = @i_usuario             
 and A.vt_maquina = @i_maquina             
 and A.vt_tipo_prod = 2             
 and B.pr_ManejaDocificacion = 'N'            
 )              
 begin                      
  INSERT INTO TEMPVal_Producto(compania,sucursal,usuario,maquina,idClave,detalle,stock)              
  select A.vt_compania, A.vt_sucursal, A.vt_usuario,A.vt_maquina,ROW_NUMBER() OVER(ORDER BY A.vt_codigo_producto)              
  ,ltrim(rtrim(C.pr_codigo)) + '-' + C.pr_descripcion,              
  B.pr_stock - A.vt_cantidad              
  FROM TEMPdet_pos A              
  , tbprodsucu B,tbproducto C              
  where A.vt_compania= B.pr_compania              
  and  A.vt_sucursal=B.pr_sucursal              
  and A.vt_codigo_producto=B.pr_clave              
  and B.pr_compania = C.pr_compania              
  and B.pr_clave=C.pr_clave              
  and B.pr_stock < A.vt_cantidad              
  and A.vt_compania = @i_compania              
  and A.vt_sucursal= @i_sucursal              
  and A.vt_tipo_prod = 2              
  and A.vt_usuario = @i_usuario              
  and A.vt_maquina = @i_maquina              
  and C.pr_ManejaDocificacion = 'N'            
  
  set @NoReg = ISNULL((SELECT COUNT(*) FROM TEMPVal_Producto where compania=@i_compania and  sucursal=@i_sucursal and usuario=@i_usuario and maquina=@i_maquina),0)              
  set @count = 1              
  set @w_detprod=''              
  while @NoReg > 0 and  @count <=@NoReg              
  begin              
   select @w_det = ' Stk(' + rtrim(rtrim(convert(varchar(40),stock))) + ') ' + detalle              
   from TEMPVal_Producto              
   where compania=@i_compania               
   and sucursal=@i_sucursal               
   and usuario=@i_usuario              
   and maquina = @i_maquina              
   and idClave = @count              
  
   set @w_detprod = @w_detprod + @w_det + char(13)              
   set @count = @count + 1              
  end              
  if @NoReg > 0               
  begin             
   set @o_idfactura = 0            
   --set @o_iddevolucion =0            
   set @o_error =1              
   set @o_mensaje = 'Stock Insuficiente...Producto1....'+ @w_detprod              
   return 0              
  end                     
 end    
     
 -- *****************************************************************************              
 --**************  Validacion de Existencia de Stock Dosificado******************              
 --******************************************************************************                      
 if EXISTS (            
 select 1            
 FROM TEMPdet_pos  A,tbproducto B            
 where A.vt_compania= B.pr_compania              
 and A.vt_codigo_producto=B.pr_clave            
 and A.vt_compania = @i_compania             
 and A.vt_sucursal= @i_sucursal             
 and A.vt_usuario = @i_usuario             
 and A.vt_maquina = @i_maquina             
 and A.vt_tipo_prod = 2             
 and B.pr_ManejaDocificacion = 'S'            
 )                       
 begin              
  INSERT INTO TEMPVal_DodProducto(compania,sucursal,usuario,maquina,idClave,detalle,stock)              
  select A.vt_compania, A.vt_sucursal, A.vt_usuario,A.vt_maquina,ROW_NUMBER() OVER(ORDER BY A.vt_codigo_producto)              
  ,'[' + ltrim(rtrim(B.pr_codigo)) + '-' + B.pr_descripcion + ']/' + E.pr_descripcion ,              
  C.pr_stock - (A.vt_cantidad * D.pd_Cantidad)             
  FROM TEMPdet_pos A              
  , tbprodsucu C,tbproducto B , tbprodosifi D, tbProducto E            
  where A.vt_compania = B.pr_compania              
  and A.vt_codigo_producto=B.pr_clave              
  and A.vt_compania = D.pd_compania              
  and A.vt_codigo_producto = D.pd_codigoProd            
  and D.pd_compania = C.pr_compania            
  and D.pd_CodElemento = C.pr_clave            
  and C.pr_sucursal = @i_sucursal            
  and C.pr_compania = E.pr_compania             
  and C.pr_clave  = E.pr_clave            
  and C.pr_stock < (A.vt_cantidad * D.pd_Cantidad)            
  and A.vt_compania = @i_compania              
  and A.vt_sucursal= @i_sucursal              
  and A.vt_usuario = @i_usuario              
  and A.vt_maquina = @i_maquina              
  and A.vt_tipo_prod = 2            
  and B.pr_ManejaDocificacion = 'S'            
  
  set @NoReg = ISNULL((SELECT COUNT(*) FROM TEMPVal_DodProducto where compania=@i_compania and  sucursal=@i_sucursal and usuario=@i_usuario and maquina=@i_maquina),0)              
  set @count = 1              
  set @w_detprod=''              
  while @NoReg > 0 and  @count <=@NoReg              
  begin              
   select @w_det = ' Stk(' + rtrim(rtrim(convert(varchar(40),stock))) + ') ' + detalle              
   from TEMPVal_DodProducto              
   where compania=@i_compania               
   and sucursal=@i_sucursal       
   and usuario=@i_usuario              
   and maquina = @i_maquina              
   and idClave = @count              
  
   set @w_detprod = @w_detprod + @w_det + char(13)              
   set @count = @count + 1              
  end              
  if @NoReg > 0               
  begin             
   set @o_idfactura = 0            
   --set @o_iddevolucion =0            
   set @o_error =1              
   set @o_mensaje = '*Stock Insuficiente...Producto Dosificado....'+ @w_detprod              
   return 0              
  end                         
 end              
              
 --**************************************************************************************************************************              
 --******************************* Validacion de Lotes ********************************************************************              
 --**************************************************************************************************************************              
 delete from TEMPVal_Lote              
 where compania = @i_compania              
 and sucursal = @i_sucursal               
 and usuario = @i_usuario                    
              
 if EXISTS (          
 select 1            
 FROM TEMPdet_pos  A,tbproducto B            
 where A.vt_compania= B.pr_compania              
 and A.vt_codigo_producto=B.pr_clave            
 and A.vt_compania = @i_compania             
 and A.vt_sucursal= @i_sucursal             
 and A.vt_usuario = @i_usuario             
 and A.vt_maquina = @i_maquina             
 and A.vt_tipo_prod = 2             
 and B.pr_ManejaDocificacion = 'N'            
 and A.vt_ManLote = 'S'             
 )              
 begin                         
  INSERT INTO TEMPVal_Lote (compania,sucursal,usuario, maquina,idClave,detalle,stock)              
  select A.vt_compania,A.vt_sucursal,A.vt_usuario,A.vt_maquina, ROW_NUMBER() OVER(ORDER BY A.vt_codigo_producto)              
  ,'LT-' + A.vt_lote + ltrim(rtrim(C.pr_codigo)) + '-' + C.pr_descripcion,              
  D.lo_cantidadPendiente - A.vt_cantidad              
  FROM TEMPdet_pos A , tbprodsucu B,tbproducto C, tbINLote D              
  where A.vt_compania = B.pr_compania              
  and  A.vt_sucursal=B.pr_sucursal              
  and A.vt_codigo_producto =B.pr_clave              
  and B.pr_compania = C.pr_compania              
  and B.pr_clave=C.pr_clave              
  and A.vt_compania= D.lo_compania               
  and A.vt_sucursal = D.lo_sucursal               
  and A.vt_codigo_producto = D.lo_producto              
  and A.vt_lote = D.lo_lote                
  and D.lo_cantidadPendiente < A.vt_cantidad              
  and A.vt_compania = @i_compania              
  and A.vt_sucursal = @i_sucursal              
  and A.vt_ManLote = 'S'              
  and A.vt_tipo_prod = 2              
  and C.pr_ManejaDocificacion = 'N'            
  and A.vt_usuario = @i_usuario              
  and A.vt_maquina = @i_maquina              
  set @NoReg = ISNULL((SELECT COUNT(*) FROM TEMPVal_Lote where compania=@i_compania and  sucursal=@i_sucursal and usuario=@i_usuario and maquina = @i_maquina),0)              
  set @count = 1              
  set @w_detprod=''              
  while @NoReg > 0 and  @count <=@NoReg              
  begin              
   select @w_det = ' Stk(' + rtrim(rtrim(convert(varchar(40),stock))) + ') ' + detalle +char(13)              
   from TEMPVal_Lote              
   where compania=@i_compania               
   and sucursal=@i_sucursal               
   and usuario=@i_usuario              
   and maquina = @i_maquina              
   and idClave = @count              
   set @w_detprod = @w_detprod + @w_det + char(13)              
   --select @w_det              
   set @count = @count + 1              
  end              
  if @NoReg > 0               
  begin              
   set @o_idfactura = 0            
   --set @o_iddevolucion =0            
   set @o_error =1              
   set @o_mensaje = 'Stock Insuficiente...Lotes1....'+ @w_detprod                          
   return 0        
  end              
 end              
       
 select  @w_observacion = vt_Observacion              
 -- select *  
 from TEMPCab_pos              
 where vt_compania = @i_compania              
 and vt_sucursal = @i_sucursal              
 and vt_usuario = @i_usuario              
 and vt_maquina = @i_maquina               
                      
 ALTER TABLE tbINV_Parametro_Cbte_Vta DISABLE TRIGGER ALL                  
 --ALTER TABLE tbProdsucu DISABLE TRIGGER ALL                
 SET XACT_ABORT ON                        
 begin tran fact              
 --**************************************************************************************************************************              
 --******************************* Asignacion de Secuencia ********************************************************************              
 --**************************************************************************************************************************              
 Begin Try              
  update tbSucursal                              
  set                                
  su_consecu_venta   = su_consecu_venta + 1                              
  where su_compania  =@i_compania                  
  and su_clave       =@i_sucursal               
 End try              
 Begin Catch              
  set @o_idfactura = 0            
  --set @o_iddevolucion =0            
  set @o_error =1           
  set @o_mensaje = 'Error Al Generar Secuencial Interno de Factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                        
  rollback tran fact               
  return 0              
 End Catch               
              
 select @w_idFactura = su_consecu_venta                             
 from tbSucursal                            
 where su_compania  =@i_compania                  
 and su_clave       =@i_sucursal               
           
 set @w_observacion = @w_observacion + ' No Sis ' + ltrim(rtrim(convert(varchar(30),isnull(@w_idFactura,0))))              
 set @w_signo = '-'             
            
 --**************************************************************************************************************************              
 --************************************* ingreso de cliente ***************************************************************              
 --**************************************************************************************************************************                                  
 select @w_noesruc=            
 (case when substring(isnull(vt_cedula,'999999'),1,5)='99999' then 'CF'            
 else 'NC' end) ,  
 @w_idcliente=vt_cliente            
 from TEMPCab_pos              
 where vt_compania = @i_compania              
 and vt_sucursal = @i_sucursal              
 and vt_usuario = @i_usuario               
 and vt_maquina = @i_maquina    
            
 set @w_noesruc = isnull(@w_noesruc,'CF')            
                      
 if @w_noesruc = 'NC'            
 begin            
  if not EXISTS (            
  select 1             
  from tbCliente              
  where cl_compania = @i_compania            
  and cl_sucursal = @i_sucursal            
  and cl_cedula_ruc in            
  (select vt_cedula            
  from TEMPCab_pos              
  where vt_compania = @i_compania              
  and vt_sucursal = @i_sucursal              
  and vt_usuario = @i_usuario               
  and vt_maquina = @i_maquina))            
  begin            
   select @w_idcliente = max(cl_clave)+1            
   from tbCliente            
   where cl_compania = @i_compania            
   and cl_sucursal = @i_sucursal            
  
   set @w_idcliente = isnull(@w_idcliente ,1)    
             
   Begin Try              
    insert into tbCliente            
    (  cl_compania    , cl_sucursal    , cl_clave                           
    , cl_tipo     , cl_cedula_ruc    , cl_nombre            
    , cl_apellido    , cl_direccion    , cl_telefono             
    , cl_email     , cl_tipo_cliente   , cl_credito            
    , cl_plazo     , cl_descuento_pronto_pago , cl_porcentaje_descuento            
    , cl_estado     , cl_vendedor    , cl_Cuenta             
    , cl_Automotriz    , cl_cedgarante    , cl_nomgarante             
    , cl_observacion   , cl_fecha     , cl_GaranteTele            
    , cl_RaranteDire   , cl_Uvica     , cl_zona           
    , cl_Cupo            
    , cl_RazonSocial   , cl_RepresentanteLegal  , cl_LocalComercial              
    , cl_SupervisorEncargado , cl_PorcenDescGeneral  , cl_Rep_Legal            
    , cl_Mail_Rep_Legal   , cl_Cell_Rep_Legal   , cl_Ger_Gen            
    , cl_Mail_Ger_Gen   , cl_Cell_Ger_Gen   , cl_Compras            
    , cl_Mail_Compras   , cl_Cell_Compras   , cl_Tecnico            
    , cl_Mail_Tecnico   , cl_Cell_Tecnico   , cl_casilla            
    , cl_fax     , cl_esholding    , cl_CodHolding            
    , cl_Actividad    , cl_relacional    , cl_tipo_identificacion  
    ,cl_codigo,    cl_nombre_comercial   
    )                          
    select @i_compania   , @i_sucursal    , @w_idcliente            
    ,             
    case when len(ltrim(rtrim(vt_cedula)))=13 then            
    2            
    else            
    1 end      , vt_cedula     , vt_nombre           
    , ''      , isnull(vt_direccion,'') , isnull(vt_telefono,'')           
    , isnull(vt_email,'')  , 1       , 'T'     
    , 30      , 'N'      , 0           
    , 'A'      , vt_vendedor    , ''           
    , ''      , ''      , ''            
    , ''      , getdate()     , ''           
    , ''      , 1       , 3  
    , 100        
    , ''      , ''      , ''            
    , ''      , 0       , ''            
    , ''      , ''      , ''            
    , ''      , ''      , ''           
    , ''      , ''      , ''           
    , ''      , ''      , ''           
    , ''      , 'S'      , 0            
    , 1       , 'N'      , vt_tipo_identificacion    
    ,@w_idcliente  , vt_nombre   
    from TEMPCab_pos              
    where vt_compania = @i_compania              
    and vt_sucursal = @i_sucursal              
    and vt_usuario = @i_usuario               
    and vt_maquina = @i_maquina             
   End try              
   Begin Catch               
    set @o_idfactura = 0            
    --set @o_iddevolucion =0            
    set @o_error =1              
    set @o_mensaje = 'Error Al Registrar Cliente.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
    rollback tran fact              
    return 0              
   End Catch              
  end            
  else            
  begin            
   select  @w_idcliente = cl_clave            
   from tbCliente              
   where cl_compania = @i_compania            
   and cl_sucursal = @i_sucursal            
   and cl_cedula_ruc in            
   (select vt_cedula            
   from TEMPCab_pos              
   where vt_compania = @i_compania              
   and vt_sucursal = @i_sucursal              
   and vt_usuario = @i_usuario               
   and vt_maquina = @i_maquina)                     
  end                        
 end        
        
 --**************************************************************************************************************************              
 --**********************************Cabezera de Factura****************************************************************              
 --**************************************************************************************************************************                  
 select               
 @w_tipocbteVta =               
 case when vt_tipo = 'VT' then 1              
 else 2              
 end               
 , @w_idFacturaImp = convert(float,vt_numeroext)              
 , @w_ptoemi  = vt_ptoemision    
 , @w_tipogen = vt_TipoGen          
 from TEMPCab_pos              
 where vt_compania = @i_compania              
 and vt_sucursal = @i_sucursal              
 and vt_usuario = @i_usuario               
 and vt_maquina = @i_maquina     
   
 if @w_tipoGen=1 or @w_tipoGen=4    
 begin     
  begin try              
   if (select  count(*) as total           
   from tbINV_Parametro_Cbte_Vta          
   where pc_compania = @i_compania                 
   AND pc_sucursal=@i_sucursal       
   and pc_ptoemi=@w_ptoemi        
   and pc_tipo =  @w_tipocbteVta  
   and pc_TipoEmision = @w_tipoGen    
   and pc_estado='A')=0        
   begin    
    set @o_idfactura = 0            
    --set @o_iddevolucion =0            
    set @o_error =1              
    set @o_mensaje = 'No hay datos para el tipo de comprobante'   
    rollback tran fact              
    return 0                  
   end            
   
   select @w_NewNumeroExtNew=REPLICATE('0',9 - len(cast((ISNULL(pc_numero_actual,0) + 1) as varchar))) + cast((ISNULL(pc_numero_actual,0) + 1) as varchar)               
   , @w_SerieNew=pc_serie        
   from tbINV_Parametro_Cbte_Vta,tb_empresa          
   where em_codigo = pc_compania          
   and pc_compania = @i_compania          
   AND pc_sucursal = @i_sucursal          
   and pc_ptoemi = @w_ptoemi             
   and pc_tipo = @w_tipocbteVta    
   and pc_TipoEmision = @w_tipoGen    
   and pc_estado='A'    
  
   set @w_idFacturaImp=convert(float,@w_NewNumeroExtNew)       
   set @w_idSeriefact=@w_SerieNew  
  
   update tbINV_Parametro_Cbte_Vta                
   set pc_numero_actual = @w_idFacturaImp                
   from tbINV_Parametro_Cbte_Vta                
   where pc_compania = @i_compania                
   AND pc_sucursal=@i_sucursal       
   and pc_ptoemi =  @w_ptoemi                  
   and  pc_tipo  =   @w_tipocbteVta       
   and pc_TipoEmision = @w_tipoGen    
   and pc_estado='A'    
  
   if @w_observacion is null  
   set @w_observacion=''  
     
   --if LEN(rtrim(ltrim(@w_observacion)))>0  
   --begin  
   -- set @w_observacion= @w_observacion + CHAR(10) + 'VENTAS FACT No ' + @w_idSeriefact + '/' +right('000000000' + CAST( @w_idFacturaImp as nvarchar),9)     
   --end     
   --else  
   --begin  
    set @w_observacion= 'VENTAS FACT No ' + @w_idSeriefact + '/' +right('000000000' + CAST( @w_idFacturaImp as nvarchar),9)     
   --end  
  
   update TEMPCab_pos set vt_numeroext =@w_NewNumeroExtNew, vt_serie =@w_SerieNew, vt_Observacion=@w_observacion            
   where vt_compania = @i_compania        
   and vt_sucursal = @i_sucursal        
   and vt_usuario = @i_usuario         
   and vt_maquina = @i_maquina                         
  End try              
  Begin Catch             
   set @o_idfactura = 0          
   set @o_error =1             
   set @o_mensaje = 'Error al actualizar Secuencia Interno de factura.....'        
   rollback tran fact         
   return 0                   
  End Catch     
 end    
 else    
 begin    
  begin try    
   update tbINV_Parametro_Cbte_Vta                
   set pc_numero_actual = @w_idFacturaImp                
   from tbINV_Parametro_Cbte_Vta                
   where pc_compania = @i_compania                
   AND pc_sucursal=@i_sucursal       
   and pc_ptoemi =  @w_ptoemi                  
   and  pc_tipo  =   @w_tipocbteVta         
   and pc_TipoEmision = @w_tipoGen    
   and pc_estado='A'  
  
   if @w_observacion is null  
   set @w_observacion=''  
     
   --if LEN(rtrim(ltrim(@w_observacion)))>0  
   --begin  
   -- set @w_observacion= @w_observacion + CHAR(10) + 'VENTAS FACT No ' + @w_idSeriefact + '/' +right('000000000' + CAST( @w_idFacturaImp as nvarchar),9)     
   --end     
   --else  
   --begin  
    set @w_observacion= 'VENTAS FACT No ' + @w_idSeriefact + '/' +right('000000000' + CAST( @w_idFacturaImp as nvarchar),9)     
   --end  
  
   update TEMPCab_pos set vt_Observacion=@w_observacion            
   where vt_compania = @i_compania        
   and vt_sucursal = @i_sucursal        
   and vt_usuario = @i_usuario         
   and vt_maquina = @i_maquina      
  end try      
  Begin Catch             
   set @o_idfactura = 0          
   set @o_error =1                   
   set @o_mensaje = 'Error al actualizar Secuencia Interno de factura.....'        
   rollback tran fact         
   return 0                   
  End Catch     
 end    
-- *********************************************************************************************  
-- *********************************************************************************************  
-- ****************** validacion de duplicidad de numero de factura ****************************  
-- *********************************************************************************************  
-- *********************************************************************************************  
  
 if exists (         
  select 1  
  from (  
  select vt_compania,vt_codigo_sucursal vt_sucursal,vt_serie + vt_numeroext vt_factura     
  from tbcab_pos   
  union all  
  select vt_compania,vt_codigo_sucursal vt_sucursal,vt_serie + vt_numeroext vt_factura     
  from Dia_tbcab_pos   
  ) x  
  where vt_compania = @i_compania        
  and vt_sucursal = @i_sucursal    
  and vt_factura in (  
  select vt_serie + vt_numeroext  
  from TEMPCab_pos         
  where vt_compania = @i_compania        
  and vt_sucursal = @i_sucursal        
  and vt_usuario = @i_usuario         
  and vt_maquina = @i_maquina  
  ))  
 begin  
   set @o_idfactura = 0          
   set @o_error =1                   
   set @o_mensaje = 'Numero de factura se encuentra asignado...verifique.....'        
   rollback tran fact         
   return 0                   
 end  
  
 Begin Try              
  -- sp_help tbcab_pos          
  -- select * from Dia_tbcab_pos  
/*  select top 1 * from SIACDB..tbcab_pos  
  select * from tbcab_pos            
  select * from Dia_tbcab_pos  
  select * from TEMPCab_pos  
  alter table tbcab_pos add vt_direccion nvarchar(200), vt_telefono nvarchar(200), vt_migrado nchar(1)  
  alter table Dia_tbcab_pos add  vt_ruc nvarchar(15)  
  ,vt_nombre_cliente nvarchar(200),vt_direccion nvarchar(200),vt_telefono nvarchar(200)  
  ,vt_correo nvarchar(250), vt_migrado nchar(1)  
*/  
  insert into Dia_tbcab_pos            
  (              
  vt_compania,    vt_codigo_sucursal,   vt_numero,   vt_fecha              
  ,vt_vendedor,    vt_cliente,     vt_base_coniva,  vt_base_siniva              
  ,vt_subtotal,    vt_descuento,    vt_iva,    vt_total              
  ,vt_estado,     vt_contabilizado,   vt_tipo_venta,  vt_plazo              
  ,vt_fech_venc,    vt_desc_pront_pago,   vt_saldo,   vt_numeroext              
  ,vt_seguro,     vt_flete,     vt_retencion,  vt_Observacion              
  ,vt_tipo,     vt_tipoDoc,     vt_Doc,    vt_usuario              
  ,vt_t_venta,    vt_refrendo,    vt_No_transporte, vt_No_fue                  
  --, vt_centro               
  ,vt_contabilizadoInve,  vt_consignatario,   vt_notify,   vt_anio_embarque                
  --, vt_peso_neto, vt_peso_bruto                   
  ,vt_embarque,    vt_semana,     vt_Orden_Compra, vt_Guia_Remision              
  ,vt_Guia_Despacho,   vt_serie,     vt_autorizacion, vt_fecha_vencimiento              
  ,vt_hora,     vt_ptoemision,    vt_tipo_cobro,  vt_turno              
  ,vt_FechaHoraReg,   vt_esPorCobranza,   vt_fecha_inicio, vt_TipoGen         
  ,vt_PIva,     vt_idiva,     vt_FactElect,  vt_ClaveAcceso  
  ,vt_AutElect,    vt_NumAutElect,    vt_Emision,   vt_ambiente           
  ,vt_Autorizada,    vt_FechAutElect,   vt_FechAutTex           
  ,vt_porcent_servicio,  vt_totalservicio,   vt_ruc,    vt_nombre_cliente   
  ,vt_direccion,    vt_telefono,    vt_correo,   vt_migrado   
  )              
  -- select * from TEMPCab_pos           
  select              
  --vt_cliente            
  vt_compania,    vt_sucursal,    @w_idFactura,  vt_fecha              
  ,vt_vendedor,    @w_idcliente,    vt_base_coniva,  vt_base_siniva              
  ,vt_subtotal,    vt_descuento,    vt_iva,    vt_total              
  ,vt_estado,     vt_contabilizado,   vt_tipo_venta,  vt_plazo              
  ,vt_fech_venc,    vt_desc_pront_pago,   vt_saldo,   vt_numeroext              
  ,vt_seguro,     vt_flete,     vt_retencion,  vt_observacion              
  ,vt_tipo,     vt_tipoDoc,     vt_Doc,    vt_usuario              
  ,vt_t_venta,    vt_refrendo,    vt_No_transporte, vt_No_fue                  
  --, vt_centro               
  ,vt_contabilizadoInve,  vt_consignatario,   vt_notify,   vt_anio_embarque                
  --, vt_peso_neto, vt_peso_bruto                   
  ,vt_embarque,    vt_semana,     vt_Orden_Compra, vt_Guia_Remision              
  ,vt_Guia_Despacho,   vt_serie,     vt_autorizacion, vt_fecha_vencimiento              
  ,vt_hora,     vt_ptoemision,    vt_tipo_cobro,  vt_turno              
  ,vt_FechaHoraReg,   'N',      vt_fecha_inicio, vt_TipoGen        
  ,vt_PIva,     vt_idiva,     'N',    CASE WHEN @w_tipoGen = 4 THEN dbo.fnGenerar_clave_acceso(convert(nvarchar,vt_fecha,112),'01',@w_Ambiente,vt_serie,vt_numeroext,@w_RucEmpresa,@w_Emision) else '' END      
  ,'',      '',       CASE WHEN @w_tipoGen = 4 THEN @w_Emision else 0 END,  CASE WHEN @w_tipoGen = 4 THEN @w_Ambiente else 0 END          
  ,'N',      NULL,      ''  
  ,@i_porentservicio,@i_totservicio,      vt_cedula,   vt_nombre  
  ,vt_direccion,    vt_telefono,    vt_email,   'N'    
  --select *  
  from TEMPCab_pos              
  where vt_compania = @i_compania              
  and vt_sucursal = @i_sucursal              
  and vt_usuario = @i_usuario               
  and vt_maquina = @i_maquina              
 End try         
 Begin Catch               
  set @o_idfactura = 0            
  --set @o_iddevolucion =0                        
  set @o_error =1              
  set @o_mensaje = 'Error Al insertar Cabezera de Factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
  rollback tran fact              
  return 0              
 End Catch                        
            
 Begin Try              
  -- alter table TbPosCliente add rt_email varchar(300) null            
  insert into TbPosCliente             
  ( rt_compania, rt_sucursal, rt_numero , rt_cedula             
  , rt_nombre, rt_direccion, rt_telefono,rt_email )            
  select            
  vt_compania ,  vt_sucursal, @w_idFactura, vt_cedula            
  ,vt_nombre, vt_direccion, vt_telefono ,vt_email            
  from TEMPCab_pos              
  where vt_compania = @i_compania              
  and vt_sucursal = @i_sucursal              
  and vt_usuario = @i_usuario               
  and vt_maquina = @i_maquina                
 End try              
 Begin Catch               
  set @o_idfactura = 0            
  --set @o_iddevolucion =0            
  set @o_error =1              
  set @o_mensaje = 'Error Al insertar Datos de Factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
  rollback tran fact              
  return 0              
 End Catch     
   
 if @i_sProforma= 'S'  
 begin  
  begin try  
   update tbcab_Proforma  
   set pf_estado ='F',  
   pf_Factura = @w_idFactura,  
   pf_NumeroExt = (select vt_serie+'-'+vt_numeroext from Dia_tbcab_pos where vt_compania = pf_compania and vt_codigo_sucursal =pf_sucursal and vt_numero = @w_idFactura )  
   where pf_compania = @i_compania  
   and pf_sucursal = @i_sucursal  
   and pf_numero = @i_Proforma  
  end try  
  Begin Catch               
   set @o_idfactura = 0            
   --set @o_iddevolucion =0            
   set @o_error =1              
   set @o_mensaje = 'Error marcar proforma como facturada.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
   rollback tran fact              
   return 0              
  End Catch     
 end  
           
 -- alter table LOGdet_pos add fecha_reg  datetime null          
 Begin Try            
  insert into LOGdet_pos              
  (                    
  vt_compania,   vt_sucursal, vt_secuencia,   idClave                 
  , vt_codigo_producto, vt_cantidad, vt_valor  ,  vt_descuento                     
  , vt_iva,    vt_estado,  vt_costo,  vt_costo_Promedio                    
  , vt_S_iva,   vt_pesoNeto, vt_pesoBruto, vt_PorDescuento              
  , vt_TotalDescuento, vt_lote,  vt_cliente,  vt_detalle              
  , vt_detalle2,   vt_ManLote,  vt_tipo_prod, vt_fecha              
  , vt_usuario,   vt_maquina,  vt_numguia               
  , vt_ruta,    vt_generador, vt_centro,  vt_tipo_guia              
  , vt_hacienda             
  , vt_medico , vt_por_ret  ,fecha_reg           
  )             
  -- sp_help TEMPdet_pos             
  select           
  vt_compania,   vt_sucursal, vt_secuencia,    @w_idFactura                
  , vt_codigo_producto, vt_cantidad, vt_valor  ,  vt_descuento                     
  , vt_iva,    vt_estado,  vt_costo,  vt_costo_Promedio                    
  , vt_S_iva,   vt_pesoNeto, vt_pesoBruto, vt_PorDescuento              
  , vt_TotalDescuento, vt_lote,  vt_cliente,  vt_detalle              
  , vt_detalle2,   vt_ManLote,  vt_tipo_prod, vt_fecha              
  , vt_usuario,   vt_maquina,  vt_numguia               
  , vt_ruta,    vt_generador, vt_centro,  vt_tipo_guia              
  , vt_hacienda             
  , vt_medico , vt_por_ret ,getdate()           
  FROM TEMPdet_pos            
  where vt_compania = @i_compania           
  and vt_sucursal= @i_sucursal           
  and vt_usuario = @i_usuario           
  and vt_maquina = @i_maquina          
 End try              
 Begin Catch               
  set @o_idfactura = 0            
  --set @o_iddevolucion =0            
  set @o_error =1              
  set @o_mensaje = 'Error Al insertar log de Factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
  rollback tran fact              
  return 0              
 End Catch           
            
 --**************************************************************************************************************************              
 --********************************** Cabezera de Mov Inv ***************************************************************              
 --**************************************************************************************************************************              
 if EXISTS (            
 select 1 FROM TEMPdet_pos    
 where vt_compania = @i_compania   
 and vt_sucursal= @i_sucursal   
 and vt_usuario = @i_usuario   
 and vt_maquina = @i_maquina  
 and ((vt_tipo_prod in (2))  
 or (  
 vt_tipo_prod  = 3 and   
 exists(select top 1 1 from  tbprodosifi a ,tbproducto b    
   where a.pd_compania = b.pr_compania   
   and a.pd_CodElemento = b.pr_clave   
   and b.pr_tipo = 2   
   and a.pd_compania = vt_compania  
   and a.pd_codigoProd = vt_codigo_producto  
   )   
 ))  
   
 )              
 begin              
  Begin Try              
--   select * from Dia_tbCab_Movi_Inve  
--    select * from tbCab_Movi_Inve  
   insert into Dia_tbCab_Movi_Inve                  
   (               
   ci_compania     ,ci_sucursal    ,ci_num_movi  ,ci_concepto          
   ,ci_proveedor    ,ci_fecha     ,ci_documento  ,ci_estado                  
   ,ci_tipo         ,ci_contabilizado   ,ci_semana  ,ic_tipoDocumento                   
   ,ci_descripcion  ,ci_nume_conce      ,ci_ctacble  
   , ci_ajustado, ci_migrado,   ci_pagado,  ci_contabilizadoInv  
   --, ci_fechaLiq                  
   )              
   select              
   vt_compania , vt_sucursal       , @w_idFactura   ,@w_idconcepto              
   , 0     , vt_fecha    , @w_idFactura   ,'A'              
   , @w_signo   , 'N'      , @w_semana    , 0              
   , @w_observacion,@w_idFactura   ,''  
   , 'N','N','N','N'              
   from TEMPCab_pos              
   where vt_compania = @i_compania              
   and vt_sucursal = @i_sucursal              
   and vt_usuario = @i_usuario               
   and vt_maquina = @i_maquina              
  End try              
  Begin Catch                             
   set @o_idfactura = 0            
   --set @o_iddevolucion =0                          
   set @o_error =1              
   set @o_mensaje = 'Error Cabezera de Movimiento de Invetario.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                      
   rollback tran fact               
   return 0              
  End Catch               
      
  Begin Try              
   insert into Work_tbCab_Movi_Inve                  
   (               
   ci_compania     ,ci_sucursal    ,ci_num_movi  ,ci_concepto                  
   ,ci_proveedor    ,ci_fecha     ,ci_documento  ,ci_estado                  
   ,ci_tipo         ,ci_contabilizado   ,ci_semana  ,ic_tipoDocumento                   
   ,ci_descripcion  ,ci_nume_conce      ,ci_ctacble                  
   )              
   select              
   vt_compania , vt_sucursal       , @w_idFactura   ,@w_idconcepto              
   , 0     , vt_fecha    , @w_idFactura   ,'A'              
   , @w_signo   , 'N'      , @w_semana    , 0              
   , @w_observacion,@w_idFactura   ,''              
   from TEMPCab_pos              
   where vt_compania = @i_compania              
   and vt_sucursal = @i_sucursal              
   and vt_usuario = @i_usuario               
   and vt_maquina = @i_maquina              
  End try              
  Begin Catch               
   set @o_idfactura = 0            
   --set @o_iddevolucion =0            
   set @o_error =1              
   set @o_mensaje = 'Error Cabezera de Movimiento de Invetario Work.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
   rollback tran fact               
   return 0              
  End Catch                          
 end      
           
 --**************************************************************************************************************************              
 --********************************** Detalle de Factura****************************************************************              
 --**************************************************************************************************************************              
 set @No_sec = 1            
 set @w_maneja_dosi  = 'N'            
 set @NoReg = ISNULL((SELECT COUNT(*) FROM TEMPDet_pos where vt_compania = @i_compania and vt_sucursal = @i_sucursal and vt_usuario = @i_usuario and vt_maquina = @i_maquina ),0)              
 set @NoReg = isnull(@NoReg ,0)              
 set @count = 1              
 while @NoReg > 0 and  @count <=@NoReg              
 begin              
  set @w_producto = 0          
  set @w_cantidad = 0          
  set @w_tipo_prod = 0          
  set @w_Man_Lote = ''          
  set @w_lote = ''          
  set @w_maneja_dosi = ''          
  select @w_producto = A.vt_codigo_producto              
  , @w_cantidad = A.vt_cantidad               
  , @w_tipo_prod = A.vt_tipo_prod              
  , @w_Man_Lote = A.vt_ManLote              
  , @w_lote = A.vt_lote              
  , @w_maneja_dosi = isnull(B.pr_ManejaDocificacion,'N')           
  -- SELECT *   
  FROM TEMPdet_pos  A,tbproducto B            
  where A.vt_compania= B.pr_compania              
  and A.vt_codigo_producto=B.pr_clave            
  and A.vt_compania = @i_compania             
  and A.vt_sucursal= @i_sucursal             
  and A.vt_usuario = @i_usuario             
  and A.vt_maquina = @i_maquina             
  and A.vt_tipo_prod in (2,3)             
  AND A.idClave = @count              
        --select @w_tipo_prod,@w_maneja_dosi    
                
  if @w_tipo_prod = 2 and @w_maneja_dosi = 'N'              
  begin              
   -- inicio producto y no dosificado           
   if not exists            
   (             
   Select 1             
   from tbprodsucu             
   where pr_compania = @i_compania             
   and pr_sucursal = @i_sucursal             
   and pr_clave = @w_producto             
   and pr_stock >= @w_cantidad            
   )              
   begin              
    -- validar stock          
    set @o_idfactura = 0            
    --set @o_iddevolucion =0            
    set @o_error =1              
    set @o_mensaje = 'No existe Stock .....Verifique..'   
    rollback tran fact              
    return  0                  
   end                               
              
   if @w_Man_Lote = 'S'               
   begin               
    if not exists(               
    Select 1 from tbINLote               
    where lo_compania = @i_compania               
    and lo_sucursal = @i_sucursal               
    and lo_producto = @w_producto               
    and lo_lote = @w_lote              
    and lo_cantidadPendiente >= @w_cantidad)              
    begin              
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'No existe Stock en lotes .....Verifique'              
     rollback tran fact              
     return 0                   
    end              
   end              
              
   if @w_Man_Lote = 'S'               
   begin               
    Begin Try                
     update tbINLote              
     set lo_cantidadPendiente = lo_cantidadPendiente - @w_cantidad              
     where lo_compania = @i_compania               
     and lo_sucursal = @i_sucursal               
     and lo_producto = @w_producto               
     and lo_lote = @w_lote              
    End try              
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0                   
     set @o_error =1              
     set @o_mensaje = 'Error actualizar Lotes .....'  + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact              
     return 0              
    End Catch    
                
    Begin Try               
     insert into tbMovi_Inve_Lotes                    
     ( mv_compania     , mv_sucursal  , mv_nume_movi    , mv_secu_movi , mv_concepto                    
     , mv_nume_conce   , mv_tipo_movi , mv_fecha_movi   , pr_clave     , mv_cant_arti                     
     , mv_observacion  , mv_usuario   , mv_maquina  , mv_Lote    ,mv_fechaReg                    
     )                         
     select               
     vt_compania,  vt_sucursal, @w_idFactura, vt_secuencia , @w_idconcepto                      
     , @w_idFactura     ,@w_signo    , vt_fecha   , vt_codigo_producto,vt_cantidad                
     , @w_observacion   ,vt_usuario,     vt_maquina   , vt_lote  ,getdate()                 
     FROM TEMPDet_pos               
     where vt_compania = @i_compania               
     and vt_sucursal = @i_sucursal               
     and vt_usuario = @i_usuario              
     and vt_maquina = @i_maquina               
     AND idClave = @count              
    End try              
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'Error al Registrar Movimiento de Lotes .....'  + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran               
     return 0              
    End Catch              
   end              
             
   select               
   @w_stock = pr_stock               
   FROM tbProdsucu               
   where pr_compania = @i_compania                
   AND  pr_sucursal = @i_sucursal              
   AND  pr_clave = @w_producto               
              
   Begin Try              
    update tbProdsucu                
    set pr_stock = pr_stock - @w_cantidad                 
    where pr_compania = @i_compania                
    AND  pr_sucursal = @i_sucursal              
    AND  pr_clave = @w_producto               
   End try              
   Begin Catch               
    set @o_idfactura = 0            
    --set @o_iddevolucion =0            
    set @o_error =1              
    set @o_mensaje = 'Error actualizar Productos x Sucursal.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
    rollback tran fact              
    return 0              
   End Catch     
               
   select               
   @w_stock_n = pr_stock               
   FROM tbProdsucu               
   where pr_compania = @i_compania                
   AND  pr_sucursal = @i_sucursal              
   AND  pr_clave = @w_producto               
   set @w_stock = isnull(@w_stock,0)              
   set @w_stock_n = isnull(@w_stock_n ,0)            
            
   Begin Try               
    insert into Dia_tbMovi_Inve                            
    ( mv_compania     , mv_sucursal  , mv_nume_movi    , mv_secu_movi , mv_concepto                            
    , mv_nume_conce  , mv_tipo_movi , mv_fecha_movi   , pr_clave     , mv_cant_arti                             
    , mv_stock_ante  , mv_stock_actu, mv_observacion  , mv_usuario   , mv_maquina                            
    , mv_precio , mv_costoPromedio,mv_fechaReg)                            
    select                             
    vt_compania,   vt_sucursal, @w_idFactura, @No_sec , @w_idconcepto              
    , @w_idFactura,  @w_signo, vt_fecha  , vt_codigo_producto,vt_cantidad                      
    , @w_stock,   @w_stock_n  , @w_observacion , vt_usuario    ,vt_maquina              
    , vt_valor,   vt_costo_Promedio,GETDATE()              
    FROM TEMPDet_pos               
    where vt_compania = @i_compania               
    and vt_sucursal = @i_sucursal               
    and vt_usuario = @i_usuario           
    and vt_maquina = @i_maquina              
    AND idClave = @count    
                
    set @No_sec  = @No_sec  + 1             
   End try              
   Begin Catch              
    set @o_idfactura = 0            
    --set @o_iddevolucion =0            
    set @o_error =1              
    set @o_mensaje = 'Error al Registrar Movimiento de Inventario .....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
    rollback tran fact              
    return 0               
   End Catch                 
      
   Begin Try               
    insert into Work_tbMovi_Inve                            
    ( mv_compania     , mv_sucursal  , mv_nume_movi    , mv_secu_movi , mv_concepto                            
    , mv_nume_conce  , mv_tipo_movi , mv_fecha_movi   , pr_clave     , mv_cant_arti                             
    , mv_stock_ante  , mv_stock_actu, mv_observacion  , mv_usuario   , mv_maquina                            
    , mv_precio , mv_costoPromedio, mv_fechaReg)                            
    select                             
    vt_compania,   vt_sucursal, @w_idFactura, @No_sec , @w_idconcepto              
    , @w_idFactura,  @w_signo, vt_fecha  , vt_codigo_producto,vt_cantidad                      
    , @w_stock,   @w_stock_n  , @w_observacion , vt_usuario    ,vt_maquina              
    , vt_valor,   vt_costo_Promedio, GETDATE()              
    FROM TEMPDet_pos               
    where vt_compania = @i_compania               
    and vt_sucursal = @i_sucursal               
    and vt_usuario = @i_usuario               
    and vt_maquina = @i_maquina              
    AND idClave = @count     
               
    set @No_sec  = @No_sec  + 1             
   End try              
   Begin Catch              
    set @o_idfactura = 0            
    --set @o_iddevolucion =0            
    set @o_error =1              
    set @o_mensaje = 'Error al Registrar Movimiento de Inventario Work.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
    rollback tran fact              
    return 0               
   End Catch                   
  end             
       --   select @w_tipo_prod, @w_maneja_dosi  
  if @w_tipo_prod in (2,3)  and @w_maneja_dosi = 'S'              
  begin             
  -- SELECT * FROM TEMPDet_pos_dos  
   set @NoReg2 = ISNULL((SELECT max(idClave) FROM TEMPDet_pos_dos where vt_compania = @i_compania and vt_sucursal = @i_sucursal and vt_usuario = @i_usuario and vt_maquina = @i_maquina and vt_codigo_producto  = @w_producto ),0)              
   set @NoReg2 = isnull(@NoReg2 ,0)              
   set @count2 = (SELECT min(idClave) FROM TEMPDet_pos_dos where vt_compania = @i_compania and vt_sucursal = @i_sucursal and vt_usuario = @i_usuario and vt_maquina = @i_maquina and vt_codigo_producto  = @w_producto )              
   while @NoReg2 > 0 and  @count2 <=@NoReg2              
   begin               
    set @w_idproducto = 0          
    set @w_cantidad = 0       
    set @w_tipo_prod_dos = 0     
    select @w_idproducto = vt_clave            
    , @w_cantidad = vt_cantidad  
    , @w_tipo_prod_dos = vt_tipo_prod   
    -- select *              
    FROM TEMPDet_pos_dos               
    where vt_compania = @i_compania               
    and vt_sucursal = @i_sucursal               
    and vt_usuario = @i_usuario               
    and vt_maquina = @i_maquina               
    and vt_codigo_producto  = @w_producto              
    AND idClave = @count2       
      
      
   if @w_tipo_prod_dos = 2  
   begin         
    if not exists( Select 1 from tbprodsucu where pr_compania = @i_compania and pr_sucursal = @i_sucursal and pr_clave = @w_idproducto  and pr_stock >= @w_cantidad)              
    begin              
     set @o_idfactura = 0            
     --set @o_iddevolucion =0        
           
     select @w_detprod   = b.pr_descripcion  + '-' + convert(varchar(10),a.pr_stock - @w_cantidad)            
     from tbprodsucu a,  tbproducto b              
     where a.pr_compania = b.pr_compania            
     and a.pr_clave = b.pr_clave            
     and a.pr_compania = @i_compania                
     and a.pr_clave =@w_idproducto            
     and  a.pr_sucursal = @i_sucursal   
                
     set @o_error =1              
     set @o_mensaje = '**No existe Stock en la dosificacion de este producto.....Verifique *' + @w_detprod            
     rollback tran fact              
     return  0                  
    end   
                 
    select               
    @w_stock = pr_stock               
    FROM tbProdsucu               
    where pr_compania = @i_compania                
    AND  pr_sucursal = @i_sucursal              
    AND  pr_clave = @w_idproducto             
             
    Begin Try              
     update tbProdsucu                
     set pr_stock = pr_stock - @w_cantidad                 
     where pr_compania = @i_compania                
     AND  pr_sucursal = @i_sucursal              
     AND  pr_clave = @w_idproducto               
    End try              
    Begin Catch               
     set @o_error =1              
     set @o_mensaje = 'Error actualizar Productos x Sucursal.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact              
     return 0              
    End Catch      
               
      set @w_stock = isnull(@w_stock,0)              
      set @w_stock_n = @w_stock - @w_cantidad               
      set @w_stock_n = isnull(@w_stock_n ,0)   
                 -- select * from Dia_tbMovi_Inve  
    Begin Try               
     insert into Dia_tbMovi_Inve                            
     ( mv_compania     , mv_sucursal  , mv_nume_movi    , mv_secu_movi , mv_concepto                            
     , mv_nume_conce , mv_tipo_movi , mv_fecha_movi   , pr_clave     , mv_cant_arti                             
     , mv_stock_ante  , mv_stock_actu, mv_observacion  , mv_usuario   , mv_maquina                            
     , mv_precio , mv_costoPromedio,mv_fechaReg)                            
     select                             
     vt_compania,   vt_sucursal, @w_idFactura, @No_sec, @w_idconcepto              
     , @w_idFactura,  @w_signo, vt_fecha  , vt_clave,vt_cantidad                      
     , @w_stock,   @w_stock_n  , @w_observacion + ' COMPUESTO' , vt_usuario    ,vt_maquina              
     , vt_valor,   vt_costo_Promedio, getdate()              
     FROM TEMPDet_pos_dos               
     where vt_compania = @i_compania               
     and vt_sucursal = @i_sucursal               
     and vt_usuario = @i_usuario               
     and vt_maquina = @i_maquina              
     and vt_codigo_producto  = @w_producto              
     AND idClave = @count2            
    End try              
    Begin Catch              
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'Error al Registrar Movimiento de Inventario x Dosificacion.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact              
     return 0               
    End Catch              
    Begin Try               
    insert into Work_tbMovi_Inve                            
    ( mv_compania     , mv_sucursal  , mv_nume_movi    , mv_secu_movi , mv_concepto                            
    , mv_nume_conce  , mv_tipo_movi , mv_fecha_movi   , pr_clave     , mv_cant_arti                             
    , mv_stock_ante  , mv_stock_actu, mv_observacion  , mv_usuario   , mv_maquina                            
    , mv_precio , mv_costoPromedio, mv_fechaReg)                            
    select                             
    vt_compania,   vt_sucursal, @w_idFactura, @No_sec , @w_idconcepto              
    , @w_idFactura,  @w_signo, vt_fecha  , vt_codigo_producto,vt_cantidad                      
    , @w_stock,   @w_stock_n  , @w_observacion + ' COMPUESTO', vt_usuario    ,vt_maquina              
    , vt_valor,   vt_costo_Promedio, GETDATE()              
     FROM TEMPDet_pos_dos               
     where vt_compania = @i_compania               
     and vt_sucursal = @i_sucursal               
     and vt_usuario = @i_usuario               
     and vt_maquina = @i_maquina              
     and vt_codigo_producto  = @w_producto              
     AND idClave = @count2      
               
    --set @No_sec  = @No_sec  + 1             
   End try              
   Begin Catch              
    set @o_idfactura = 0            
    --set @o_iddevolucion =0            
    set @o_error =1              
    set @o_mensaje = 'Error al Registrar Movimiento de Inventario Work.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
    rollback tran fact              
    return 0               
   End Catch         
                
     end  
  
     -- select * from TEMPDet_pos_dos  
    Begin Try              
     insert into Dia_tbdet_pos_dos              
     (                    
     vt_compania,   vt_sucursal, vt_numero ,     vt_secuencia                     
     , vt_codigo_producto,vt_clave, vt_cantidad, vt_valor  ,  vt_descuento                     
     , vt_iva,    vt_estado,  vt_costo,  vt_costo_Promedio                    
     , vt_S_iva,   vt_pesoNeto, vt_pesoBruto, vt_PorDescuento              
     , vt_TotalDescuento, vt_lote,  vt_cliente,  vt_detalle              
     , vt_detalle2,   vt_numguia,  vt_ruta,     vt_generador              
     , vt_centro,      vt_tipo_guia, vt_hacienda, vt_fecha_guia                  
     , vt_medico , vt_por_ret, vt_tipo_p, vt_turno                     
     )               
     select               
     a.vt_compania,   a.vt_sucursal, @w_idFactura, @No_sec                      
     , a.vt_codigo_producto,a.vt_clave, a.vt_cantidad, a.vt_valor  ,  a.vt_descuento                     
     , a.vt_iva,    a.vt_estado,  a.vt_costo,  a.vt_costo_Promedio                    
     , a.vt_S_iva,   a.vt_pesoNeto, a.vt_pesoBruto, a.vt_PorDescuento              
     , a.vt_TotalDescuento, a.vt_lote,  a.vt_cliente,  a.vt_detalle              
     , a.vt_detalle2,   a.vt_numguia,  a.vt_ruta,     a.vt_generador              
     , a.vt_centro,      a.vt_tipo_guia, a.vt_hacienda, @w_fecha_guia                 
     , a.vt_medico , a.vt_por_ret, a.vt_tipo_prod, b.vt_turno   
     -- select * 
	  FROM TEMPDet_pos_dos a, TEMPCab_pos b            
   where a.vt_compania = b.vt_compania
   and a.vt_sucursal = b.vt_sucursal
   and a.vt_usuario = b.vt_usuario
   and a.vt_maquina = b.vt_maquina 
   and a.vt_compania = @i_compania               
     and a.vt_sucursal = @i_sucursal               
     and a.vt_usuario = @i_usuario               
     and a.vt_maquina = @i_maquina              
     and a.vt_codigo_producto  = @w_producto              
     AND idClave = @count2            
    End try              
    Begin Catch             
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'Error al Registrar detalle de factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact              
     return 0               
    End Catch     
               
    set @No_sec = @No_sec  + 1             
    set @count2  = @count2  + 1            
   end           
  -- fin de while             
  end        
      
  -- fin de tipo producto dosificado             
  
  /*if EXISTS (select 1 FROM TEMPDet_pos where vt_compania = @i_compania and vt_sucursal = @i_sucursal and vt_usuario = @i_usuario and vt_maquina = @i_maquina AND vt_tipo_prod = 3 and vt_tipo_guia not in(0) AND idClave = @count)              
  begin              
  --sp_help TEMP_guia              
  declare @w_guia varchar(20), @w_tipo_guia int              
  select               
  @w_guia = vt_numguia              
  ,@w_tipo_guia = vt_tipo_guia              
  FROM TEMPDet_pos               
  where vt_compania = @i_compania               
  and vt_sucursal = @i_sucursal               
  and vt_usuario = @i_usuario               
  and vt_maquina = @i_maquina              
  AND idClave = @count              
                  
  select @w_fecha_guia = gr_fehaemisi              
  from LOGISTICA.dbo.tbCop_CabcGuiaRemision              
  where gr_comapinia = @i_compania              
  and  gr_numguia = @w_guia              
  
  if @w_tipo_guia = 1              
  begin              
  update LOGISTICA.dbo.tb_planificador               
  set pla_generada = 'S'              
  , pla_secuencial = @w_idFactura              
  , pla_factgenerador = @w_idFactura              
  where pla_compania =@i_compania              
  and pla_numguia = @w_guia              
  end              
  if @w_tipo_guia = 2          
  begin              
  update LOGISTICA.dbo.tb_planificador               
  set pla_generada = 'S'              
  , pla_secuencial = @w_idFactura              
  where pla_compania =@i_compania              
  and pla_numguia = @w_guia              
  end              
  if @w_tipo_guia = 3              
  begin              
  update LOGISTICA.dbo.tb_planificador               
  set pla_factstand = @w_idFactura              
  where pla_compania =@i_compania              
  and pla_numguia = @w_guia              
  end              
  if @w_tipo_guia = 4              
  begin              
  update LOGISTICA.dbo.tb_planificador               
  set pla_factgenerador = @w_idFactura              
  where pla_compania =@i_compania              
  and pla_numguia = @w_guia              
  end                      
  end              
  */            
            
  Begin Try 
  -- select * from Dia_tbdet_pos             
   insert into Dia_tbdet_pos              
   (                    
   vt_compania,   vt_sucursal, vt_numero ,     vt_secuencia                     
   , vt_codigo_producto, vt_cantidad, vt_valor  ,  vt_descuento                     
   , vt_iva,    vt_estado,  vt_costo,  vt_costo_Promedio                    
   , vt_S_iva,   vt_pesoNeto, vt_pesoBruto, vt_PorDescuento              
   , vt_TotalDescuento, vt_lote,  vt_cliente,  vt_detalle              
   , vt_detalle2,   vt_numguia,  vt_ruta,     vt_generador              
   , vt_centro,      vt_tipo_guia, vt_hacienda, vt_fecha_guia                  
   , vt_medico , vt_por_ret, vt_tipo_p,vt_turno                      
   )               
   -- select * from tbproducto            
   -- select * from TEMPDet_pos_dos   
   -- select * from TEMPDet_pos         
   select               
   a.vt_compania,   a.vt_sucursal, @w_idFactura, a.vt_secuencia                      
   , a.vt_codigo_producto, vt_cantidad, vt_valor  ,  a.vt_descuento                     
   , a.vt_iva,    a.vt_estado,              
   case when pr_manejaDocificacion = 'N' then vt_costo            
   else (select sum(x.vt_costo) FROM TEMPDet_pos_dos x              
   where             
   x.vt_compania = a.vt_compania             
   and x.vt_sucursal = a.vt_sucursal             
   and x.vt_usuario = a.vt_usuario             
   and x.vt_maquina = a.vt_maquina             
   and x.vt_codigo_producto  = a.vt_codigo_producto  )            
   end            
   ,case when pr_manejaDocificacion = 'N' then vt_costo_Promedio            
   else (select sum(x.vt_costo_Promedio) FROM TEMPDet_pos_dos x              
   where             
   x.vt_compania = a.vt_compania             
   and x.vt_sucursal = a.vt_sucursal             
   and x.vt_usuario = a.vt_usuario             
   and x.vt_maquina = a.vt_maquina             
   and x.vt_codigo_producto  = a.vt_codigo_producto  )            
   end                           
   , vt_S_iva,   vt_pesoNeto, vt_pesoBruto, vt_PorDescuento              
   , vt_TotalDescuento, vt_lote,  a.vt_cliente,  vt_detalle              
   , vt_detalle2,   vt_numguia,  vt_ruta,     vt_generador              
   , a.vt_centro,      vt_tipo_guia, vt_hacienda, @w_fecha_guia                 
   , vt_medico , vt_por_ret , vt_tipo_prod, b.vt_turno            
   FROM TEMPDet_pos a, TEMPCab_pos b, tbproducto c               
   where a.vt_compania = b.vt_compania
   and a.vt_sucursal = b.vt_sucursal
   and a.vt_usuario = b.vt_usuario
   and a.vt_maquina = b.vt_maquina 
   and a.vt_compania = pr_compania            
   and a.vt_codigo_producto = pr_clave             
   and a.vt_compania = @i_compania               
   and a.vt_sucursal = @i_sucursal               
   and a.vt_usuario = @i_usuario               
   and a.vt_maquina = @i_maquina         
   AND idClave = @count              
  End try              
  Begin Catch             
   set @o_idfactura = 0            
   --set @o_iddevolucion =0            
   set @o_error =1              
   set @o_mensaje = 'Error al Registrar detalle de factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
   rollback tran fact              
   return 0               
  End Catch              
 set @count = @count + 1              
 end              
               
 --Begin Try              
 -- -- select * from tbINV_Parametro_Cbte_Vta          
 -- update tbINV_Parametro_Cbte_Vta                
 -- set pc_numero_actual = @w_idFacturaImp                
 -- from tbINV_Parametro_Cbte_Vta                
 -- where pc_compania = @i_compania                
 -- AND pc_sucursal=@i_sucursal                
 -- and  pc_tipo  =   @w_tipocbteVta            
 -- and pc_ptoemi =  @w_ptoemi     
 -- and pc_TipoEmision = @w_tipogen            
 --End try              
 --Begin Catch              
 -- set @o_idfactura = 0            
 -- set @o_iddevolucion =0            
 -- set @o_error =1              
 -- set @o_mensaje = 'Error al actualizar Secuencia Interno de factura.....'              
 -- rollback tran fact              
 -- return 0              
 --End Catch              
            
 --SET NOCOUNT ON             
  
 declare @w_NotaC as float  
     
 if exists( Select 1 from TEMPDet_FormaCobro   
 where cb_compania = @i_compania   
 and cb_sucursal = @i_sucursal   
 and cb_usuario = @i_usuario   
 and cb_maquina = @i_maquina)             
 begin              
  set @NoReg = ISNULL((SELECT COUNT(*) FROM TEMPDet_FormaCobro where cb_compania = @i_compania and cb_sucursal = @i_sucursal and cb_usuario = @i_usuario and cb_maquina = @i_maquina ),0)              
  set @NoReg = isnull(@NoReg ,0)              
  set @count = 1   
             
  while @NoReg > 0 and  @count <=@NoReg              
  begin              
   set @w_tipo_cobro = 0          
   set @w_fact_devo = 0          
   set @w_tipo_nc = 0          
   set @w_valor = 0     
   set @w_NotaC = 0      
   set @w_idnc=0   
     
   select @w_tipo_cobro  = cb_cod_formaPago            
   ,@w_fact_devo = isnull(cb_fact_devo,0)            
   ,@w_tipo_nc = isnull(cb_tipNota,0)            
   , @w_valor = isnull(cb_valor,0)   
   ,@w_NotaC =isnull(cb_nota,0)              
   FROM TEMPDet_FormaCobro               
   where cb_compania = @i_compania               
   and cb_sucursal = @i_sucursal               
   and cb_usuario = @i_usuario               
   and cb_maquina = @i_maquina               
   AND cb_secuencia = @count            
                         
   --**************************************************************************************************************************              
   --******************************* Asignacion de Secuencia Cobro ********************************************************************              
   --**************************************************************************************************************************              
   Begin Try              
    update tbSucursal                              
    set                                
    su_consecutivo_recibo   = isnull(su_consecutivo_recibo,0)+1                             
    where su_compania  =@i_compania                  
    and su_clave       =@i_sucursal               
   End try              
   Begin Catch               
    set @o_idfactura = 0            
    --set @o_iddevolucion =0            
    set @o_error =1              
    set @o_mensaje = 'Error Al Generar Secuencial Cobro Factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
    rollback tran fact               
    return 0              
   End Catch               
               
   select @w_idcobro  = su_consecutivo_recibo                         
   from tbSucursal                            
   where su_compania  =@i_compania                     and su_clave       =@i_sucursal               
  
   if @w_tipo_cobro in (10)            
   begin             
    ---- 3er begin            
    ----**************************************************************************************************************************              
    ----******************************* Asignacion de Secuencia Devolucion ********************************************************************              
    ----**************************************************************************************************************************              
    --Begin Try              
    -- update tbSucursal        
    -- set                                
    -- su_consecu_deventa   = isnull(su_consecu_deventa,0)+1                             
    -- where su_compania  =@i_compania                  
    -- and su_clave       =@i_sucursal               
    --End try              
    --Begin Catch               
    -- set @o_idfactura = 0            
    -- set @o_iddevolucion =0            
    -- set @o_error =1              
    -- set @o_mensaje = 'Error Al Generar Secuencial Interno de Dev Factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
    -- rollback tran fact               
    -- return 0              
    --End Catch               
                 
    --select @w_iddevolucion_fact  = su_consecu_deventa                             
    --from tbSucursal                            
    --where su_compania  =@i_compania                  
    --and su_clave       =@i_sucursal               
  
    --select @w_gen_nc = su_GeneraNCxDevVent             
    --from tbsucursal             
    --where su_compania = @i_compania              
    --and su_compania = @i_sucursal              
            
    --Begin Try              
    -- execute spFac_MantDevoluciones              
    -- @opcion    ='ING_CAB'            
    -- , @compania   = @i_compania            
    -- , @sucursal  = @i_sucursal            
    -- , @factura   = @w_fact_devo             
    -- , @nrecibo   = @w_idcobro            
    -- , @pwinumero = @w_idFactura            
    -- , @num_devo  = @w_iddevolucion_fact            
    -- , @gereanc  = @w_gen_nc               
    --End try              
    --Begin Catch               
    -- set @o_idfactura = 0            
    -- set @o_iddevolucion =0            
    -- set @o_error =1              
    -- set @o_mensaje = 'Error Al Generar Cab Dev Factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
    -- rollback tran fact               
    -- return 0              
    --End Catch               
            
    --Begin Try              
    -- execute spFac_MantDevo_Det              
    -- @opcion    ='ING_DET'            
    -- , @compania   = @i_compania            
    -- , @sucursal  = @i_sucursal            
    -- , @factura   = @w_fact_devo            
    --End try              
    --Begin Catch               
    -- set @o_idfactura = 0            
    -- set @o_iddevolucion =0            
    -- set @o_error =1              
    -- set @o_mensaje = 'Error Al Generar Det Dev Factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
    -- rollback tran fact               
    -- return 0              
    --End Catch    
      
    set @w_idnc = @w_NotaC  
      
    begin try  
     update  tbdet_NotaDC set Nt_Saldo=0     
     ,Nt_estado='I'    
     ,Nt_factura=@w_idFactura    
     where    Nt_compania    =@i_compania    
     and     Nt_Sucursal     =@i_sucursal    
     and     Nt_Tipo         ='C'    
     and     Nt_Numero       =@w_idnc    
    End try              
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'Error Al disminuir saldo de nota de crédito.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact               
     return 0              
    End Catch               
   end              
       
   if @w_tipo_cobro in (11)           
   begin                       
    select @w_ctanc =isnull(tn_cuenta,'')              
    , @w_observacion_nc  = isnull(tn_descripcion,'')            
    FROM  tbTipNotas              
    WHERE tn_compania = @i_compania             
    AND tn_Tipo = 'C'             
    AND tn_clave = @w_tipo_nc     
             
    set @w_observacion_nc  = @w_observacion_nc + @w_observacion       
           
    select @w_idnc = isnull(max(nt_numero),0)+1               
    from tbdet_NotaDC              
    where nt_compania=@i_compania              
    and nt_sucursal=@i_sucursal   
                
    -- select * from tbdet_NotaDC where nt_sucursal = 3            
    select @w_empleado = em_clave               
    from tbempleado               
    where em_codigo = @i_usuario            
    and em_compania = @i_compania   
                
    set @w_empleado = isnull(@w_empleado,1)      
            
    Begin Try            
     INSERT INTO tbdet_NotaDC               
     ( Nt_compania    , Nt_Sucursal   , Nt_Tipo              
     , Nt_Numero      , Nt_Cliente    , Nt_Factura              
     , Nt_Valor       , Nt_Concepto   , Nt_Responsable              
     , Nt_Fecha       , Nt_Estado     , Nt_Contabilizado              
     , Nt_Motivo      , Nt_iva        , Nt_UltUsuario              
     , Nt_Fact_Origen , Nt_Cuenta     , Nt_Saldo, Nt_fechaVenci       
     )              
     select             
     cb_compania,  cb_sucursal,   'C'            
     , @w_idnc,  vt_cliente,     @w_idFactura            
     , cb_valor,  @w_observacion_nc,@w_empleado            
     , cb_fecha_cobro, cb_estado,  'N'            
     , @w_tipo_nc, 0,    @i_usuario            
     , @w_fact_devo,@w_ctanc,0,cb_fecha_cobro            
     from TEMPDet_FormaCobro , TEMPcab_pos            
     where cb_compania = vt_compania            
     and cb_sucursal  = vt_sucursal            
     and cb_usuario = vt_usuario            
     and cb_maquina = vt_maquina            
     and cb_compania = @i_compania               
     and cb_sucursal = @i_sucursal               
     and cb_usuario = @i_usuario               
     and cb_maquina = @i_maquina               
     AND cb_secuencia = @count              
    End try              
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'Error Al Generar N/C Retencion .....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact               
     return 0              
    End Catch               
   end    
                       
   if @w_tipo_cobro not in (0)            
   begin                   
    set @w_idnc = isnull(@w_idnc,0)    
              
    select @w_secuencia = isnull(cb_secuencia,0) + 1            
    from tbDet_FormaCobro               
    where               
    cb_compania     = @i_compania                
    and cb_sucursal = @i_sucursal                
    and cb_numero   = @w_idFactura              
    set @w_secuencia = isnull(@w_secuencia,1)             
                  
    Begin Try            
     insert into tbDet_FormaCobro              
     (              
     cb_compania   ,cb_sucursal   ,cb_numero       ,cb_tipo                      
     ,cb_secuencia   ,cb_cod_formaPago  ,cb_fecha_cobro    ,cb_fecha_cancela               
     ,cb_valor          ,cb_Banco          ,cb_cuenta         ,cb_NumCheque                   
     ,cb_estado         ,cb_contabilizado  ,cb_num_tarj       ,cb_des_tarj                    
     ,cb_tipo_abono     ,cb_Cobrador       ,cb_EDocumento     ,cb_Recibo               
     ,cb_Depositado      ,cb_usuario               
     ,cb_observacion  , cb_tipNota  ,cb_nota  ,cb_cobroMasivo              
     ,cb_fechaHoraTrans                        
     )              
     -- select * FROM TEMPDet_FormaCobro            
     select             
     cb_compania, cb_sucursal, @w_idFactura, 'F'            
     ,@w_secuencia, cb_cod_formaPago,  cb_fecha_cobro,  cb_fecha_cancela             
     ,cb_valor,  cb_Banco,  cb_cuenta,   cb_NumCheque            
     ,cb_estado,  'N',   cb_num_tarj,  cb_des_tarj            
     ,cb_tipo_abono, cb_Cobrador, cb_EDocumento,  @w_idcobro            
     ,'N',   cb_usuario            
     ,' COBRO ' + @w_observacion ,   isnull(cb_tipNota,0),@w_idnc,0            
     ,getdate()            
     from TEMPDet_FormaCobro             
     where cb_compania = @i_compania               
     and cb_sucursal = @i_sucursal               
     and cb_usuario = @i_usuario               
     and cb_maquina = @i_maquina               
     AND cb_secuencia = @count              
    End try              
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0                    
     set @o_error =1              
     set @o_mensaje = 'Error Al Guardar Cobro de factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact               
     return 0              
    End Catch     
               
    Begin Try            
     update Dia_tbcab_pos              
     set  vt_saldo = vt_saldo - @w_valor            
     where vt_compania = @i_compania             
     and  vt_codigo_sucursal = @i_sucursal            
     and  vt_numero = @w_idFactura                
    End try      
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'Error Al Actualizar Saldo de factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact               
     return 0              
    End Catch       
              
    Begin Try            
     update Dia_tbcab_pos              
     set  vt_estado = 'P'            
     where vt_compania = @i_compania             
     and  vt_codigo_sucursal = @i_sucursal            
     and  vt_numero = @w_idFactura                
     and  vt_saldo <= 0            
    End try              
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'Error Al Actualizar Estado x Saldo de factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact               
     return 0              
    End Catch                         
   end            
             
			 --------------------------TIPO DE COBRO 18 DE UNA----------------------------
    if @w_tipo_cobro not in (18)            
   begin                   
    set @w_idnc = isnull(@w_idnc,0)    
              
    select @w_secuencia = isnull(cb_secuencia,0) + 1            
    from tbDet_FormaCobro               
    where               
    cb_compania     = @i_compania                
    and cb_sucursal = @i_sucursal                
    and cb_numero   = @w_idFactura              
    set @w_secuencia = isnull(@w_secuencia,1)             
                  
    Begin Try            
     insert into tbDet_FormaCobro              
     (              
     cb_compania   ,cb_sucursal   ,cb_numero       ,cb_tipo                      
     ,cb_secuencia   ,cb_cod_formaPago  ,cb_fecha_cobro    ,cb_fecha_cancela               
     ,cb_valor          ,cb_Banco          ,cb_cuenta         ,cb_NumCheque                   
     ,cb_estado         ,cb_contabilizado  ,cb_num_tarj       ,cb_des_tarj                    
     ,cb_tipo_abono     ,cb_Cobrador       ,cb_EDocumento     ,cb_Recibo               
     ,cb_Depositado      ,cb_usuario               
     ,cb_observacion  , cb_tipNota  ,cb_nota  ,cb_cobroMasivo              
     ,cb_fechaHoraTrans                        
     )              
     -- select * FROM TEMPDet_FormaCobro            
     select             
     cb_compania, cb_sucursal, @w_idFactura, 'F'            
     ,@w_secuencia, cb_cod_formaPago,  cb_fecha_cobro,  cb_fecha_cancela             
     ,cb_valor,  cb_Banco,  cb_cuenta,   cb_NumCheque            
     ,cb_estado,  'N',   cb_num_tarj,  cb_des_tarj            
     ,cb_tipo_abono, cb_Cobrador, cb_EDocumento,  @w_idcobro            
     ,'S',   cb_usuario            
     ,' COBRO ' + @w_observacion ,   isnull(cb_tipNota,0),@w_idnc,0            
     ,getdate()            
     from TEMPDet_FormaCobro             
     where cb_compania = @i_compania               
     and cb_sucursal = @i_sucursal               
     and cb_usuario = @i_usuario               
     and cb_maquina = @i_maquina               
     AND cb_secuencia = @count              
    End try              
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0                    
     set @o_error =1              
     set @o_mensaje = 'Error Al Guardar Cobro de factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact               
     return 0              
    End Catch     
               
    Begin Try            
     update Dia_tbcab_pos              
     set  vt_saldo = vt_saldo - @w_valor            
     where vt_compania = @i_compania             
     and  vt_codigo_sucursal = @i_sucursal            
     and  vt_numero = @w_idFactura                
    End try      
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'Error Al Actualizar Saldo de factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact               
     return 0              
    End Catch       
              
    Begin Try            
     update Dia_tbcab_pos              
     set  vt_estado = 'P'            
     where vt_compania = @i_compania             
     and  vt_codigo_sucursal = @i_sucursal            
     and  vt_numero = @w_idFactura                
     and  vt_saldo <= 0            
    End try              
    Begin Catch               
     set @o_idfactura = 0            
     --set @o_iddevolucion =0            
     set @o_error =1              
     set @o_mensaje = 'Error Al Actualizar Estado x Saldo de factura.....' + ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'              
     rollback tran fact               
     return 0              
    End Catch                         
   end            
     -----------------------------------------------------------------------------------                  
  set @count = @count  + 1              
  end                     
 end                       
                      
 --set @w_iddevolucion_fact= isnull(@w_iddevolucion_fact,0)            
 set @o_idfactura = @w_idFactura            
 --set @o_iddevolucion = @w_iddevolucion_fact            
 set @o_error =0              
 set @o_mensaje = 'Generación de Movimiento Ok, Número de Venta es ' +  @w_idSeriefact + '/' +right('000000000' + CAST( @w_idFacturaImp as nvarchar),9) +' Registrado Correctamente.....Ok'              
 SET XACT_ABORT OFF                
  commit tran fact              
 --rollback tran fact     
 ALTER TABLE tbINV_Parametro_Cbte_Vta ENABLE  TRIGGER ALL               
 --ALTER TABLE tbProdsucu ENABLE  TRIGGER ALL                 
 --select @w_error ,@w_mensaje              
 return 0              
         
              
              
              
