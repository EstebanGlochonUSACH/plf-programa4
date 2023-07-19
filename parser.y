%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define YYERROR_VERBOSE 1

typedef struct _node {
    char *token;
    double value;
    struct _node *next;
} node_t;

typedef struct {
    node_t *head;
    node_t *tail;
    node_t *curr;
} list_t;

list_t *list_create();
void list_destroy(list_t *list);
void list_add(list_t *list, char *token, double value);
node_t *list_search(list_t *list, char *token); 

const double C_EULER = 2.71828182845904523536;
const double C_PI = 3.14159;
const char C_COMMA[] = ",";
const char C_POINT[] = ".";
list_t *token_list;

extern char *tmp_indentificador;
extern int yylineno;
extern char* yytext;
extern int yylex();
extern int yyparse();
void yyerror(const char *s);
double assign_token(char *reg_name, double value);
double get_from_table(char *reg_name);
void parse_print(double num);
double parse_factorial(double n);
double parse_decimal(char *exp);
double parse_exponencial(char *exp);
double parse_abs(double dbl);
double parse_div(double n1, double n2);
double parse_mod(double n1, double n2);
double parse_sqrt(double num);
double parse_cbrt(double num);
double parse_exp(double num);
double parse_log_n(double num);
double parse_log_10(double num);
double parse_sign(double num);
double parse_int(double num);
double parse_fix(double num);
double parse_frac(double num);
%}

%union {
    char *sval;
    double dval;
    int ival;
}

%token <sval> IDENTIFICADOR EXPONENCIAL DECIMAL ENTERO
%token CONST_PI
%token F_SQR F_CUR F_EXP F_LN F_LOG F_SGN F_INT F_FIX F_FRAC F_ROUND
%token O_SUMA O_RESTA O_MULT O_DIV O_DIVE O_FACT O_MOD O_EXP
%token O_ABS O_PIZQ O_PDER O_IGUAL O_ERR
%token FIN_LINEA END_ROUND

%left O_SUMA O_RESTA O_EXP O_IGUAL O_MOD
%left O_MULT O_DIV O_DIVE
%right O_FACT

%type <sval> variable
%type <dval> expresion
%type <dval> expresion_rama
%type <dval> op_unidad
%type <dval> funcion
%type <dval> factorial
%type <dval> operando
%type <dval> linea
%type <dval> asignacion

%%

calcular:
    /* empty */
    | calcular linea
    | calcular FIN_LINEA
;
linea:
    expresion FIN_LINEA { parse_print($1);}
    | asignacion FIN_LINEA { parse_print($1);}
    | END_ROUND FIN_LINEA { YYACCEPT; }
;
funcion:
    F_SQR O_PIZQ expresion O_PDER      { $$ = parse_sqrt($3); }
    | F_CUR O_PIZQ expresion O_PDER    { $$ = parse_cbrt($3); }
    | F_EXP O_PIZQ expresion O_PDER    { $$ = parse_exp($3); }
    | F_LN O_PIZQ expresion O_PDER     { $$ = parse_log_n($3); }
    | F_LOG O_PIZQ expresion O_PDER    { $$ = parse_log_10($3); }
    | F_SGN O_PIZQ expresion O_PDER    { $$ = parse_sign($3); }
    | F_INT O_PIZQ expresion O_PDER    { $$ = floor($3); }
    | F_FIX O_PIZQ expresion O_PDER    { $$ = parse_fix($3); }
    | F_FRAC O_PIZQ expresion O_PDER   { $$ = parse_frac($3); }
    | F_ROUND O_PIZQ expresion O_PDER  { $$ = round($3); }
    | O_ABS expresion O_ABS            { $$ = parse_abs($2); }
