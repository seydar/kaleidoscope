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
