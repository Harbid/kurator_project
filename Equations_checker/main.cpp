#include "Worker.h"
#include "worker_v2.h"

Debug_logger d_logger;

int main()
{
    using namespace eq_checker_v2;

    Worker worker;
    worker.generate_multiplication_table(257);
    std::cout << "Main cout\n";

    return 0;
}
