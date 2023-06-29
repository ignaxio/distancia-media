//+------------------------------------------------------------------+
//|                                              Distancia 4h en m30 |
//|                                                    Ignacio Farre |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ignacio Farre"
#property link      ""
#property version   "2.00"
#property strict

#define MAGIC  20188888

//--- input parameters
input int      apt_media=30;// Media 
input int      apt_media_2=30;// Media de tendencia

// Varaibles staticas
static bool se_ha_operado_en_barra_actual=false;
static double spread = 0;// Precio de spread actual

static double media = 0;// Precio de media actual
static double media_2 = 0;// Precio de media actual
static double max_lots=0;

static int tipo_grupo_entradas=0;// 1=compras, 2=ventas
static int num_entradas_consecutivas=0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  if(Bars<apt_media_2+1)
    return;
            
  if(IsNewBarOnChart()) {
    se_ha_operado_en_barra_actual = false;   
  }     
 	
  if(num_entradas_consecutivas==0) {
    // Vamnos a calcular el factor de lotes por cash
    double fator_lotes = 0.03;
    double account_balance = AccountBalance();
    max_lots=(account_balance*fator_lotes)/100;
    
    //Print("max_lots" + (string)max_lots);
  }
  
  // Analizamos todos los parametros que necesitamos   
  media=nor1(iMA(NULL,0,apt_media,0,MODE_EMA,PRICE_CLOSE,1));
  media_2=nor1(iMA(NULL,0,apt_media_2,0,MODE_EMA,PRICE_CLOSE,1));
  double precio_apertura =Open[0];
  
  double percio_ask_actual = nor1(MarketInfo(Symbol(), MODE_ASK)); // precio de compra
  double percio_bid_actual = nor1(MarketInfo(Symbol(), MODE_BID)); // Precio de venta
  
  //Print("percio_ask_actual = " + (string)percio_ask_actual );
  //Print("media = " + (string)media );
  //Print("tipo_grupo_entradas = " + (string)tipo_grupo_entradas );
  // Chequeamos las operaciones abiertas en cada tick si hay operaciones
  // Grupo de compras
  if(tipo_grupo_entradas==1 && percio_bid_actual>media) {
    cerrar_operaciones_compra(); 
  }
  // Grupo de ventas
  if(tipo_grupo_entradas==2 && percio_ask_actual<media) {
    cerrar_operaciones_venta(); 
  }
  
  // La media es solo al empezar, despues tiene que seguir con la estrategia
  //if(num_entradas_consecutivas==0) {  	
	 // // Compras
	 // if(nor0(precio_apertura)<nor0(media) && nor0(media)>nor0(media_2)) {
	 // 	compra();
	 // }
	 // // Ventas
	 // if(nor0(precio_apertura)>nor0(media) && nor0(media)<nor0(media_2)) {
	 // 	venta();
	 // }
  //} else {  	
	  // Compras
	  if(nor0(precio_apertura)<nor0(media)) {
	  	compra();
	  }
	  // Ventas
	  if(nor0(precio_apertura)>nor0(media)) {
	  	venta();
	  }
  //}
  
  
   
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion de compra                                                                |
//+------------------------------------------------------------------+
bool compra() {
  bool check_order = false;
  int order_id = 0;
  double lots = get_lots();
  Print("lots = " + (string)lots );
  if(check_podemos_operar(lots)) {
    order_id = OrderSend(Symbol(),OP_BUY,lots,Ask,10,0,0,"Diferencia",MAGIC,0,Green);
    if(!order_id) {
      Print("Order send error ",GetLastError());
    } else {      
      se_ha_operado_en_barra_actual=true;
      check_order=true;  
      tipo_grupo_entradas=1;// Compras
      num_entradas_consecutivas++;      
    }
  }
  return check_order;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion de venta                                                                |
//+------------------------------------------------------------------+
bool venta() {
  bool check_order = false;
  int order_id = 0;
  double lots = get_lots();
  Print("lots = " + (string)lots );
  if(check_podemos_operar(lots)) {
    order_id = OrderSend(Symbol(),OP_SELL,lots,Bid,10,0,0,"Diferencia",MAGIC,0,Green);
    if(!order_id) {
      Print("Order send error ",GetLastError());
    } else {    
      se_ha_operado_en_barra_actual=true;
      check_order=true; 
      tipo_grupo_entradas=2;// Ventas
      num_entradas_consecutivas++;
    }
  }
  return check_order;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas                                                               |
//+------------------------------------------------------------------+
double get_lots() {	
  double lots=nor1(max_lots*0.1);
  if(lots==0) {
    lots=0.1;
  }
  if(num_entradas_consecutivas>10) {
    lots=nor1(max_lots*0.4);// max_lots*0,6
  }
  if(num_entradas_consecutivas>20) {
    lots=nor1(max_lots*1.2);// max_lots*0,6
  }
  if(num_entradas_consecutivas>30) {
    lots=nor1(max_lots*2.4);// max_lots*0,6
  }
  if(num_entradas_consecutivas>40) {
    lots=nor1(max_lots*6);// max_lots*0,6
  }
  return lots;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas                                                               |
//+------------------------------------------------------------------+
void cerrar_operaciones_venta() {
	// Vamos a cerrar las compras	
  if(OrdersTotal()>0) {
    for(int i = OrdersTotal()-1; i >= 0; i--) {    
      // Compras m1
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
      	bool check_close = OrderClose(OrderTicket(),OrderLots(),Bid,10);
		    if(check_close==false) {
		      Alert("OrderSelect failed");
		    } else {
		    	// Todo correcto....
		    	tipo_grupo_entradas=0;
		    }
      }
		}
	}
	num_entradas_consecutivas=0;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas                                                               |
//+------------------------------------------------------------------+
void cerrar_operaciones_compra() {
	// Vamos a cerrar las compras	
  if(OrdersTotal()>0) {
    for(int i = OrdersTotal()-1; i >= 0; i--) {    
      // Compras m1
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
      	bool check_close = OrderClose(OrderTicket(),OrderLots(),Ask,10);
		    if(check_close==false) {
		      Alert("OrderSelect failed");
		    } else {
		    	// Todo correcto....
		    	tipo_grupo_entradas=0;
		    }
      }
		}
	}
	num_entradas_consecutivas=0;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas                                                               |
//+------------------------------------------------------------------+
void cerrar_entrada_mas_lejana() {  
int count=0;
	if(OrdersTotal()>0) {
    for(int i=0; i<=OrdersTotal()-1; i++) {   
    //for(int i = OrdersTotal()-1; i >= 0; i--) {    
      // Compras m1
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
      // Compras
      	if(tipo_grupo_entradas==1) {
	      	bool check_close = OrderClose(OrderTicket(),OrderLots(),Ask,10);
			    if(check_close==false) {
			      Alert("OrderSelect failed");
			    } else {
			    	// Todo correcto....
			    	break;
			    }
      	}      	
      	// Ventas
      	if(tipo_grupo_entradas==2) {
	      	bool check_close = OrderClose(OrderTicket(),OrderLots(),Bid,10);
			    if(check_close==false) {
			      Alert("OrderSelect failed");
			    } else {
			    	// Todo correcto....
			    	break;
			    }
      	}
      }
		}
	}
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Funcion que devuelve true si hay una nueva barra                                                                 |
//+------------------------------------------------------------------+
bool IsNewBarOnChart() {
  bool new_candle = false;
  static datetime lastbar;
  datetime curbar = (datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
  
  if(lastbar != curbar) {
    lastbar = curbar;
    new_candle = true;
  }
  return new_candle;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que checkea si hay operaciones abieras                                                                |
//+------------------------------------------------------------------+
bool check_podemos_operar(double lots) {
  bool result = false;    
  //double availableMarginCall = AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);  
  //double lots_to_call = (AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL))/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
    
  // Implementar aquí abailable margin mejor %%%%%
  while((AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL))/MarketInfo(Symbol(),MODE_MARGINREQUIRED)<lots) {
    cerrar_entrada_mas_lejana();
  }  
  if(!se_ha_operado_en_barra_actual) {
    result = true;  
  }
  //if(availableMarginCall<1000) {
  //	result = false;    
  //}
  return result;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 2 decimales                                                       |
//+------------------------------------------------------------------+
double nor2(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,2);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 1 decimales                                                       |
//+------------------------------------------------------------------+
double nor1(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,1);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 0 decimales                                                       |
//+------------------------------------------------------------------+
double nor0(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,0);
}
//+------------------------------------------------------------------+



