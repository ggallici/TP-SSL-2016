%{
#include <stdio.h>
#include "bison.h"

int num_linea = 1;
int contador_errores = 0;
char * error = "";

void mostrarErrorLexico(const char *);
%}

%option header-file="flex.h"
%option outfile="flex.c"


letra [a-zA-Z]
digito [0-9]
constante {digito}{digito}*
identificador {letra}({letra}|{digito})*
comentario "//".*
espacio [ \t]
caracterMal [[:punct:]]{-}["+""-""*""/""("")"","";" \t":=""//".*]
constanteMal {constante}{letra}({letra}|{digito})*
identificadorMal {identificador}{caracterMal}({caracterMal}|{letra}|{digito})*


%%
"inicio"							{yylval = strdup(yytext); return INICIO;}
"fin"								{yylval = strdup(yytext); return FIN;}
"leer"								{yylval = strdup(yytext); return LEER;}
"escribir"							{yylval = strdup(yytext); return ESCRIBIR;}
{identificador}						{yylval = strdup(yytext); return IDENTIFICADOR;}
{constante}							{yylval = strdup(yytext); return CONSTANTE;}
"+"									{yylval = strdup(yytext); return '+';}
"-"									{yylval = strdup(yytext); return '-';}
"*"									{yylval = strdup(yytext); return '*';}
"/"									{yylval = strdup(yytext); return '/';}
"("									{yylval = strdup(yytext); return '(';}
")"									{yylval = strdup(yytext); return ')';}
","									{yylval = strdup(yytext); return ',';}
";"									{yylval = strdup(yytext); return ';';}
":="								{yylval = strdup(yytext); return ASIGNACION;}
{comentario}						/*SE COME COMENTARIOS */
{espacio}							/*SE COME ESPACIOS Y TABULACIONES */
{caracterMal}						{++contador_errores; error = "Caracter invalido\n"; mostrarErrorLexico(error);}
{constanteMal}						{++contador_errores; error = "Constante mal formada\n"; mostrarErrorLexico(error);}
{identificadorMal}					{++contador_errores; error = "Identificador invalido\n"; mostrarErrorLexico(error);}
\n			  						{++num_linea;}
%%


void mostrarErrorLexico(const char *msj)
{
	printf("Linea #%d:, Error Léxico: %s", num_linea, msj);
}