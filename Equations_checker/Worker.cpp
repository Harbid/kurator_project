#include "Worker.h"

namespace eq_checker
{
    Worker::Worker(){}
    Worker::~Worker(){}

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

    int Worker::get_equations_from_file()
    {
        int K = 8;
        int N = 9;
        std::fstream input;
        input.open("C:/Users/Harbid/Documents/Qt Project/Equations_checker/equations.txt", std::fstream::in);
        for(int i = 0; i < N; ++i)
        {
            std::vector<int> mask;
            char val = 0;
            for(int j = 0; j < K; ++j)
            {
                input >> val;
                mask.push_back(val - '0');
            }
#ifdef HRB_GET_EQ_FROM_FILE_DEBUG
            d_logger.print(mask);
#endif
            all_equations_masks.push_back(mask);
            this->_K = K;
            this->_N = N;
        }
        input.close();
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
#ifdef DEBUG_PRINT
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
                result = result^(system[i][j] * (j+1));
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

    void Worker::check()
    {
        std::vector<int> mask = init_mask(0);
        std::vector<int> final_mask = init_mask(1);
        std::vector<int> original_values;
        for(int i = 0; i < _K; i++)
        {
            original_values.push_back(i+1);
        }
        int succeeded_systems = 0;
        int failed_systems = 0;
        //while(mask != final_mask)
        for(int i = 0; i < 9; ++i)
        {
            std::vector<std::vector<int> > current_system = get_current_system(mask);
            std::vector<int> current_values = generate_values(current_system);
            std::vector<int> solved_values = solve_system(current_system, current_values);
#ifdef HRB_CHECK_DEBUG
            d_logger.print(current_system, current_values);
            d_logger.print(solved_values);
            d_logger.skip_line();
#endif
            if(original_values == solved_values)
            {
                //std::cout << "Success" << std::endl;
                ++succeeded_systems;
                if(succeeded_systems % 10000 == 0)
                {
                    std::cout << "Still working\n";
                }
            }
            else
            {
                //std::cout << "Error" << std::endl;
                ++failed_systems;
            }
            mask = get_next_mask(mask);
        }
        std::cout << "Succeeded " << succeeded_systems << " times.\n";
        std::cout << "Failed " << failed_systems << " times.\n";
        return;
    }

    void Worker::print()
    {
        for(int i = 0; i < _N; ++i)
        {
            for(int j = 0; j < _K; ++j)
            {
                std::cout << all_equations_masks[i][j];
            }
            std::cout << std::endl;
        }
        std::cout << "Total equations: " << _N << std::endl;
        return;
    }
}
