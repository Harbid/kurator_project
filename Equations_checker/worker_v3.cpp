#include "worker_v3.h"

namespace eq_checker_v3
{
    typedef unsigned int u_int;
    Worker::Worker(){}
    Worker::~Worker(){std::cout << "Destructor called.\n";}

    int Worker::generate_equations(const int K, const int N)
    {
        if(N != K*2)
        {
            std::cout << "N should be == K*2." << std::endl;
            return -1;
        }
        this->_K = K;
        this->_N = N;
        std::vector<int> identity_mask;

        for(int i = 0; i < N; ++i)
        {
            identity_mask.push_back(1);
        }
        std::vector<int> _1_0_mask(identity_mask);
        for(int i = N/2; i < N; ++i)
        {
            _1_0_mask[i] = 0;
        }
        // 11110000
        for(int i = 0; i < N/2; ++i)
        {
             std::vector<int> mask(_1_0_mask);
             mask[i] = 0;
             mask[N-1-i] = 1;
             all_equations_masks.push_back(mask);
        }

        for(int i = 0; i < _K-1; ++i)
        {
            all_equations_masks[i][K-1] = 0;
            all_equations_masks[i][K] = 1;
        }
        for(int i = _K-1; i >= 0; --i)
        {
            std::vector<int> mask(all_equations_masks[i]);
            for(int j = 0; j < N; ++j)
            {
                mask[j] = mask[j]^identity_mask[j];
            }
            all_equations_masks.push_back(mask);
        }
/*
        all_equations_masks[3][K+1] = 1;
        all_equations_masks[3][K] = 0;

        all_equations_masks[6][K] = 1;
        all_equations_masks[6][K+1] = 0;
*/
        d_logger.print(all_equations_masks);
        return 0;
    }

    int Worker::get_equations_from_file()
    {
        int K = 4;
        int N = 8;
        std::fstream input;
        input.open("C:/Users/Harbid/Documents/QT Projects/Equations_checker/equations.txt", std::fstream::in);
        for(int i = 0; i < N; ++i)
        {
            std::vector<int> mask;
            char val = 0;
            for(int j = 0; j < N; ++j)
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
        d_logger.print(all_equations_masks);
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

    std::vector<std::vector<int> > Worker::reduce_to_system(const std::vector<std::vector<int> > &system, const std::vector<int> &system_mask)
    {
        std::vector<std::vector<int> > reduced_system;
        u_int size = system.size();

        for(u_int i = 0; i < size; ++i)
        {
            std::vector<int> equation;
            for(int j = 0; j < _N; ++j)
            {
                if(0 == system_mask[j])
                {
                    equation.push_back(system[i][j]);
                }
            }
            reduced_system.push_back(equation);
        }

        return reduced_system;
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

    int Worker::check()
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
        int prev_failed = 0;
        bool finished = false;
        while(mask != final_mask || !finished)
        //for(int i = 0; i < 1; ++i)
        {
            if(mask == final_mask)
            {
                finished = true;
            }
            std::vector<std::vector<int> > current_system = get_current_system(mask);
            std::vector<std::vector<int> > reduced_system = reduce_to_system(current_system, mask);
            std::vector<int> current_values = generate_values(reduced_system);

            std::vector<int> solved_values = solve_system(reduced_system, current_values);
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
                    //std::cout << "Still working " << failed_systems-prev_failed << " failed.\n";
                    //prev_failed = failed_systems;
                }
            }
            else
            {
                //std::cout << "al s " << succeeded_systems << std::endl;
                //std::cout << "Error" << std::endl;
                ++failed_systems;
                //d_logger.print(mask);
                //d_logger.print(all_equations_masks);
                //break;
            }
            mask = get_next_mask(mask);

        }
        std::cout << "Succeeded " << succeeded_systems << " times.\n";
        std::cout << "Failed " << failed_systems << " times.\n";
        return failed_systems;
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


    std::vector<int> Worker::get_next_mask(std::vector<int> mask, const int N)
    {
        int count = -1; // counting '1' values to rewrite them instead of moving
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
    std::vector<int> Worker::init_mask(bool final_mask, const int K, const int N)
    {
        if(final_mask)
        {
            std::vector<int> final_mask;

            for(int i = 0; i < N+1; ++i)
            {
                final_mask.push_back(0);
            }
            for(int i = 0; i < K; ++i)
            {
                final_mask[N-1-i] = 1;
            }
            final_mask[N] = 2;
            return final_mask;
        }
        else
        {
            std::vector<int> mask;
            for(int i = 0; i < N+1; ++i)
            {
                mask.push_back(0);
            }
            for(int i = 0; i < K; ++i)
            {
                mask[i] = 1;
            }
            mask[N] = 2;
            return mask;
        }
    }


    int Worker::generate_equations(const int K, const int N, std::vector<int> mask)
    {
        this->_K = K;
        this->_N = N;

        for(int i = 0; i < N; ++i)
        {
            std::vector<int> equation_mask;
            for(int j = 0; j < N; ++j)
            {
                equation_mask.push_back(mask[i*N + j]);
            }
            all_equations_masks.push_back(equation_mask);
        }
        //d_logger.print(all_equations_masks);
        return 0;
    }

    std::vector<int> Worker::get_mask_from_eq()
    {
        std::vector<int> mask;
        for(int i = 0; i < _N; ++i)
        {
            for(int j = 0; j < _N; ++j)
            {
                mask.push_back(all_equations_masks[i][j]);
            }
        }
        mask.push_back(2);
        return mask;
    }

    void Worker::print()
    {
        for(int i = 0; i < _N; ++i)
        {
            for(int j = 0; j < _K; ++j)
            {
                std::cout << std::setw(2) << all_equations_masks[i][j] << " ";
            }
            std::cout << std::endl;
        }
        std::cout << "Total equations: " << _N << std::endl;
        return;
    }
}
