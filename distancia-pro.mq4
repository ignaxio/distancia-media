//+------------------------------------------------------------------+
//|                                              Distancia 4h en m30 |
//|                                                    Ignacio Farre |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ignacio Farre"
#property link      ""
#property version   "2.01"
#property strict

#define MAGIC  201

//--- input parameters
input int       apt_media=21;// Media
input int       apt_intervalo_aumento=10;// Intervalo de aumento
input int       apt_min_order_open=15;// Entradas minimas abiertas
input bool      apt_subidas_multiplicadas=false; // Subidas multiplicadas

input bool      apt_ventas=true; // Incluir ventas
input bool      apt_compras=true; // Incluir compras

// Varaibles staticas
static bool se_ha_operado_en_barra_actual=false;
static bool se_puede_operar_margin_level=true;

static double media = 0;// Precio de media actual
static double media_2 = 0;// Precio de media actual
static double max_lots=0;

static int max_num_entradas_consecutivas=0;
static int mayores_de_70_entradas_consecutivas=0;
static int mayores_de_60_entradas_consecutivas=0;
static int mayores_de_50_entradas_consecutivas=0;
static int mayores_de_40_entradas_consecutivas=0;
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

    Print("mayores_de_70_entradas_consecutivas = " + (string)mayores_de_70_entradas_consecutivas );
    Print("mayores_de_60_entradas_consecutivas = " + (string)mayores_de_60_entradas_consecutivas );
    Print("mayores_de_50_entradas_consecutivas = " + (string)mayores_de_50_entradas_consecutivas );
    Print("mayores_de_40_entradas_consecutivas = " + (string)mayores_de_40_entradas_consecutivas );
    Print("mayores_de_30_entradas_consecutivas = " + (string)mayores_de_30_entradas_consecutivas );
    Print("mayores_de_25_entradas_consecutivas = " + (string)mayores_de_25_entradas_consecutivas );
    Print("mayores_de_20_entradas_consecutivas = " + (string)mayores_de_20_entradas_consecutivas );
    Print("max_num_entradas_consecutivas = " + (string)max_num_entradas_consecutivas );
    Print("Account #",AccountNumber(), " leverage is ", AccountLeverage());
 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  if(Bars<apt_media+1)
    return;

// IMPORTANTE ----------------------------------------------------------------------------
// @TODO: Tenemos que sacar las num_entradas_consecutivas calculando el tiempo que hace que no toca la media
// @TODO: se_ha_operado_en_barra_actual sacar variable con el tiempo, estas dos mejoras son importante para poder reseterar el programa sin problema


//Time[0];

//  Print("Time[0] = " + (string)Time[0] );
//  Print("Time[1] = " + (string)Time[1] );
//  get_last_trade_time();

// string MarginLevel;
//   string CommentString=StringConcatenate("Account Number = ",AccountNumber(),"n");
//   CommentString=StringConcatenate(CommentString,"AccountCurrency=",AccountCurrency(),"n");
//   CommentString=StringConcatenate(CommentString,"AccountCompany=",AccountCompany(),"n");
//   CommentString=StringConcatenate(CommentString,"AccountName=",AccountName(),"n");
//   CommentString=StringConcatenate(CommentString,"AccountServer=",AccountServer(),"n");
//   CommentString=StringConcatenate(CommentString,"AccountStopoutLevel=",AccountStopoutLevel(),"n");
//   CommentString=StringConcatenate(CommentString,"AccountStopoutMode=",AccountStopoutMode(),"n");
//   CommentString=StringConcatenate(CommentString,"AccountBalance()=",AccountBalance(),"n");
//   CommentString=StringConcatenate(CommentString,"AccountMargin=",AccountMargin(),"n");
//   CommentString=StringConcatenate(CommentString,"AccountEquity=",AccountEquity(),"n");
//
//   if (AccountMargin()>0) MarginLevel=StringConcatenate("MarginLevel=",DoubleToStr(AccountEquity()/AccountMargin()*100,2),"% ");
//   else MarginLevel="MarginLevel=N/A";
//
//   CommentString=StringConcatenate(CommentString,MarginLevel);
//   Comment(CommentString);


// printf("ACCOUNT_BALANCE =  %G",AccountInfoDouble(ACCOUNT_BALANCE));
//   printf("ACCOUNT_CREDIT =  %G",AccountInfoDouble(ACCOUNT_CREDIT));
//   printf("ACCOUNT_PROFIT =  %G",AccountInfoDouble(ACCOUNT_PROFIT));
//   printf("ACCOUNT_EQUITY =  %G",AccountInfoDouble(ACCOUNT_EQUITY));
//   printf("ACCOUNT_MARGIN =  %G",AccountInfoDouble(ACCOUNT_MARGIN));
//   printf("ACCOUNT_MARGIN_FREE =  %G",AccountInfoDouble(ACCOUNT_FREEMARGIN));
//   printf("ACCOUNT_MARGIN_LEVEL =  %G",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
//   printf("ACCOUNT_MARGIN_SO_CALL = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
//   printf("ACCOUNT_MARGIN_SO_SO = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));



 // TODO: Al 50% el programa peta, asi que vamos a eliminar entradas cuando esté al 60%?????
//equinidad - margen libre = accountMargen


