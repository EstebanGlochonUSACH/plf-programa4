%{
#include <stdio.h>
#define YY_DECL int yylex()
#include "y.tab.h"

int return_simbolo(char simbol);
%}

%option noyywrap
%option yylineno

%s PI
%s MOD
%s SQR
%s CUR
%s EXP
%s LN
%s LOG
%s SGN
%s INT
%s FIX
%s FRAC
%s ROUND
%s CHARX
%s CEOF

SIMBOLOS     "+"|"-"|":"|"/"|"^"|"|"|"!"|"("|")"|"="

%%

"x"                                    {BEGIN(CHARX);}
<CHARX><<EOF>>                         {BEGIN(INITIAL); return O_MULT;}
<CHARX>[a-zA-Z0-9]+                    {BEGIN(INITIAL); return IDENTIFICADOR;}
<CHARX>(.|\n)                          {BEGIN(INITIAL); unput(yytext[0]); return O_MULT;}
<INITIAL>"PI"                          {BEGIN(PI);}
<PI><<EOF>>                            {BEGIN(INITIAL); return CONST_PI;}
<PI>[a-zA-Z0-9]+                       {BEGIN(INITIAL); return IDENTIFICADOR;}
<PI>(.|\n)                             {BEGIN(INITIAL); unput(yytext[0]); return CONST_PI;}
<INITIAL>"MOD"                         {BEGIN(MOD);}
<MOD><<EOF>>                           {BEGIN(INITIAL); return O_MOD;}
<MOD>[a-zA-Z0-9]+                      {BEGIN(INITIAL); return IDENTIFICADOR;}
<MOD>(.|\n)                            {BEGIN(INITIAL); unput(yytext[0]); return O_MOD;}
<INITIAL>"SQR"                         {BEGIN(SQR);}
<SQR><<EOF>>                           {BEGIN(INITIAL); return F_SQR;}
<SQR>[a-zA-Z0-9]+                      {BEGIN(INITIAL); return IDENTIFICADOR;}
<SQR>(.|\n)                            {BEGIN(INITIAL); unput(yytext[0]); return F_SQR;}
<INITIAL>"CUR"                         {BEGIN(CUR);}
<CUR><<EOF>>                           {BEGIN(INITIAL); return F_CUR;}
<CUR>[a-zA-Z0-9]+                      {BEGIN(INITIAL); return IDENTIFICADOR;}
<CUR>(.|\n)                            {BEGIN(INITIAL); unput(yytext[0]); return F_CUR;}
<INITIAL>"EXP"                         {BEGIN(EXP);}
<EXP><<EOF>>                           {BEGIN(INITIAL); return F_EXP;}
<EXP>[a-zA-Z0-9]+                      {BEGIN(INITIAL); return IDENTIFICADOR;}
<EXP>(.|\n)                            {BEGIN(INITIAL); unput(yytext[0]); return F_EXP;}
<INITIAL>"LN"                          {BEGIN(LN);}
<LN><<EOF>>                            {BEGIN(INITIAL); return F_LN;}
<LN>[a-zA-Z0-9]+                       {BEGIN(INITIAL); return IDENTIFICADOR;}
<LN>(.|\n)                             {BEGIN(INITIAL); unput(yytext[0]); return F_LN;}
<INITIAL>"LOG"                         {BEGIN(LOG);}
<LOG><<EOF>>                           {BEGIN(INITIAL); return F_LOG;}
<LOG>[a-zA-Z0-9]+                      {BEGIN(INITIAL); return IDENTIFICADOR;}
<LOG>(.|\n)                            {BEGIN(INITIAL); unput(yytext[0]); return F_LOG;}
<INITIAL>"SGN"                         {BEGIN(SGN);}
<SGN><<EOF>>                           {BEGIN(INITIAL); return F_SGN;}
<SGN>[a-zA-Z0-9]+                      {BEGIN(INITIAL); return IDENTIFICADOR;}
<SGN>(.|\n)                            {BEGIN(INITIAL); unput(yytext[0]); return F_SGN;}
<INITIAL>"INT"                         {BEGIN(INT);}
<INT><<EOF>>                           {BEGIN(INITIAL); return F_INT;}
<INT>[a-zA-Z0-9]+                      {BEGIN(INITIAL); return IDENTIFICADOR;}
<INT>(.|\n)                            {BEGIN(INITIAL); unput(yytext[0]); return F_INT;}
<INITIAL>"FIX"                         {BEGIN(FIX);}
<FIX><<EOF>>                           {BEGIN(INITIAL); return F_FIX;}
<FIX>[a-zA-Z0-9]+                      {BEGIN(INITIAL); return IDENTIFICADOR;}
<FIX>(.|\n)                            {BEGIN(INITIAL); unput(yytext[0]); return F_FIX;}
<INITIAL>"FRAC"                        {BEGIN(FRAC);}
<FRAC><<EOF>>                          {BEGIN(INITIAL); return F_FRAC;}
<FRAC>[a-zA-Z0-9]+                     {BEGIN(INITIAL); return IDENTIFICADOR;}
<FRAC>(.|\n)                           {BEGIN(INITIAL); unput(yytext[0]); return F_FRAC;}
<INITIAL>"ROUND"                       {BEGIN(ROUND);}
<ROUND><<EOF>>                         {BEGIN(INITIAL); return F_ROUND;}
<ROUND>[a-zA-Z0-9]+                    {BEGIN(INITIAL); return IDENTIFICADOR;}
<ROUND>(.|\n)                          {BEGIN(INITIAL); unput(yytext[0]); return F_ROUND;}
[a-zA-Z][a-zA-Z0-9]*                   {return IDENTIFICADOR;}
[0-9]+(","[0-9]+)?"E"("+"|"-")?[0-9]+  {return EXPONENCIAL;}
[0-9]+","[0-9]+                        {return DECIMAL;}
[0-9]+                                 {return ENTERO;}
({SIMBOLOS})                           {return return_simbolo(yytext[0]);}
\n                                     {return FIN_LINEA;}
<CEOF><<EOF>>                          {return 0;}
<<EOF>>                                {BEGIN(CEOF); return FIN_LINEA;}
.                                      {}

%%

int return_simbolo(char simbol)
{
    switch(simbol){
        case '+': return O_SUMA;
        case '-': return O_RESTA;
        case '/': return O_DIV;
        case ':': return O_DIVE;
        case '!': return O_FACT;
        case '^': return O_EXP;
        case '|': return O_ABS;
        case '(': return O_PIZQ;
        case ')': return O_PDER;
        case '=': return O_IGUAL;
        default:  return O_ERR;
    };
};