#include <stdio.h>

/* taken from RLTK's kazoo implementation */
/* putchard - putchar that takes a double and returns 0. */
double putchard(double x) {
	putchar((int) x);
	fflush(stdout);
	
	return 0;
}

double putd(double x) {
	printf("%f\n", x);
	fflush(stdout);
	
	return 0;
}


float allocate() {
  printf("@");
  fflush(stdout);
  
  return 0;
}

float put() {
  printf("*");
  fflush(stdout);
  return 0;
}

float update() {
  printf("$");
  fflush(stdout);
  return 0;
}

float get() {
  printf("#");
  fflush(stdout);
  return 0;
}

float create() {
  printf("!");
  allocate();
  put();
  update();
  fflush(stdout);
  return 0;
}
