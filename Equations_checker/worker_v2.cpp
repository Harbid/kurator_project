#include "worker_v2.h"

namespace eq_checker_v2
{
    Worker::Worker(){}
    Worker::~Worker(){std::cout << "Destructor called.\n";}

    int Worker::generate_equations(const int K, const int N)
    {
        //if(N > ((K)*(K-1))/2)
        if(N > (((K-1)*(K-2))/2 + K + 1))
        {
            //std::cout << "N should be lower. (Max: " << ((K)*(K-1))/2 << ")" << std::endl;
            std::cout << "N should be lower. (Max: " << ((K-1)*(K-2))/2 + K + 1 << ")" << std::endl;
            return -1;
        }
        this->_K = K;
        this->_N = N;
        std::vector<int> identity_mask;
        for(int i = 0; i < K; ++i)
        {
            identity_mask.push_back(1);
        }
        int eq_count = 0;
        for(int sd = 0; sd < K; sd++) // one zero masks
        {
            if(N == eq_count)
            {
                break;
            }
            std::vector<int> mask(identity_mask);
            mask[sd] = 0;
            all_equations_masks.push_back(mask); // fd - first digit, sd - second digit
            ++eq_count;
        }

        for(int fd = 0; fd < K-2; ++fd)
        {
            for(int sd = fd+1; sd < K-1; ++sd)
            {
                if(N == eq_count)
                {
                    break;
                }
                std::vector<int> mask(identity_mask);
                mask[fd] = 0;
                mask[sd] = 0;
                all_equations_masks.push_back(mask); // fd - first digit, sd - second digit
                ++eq_count;
            }
        }
        return 0;
    }

    int Worker::generate_multiplication_table(const int ring_base)
    {
        RING_BASE = ring_base;

        for(int i = 0; i < RING_BASE; ++i)
        {
            multiplication_table.push_back(0);
        }

        for(int i = 1; i < RING_BASE; ++i)
        {
            for(int j = 1; j < RING_BASE; ++j)
            {
                if(i*j % RING_BASE == 1)
                {
                    multiplication_table[i] = j;
                    break;
                }
            }
        }
#ifdef HRB_GENERATE_MULT_TABLE_DEBUG
        d_logger.print_mult_table(multiplication_table);
#endif
        return 0;
    }

    std::vector<std::vector<int> > Worker::get_current_system(const std::vector<int> &system_mask)
    {
        std::vector<std::vector<int> > current_system;
        for(int i = 0; i < _N; ++i)
        {
            if(1 == system_mask[i])
            {
                current_system.push_back(all_equations_masks[i]);
            }
        }
#ifdef HRB_GET_CURRENT_SYSTEM_DEBUG
        d_logger.print(current_system);
#endif
        return current_system;
    }

    std::vector<int> Worker::generate_values(const std::vector<std::vector<int> > &system)
    {
        //setting values
        std::vector<int> current_values;
        std::vector<int> original_values;
        for(int i = 0; i < _K; i++)
        {
            original_values.push_back(i+1);
        }
#ifdef HRB_GENERATE_VALUES_DEBUG
        d_logger.print("Original values:");
        d_logger.print(original_values);
#endif
        for(int i = 0; i < _K; ++i)
        {
            int result = 0;
            for(int j = 0; j < _K; ++j)
            {
                result = (result + (system[i][j] * (j+1))) % RING_BASE;
            }
            current_values.push_back(result);
        }
        return current_values;
    }

    std::vector<int> Worker::solve_system(const std::vector<std::vector<int> > &system, const std::vector<int> &values)
    {
        std::vector<std::vector<int> > current_system = system;
        std::vector<int> current_values = values;
        //forward solve
        for(int i = 0; i < _K; ++i)
        {
            if(0 == current_system[i][i])
            {
                for(int j = i; j < _K; ++j)
                {
                    if(1 == current_system[j][i])
                    {
                        //swap
                        std::vector<int> swp;
                        swp = current_system[i];
                        current_system[i] = current_system[j];
                        current_system[j] = swp;

                        //values swap
                        int swp_val;
                        swp_val = current_values[i];
                        current_values[i] = current_values[j];
                        current_values[j] = swp_val;
                    }
                }
            }
#ifdef HRB_SOLVE_SYSTEM_DEBUG
            d_logger.print(current_system, current_values);
            d_logger.print("Swapped");
#endif

            for(int j = i+1; j < _K; j++)
            {
                if(current_system[j][i] != 0)
                {
                    for(int k = 0; k < _K; k++)
                    {
                        current_system[j][k] = current_system[j][k]^current_system[i][k];
                    }
                    current_values[j] = current_values[j]^current_values[i];
                }
            }
#ifdef HRB_SOLVE_SYSTEM_DEBUG
            d_logger.print(current_system, current_values);
#endif
        }
#ifdef HRB_SOLVE_SYSTEM_DEBUG
            d_logger.print("*** FORWARD END. ***");
#endif
        //backward solve
        for(int i = _K-1; i >= 0; i--)
        {
            for(int j = i-1; j >= 0; j--)
            {
                if(current_system[j][i] != 0)
                {
                    for(int k = 0; k < _K; k++)
                    {
                        current_system[j][k] = current_system[j][k]^current_system[i][k];
                    }
                    current_values[j] = current_values[j]^current_values[i];
                }
            }
#ifdef HRB_SOLVE_SYSTEM_DEBUG
            d_logger.print(current_system, current_values);
#endif
        }
        return current_values;
    }

    std::vector<int> Worker::get_next_mask(std::vector<int> mask)
    {
        int count = -1; // counting '1' values to rewrite them instead of moving
        const int N = _N;
        for(int i = N-1; i >= 0; --i) // move to the right
        {
            if(1 == mask[i])
            {
                ++count;
                if(0 == mask[i+1])
                {
                    mask[i+1] = 1;
                    mask[i] = 0;

                    for(int j = i+2; j < N; ++j) // rewrite "right" part
                    {
                        if(count > 0)
                        {
                            mask[j] = 1;
                            --count;
                        }
                        else
                        {
                            mask[j] = 0;
                        }
                    }
                    break;
                }
            }
        }
        return mask;
    }

    std::vector<int> Worker::init_mask(bool final_mask)
    {
        if(final_mask)
        {
            std::vector<int> final_mask;

            for(int i = 0; i < _N+1; ++i)
            {
                final_mask.push_back(0);
            }
            for(int i = 0; i < _K; ++i)
            {
                final_mask[_N-1-i] = 1;
            }
            final_mask[_N] = 2;
            return final_mask;
        }
        else
        {
            std::vector<int> mask;
            for(int i = 0; i < _N+1; ++i)
            {
                mask.push_back(0);
            }
            for(int i = 0; i < _K; ++i)
            {
                mask[i] = 1;
            }
            mask[_N] = 2;
            return mask;
        }
    }
}
