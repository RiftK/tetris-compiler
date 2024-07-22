%debug
%{
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#define STRLEN 2048

void yyerror(char *s) {
  fprintf(stderr,"%s\n",s);
  return;
}

extern int yylex();
extern int yywrap();

extern char* yytext;

char* indent(char* body) {
  char* ans = malloc(STRLEN);
  memset(ans, 0, STRLEN);
  char* line = strtok(body, "\n");
  while(line != NULL) {
    sprintf(ans, "%s    %s\n", ans, line);
    line = strtok(NULL, "\n");
  }
  free(body);
  return ans;
}


const char set_args[] = "    for c in kwargs: exec(f'{c} = {kwargs.get(c)}')\n";
const char return_token[] = "return";
const char verbatim[] = "from rsjTetris import TetrisApp\ndef play(cell_size = 20, cols = 8, rows = 16, delay = 750, maxfps = 30):\n    config = {\"cell_size\": cell_size, \"cols\": cols, \"rows\": rows, \"delay\": delay, \"maxfps\": maxfps}\n    TetrisApp(config).run()\n";

%}

%union{
  char*	string;
  int		int_val;
}

%start START

/* %token <int_val> NUM   */
%token <string> NUM ID SECTION1 SECTION2 SECTION3 NEWLINE IF THEN ELSE END WHILE CALL WITH OP_OR OP_AND OP_NOT OP_NEG PLAY BRACKET_SQ_OPEN BRACKET_SQ_CLOSE BRACKET_PAREN_OPEN BRACKET_PAREN_CLOSE BRACKET_CURLY_OPEN BRACKET_CURLY_CLOSE OP_MUL OP_ADD OP_SUB ASSIGN DELIMITER ERROR
%left OP_ADD OP_SUB OP_MUL OP_DIV OP_MOD OP_AND OP_OR OP_NOT OP_NEG 


%type <string> START
%type <string> VERBATIM PRIMITIVE MAINGAME FUNCTIONS FUNCTION BODY STATEMENT IFSTATEMENT WHILELOOP EXPR ARITHLOGIC TERM ARITHTEMP FACTOR TERMTEMP PARAM PARAMLIST

%%

START: VERBATIM SECTION1 NEWLINE PRIMITIVE SECTION2 NEWLINE FUNCTIONS SECTION3 NEWLINE MAINGAME VERBATIM { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "\n%s\n%s\n%s\n%s\n\n", verbatim, $4, $7, $10); printf("%s", $$); }
     ;

MAINGAME: BRACKET_SQ_OPEN PLAY BRACKET_SQ_CLOSE { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "play()\n"); }
      | BRACKET_SQ_OPEN PLAY WITH PARAM PARAMLIST BRACKET_SQ_CLOSE { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "play(%s%s)\n", $4, $5); free($4); free($5);}
      ;

VERBATIM: VERBATIM NEWLINE { $$ = malloc(STRLEN); memset($$, 0, STRLEN); strcpy($$, $1); free($1); }
        | {$$ = malloc(STRLEN); memset($$, 0, STRLEN);}
        ;

