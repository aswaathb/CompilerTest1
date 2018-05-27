#include "ast.hpp"

int main()
{
    const Expression *ast=parseAST();

    ast->translate();

    return 0;
}
