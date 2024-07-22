delim     [ \t]
ws        {delim}+
letter    [A-Za-z_]
digit     [0-9]
id        {letter}({letter}|{digit})*
num       (-)?{digit}+
operator  [+-/*=]
float     (-)?{num}+(\.{num}+)


%{
    #include <stdlib.h>
    #include <stdio.h>
    #include "grammar.tab.h"
    
    void yyerror(char*);
    int yylex();
    
    #define NONE -1
    #define EOS 0

    #define STRMAX 999
    #define SYMMAX 5000


    int tokenval = NONE;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    int S1done = 0, S2done = 0, S3done = 0;
    int parenthesisCount = 0;
    int S1going = 0, S2going = 0, S3going = 0;
    int SquareBraketCount = 0, CurlyBracketCount = 0;
    int Sequence = 0;

    //return token type string
    char *tokenType(int token)
    {
        switch(token)
        {
            case NUM: return "NUM";
            case ID: return "ID";
            case SECTION1: return "SECTION1";
            case SECTION2: return "SECTION2";
            case SECTION3: return "SECTION3";
            case PLAY: return "PLAY";
            case IF: return "IF";
            case THEN: return "THEN";
            case ELSE: return "ELSE";
            case END: return "END";
            case WHILE: return "WHILE";
            case CALL: return "CALL";
            case WITH: return "WITH";
            case OP_OR: return "OP_OR";
            case OP_AND: return "OP_AND";
            case OP_NOT: return "OP_NOT";
            case OP_NEG: return "OP_NEG";
            case OP_ADD: return "OP_ADD";
            case OP_SUB: return "OP_SUB";
            case OP_MUL: return "OP_MUL";
            case OP_DIV: return "OP_DIV";
            case ASSIGN: return "ASSIGN";
            case BRACKET_SQ_OPEN: return "BRACKET_SQ_OPEN";
            case BRACKET_SQ_CLOSE: return "BRACKET_SQ_CLOSE";
            case BRACKET_CURLY_OPEN: return "BRACKET_CURLY_OPEN";
            case BRACKET_CURLY_CLOSE: return "BRACKET_CURLY_CLOSE";
            case BRACKET_PAREN_OPEN: return "BRACKET_PAREN_OPEN";
            case BRACKET_PAREN_CLOSE: return "BRACKET_PAREN_CLOSE";
            case DELIMITER: return "DELIMITER";
            case NEWLINE: return "NEWLINE";
            default: return "UNKNOWN";
        }
    }
    int lineno = 0;
%}
%%

[\n]+  {lineno = lineno + strlen(yytext);tokenval = NEWLINE; return NEWLINE;}
{ws}+   { fprintf(stderr, " ");tokenval = DELIMITER;}


"play"                  { fprintf(stderr, "%s", yytext); return PLAY; }
"if"                    { fprintf(stderr, "%s", yytext); return IF; } 
"then"                  { fprintf(stderr, "%s", yytext); return THEN; }
"else"                  { fprintf(stderr, "%s", yytext); return ELSE; }
"end"                   { fprintf(stderr, "%s", yytext); return END; }
"while"                 { fprintf(stderr, "%s", yytext); return WHILE; }
"call"                  { fprintf(stderr, "%s", yytext); return CALL; }
"with"                  { fprintf(stderr, "%s", yytext); return WITH; }
"and"                   { fprintf(stderr, "%s", yytext); return OP_AND; }
"or"                    { fprintf(stderr, "%s", yytext); return OP_OR; }
"not"                   { fprintf(stderr, "%s", yytext); return OP_NOT; }
"neg"                   { fprintf(stderr, "%s", yytext); return OP_NEG; }
"+"                     { fprintf(stderr, "%s", yytext); return OP_ADD; }
"-"                     { fprintf(stderr, "%s", yytext); return OP_SUB; }
"*"                     { fprintf(stderr, "%s", yytext); return OP_MUL; }
"/"                     { fprintf(stderr, "%s", yytext); return OP_DIV; }
"="                     { fprintf(stderr, "%s", yytext); return ASSIGN; }

^"Section1"$ {
        if(S1done == 1 || S2done == 1 || S3done == 1) {
            perror("Error\n"); 
            return -1;
        }
        S1done = 1;
        S1going = 1;
        tokenval = SECTION1;
        yylval.string = malloc(strlen(yytext)+1);
        strcpy(yylval.string, yytext);
        return SECTION1;
    }

^"Section2"$ {
        tokenval = SECTION2;
        if(S1done == 0 || S2done == 1 || S3done == 1) {
            perror("Error\n"); 
            return -1;
        } 
        S2done = 1;
        S1going = 0;
        S2going = 1;
        yylval.string = malloc(strlen(yytext)+1);
        strcpy(yylval.string, yytext);
        return SECTION2;
    }

^"Section3"$ {
        tokenval = SECTION3;
        if(S1done == 0 || S2done == 0 || S3done == 1) {
            perror("Error\n"); 
            return -1;
            
        }
        if(SquareBraketCount>0 || CurlyBracketCount>0) {
            perror("Section 2 brackets are unbalanced.");
            return -1;
        }
        S3done = 1;
        S3going = 1;
        S2going = 0;
        yylval.string = malloc(strlen(yytext)+1);
        strcpy(yylval.string, yytext);
        return SECTION3;
    }    

"[" {
    yylval.string = malloc(strlen(yytext)+1);
    strcpy(yylval.string, yytext);
    tokenval = BRACKET_SQ_OPEN;
    SquareBraketCount++;
    return BRACKET_SQ_OPEN;

}

"]" {
    yylval.string = malloc(strlen(yytext)+1);
    strcpy(yylval.string, yytext);
    tokenval = BRACKET_SQ_CLOSE;
    SquareBraketCount--;
    return BRACKET_SQ_CLOSE;

}

"{" {
    yylval.string = malloc(strlen(yytext)+1);
    strcpy(yylval.string, yytext);
    tokenval = BRACKET_CURLY_OPEN;
    CurlyBracketCount++;
    return BRACKET_CURLY_OPEN;

}

"}" {
    yylval.string = malloc(strlen(yytext)+1);
    strcpy(yylval.string, yytext);
    tokenval = BRACKET_CURLY_CLOSE;
    CurlyBracketCount--;
    return BRACKET_CURLY_CLOSE;

}

{id}    {
    yylval.string = malloc(strlen(yytext)+1);
    strcpy(yylval.string, yytext);
    tokenval = ID;
    return ID;
}

"(" {
    yylval.string = malloc(strlen(yytext)+1);
    strcpy(yylval.string, yytext);
    parenthesisCount++; 
    tokenval = BRACKET_PAREN_OPEN;
    return BRACKET_PAREN_OPEN;
}

")" {
    yylval.string = malloc(strlen(yytext)+1);
    strcpy(yylval.string, yytext);
    parenthesisCount--;
    tokenval = BRACKET_PAREN_CLOSE;
    if(parenthesisCount < 0){
        perror("Error\n");
        return -1;
    }
    return BRACKET_PAREN_CLOSE;
}

{num} {
    yylval.string = malloc(strlen(yytext)+1);
    strcpy(yylval.string, yytext);
    tokenval = NUM;
    return NUM;
}

{float} {
    yylval.string = malloc(strlen(yytext)+1);
    strcpy(yylval.string, yytext);
    tokenval = NUM;
    return NUM;
}

. {
    tokenval = NONE;
    perror("Error\n");
    return ERROR;
}

%%

int yywrap() { return 1; }