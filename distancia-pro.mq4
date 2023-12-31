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
input int      apt_media=21;// Media
input double   apt_fator_lotes=0.03;// Factor para lotes = 0.03

// Varaibles staticas
static bool se_ha_operado_en_barra_actual=false;

static double media = 0;// Precio de media actual
static double media_2 = 0;// Precio de media actual
static double max_lots=0;
static int max_num_entradas_consecutivas=0;
static int mayores_de_30_entradas_consecutivas=0;
static int mayores_de_25_entradas_consecutivas=0;
static int mayores_de_20_entradas_consecutivas=0;

static int tipo_grupo_entradas=0;// 1=compras, 2=ventas
static int num_entradas_consecutivas=0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    // Si se ha reiniciado el programa tenemos que checkear las entradas
    get_numero_entradas_consecutivas();
    get_tipo_entradas();
    // TODO: Analizar aquí se_ha_operado_en_barra_actual

  return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

    Print("mayores_de_30_entradas_consecutivas = " + (string)mayores_de_30_entradas_consecutivas );
    Print("mayores_de_25_entradas_consecutivas = " + (string)mayores_de_25_entradas_consecutivas );
    Print("mayores_de_20_entradas_consecutivas = " + (string)mayores_de_20_entradas_consecutivas );
    Print("max_num_entradas_consecutivas = " + (string)max_num_entradas_consecutivas );
 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  if(Bars<apt_media+1)
    return;

//    @TODO: Tenemos que sacar un tamaño de barra medio para poner un minimo de separacion con la media para realizar cerrar_entrada_mas_lejana

//    @TODO: Para eliminar entradas antiguas se verifica que la entrada esté por debajo, no se eliminan entradas que sean mejores que la que vayamos a colocar  :)

// @TODO: Vamos a sacar los lots con el nuevo sistema, see get_lots_new()


//Time[0];

