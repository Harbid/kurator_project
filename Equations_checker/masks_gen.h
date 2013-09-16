#ifndef MASKS_GEN_H
#define MASKS_GEN_H
#include <iostream>
#include <iomanip>
#include <vector>
#define DEBUG_PRINT
#define COUT_OFFSET 2
#define _N 6
#define _K 3

namespace eq_checker
{
    void print_all_masks();
    std::vector<int> get_next_mask(std::vector<int> mask);
    void print_all_masks(int get_function_used);
    std::vector<int> init_mask(bool final_mask);
    void print_all_masks(int get_function_used, int init_function_used);
}
#endif // MASKS_GEN_H
