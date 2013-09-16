#include "debug_logger.h"

typedef unsigned int u_int;

Debug_logger::Debug_logger(){}
Debug_logger::~Debug_logger(){}

void Debug_logger::print(const std::vector<int> &v)
{
    u_int size = v.size();
    for(u_int i = 0; i < size; ++i)
    {
        std::cout << v[i] << ' ';
    }
    std::cout << std::endl;
    return;
}

void Debug_logger::print(const std::vector<char> &v)
{
    u_int size = v.size();
    for(u_int i = 0; i < size; ++i)
    {
        std::cout << v[i] << ' ';
    }
    std::cout << std::endl;
    return;
}

void Debug_logger::print(const std::vector<std::vector<int> > &v)
{
    u_int upper_size = v.size();
    for(u_int i = 0; i < upper_size; ++i)
    {
        u_int inner_size = v[i].size();
        for(u_int j = 0; j < inner_size; ++j)
        {
            std::cout << v[i][j] << ' ';
        }
        std::cout << '\n' << std::endl;
    }
    return;
}

void Debug_logger::print(const std::vector<std::vector<int> > &s, const std::vector<int> &v)
{
    u_int upper_size = s.size();

    for(u_int i = 0; i < upper_size; ++i)
    {
        u_int inner_size = s[i].size();
        for(u_int j = 0; j < inner_size; ++j)
        {
            std::cout << s[i][j] << ' ';
        }
        std::cout << "   " << v[i] << std::endl;
    }
    std::cout << std::endl;
    return;
}

void Debug_logger::print(const std::string &s)
{
    std::cout << s << std::endl;
    return;
}

void Debug_logger::print_mult_table(const std::vector<int> &v)
{
    u_int table_size = v.size();

    for(u_int i = 0; i < table_size; ++i)
    {
        std::cout << i << " : " << v[i] << std::endl;
    }
    return;
}

void Debug_logger::skip_line()
{
    std::cout << std::endl;
    return;
}
