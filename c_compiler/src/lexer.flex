%option noyywrap

%{
// Avoid error "error: `fileno' was not declared in this scope"
extern "C" int fileno(FILE *stream);

#include "parser.tab.hpp"
void yy_colCount();
%}



%%


"void" 						{ yylval.string=new std::string("void"); 		return VOID; 	}
"char" 						{ yylval.string=new std::string("char"); 		return CHAR; 	}
"short" 					{ yylval.string=new std::string("short"); 		return SHORT; 	}
"int" 						{ yylval.string=new std::string("int"); 		return INT; 	}
"long" 						{ yylval.string=new std::string("long"); 		return LONG; 	}
"float" 					{ yylval.string=new std::string("float"); 		return FLOAT; 	}
"double" 					{ yylval.string=new std::string("double"); 		return DOUBLE; 	}
"signed"					{ yylval.string=new std::string("signed"); 		return SIGNED; 	}
"unsigned"					{ yylval.string=new std::string("unsigned"); 	return UNSIGNED;}

"return"					{ yylval.string=new std::string("return"); 		return RETURN;	}


"="							{ return EQ		; }
"("							{ return L_BRAC ; }
")"							{ return R_BRAC ; }
"{"							{ return L_CURLY; }
"}"							{ return R_CURLY; }
";"							{ return SEMIC 	; }
","							{ return COMMA 	; }


[a-z]+        				{ yylval.string=new std::string(yytext); return VAR; }
[-]?[0-9]+([\.][0-9]*)? 	{ yylval.number=strtod(yytext, 0); return NUM; }




%%

int col = 0;

void yy_colCount(){
  for (int i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n')
			col = 0;
		else if (yytext[i] == '\t')
			col += 8 - (col % 8);
		else
			col++;
	ECHO;
}

void yyerror (char const *s)
{
  fprintf (stderr, "Flex Error: %s\n", s); /* s is the text that wasn't matched */
  exit(1);
}