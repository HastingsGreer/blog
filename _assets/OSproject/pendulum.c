#include "math.h"
#include "time.h"
#include "raylib.h"
#include "simulator.h"

struct nearest_result {
  int index;
  float distance;
  Vector2 point;
};

struct nearest_result pnearest(vector v, Vector2 query) {
  struct nearest_result res;
  res.point = pget(v, 0);
  res.distance = Vector2Distance(res.point, query);
  res.index = 0;
  for (int i = 0; i < v.len / 2; i++) {
    float d = Vector2Distance(query, pget(v, i));
    if (d < res.distance) {
      res.point = pget(v, i);
      res.distance = d;
      res.index = i;
    }
  }
  return res;
}

struct simulated_trebuchet {
	particlesystem system;
	int mainaxle;
	int projectile;
};

float range(pool* source, struct simulated_trebuchet *treb, float tfinal) {
	return 1;
}

int main() {
  float runtime_sum = 0;
  int n_runs = 0;
  #define fiffer

  Vector2 test = {1, 2};

  test = Vector2Normalize(test);

  pool *source = make_pool(100000);
  source->loud = 1;
  pool *isource = make_pool(100000);
  pool *rsource = make_pool(100000);

#ifdef TRIPLE
  vector positions = init_vec(source, 300, 100, 400, 100, 500, 100, 600, 100);
  vector masses = init_vec(source, 1, 1, 1, 2);

  particlesystem system = make_system(source, masses, positions);

  add_slider(&system, (slider){0, {0, 1}});
  add_slider(&system, (slider){0, {1, 0}});
  add_rod(&system, (rod){0, 1});
  add_rod(&system, (rod){1, 2});
  add_rod(&system, (rod){2, 3});
  matrix result;
#endif

#ifdef trebuchet
  vector positions =
      init_vec(source, 
		      300, 300,
		      350, 250,
		      100, 450,
		      400, 350,
		      300, 450,
		      );
  vector masses = init_vec(source, 1, 1, 1, 100, 1);

  particlesystem system = make_system(source, masses, positions);

  add_slider(&system, (slider){0, {0, 1}});
  add_slider(&system, (slider){0, {1, 0}});
  add_slider(&system, (slider){4, {0, 1}, 1});
  add_rod(&system, (rod){0, 1});
  add_rod(&system, (rod){1, 2});
  add_rod(&system, (rod){1, 3});
  add_rod(&system, (rod){2, 0});
  add_rod(&system, (rod){2, 4});
  matrix result;
#endif

#ifdef whipper
  vector positions =
      init_vec(source, 300, 300, 250, 350, 450, 100, 300, 250, 400, 150);
  vector masses = init_vec(source, 1, 1, 1, 1, 100);

  particlesystem system = make_system(source, masses, positions);

  add_slider(&system, (slider){0, {0, 1}});
  add_slider(&system, (slider){0, {1, 0}});
  add_rod(&system, (rod){0, 1});
  add_rod(&system, (rod){1, 2});
  add_rod(&system, (rod){2, 3});
  add_rod(&system, (rod){1, 4});
  add_rod(&system, (rod){2, 0});
  add_rod(&system, (rod){3, 0, 1});
  add_rod(&system, (rod){4, 0, 1});
  matrix result;
#endif
#ifdef fiffer
  vector positions = init_vec(source,   // source
                              200, 300, // axle
                              200, 500, // arm tip
                              185, 285, // short arm
                              400, 300, // cw anchor
                              360, 310, // cw link
                              400, 320, // cw
                              200, 310, // cw pivot
                              300, 500  // projectile
  );
  vector masses = init_vec(source, 1, 4, 1, 1, 1, 400, 1, 1);

  particlesystem system = make_system(source, masses, positions);

  add_slider(&system, (slider){0, {0, 1}});
  add_slider(&system, (slider){0, {1, 0}});
  add_slider(&system, (slider){3, {0, 1}});
  add_slider(&system, (slider){3, {1, 0}});
  add_slider(&system, (slider){6, {0, 1}});
  add_slider(&system, (slider){6, {1, 0}});
  add_slider(&system, (slider){7, {0, 1}, 1, 0});
  add_rod(&system, (rod){0, 1});
  add_rod(&system, (rod){1, 2});
  add_rod(&system, (rod){0, 2});
  add_rod(&system, (rod){2, 4});
  add_rod(&system, (rod){3, 4});
  add_rod(&system, (rod){4, 5});
  add_rod(&system, (rod){5, 6});
  add_rod(&system, (rod){1, 7});
  matrix result;
#endif
  for (int i = 0; i < 1; i++) {
	  for (int i = 0; i < 100; i++) {
      empty(rsource);

      clock_t start = clock();

      result = simulate(rsource,  &system,30);
      clock_t end = clock();
double runtime_ms = (double)(end - start) * 1000.0 / CLOCKS_PER_SEC;
      runtime_sum += runtime_ms;
      n_runs += 1;
	  }


printf("Simulation runtime: %.2f ms\n", runtime_sum / n_runs);

  }

  InitWindow(600, 600, "raylib");
  SetTargetFPS(60);
  SetExitKey(KEY_Q);
  int i = 0;
  int moved_pt = -1;
  result = simulate(rsource, &system, 30);

  while (!WindowShouldClose()) {
    i += 1;
    if (i >= result.cols) {
      i = 0;
    }
    if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON)) {
      struct nearest_result near =
          pnearest(system.positions, (Vector2){(float)GetMouseX(), (float)GetMouseY()});
      if (near.distance < 60) {
        moved_pt = near.index;
      }
    }
    if (IsMouseButtonReleased(MOUSE_LEFT_BUTTON)) {
      moved_pt = -1;
    }
    empty(isource);
    if (moved_pt != -1) {
      if (!Vector2Equals(GetMouseDelta(), (Vector2){0, 0})) {
        i = 0;

        system.positions.data[2 * moved_pt] = (float)GetMouseX();
        system.positions.data[2 * moved_pt + 1] = (float)GetMouseY();
      empty(rsource);

      clock_t start = clock();

      result = simulate(rsource,  &system,30);
      clock_t end = clock();
double runtime_ms = (double)(end - start) * 1000.0 / CLOCKS_PER_SEC;
      runtime_sum += runtime_ms;
      n_runs += 1;

printf("Simulation runtime: %.2f ms\n", runtime_sum / n_runs);
      }
    }
    if (!Vector2Equals(GetMouseDelta(), (Vector2){0, 0})) {
      struct nearest_result near =
          pnearest(system.positions, (Vector2){(float)GetMouseX(), (float)GetMouseY()});
      if (near.distance < 10) {
        SetMouseCursor(MOUSE_CURSOR_POINTING_HAND);
      } else {
        SetMouseCursor(MOUSE_CURSOR_ARROW);
      }
    }
    vector state = get_col(isource, result, i);

    vector vx = get_row(result, result.rows - 2);
    vector vy = get_row(result, result.rows - 1);

    float range = max_v(mul_vs(isource, mul_vv(isource, vx, vy), -2));

    BeginDrawing();
    ClearBackground(RAYWHITE);
    for (int j = 0; j < result.cols; j += 1) {
      vector state2 = get_col(isource, result, j);

      for (int k = 0; k < system.nrods; k++) {
        Vector2 start = pget(state2, system.rods[k].p1);
        Vector2 end = pget(state2, system.rods[k].p2);
        DrawLineEx(start, end, 1, PINK);
      }
    }
    for (int j = 0; j < system.nrods; j++) {
      Vector2 start = pget(state, system.rods[j].p1);
      Vector2 end = pget(state, system.rods[j].p2);
      DrawLineEx(start, end, 3, BLACK);
    }
    for (int j = 0; j < system.positions.len / 2; j++) {
      Vector2 start = pget(state, j);
      DrawCircleV(start, 5 * powf(system.masses.data[j * 2], 1. / 3), BLUE);
    }
    DrawText(TextFormat("Range: %.0f", range), 10, 10, 20, BLACK);

    EndDrawing();
  }
  CloseWindow();
  

  return 0;
}
