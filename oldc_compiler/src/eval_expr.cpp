#include "ast.hpp"

#include <iomanip>

int main(int argc, char *argv[])
{
    
    const Expression *ast=parseAST();
    
    //python translation
    ast->translate();
    std::cout<<std::endl;
    //Python "Footer"
    std::cout<<"if __name__ == \"__main__\": "<<std::endl;
    std::cout<<"import sys" <<std::endl ;
    std::cout<<"ret=main()" << std::endl;
    std::cout<<"sys.exit(ret)" << std::endl;
    

    //MIPS Machine Code
    //ast->compile();
    //std::cout<<std::endl;   
    
    return 0;
}
