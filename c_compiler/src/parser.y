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
      double number;
      std::string *string;
      variable_declaration *variable;
      function_definition *func;
      return_statement *ret_state;
}

%token VAR NUM
%token EQ SEMIC COMMA L_BRAC R_BRAC L_CURLY R_CURLY
%token VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED
%token RETURN


%type <node> ROOT TYPE_SPEC  
%type <variable>  SCOPE FACTOR DECLARATION STATEMENT 
%type <func> FUNC
%type <number> NUM 
%type <string> VAR  RETURN
%type <ret_state> RETURN_STATEMENT

%start ROOT

%%
    ROOT : STATEMENT                      { g_root = $1; }

    STATEMENT : DECLARATION               
              | FUNC                      
              | RETURN_STATEMENT          
    
    RETURN_STATEMENT : RETURN NUM SEMIC                   {$$ = new return_statement($1,$2); }

    DECLARATION : TYPE_SPEC VAR EQ NUM SEMIC STATEMENT    {$$ = new variable_declaration($2,$4);}
                | TYPE_SPEC VAR EQ NUM SEMIC STATEMENT    {$$ = new variable_declaration($2,$4);}
                | TYPE_SPEC VAR SEMIC                     {$$ = new variable_declaration($2,0);}
 
         
    FUNC : TYPE_SPEC VAR L_BRAC R_BRAC SCOPE      {$$ = new function_definition($2,$5); }
  

    FACTOR : L_BRAC R_BRAC  	                    {;}
           | L_BRAC TYPE_SPEC VAR R_BRAC          {$$ = new variable_declaration($3,0);}
    
    SCOPE : L_CURLY DECLARATION R_CURLY             {$$ = $2 ;}

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