PRIMITIVE: ID ASSIGN EXPR NEWLINE PRIMITIVE { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s = %s\n%s", $1, $3, $5); free($1); free($3); free($5);}
         | {$$ = malloc(STRLEN); memset($$, 0, STRLEN);}
         ;

FUNCTIONS: FUNCTION NEWLINE FUNCTIONS { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s\n%s", $1, $3); free($1); free($3); }
         | { $$ = malloc(STRLEN); memset($$, 0, STRLEN); }
         ;

FUNCTION: BRACKET_CURLY_OPEN ID BODY BRACKET_CURLY_CLOSE {
        char* body = indent($3);
        $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "def %s(**kwargs):\n%s%s", $2, set_args, body);
        free($2); free(body);
        }
        ;

BODY: STATEMENT BODY { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s\n%s", $1, $2); free($1); free($2);}
    | STATEMENT { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s", $1); free($1); }
    ;

EXPR: ARITHLOGIC { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s", $1); free($1); }
    | BRACKET_SQ_OPEN CALL ID BRACKET_SQ_CLOSE { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s()", $3); free($3); }
    | BRACKET_SQ_OPEN CALL ID WITH PARAM PARAMLIST BRACKET_SQ_CLOSE {
    $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s(%s%s)", $3, $5, $6);
    free($3); free($5); free($6);
    }
    ;

STATEMENT: ID ASSIGN EXPR {
           $$ = malloc(STRLEN); memset($$, 0, STRLEN);
           if (strcmp($1, return_token) == 0) {
            sprintf($$, "return %s", $3);
           } 
           else {
            sprintf($$, "%s = %s", $1, $3);
           }
           free($1);
           free($3);
         }
         | WHILELOOP { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s", $1); free($1); }
         | IFSTATEMENT { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s", $1); free($1); }
         ;

IFSTATEMENT: IF BRACKET_PAREN_OPEN EXPR BRACKET_PAREN_CLOSE THEN STATEMENT END {
           char* statement = indent($6);
           $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "if %s:\n%s", $3, statement);
           free($3); free(statement);
           }
           | IF BRACKET_PAREN_OPEN EXPR BRACKET_PAREN_CLOSE THEN STATEMENT ELSE STATEMENT END {
           char* if_statement = indent($6);
           char* else_statement = indent($8);
           $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "if %s:\n%s\nelse:\n%s", $3, if_statement, else_statement);
           free($3); free(if_statement); free(else_statement);
           }
           ;

WHILELOOP: WHILE BRACKET_PAREN_OPEN EXPR BRACKET_PAREN_CLOSE STATEMENT END {
         char* statement = indent($5);
         $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "while %s:\n%s", $3, statement);
         free($3); free(statement);
         }
         ;

ARITHLOGIC: TERM ARITHTEMP { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s%s", $1, $2); free($1); free($2); }
          ;

ARITHTEMP: OP_ADD TERM ARITHTEMP { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, " + %s%s", $2, $3); free($2); free($3); }
      | OP_SUB TERM ARITHTEMP { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, " - %s%s", $2, $3); free($2); free($3); }
      | OP_OR TERM ARITHTEMP { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, " or %s%s", $2, $3); free($2); free($3); }
      | { $$ = malloc(STRLEN); memset($$, 0, STRLEN); }
      ;          

TERM: FACTOR TERMTEMP { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s%s", $1, $2); free($1); free($2); }
    ;

TERMTEMP: OP_MUL FACTOR TERMTEMP { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, " * %s%s", $2, $3); free($2); free($3); }
     | OP_AND FACTOR TERMTEMP { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, " and %s%s", $2, $3); free($2); free($3); }
     | { $$ = malloc(STRLEN); memset($$, 0, STRLEN); }
     ;

FACTOR: ID { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s", $1); free($1); }
      | NUM { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s", $1); free($1); }
      | BRACKET_PAREN_OPEN EXPR BRACKET_PAREN_CLOSE { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "(%s)", $2); free($2); }
      | BRACKET_PAREN_OPEN OP_NEG EXPR BRACKET_PAREN_CLOSE { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "(not %s)", $3); free($3); }
      | BRACKET_PAREN_OPEN OP_NOT EXPR BRACKET_PAREN_CLOSE { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "(~ %s)", $3); free($3); }
      ;

PARAMLIST: PARAM PARAMLIST { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, ",%s%s", $1, $2); free($1); free($2); }
         | { $$ = malloc(STRLEN); memset($$, 0, STRLEN); }
         ;

PARAM: ID ASSIGN EXPR { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s = %s", $1, $3); free($1); free($3); }
     | ID { $$ = malloc(STRLEN); memset($$, 0, STRLEN); sprintf($$, "%s", $1); free($1);}
     ;
%%

int main(int argc, char *argv[]) {
  yyparse();
  return 0;
}
