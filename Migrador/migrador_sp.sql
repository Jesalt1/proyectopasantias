USE [SIACDB]
GO
/****** Object:  StoredProcedure [dbo].[SpMigradorParqueos]    Script Date: 18/12/2023 08:54:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 exec SpMigradorParqueos_MEYPAR '20231128'
*/
ALTER procedure [dbo].[SpMigradorParqueos]        
(        	 
@i_FInicio		date=null,        
@i_Intervalo	int=2,        
@o_error		int=0 output,                    
@o_mensaje		nvarchar(600)=''output,
@i_servidor     varchar(50),
@i_usuario		varchar(50),
@i_maquina		varchar(50)
)        
as 
begin
	declare @w_FIntervalo date
	declare @existeduplicado int,@@est char(3),@@pemision char(3),@@secuencia char(9)
	, @w_sucursal int
	set @w_sucursal = 50
	set @existeduplicado=0
	
	set @w_FIntervalo = dateadd(day,-@i_Intervalo,@i_FInicio)
	
	------------------NUMEROS DE LOTES------------------
	declare @Lote int
	set @Lote =(SELECT COALESCE(MAX(LOTE), 0) + 1 FROM FAC_Car_Electronicas)


	------------------------------------------
	-- select * from tb_facturas_offline
	---------------------------------------------------------------------------------------------------
	------------------- Depura de Informacion 
	---------------------------------------------------------------------------------------------------
	delete tb_facturas_offline
	where  convert(int, isnull(PTO_EMI,0)) >= 50 

	delete FAC_MALECON
	where convert(int, isnull(PTO_EMI,0)) >= 50 
	and  convert(nvarchar(30),fecha_emision,112)  = @i_FInicio

------------------------------------TOMANDO ULTIMO REGISTRO------------------
	DECLARE @conteoRegistrosHoy INT;

-- Obtén el conteo de registros con la fecha de hoy
	SELECT @conteoRegistrosHoy = COUNT(*)
	FROM FAC_Car_Electronicas
	WHERE CAST(Fecha AS DATE) = CAST(GETDATE() AS DATE);
----------------------------------------------------------------------------
--SI SOLO HAY UN REGISTRO DEL DIA CAMBIAR FECHA A UN DIA MENOS PARA TREAER REGISTROS FALTANTES-
IF(@conteoRegistrosHoy<1)
BEGIN
	SET @i_FInicio =  CAST((select MAX(fecha) from FAC_Car_Electronicas) AS DATE)