;
op_unidad:
    IDENTIFICADOR           { $$ = get_from_table(tmp_indentificador); }
    | CONST_PI              { $$ = C_PI; }
    | O_RESTA ENTERO        { $$ = -1 * (double)atoi(yytext); }
    | ENTERO                { $$ = (double)atoi(yytext); }
    | O_RESTA DECIMAL       { $$ = -1 * parse_decimal(yytext); }
    | DECIMAL               { $$ = parse_decimal(yytext); }
    | O_RESTA EXPONENCIAL   { $$ = -1 * parse_exponencial(yytext); }
    | EXPONENCIAL           { $$ = parse_exponencial(yytext); }
;
factorial:
    O_FACT op_unidad                   { $$ = parse_factorial($2); }
    | O_FACT funcion                   { $$ = parse_factorial($2); }
    | O_FACT O_PIZQ expresion O_PDER   { $$ = parse_factorial($3); }
;
operando:
    op_unidad       { $$ = $1; }
    | funcion       { $$ = $1; }
    | factorial     { $$ = $1; }
;
expresion_rama:
    O_PIZQ expresion O_PDER   { $$ = $2; }
    | operando                { $$ = $1; }
;
expresion:
    operando                            { $$ = $1; }
    | O_PIZQ expresion O_PDER           { $$ = $2; }
    | expresion_rama O_SUMA expresion   { $$ = $1 + $3; }
    | expresion_rama O_RESTA expresion  { $$ = $1 - $3; }
    | expresion_rama O_MULT expresion   { $$ = $1 * $3; }
    | expresion_rama O_DIV expresion    { $$ = parse_div($1, $3); }
    | expresion_rama O_DIVE expresion   { $$ = $1 / $3; }
    | expresion_rama O_MOD expresion    { $$ = parse_mod($1, $3); }
    | expresion_rama O_EXP expresion    { $$ = pow($1, $3); }
;
variable:
    IDENTIFICADOR           { $$ = tmp_indentificador; }
;
asignacion:
    variable O_IGUAL expresion { $$ = assign_token($1, $3); }
;

%%

void yyerror(const char *s)
{
    printf("Error en la l%cnea n%cumero: %d\n", 161, 163, yylineno);
    //printf("Error en la l%cnea n%cumero: %d\n%s\n", 161, 163, yylineno, s);
    exit(1);
};

int main(int argc, char *argv[])
{
    token_list = list_create();
	yyparse();
    list_destroy(token_list);
    return 0;
};

double assign_token(char *reg_name, double value)
{
    if(reg_name == NULL){
        printf("Error: El identificador es NULL.\n");
        exit(-1);
    }
    node_t *tmp_node = list_search(token_list, reg_name);
    if(tmp_node != NULL){
        tmp_node->value = value;
    }
    else{
        list_add(token_list, reg_name, value);
    }
    return value;
}

double get_from_table(char *reg_name)
{
    node_t *tmp_node = list_search(token_list, reg_name);
    if(tmp_node == NULL){
        printf("Error: El identificador \"%s\" no est%c definido.\n", reg_name, 160);
        exit(-1);
    }
    return tmp_node->value;
}

void parse_print(double num)
{
    if(floor(num) == num){
        int i1 = (int)num;
        printf("%d\n", i1);
    }
    else{
        printf("%f\n", num);
    }
};

double parse_factorial(double n)
{
    if(n < 0){
        printf("Error: No se puede calcular el factorial de un n%umero negativo.\n", 163);
        exit(-1);
    }
    int res = 1, i;
    for (i = 2; i <= n; i++)
        res *= i;
    return (double)res;
};

double parse_exponencial(char *exp)
{
    char *token, *str, *tmp_str;
    int sign1 = 1, sign2 = 1;
    char part1[10];
    char part2[10];
    char part2_2[10];
    double num1, num2;
    tmp_str = str = strdup(exp);
    int part = 0;
    while ((token = strsep(&str, "E"))){
        if(part == 0){
            strcpy(part1, token);
        }
        else if(part == 1){
            strcpy(part2, token);
        }
        ++part;
    }
    free(tmp_str);

    if(part2[0] == '-'){
        sign2 = -1;
        strcpy(part2_2, &part2[1]);
        strcpy(part2, part2_2);
    }
    else if(part2[0] == '+'){
        sign2 = 1;
        strcpy(part2_2, &part2[1]);
        strcpy(part2, part2_2);
    }

    num1 = sign1 * atof(part1);
    num2 = sign2 * atof(part2);

    return num1 * pow(10.0, num2);
};

