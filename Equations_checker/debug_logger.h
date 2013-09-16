#ifndef DEBUG_LOGGER_H
#define DEBUG_LOGGER_H
#include "headers.h"

class Debug_logger
{
public:
    Debug_logger();
    ~Debug_logger();
    void print(const std::vector<int> &v);
    void print(const std::vector<char> &v);
    void print(const std::vector<std::vector<int> > &v);
    void print(const std::vector<std::vector<int> > &s, const std::vector<int> &v);
    void print(const std::string &s);
    void print_mult_table(const std::vector<int> &v);
    void skip_line();
};

#endif // DEBUG_LOGGER_H