END
----------------------------------------------------------------------------------------------
	-- select * from FAC_MALECON
	INSERT INTO FAC_MALECON(
		SECUENCIA,				AMBIENTE,				TIPO_EMISION
		,RAZON_SOCIAL,			NOMBRE_COMERCIAL,		RUC
		,CLAVE_ACCESO,			COD_DOC,				ESTAB
		,PTO_EMI,				SECUENCIAL,				DIR_MATRIZ
		,FECHA_EMISION,			DIR_ESTABLECIMIENTO,	CONTRIBUYENTE_ESPECIAL
		,OBLIGADO_CONTABILIDAD,	TIPO_IDENTIFICACION_COMPRADOR,RAZON_SOCIAL_COMPRADOR
		,IDENTIFICACION_COMPRADOR,CODIGO_PRINCIPAL,		DESCRIPCION
		,CANTIDAD,				PRECIO_UNITARIO,		TOTAL_SIN_IMPUESTOS
		,IMPUESTO_CODIGO,		IMPUESTO_CODIGO_PORCENTAJE,IMPUESTO_TARIFA
		,IMPUESTO_BASE_IMPONIBLE,IMPUESTO_VALOR,		VALOR_TOTAL
		,FORMA_PAGO,			ADICIONAL_ENTRADA,		ADICIONAL_SALIDA
		,ADICIONAL_TICKET,		ADICIONAL_EMAIL)
	select SECUENCIA,		AMBIENTE,				TIPO_EMISION
	,RAZON_SOCIAL,			NOMBRE_COMERCIAL,		RUC
	,CLAVE_ACCESO,			COD_DOC,				RIGHT('000'+ltrim(rtrim(ESTAB)),3)
	,RIGHT('000' + ltrim(rtrim(PTO_EMI)),3) ,RIGHT('000000000' + ltrim(rtrim(SECUENCIAL)),9),DIR_MATRIZ
  	,convert(nvarchar(30),fecha_emision,112),			DIR_ESTABLECIMIENTO,	CONTRIBUYENTE_ESPECIAL
	,OBLIGADO_CONTABILIDAD,	TIPO_IDENTIFICACION_COMPRADOR,RAZON_SOCIAL_COMPRADOR
	,IDENTIFICACION_COMPRADOR,CODIGO_PRINCIPAL,		DESCRIPCION
	,CANTIDAD,				PRECIO_UNITARIO,		TOTAL_SIN_IMPUESTOS
	,IMPUESTO_CODIGO,		IMPUESTO_CODIGO_PORCENTAJE,IMPUESTO_TARIFA
	,IMPUESTO_BASE_IMPONIBLE,IMPUESTO_VALOR,		VALOR_TOTAL
	,FORMA_PAGO,			ADICIONAL_ENTRADA,		   ADICIONAL_SALIDA
	,ADICIONAL_TICKET,		ADICIONAL_EMAIL
	--select *
	from [192.168.1.246].[FEM].[dbo].[FAC_MALECON] with (nolock)
	where fecha_emision is not null
		--and fecha_emision>=@w_FIntervalo
		--and fecha_emision<=@i_FInicio
	and  convert(nvarchar(30),fecha_emision,112)  = @i_FInicio
	--and (RIGHT('000'+ltrim(rtrim(ESTAB)),3) + RIGHT('000' + ltrim(rtrim(PTO_EMI)),3) + RIGHT('000000000' + ltrim(rtrim(SECUENCIAL)),9))
	--not in 
	--(select (RIGHT('000'+ltrim(rtrim(ESTAB)),3) + RIGHT('000' + ltrim(rtrim(PTO_EMI)),3) + RIGHT('000000000' + ltrim(rtrim(SECUENCIAL)),9))  collate Latin1_General_CI_AI
	--from FAC_MALECON 
	--where convert(nvarchar(30),fecha_emision,112)  = @i_FInicio
	--)

		--select * from tb_facturas_offline
	INSERT INTO tb_facturas_offline(
	SEC,					AMBIENTE,				TIPO_EMISION
	,RAZON_SOCIAL,			NOMBRE_COMERCIAL,		RUC
	,CLAVE_ACCESO,			COD_DOC,				ESTAB
	,PTO_EMI,				SECUENCIAL,				DIR_MATRIZ
	,FECHA_EMISION,			DIR_ESTABLECIMIENTO,	CONTRIBUYENTE_ESPECIAL
	,OBLIGADO_CONTABILIDAD,	TIPO_IDENTIFICACION_COMPRADOR,RAZON_SOCIAL_COMPRADOR
	,IDENTIFICACION_COMPRADOR,CODIGO_PRINCIPAL,		DESCRIPCION
	,CANTIDAD,				PRECIO_UNITARIO,		TOTAL_SIN_IMPUESTOS
	,IMPUESTO_CODIGO,		IMPUESTO_CODIGO_PORCENTAJE,IMPUESTO_TARIFA
	,IMPUESTO_BASE_IMPONIBLE,IMPUESTO_VALOR,		FORMA_PAGO
	,ADICIONAL_ENTRADA,		ADICIONAL_SALIDA,		ADICIONAL_TICKET
	,ADICIONAL_EMAIL)
	select id,		AMBIENTE,				TIPO_EMISION
	,RAZON_SOCIAL,			NOMBRE_COMERCIAL,		RUC
	,'' CLAVE_ACCESO,			COD_DOC,				RIGHT('000'+ltrim(rtrim(ESTAB)),3)
	,RIGHT('000' + ltrim(rtrim(PTO_EMI)),3) ,RIGHT('000000000' + ltrim(rtrim(SECUENCIAL)),9),DIR_MATRIZ
  	,convert(nvarchar(30),fecha_emision,112),			DIR_ESTABLECIMIENTO,	CONTRIBUYENTE_ESPECIAL
	,OBLIGADO_CONTABILIDAD,	TIPO_IDENTIFICACION_COMPRADOR,RAZON_SOCIAL_COMPRADOR
	,IDENTIFICACION_COMPRADOR,CODIGO_PRINCIPAL,		DESCRIPCION
	,CANTIDAD,				PRECIO_UNITARIO,		TOTAL_SIN_IMPUESTOS
	,IMPUESTO_CODIGO,		IMPUESTO_CODIGO_PORCENTAJE,IMPUESTO_TARIFA
	,IMPUESTO_BASE_IMPONIBLE,IMPUESTO_VALOR,		FORMA_PAGO
	,ADICIONAL_ENTRADA,		ADICIONAL_SALIDA,		ADICIONAL_TICKET
	,ADICIONAL_EMAIL
	--select *
	from FAC_MALECON 
	where fecha_emision is not null
	and  convert(nvarchar(30),fecha_emision,112)  = @i_FInicio

	--from MEYPAR.FEM.dbo.FAC_MALECON (nolock)
		--where fecha_emision is not null
		--and fecha_emision>=@w_FIntervalo
		--and fecha_emision<=@i_FInicio
		--and  convert(nvarchar(30),fecha_emision,112)  = @i_FInicio
		--and fecha_emision>='20180201'
		--and fecha_emision<='20180228'
	
	----------------------Elimina facturas ya existentes ---------------------------------
	delete tb_facturas_offline where 
	 convert(int, isnull(PTO_EMI,0)) >= 50 
	and ESTAB + PTO_EMI +'-'+ SECUENCIAL in (select vt_serie+'-'+vt_numeroext from tbcab_pos 
											Where vt_compania=1 and vt_codigo_sucursal= @w_sucursal
												and vt_fecha>=@w_FIntervalo
												and vt_fecha<=@i_FInicio
											)
											
	-------------------------------limpiar repetidos -------------------------------
	--declare @existeduplicado int,@@est char(3),@@pemision char(3),@@secuencia char(9)
	select top 1 @existeduplicado=COUNT(sec),@@est=ESTAB,@@pemision=PTO_EMI
				,@@secuencia=SECUENCIAL from tb_facturas_offline
				where  convert(int, isnull(PTO_EMI,0)) >= 50
	group by ESTAB,PTO_EMI,SECUENCIAL
	having (COUNT(SEC)>1)
	
	if isnull(@existeduplicado,0)>0
	begin
	  while isnull(@existeduplicado,0)>0
	  begin
	    update tb_facturas_offline set SEC=SEC*-1 where  convert(int, isnull(PTO_EMI,0)) >= 50
		and ESTAB=@@est and PTO_EMI=@@pemision
													and SECUENCIAL=@@secuencia
													and IDENTIFICACION_COMPRADOR='9999999999999'
													
		delete top (@existeduplicado-1) from tb_facturas_offline where  convert(int, isnull(PTO_EMI,0)) >= 50 
		and ESTAB=@@est and PTO_EMI=@@pemision
													and SECUENCIAL=@@secuencia
		
		update tb_facturas_offline set SEC=case when SEC>0 then SEC else SEC*-1 end where  convert(int, isnull(PTO_EMI,0)) >= 50 
		and  ESTAB=@@est and PTO_EMI=@@pemision
													and SECUENCIAL=@@secuencia
							
		set @existeduplicado=0
		
		select top 1 @existeduplicado=COUNT(sec),@@est=ESTAB,@@pemision=PTO_EMI
				,@@secuencia=SECUENCIAL from tb_facturas_offline
				where  convert(int, isnull(PTO_EMI,0)) >= 50 
		group by ESTAB,PTO_EMI,SECUENCIAL
		having (COUNT(SEC)>1)
	  end
	end
			
	---------------------------------------------------------------------------------------------------
	------------------- Continua el proceso normal
	---------------------------------------------------------------------------------------------------

	SET NOCOUNT ON 
	SET XACT_ABORT ON                 
	begin tran 
	
	begin try	
		insert into tbcab_pos
		(
		vt_compania,	vt_codigo_sucursal,		vt_numero,			vt_fecha,			vt_vendedor,              
		vt_cliente,		vt_base_coniva,			vt_base_siniva,		vt_subtotal,		vt_descuento,              
		vt_iva,			vt_total,				vt_estado,			vt_contabilizado,	vt_tipo_venta,              
		vt_plazo,		vt_fech_venc,			vt_desc_pront_pago,	vt_saldo,			vt_numeroext,		             
		vt_Observacion,	vt_tipo,				vt_tipoDoc,			vt_Doc,				vt_contabilizadoInve,              
		vt_usuario,		vt_FechaHoraReg,		vt_hora,			vt_tipo_cobro,		vt_serie,  		            
		vt_ptoemision,	vt_TipoGen,				vt_Autorizada,		vt_ruc,				vt_nombre_cliente,              		
		vt_telefono,	vt_direccion,			vt_correo,			vt_migrado,			vt_pasado,			
		vt_Emision,		vt_autorizacion,		vt_AutElect,		vt_NumAutElect,		vt_t_venta,            
		vt_idiva,vt_PIva, vt_ClaveAcceso, 
		--Nuevo campo lotes
		vt_NumGuiaExt)   					  
		select 
		1,				@w_sucursal,			sec,				fecha_emision,		0,
		0,				case  when impuesto_valor>0 then impuesto_base_imponible else 0 end,	
		case  when impuesto_valor=0 then impuesto_base_imponible else 0 end,
		total_sin_impuestos, 0,
		impuesto_valor,	(total_sin_impuestos+impuesto_valor),	'V',	'N',				'CON',						
		0,				fecha_emision,			0,					(total_sin_impuestos+impuesto_valor),				secuencial,
		'FACT. # ' + estab+pto_emi+'-'+secuencial,				'VT',				1,					0,		'N',		
		'SISTEMAS',		adicional_salida,		convert(nvarchar,adicional_salida,108),		0,		estab+pto_emi,			
		1,				4,						'N',				LTRIM(RTRIM(identificacion_comprador)),	LTRIM(RTRIM(upper(razon_social_comprador))),			
		'',				''
		,	case when 	LTRIM(RTRIM(identificacion_comprador)) ='9999999999999' then '' else LTRIM(RTRIM(adicional_email)) end
		,	'S',				1,
		tipo_emision,	'',						'',					'',					1,
		impuesto_codigo_porcentaje, impuesto_tarifa, LTRIM(RTRIM(CLAVE_ACCESO)),
		--Nuevo campo Lotes
		@Lote			          
		from  tb_facturas_offline 
		where  
		convert(int, isnull(PTO_EMI,0)) >= 50 
		and fecha_emision is not null
		--and fecha_emision>=@w_FIntervalo
		and fecha_emision=@i_FInicio
		--and sec not in(select vt_numero from tbcab_pos where vt_compania=1               
		--and vt_codigo_sucursal=1 and vt_fecha>=@w_FIntervalo and vt_fecha<=@i_FInicio) 
       
		--select * from tbdet_pos
		insert into tbdet_pos
		(
		vt_compania,		vt_sucursal,		vt_numero,		vt_secuencia,
		vt_codigo_producto,	vt_cantidad,		vt_valor,		vt_descuento,             
		vt_iva,				vt_estado,			vt_costo,		vt_costo_Promedio,             
		vt_S_iva,			vt_tipo_p,			vt_detalle2,	vt_codigo_prod,             
		vt_nombre_producto
		)
		select
		1,					@w_sucursal,					sec,			1,
		1,					cantidad,			precio_unitario,	0,
		impuesto_valor,			'V',				0,				0
		,case 
		when impuesto_valor > 0 then 'S' 
		else 'N' end,		2,					'',				LTRIM(RTRIM(codigo_principal)),
		LTRIM(RTRIM(upper(descripcion)))				
		from  tb_facturas_offline
		where  convert(int, isnull(PTO_EMI,0)) >= 50 
		and fecha_emision is not null
		and fecha_emision=@i_FInicio
		--and sec not in(select tbdet_pos.vt_numero from tbdet_pos inner join tbcab_pos on tbcab_pos.vt_compania = tbdet_pos.vt_compania 
		--and tbcab_pos.vt_codigo_sucursal = tbdet_pos.vt_sucursal 
		--and tbcab_pos.vt_numero = tbdet_pos.vt_numero  		
		--where tbdet_pos.vt_compania=1               
		--and tbdet_pos.vt_sucursal=1
		--and tbcab_pos.vt_fecha>=@w_FIntervalo and tbcab_pos.vt_fecha<=@i_FInicio) 	

		--select * from FAC_Car_Electronicas
		
