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

%token IDENTIFIER F_CONST I_CONST C_CONST

%token PLUS MINUS TIMES DIVIDE MODULUS 
%token LOR LAND OR NEQUAL LESSEQUAL LESSTHAN GREATEQUAL GREATTHAN AND XOR L_SHIFT R_SHIFT

%token MUL_ASS DIV_ASS MOD_ASS ADD_ASS SUB_ASS LL_ASS RR_ASS AND_ASS XOR_ASS OR_ASS ARROW DECR INCR

%token VOID CHAR SHORT INT LONG FLOAT DOUBLE SIGNED UNSIGNED CONST

%token DO WHILE IF ELSE FOR SWITCH
%token RETURN CONTINUE BREAK GOTO

%token EQUAL SEMICOLON COMMA L_BRAC R_BRAC L_CURLY R_CURLY L_SQUARE R_SQUARE

%token QUES_MARK COLON DOT STRING SIZEOF 

%type <string> ASSIGNMENT_OP TYPE_NAME IDENTIFIER PLUS MINUS TIMES DIVIDE MODULUS STRING C_CONST F_CONST I_CONST SIZEOF UNARY_OPERATOR  EQUAL SEMICOLON COMMA L_BRAC R_BRAC L_CURLY R_CURLY L_SQUARE R_SQUARE QUES_MARK COLON MUL_ASS DIV_ASS MOD_ASS ADD_ASS SUB_ASS LL_ASS RR_ASS AND_ASS XOR_ASS OR_ASS ARROW DECR INCR LOR LAND OR NEQUAL LESSEQUAL LESSTHAN GREATEQUAL GREATTHAN AND XOR L_SHIFT R_SHIFT

%type <node> ROOT TYPE_SPEC  
%type <variable>  SCOPE FACTOR DECLARATION STATEMENT RETURN_STATEMENT FUNC

%type <number> NUM 
%type <string> VAR  RETURN

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