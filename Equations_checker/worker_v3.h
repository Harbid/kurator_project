#ifndef WORKER_V3_H
#define WORKER_V3_H
#include "debug_logger.h"
//#define DEBUG_PRINT
//#define HRB_GENERATE_VALUES_DEBUG
//#define HRB_CHECK_DEBUG
//#define HRB_SOLVE_SYSTEM_DEBUG
//#define HRB_GET_EQ_FROM_FILE_DEBUG
//#define HRB_GET_CURRENT_SYSTEM_DEBUG
#define HRB_GENERATE_MULT_TABLE_DEBUG

extern Debug_logger d_logger;
namespace eq_checker_v3
{
    class Worker
    {
    private:
        std::vector<std::vector<int> > all_equations_masks;
        std::vector<int> equations_values;
        int _K;
        int _N;

        std::vector<int> get_next_mask(std::vector<int> mask);
        std::vector<int> init_mask(bool final_mask);
        std::vector<std::vector<int> > get_current_system(const std::vector<int> &system_mask); // choose equations according to mask
        std::vector<std::vector<int> > reduce_to_system(const std::vector<std::vector<int> > &system, const std::vector<int> &system_mask);
        std::vector<int> generate_values(const std::vector<std::vector<int> > &system);
    public:
        Worker();
        ~Worker();
        int generate_equations(const int K, const int N);
        std::vector<int> solve_system(const std::vector<std::vector<int> > &system, const std::vector<int> &values);

        std::vector<int> get_next_mask(std::vector<int> mask, const int N);
        std::vector<int> init_mask(bool final_mask, const int K, const int N);
        int generate_equations(const int K, const int N, std::vector<int> mask);
        std::vector<int> get_mask_from_eq();
        int get_equations_from_file();
        int check();
        void print();
    };
}
#endif // WORKER_V3_H
