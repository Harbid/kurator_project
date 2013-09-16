#include "Worker.h"

namespace eq_checker
{
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