double parse_decimal(char *exp)
{
    char *tmp_str = malloc(strlen(exp)+1);
    size_t pos = strcspn(exp, C_COMMA);
    strncpy(tmp_str, exp, pos);
    strcat(tmp_str, C_POINT);
    strcat(tmp_str, exp + pos + 1);
    return atof(tmp_str);
}

double parse_abs(double dbl)
{
    if(dbl < 0) return -1.0 * dbl;
    return dbl;
}

double parse_div(double n1, double n2)
{
    if(floor(n1) != n1 || floor(n2) != n2){
        printf("Error: No se puede obtener una divisi%cn entera con n%umeros decimales.\n", 162, 163);
        exit(-1);
    }

    int i1 = (int)n1;
    int i2 = (int)n2;
    return (double)(i1 / i2);
};

double parse_mod(double n1, double n2)
{
    if(floor(n1) != n1 || floor(n2) != n2){
        printf("Error: No se puede obtener el m%cdulo de n%umeros no enteros.\n", 162, 163);
        exit(-1);
    }

    int i1 = (int)n1;
    int i2 = (int)n2;
    return (double)(i1 % i2);
};

double parse_sqrt(double num)
{
    if(num < 0){
        printf("Error: El argumento de SQR no puede ser un n%umero negativo.\n", 163);
        exit(-1);
    }
    return sqrt(num);
}

double parse_cbrt(double num)
{
    if(num < 0){
        printf("Error: El argumento de CUR no puede ser un n%umero negativo.\n", 163);
        exit(-1);
    }
    return cbrt(num);
}

double parse_exp(double num)
{
    return pow(C_EULER, num);
}

double parse_log_n(double num)
{
    if(num < 0){
        printf("Error: El argumento de LN no puede ser un n%umero negativo.\n", 163);
        exit(-1);
    }
    return log(num);
}

double parse_log_10(double num)
{
    if(num < 0){
        printf("Error: El argumento de LOG no puede ser un n%umero negativo.\n", 163);
        exit(-1);
    }
    return log10(num);
}

double parse_sign(double num)
{
    if(num < 0) return -1.0;
    if(num > 0) return 1.0;
    return 0.0;
}

double parse_fix(double num)
{
    double fractional, integer;
    fractional = modf(num, &integer);
    return integer;
};

double parse_frac(double num)
{
    double fractional, integer;
    fractional = modf(num, &integer);
    return fractional;
};

list_t *list_create()
{
    list_t *list = (list_t*)malloc(sizeof(list_t));
    if(list == NULL){
        printf("Error: No se pudo crear la lista.\n");
        exit(-1);
    }
    list->head = NULL;
    list->tail = NULL;
    list->curr = NULL;
    return list;
}
void list_destroy(list_t *list)
{
    if(list->head != NULL){
        node_t *tmp_next;
        list->curr = list->head;
        while(list->curr != NULL){
            tmp_next = list->curr->next;
            free(list->curr);
            list->curr = tmp_next;
        }
    }
    free(list);
}
void list_add(list_t *list, char *token, double value)
{
    node_t *node = (node_t*)malloc(sizeof(node_t));
    if(node == NULL){
        printf("Error: No se pudo crear el nodo para la lista.\n");
        exit(-1);
    }
    node->token = strdup(token);
    node->value = value;

    if(list->head == NULL){
        list->head = node;
        list->tail = node;
    }
    else{
        list->tail->next = node;
        list->tail = node;
    }
}
node_t *list_search(list_t *list, char *token)
{
    if(list->head == NULL) return NULL;

    list->curr = list->head;
    while(list->curr != NULL){
        if(strcmp(list->curr->token, token) == 0){
            return list->curr;
        }
        list->curr = list->curr->next;
    }

    return NULL;
}