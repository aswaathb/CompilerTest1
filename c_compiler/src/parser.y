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
              | CHAR
              | SHORT
              | INT
              | LONG
              | FLOAT
              | DOUBLE
              | SIGNED 
              | UNSIGNED
      

 



%%

const Expression *g_root; // Definition of variable (to match declaration earlier)

const Expression *parseAST()
{
  g_root=0;
  yyparse();
  return g_root;
}