--NUMERO DE REGISTROS
	declare @no_registros int
		SELECT @no_registros = COUNT(*)
		FROM tb_facturas_offline
		where  convert(int, isnull(PTO_EMI,0)) >= 50 
		and fecha_emision is not null
		--and fecha_emision>=@w_FIntervalo
		--and fecha_emision=@i_FInicio
		--select @no_registros

-----------------------

-----INSERTAR DATOS A TABLA DE AUDITORIA
		insert into FAC_Car_Electronicas (Compania, Procesos, Servidor,  No_registros, Fecha, Hora, lote, usuario, maquina, Fecha_parametro)
		values 
		( 1,
		 'EXTRACCION DE FACTURA',
		 @i_servidor,
		 @no_registros,
		 CONVERT(DATE, GETDATE()),
		 FORMAT(GETDATE(), 'HH:mm:ss'),
		 ISNULL((SELECT MAX(LOTE) FROM FAC_Car_Electronicas) + 1, 0),
		 @i_usuario,
		 @i_maquina,
		 @i_FInicio
		 )
--------------------------------------------------------------------

	end try        
	Begin Catch                          
		set @o_error =1                      
		set @o_mensaje = 'Error Al migrar datos de factura del servidor de parqueos...'+ ERROR_MESSAGE() + ' en la línea ' + CONVERT(NVARCHAR(255), ERROR_LINE() ) + '.'                      
		rollback tran Parq           
		print @o_mensaje                    
		return 0                      
	End Catch           

	set @o_error =0                      
	set @o_mensaje = 'Datos Migrados Correctamente'
	commit tran Parq  
	                     
	SET XACT_ABORT OFF                        
	print @o_mensaje     
end      

