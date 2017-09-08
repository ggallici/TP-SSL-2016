%{
#include <stdio.h>
#include "flex.h"

#define YYERROR_VERBOSE

extern int num_linea;
extern int contador_errores;
%}

%code provides
{
	static int contador_temporales = 0;
	static char * diccionario[1000];
	
	void yyerror(const char *);
	
	void inicializarDiccionario();
	int estaEnDiccionario(char *);	
	void ponerEnDiccionario(char *);
	
	void comenzar();
	void terminar();
	void leerId();
	void escribirExpresion();
	void chequear();
	
	char * generarInfijo(char *, char*, char *);
	char * generarInfijoNegativo();
	char * asignar();
	
	void generarNuevoTemporal();
	char * getTemporal();
}

%defines "bison.h"
%output "bison.c"

%token INICIO FIN LEER ESCRIBIR IDENTIFICADOR CONSTANTE '(' ')' ',' ';' ASIGNACION ":="
%define api.value.type {char *}

%left '+' '-'
%left '*' '/'
%precedence NEG


%%
programa : {comenzar();} INICIO listaSentencias FIN {terminar();} {if (contador_errores) YYABORT;}
		 ;
		 
listaSentencias : sentencia 
				| sentencia listaSentencias
				;
				
sentencia : identificador ":=" expresion {$$ = asignar($1);} ';'
		  | LEER '(' listaIdentificadores ')' ';'
		  | ESCRIBIR '(' listaExpresiones ')' ';'
		  | error ';'
		  ;
		  
listaIdentificadores : identificador {leerId($1);}
					 | listaIdentificadores ',' identificador {leerId($3);}
					 ;
					 
identificador : IDENTIFICADOR {chequear($1);}
			  ;
			  
listaExpresiones : expresion {escribirExpresion($1);}
				 | listaExpresiones ',' expresion {escribirExpresion($3);}
				 ;
				 
expresion : expresion '+' expresion {$$ = generarInfijo($1,$2,$3);}
		  | expresion '-' expresion {$$ = generarInfijo($1,$2,$3);}
		  | expresion '*' expresion {$$ = generarInfijo($1,$2,$3);}
		  | expresion '/' expresion {$$ = generarInfijo($1,$2,$3);}
		  | identificador
		  | CONSTANTE
		  | '(' expresion ')' {$$ = $2;}
		  | '-' expresion %prec NEG {$$ = generarInfijoNegativo($2);}
		  ;
%%





/*FUNCIONES PRINCIPALES*/

int main() 
{
	inicializarDiccionario();
	
	switch(yyparse())
	{
		case 0:
			printf("Compilación finalizada con éxito\n"); break;
		case 1:
			printf("Errores de compilación\n"); break;
		case 2:
			printf("Memoria insuficiente\n"); break;
	}
	
	printf("Cantidad de errores lexicos: %d - Cantidad de errores sintacticos: %d\n", contador_errores , yynerrs);
	
	return 0;
}

void yyerror(const char *msj)
{
	printf("línea #%d: %s\n", num_linea, msj);
}





/*MANEJO DE DICCIONARIO*/

void inicializarDiccionario()
{
	int i;
	
	for(i = 0; i < 1000; i++)
	{
		diccionario[i] = "";
	}
}
int estaEnDiccionario(char * identificador)
{
	int i;
	
	for(i = 0; i < 1000; i++)
	{
		if(strcmp(diccionario[i], identificador) == 0)
			return 1;
	}
	
	return 0;
}
void ponerEnDiccionario(char * identificador)
{
	int i;
	
	for(i = 0; i < 1000; i++)
	{
		if(strcmp(diccionario[i], "") == 0)
		{
			diccionario[i] = identificador;
			break;
		}
	}
}





/*RUTINAS SEMANTICAS*/

void comenzar()
{
	printf("Load rtlib,,\n");
}
void terminar()
{
	printf("Stop ,,\n");
}
char * asignar(char * derecha)
{
	char * temp = getTemporal();
	
	printf("Store %s,%s\n", temp, derecha);
	
	return temp;
}

void leerId(char * derecha)
{
	printf("Read %s,Integer,\n", derecha);
}

void escribirExpresion(char * derecha)
{
	printf("Write %s,Integer,\n", derecha);
}

void chequear(char * identificador)
{
	if(!estaEnDiccionario(identificador))
	{
		ponerEnDiccionario(identificador);
		
		printf("Declare %s,Integer,\n", identificador);
	}
}

char * generarInfijo(char * izquierda, char * operador, char * derecha)
{
	char op = *operador;

	generarNuevoTemporal();
	
	char * temp = getTemporal();
	
	printf("Declare %s,Integer,\n", temp);
	
	switch(op)
	{
		case '+':
			 printf("ADD %s, %s, %s\n", izquierda, derecha, temp); break;
		case '-':
			printf("SUBS %s, %s, %s\n", izquierda, derecha, temp); break;
		case '*': 
			printf("MULT %s, %s, %s\n", izquierda, derecha, temp); break;
		case '/':
			 printf("DIV %s, %s, %s\n", izquierda, derecha, temp); break;
	}
	
	return temp;
}

char * generarInfijoNegativo(char * derecha)
{
	generarNuevoTemporal();
	
	char * temp = getTemporal();
	
	printf("Declare %s,Integer,\n", temp);
	
	printf("INV %s,,%s\n",derecha, temp);
	
	return temp;
}





/*MANEJO DE VARIABLES TEMPORALES*/

void generarNuevoTemporal()
{
	contador_temporales++;
}

char * getTemporal()
{
	char * aux;
	
	aux = (char *) malloc(9);
	
	sprintf(aux,"Temp&%d", contador_temporales);
	
	return aux;
}
