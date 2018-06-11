%code requires{
  #include "ast.hpp"

  #include <cassert>

  extern const Expression *g_root; // A way of getting the AST out

  //! This is to fix problems when generating C++
  // We are declaring the functions provided by Flex, so
  // that Bison generated code can call them.
  int yylex(void);
  void yyerror(const char *);
}

// Represents the value associated with any kind of
// AST node.
%union{
      const Expression *node;
      variable_declaration *variable;
      double number;
      std::string *string;
      function_definition *func;
}

%token VAR NUM
%token EQ SEMIC COMMA L_BRAC R_BRAC L_CURLY R_CURLY
%token VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED
%token RETURN


%type <node> ROOT TYPE_SPEC BEGIN
%type <variable> EXPR SCOPE FACTOR
%type <func> FUNC
%type <number> NUM
%type <string> VAR

%start ROOT

%%
    ROOT : BEGIN { g_root = $1; }

    BEGIN : EXPR
          | FUNC

    EXPR : TYPE_SPEC VAR EQ NUM SEMIC     {$$ = new variable_declaration($2,$4);}
         | TYPE_SPEC VAR SEMIC            {$$ = new variable_declaration($2,0);}

    FUNC : TYPE_SPEC VAR L_BRAC R_BRAC SCOPE     {$$ = new function_definition($2,$5); }

    FACTOR : L_BRAC R_BRAC  	            {;}
           | L_BRAC TYPE_SPEC VAR R_BRAC  {$$ = new variable_declaration($3,0);}

    SCOPE : L_CURLY EXPR R_CURLY          {$$ = $2 ;}

    TYPE_SPEC : VOID
              | INT

// New Parser

BEGIN : DECLARATION_TYPES

DECLARATION_TYPES : TYPE_SPECIFIER DECLARATOR COMPOUND_STATEMENT

DECLARATOR : L_BRAC DECLARATOR R_BRAC	      { $$ = $2; }
| IDENTIFIER					              { $$ = new Variable($1);}
| L_BRAC R_BRAC DECLARATOR					  { $$ = $3; }

TYPE_SPECIFIER : VOID
| INT


COMPOUND_STATEMENT : L_CURLY R_CURLY
| L_CURLY STATEMENT_LIST R_CURLY

STATEMENT_LIST : STATEMENT
| STATEMENT_LIST STATEMENT

STATEMENT : COMPOUND_STATEMENT
| RETURN EXPRESSION_STATEMENT
| EXPRESSION_STATEMENT

EXPRESSION_STATEMENT : SEMICOLON
| EXPRESSION SEMICOLON

// Below is copied from LAB 2

EXPRESSION : TERM                 { $$ = $1; }
| EXPRESSION T_PLUS TERM { $$ = new AddOperator($1, $3); }
| EXPRESSION T_MINUS TERM { $$ = new SubOperator($1, $3); }

TERM : FACTOR               { $$ = $1; }
| TERM T_TIMES FACTOR { $$ = new MulOperator($1, $3); }
| TERM T_DIVIDE FACTOR { $$ = new DivOperator($1, $3); }


FACTOR : T_NUMBER           { $$ = new Number($1); }
| T_VARIABLE { $$ = new Variable (*$1); }
| FACTOR T_EXPONENT FACTOR { $$ = new ExpOperator($1, $3); }

| T_LOG T_LBRACKET EXPR T_RBRACKET  { $$ = new LogFunction($3); }
| T_EXP T_LBRACKET EXPR T_RBRACKET  { $$ = new ExpFunction($3); }
| T_SQRT T_LBRACKET EXPR T_RBRACKET  { $$ = new SqrtFunction($3); }

| T_LBRACKET EXPR T_RBRACKET { $$ = $2; }

%%

const Expression *g_root; // Definition of variable (to match declaration earlier)

const Expression *parseAST()
{
  g_root=0;
  yyparse();
  return g_root;
}
