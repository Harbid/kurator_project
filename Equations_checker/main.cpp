#include "Worker.h"
#include "worker_v2.h"
#include "worker_v3.h"

Debug_logger d_logger;

int main()
{
    using namespace eq_checker_v2;

    Worker worker;
    /*
    std::vector<int> mask = worker.init_mask(0, 40, 64);
    std::vector<int> final_mask = worker.init_mask(1, 40, 64);

    worker.generate_equations(4,8);
    mask = worker.get_mask_from_eq();

    int failed_systems = 0;
    int min_fails = 70;
    int count = 0;
    bool finished = false;
    while(mask != final_mask || !finished)
    //for(int i = 0; i < 1000; ++i)
    {
        if(mask == final_mask)
        {
            finished = true;
        }
        worker.generate_equations(4,8, mask);
        failed_systems = worker.check();
        if(failed_systems != 70 && min_fails > failed_systems)
        {
            min_fails = failed_systems;
            std::cout << "New record: " << failed_systems << " ";
        }
        count++;
        if(count%1000 == 0)
        {
            std::cout << "still working.\n";
        }
        mask = worker.get_next_mask(mask, 64);
    }*/


    //worker.generate_equations(4,8);
    //worker.get_equations_from_file();
    //worker.check();
    //worker.print();

    worker.generate_multiplication_table(29);
    worker.generate_equations(8,21);
    worker.check();
    worker.print();

    std::cout << "Main cout\n";

    return 0;
}