//    Print("AccountFreeMargin() = " + (string)AccountFreeMargin() );
//    if(AccountMargin()) {
//        Print("MarginLevel = " + (string)((AccountEquity()/AccountMargin())*100) );
//        if((AccountEquity()/AccountMargin())*100 < 100) {
//            se_puede_operar_margin_level=false;
//        } else {
//            se_puede_operar_margin_level=true;
//        }
//
//
//        while((AccountEquity()/AccountMargin())*100 < 60) {
//            cerrar_entrada_mas_lejana();
//        }
//
//
//    }else if(AccountInfoDouble(ACCOUNT_FREEMARGIN)) {
//        double accountMargen = AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_FREEMARGIN);
//        double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
//        Print("MarginLevel = " + (string)((accountEquity/accountMargen)*100) );
//        if((accountEquity/accountMargen)*100 < 100) {
//            se_puede_operar_margin_level=false;
//        } else {
//            se_puede_operar_margin_level=true;
//        }
//    }






    if(IsNewBarOnChart()) {
        se_ha_operado_en_barra_actual = false;
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
        if(apt_compras && nor0(Open[0])<nor0(media)) {
            compra();
        }
        // Ventas
        if(apt_ventas && nor0(Open[0])>nor0(media)) {
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
// TODO: esto no va bien, hay que contar el tiempo que hace que toco la media y sacar los calculos de barras que llevamos desde que toco la media
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

    double initial_lots=MarketInfo(Symbol(),MODE_MINLOT);
    double lots=initial_lots;
    if(apt_subidas_multiplicadas) {
        if(num_entradas_consecutivas>apt_intervalo_aumento*1) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*2) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*3) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*4) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*5) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*6) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*7) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*8) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*9) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*10) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*11) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*12) {
            lots=lots*2;
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*13) {
            lots=lots*2;
        }
    } else {
        if(num_entradas_consecutivas>apt_intervalo_aumento*1) {
            lots=initial_lots*2;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*2) {
            lots=initial_lots*3;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*3) {
            lots=initial_lots*4;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*4) {
            lots=initial_lots*5;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*5) {
            lots=initial_lots*6;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*6) {
            lots=initial_lots*7;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*7) {
            lots=initial_lots*8;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*8) {
            lots=initial_lots*9;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*9) {
            lots=initial_lots*10;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*10) {
            lots=initial_lots*11;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*11) {
            lots=initial_lots*12;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*12) {
            lots=initial_lots*13;// max_lots*0,6
        }
        if(num_entradas_consecutivas>apt_intervalo_aumento*13) {
            lots=initial_lots*14;// max_lots*0,6
        }
    }


// TODO; Pedir credito y poner diferentes cantidades en diferentes temporalidades en sp500 y nas100

// TODO: Pedir 20.000; Con esto podemos poner 10 diferentes cuentas, algunas pueden petar pero otras duplican.....

// @TODO: sp500 en 1 hora 1000 euros en media de 80 en 2 meses duplica......
// @TODO: sp500 en 1 hora 20000 euros en media de 120 en 9 meses duplica......
// @TODO: NDS100 en 1 hora 20000 euros en media de 100 en 9 meses 53.000 ganancias......



  return lots;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas
//+------------------------------------------------------------------+
void cerrar_operaciones_venta() {
	// Vamos a cerrar las ventas
    if(OrdersTotal()>0) {
        for(int i = OrdersTotal()-1; i >= 0; i--) {
            // Compras m1
            if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
                bool check_close = OrderClose(OrderTicket(),OrderLots(),Ask,5);
                if(check_close==false) {
                    Alert("OrderClose failed");
                } else {
                    // Todo correcto....
                }
            }
        }
    }

    if(num_entradas_consecutivas>70) {
        mayores_de_70_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>60) {
        mayores_de_60_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>50) {
        mayores_de_50_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>40) {
        mayores_de_40_entradas_consecutivas++;
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
    // Se se han cerrado todas las entradas ponemos el grupo de entradas a 0
    if(OrdersTotal() == 0) {
        tipo_grupo_entradas=0;
	    num_entradas_consecutivas=0;
    }
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
                bool check_close = OrderClose(OrderTicket(),OrderLots(),Bid,5);
                if(check_close==false) {
                    Alert("OrderClose failed");
                } else {
                    // Todo correcto....
                }
            }
        }
    }

    if(num_entradas_consecutivas>70) {
        mayores_de_70_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>60) {
        mayores_de_60_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>50) {
        mayores_de_50_entradas_consecutivas++;
    }
    if(num_entradas_consecutivas>40) {
        mayores_de_40_entradas_consecutivas++;
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

    // Se se han cerrado todas las entradas ponemos el grupo de entradas a 0
    if(OrdersTotal() == 0) {
        tipo_grupo_entradas=0;
	    num_entradas_consecutivas=0;
    }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Funcion que chequea las operaciones abiertas
//+------------------------------------------------------------------+
void cerrar_entrada_mas_lejana() {
	if(OrdersTotal()>0) {
        for(int i=0; i<=OrdersTotal()-1; i++) {
            // Compras m1
            if(OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == MAGIC) {
            // Compras
                if(OrderType() == OP_BUY) {
                    bool check_close = OrderClose(OrderTicket(),OrderLots(),Bid,5);
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
                    bool check_close = OrderClose(OrderTicket(),OrderLots(),Ask,5);
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
      if(OrdersTotal()<apt_min_order_open) {
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