//  Print("Time[0] = " + (string)Time[0] );
//  Print("Time[1] = " + (string)Time[1] );
//  get_last_trade_time();


    if(IsNewBarOnChart()) {
        se_ha_operado_en_barra_actual = false;
        max_lots=(AccountBalance()*apt_fator_lotes)/100;
    }

    // Analizamos todos los parametros que necesitamos
    media=nor1(iMA(NULL,0,apt_media,0,MODE_EMA,PRICE_CLOSE,0));

    // Grupo de compras
    if(tipo_grupo_entradas==1 && nor0(Bid)>=nor0(media)) {
        cerrar_operaciones_compra();
    }
    // Grupo de ventas
    if(tipo_grupo_entradas==2 && nor0(Ask)<=nor0(media)) {
        cerrar_operaciones_venta();
    }

    if(!se_ha_operado_en_barra_actual) {
        // Compras
        if(nor0(Open[0])<nor0(media)) {
            compra();
        }
        // Ventas
        if(nor0(Open[0])>nor0(media)) {
            venta();
        }
    }
    if(num_entradas_consecutivas>max_num_entradas_consecutivas) {
        max_num_entradas_consecutivas=num_entradas_consecutivas;
    }
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Funcion de compra
//+------------------------------------------------------------------+
void get_last_trade_time() {
    if(OrdersTotal()>0) {
        if(OrderSelect(OrdersTotal()-1, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
            Print("OrderOpenTime() = " + (string)OrderOpenTime() );
        }
    }
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Funcion de compra
//+------------------------------------------------------------------+
void get_tipo_entradas() {
    if(OrdersTotal()>0) {
        for(int i = OrdersTotal()-1; i >= 0; i--) {
            // Compras m1
            if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
                if(OrderType() == OP_BUY) {
                    tipo_grupo_entradas=1;// Compras
                }else if(OrderType() == OP_SELL) {
                    tipo_grupo_entradas=2;// Ventas
                }
            }
        }
    }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion de compra
//+------------------------------------------------------------------+
void get_numero_entradas_consecutivas() {
    num_entradas_consecutivas = OrdersTotal();
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion de compra
//+------------------------------------------------------------------+
bool compra() {
  bool check_order = false;
  int order_id = 0;
  double lots = get_lots();
//  Print("lots = " + (string)lots );
  if(check_podemos_operar(lots)) {
    order_id = OrderSend(Symbol(),OP_BUY,lots,Ask,5,0,0,"Diferencia",MAGIC,0,Green);
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
//| Funcion de venta
//+------------------------------------------------------------------+
bool venta() {
  bool check_order = false;
  int order_id = 0;
  double lots = get_lots();
//  Print("lots = " + (string)lots );
  if(check_podemos_operar(lots)) {
    order_id = OrderSend(Symbol(),OP_SELL,lots,Bid,5,0,0,"Diferencia",MAGIC,0,Green);
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
//| Funcion que devulve los lotes que nos quedan hasta el call out, no la estamos usando ahora
//+------------------------------------------------------------------+
double get_lots_new() {
  double lots = false;
  //double availableMarginCall = AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
  double lots_to_call = (AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL))/MarketInfo(Symbol(),MODE_MARGINREQUIRED);


  return NormalizeDouble(lots_to_call*0.80,Digits);
  //return 0.1;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas
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
    lots=nor1(max_lots*3);// max_lots*0,6
  }
  if(num_entradas_consecutivas>40) {
    lots=nor1(max_lots*3);// max_lots*0,6
  }


//  double lots=nor1(max_lots*0.1);
//  if(lots==0) {
//    lots=0.1;
//  }
//  if(num_entradas_consecutivas>10) {
//    lots=nor1(max_lots*0.2);// max_lots*0,6
//  }
//  if(num_entradas_consecutivas>20) {
//    lots=nor1(max_lots*0.4);// max_lots*0,6
//  }
//  if(num_entradas_consecutivas>30) {
//    lots=nor1(max_lots*1);// max_lots*0,6
//  }
//  if(num_entradas_consecutivas>40) {
//    lots=nor1(max_lots*2);// max_lots*0,6
//  }

//  double lots=0.1;
//  if(num_entradas_consecutivas>5) {
//    lots=0.2;// max_lots*0,6
//  }
//  if(num_entradas_consecutivas>10) {
//    lots=0.4;// max_lots*0,6
//  }
//  if(num_entradas_consecutivas>15) {
//    lots=0.6;// max_lots*0,6
//  }
//  if(num_entradas_consecutivas>20) {
//    lots=1;// max_lots*0,6
//  }
//  if(num_entradas_consecutivas>25) {
//    lots=1.2;// max_lots*0,6
//  }
//  if(num_entradas_consecutivas>30) {
//    lots=1.5;// max_lots*0,6
//  }
  return lots;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas
//+------------------------------------------------------------------+
void cerrar_operaciones_venta() {
	// Vamos a cerrar las compras
  if(OrdersTotal()>0) {
    for(int i = OrdersTotal()-1; i >= 0; i--) {
      // Compras m1
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
      	bool check_close = OrderClose(OrderTicket(),OrderLots(),Bid,5);
		    if(check_close==false) {
		      Alert("OrderSelect failed");
		    } else {
		    	// Todo correcto....
		    	tipo_grupo_entradas=0;
		    }
      }
	}
  }
    if(num_entradas_consecutivas>30) {
        mayores_de_30_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>25) {
        mayores_de_25_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>20) {
        mayores_de_20_entradas_consecutivas++;
    }
	num_entradas_consecutivas=0;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas
//+------------------------------------------------------------------+
void cerrar_operaciones_compra() {
	// Vamos a cerrar las compras
  if(OrdersTotal()>0) {
    for(int i = OrdersTotal()-1; i >= 0; i--) {
      // Compras m1
      if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
      	bool check_close = OrderClose(OrderTicket(),OrderLots(),Ask,5);
		    if(check_close==false) {
		      Alert("OrderSelect failed");
		    } else {
		    	// Todo correcto....
		    	tipo_grupo_entradas=0;
		    }
      }
		}
	}
    if(num_entradas_consecutivas>30) {
        mayores_de_30_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>25) {
        mayores_de_25_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>20) {
        mayores_de_20_entradas_consecutivas++;
    }
	num_entradas_consecutivas=0;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas
//+------------------------------------------------------------------+
void cerrar_entrada_mas_lejana() {
	if(OrdersTotal()>0) {
        for(int i=0; i<=OrdersTotal()-1; i++) {


            Print("i = " + (string)i);
            Print("OrdersTotal() = " + (string)OrdersTotal());
            // Compras m1
            if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
            // Compras
                if(OrderType() == OP_BUY) {
            Print("OrderTicket()() = " + (string)OrderTicket());
                    bool check_close = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),5);
                        if(check_close==false) {
                            Alert("OrderClose failed");
                            break;
                        } else {
                            // Todo correcto....
                            break;
                        }
                }
                // Ventas
                if(OrderType() == OP_SELL) {
            Print("OrderTicket()() = " + (string)OrderTicket());
                    bool check_close = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),5);
                        if(check_close==false) {
                            Alert("OrderClose failed");
                            break;
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
//| Funcion que devuelve true si hay una nueva barra
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
//| Funcion que checkea si hay operaciones abieras
//+------------------------------------------------------------------+
bool check_podemos_operar(double lots) {
  bool result = true;
  //double availableMarginCall = AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
  //double lots_to_call = (AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL))/MarketInfo(Symbol(),MODE_MARGINREQUIRED);

  // Implementar aquí abailable margin mejor %%%%%
  while(((AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL))/MarketInfo(Symbol(),MODE_MARGINREQUIRED)<lots)) {
      if(OrdersTotal()<15) {
        break;
      }
    cerrar_entrada_mas_lejana();
  }

  if((AccountFreeMargin()-AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL))/MarketInfo(Symbol(),MODE_MARGINREQUIRED)<lots) {
  	result = false;
  }
  return result;
 }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 2 decimales
//+------------------------------------------------------------------+
double nor2(double value_to_normalize) {
  return NormalizeDouble(value_to_normalize,2);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 1 decimales
//+------------------------------------------------------------------+
double nor1(double value_to_normalize) {
  return NormalizeDouble(value_to_normalize,1);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que normalñiza doubles con 0 decimales
//+------------------------------------------------------------------+
double nor0(double value_to_normalize) { 
  return NormalizeDouble(value_to_normalize,0);
}
//+------------------------------------------------------------------+



