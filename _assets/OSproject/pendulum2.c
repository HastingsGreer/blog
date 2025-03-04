#include "simulator.h"

int main() {

  pool *source = make_pool(1000000);
  source->loud = 1;
  pool *isource = make_pool(1000000);

  vector positions = init_vec(source, 300, 100, 400, 100, 500, 100, 600, 100);
  vector masses = init_vec(source, 1, 1, 1, 2);

  particlesystem system = make_system(source, masses, positions);

  add_slider(&system, (slider){0, {0, 1}});
  add_slider(&system, (slider){0, {1, 0}});
  add_rod(&system, (rod){0, 1});
  add_rod(&system, (rod){1, 2});
  add_rod(&system, (rod){2, 3});
  matrix result;
  result = simulate(source,  &system, 30);
//print_matrix(result);
}
