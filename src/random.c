/* %W% %G% */
#include <stdio.h>
#include <math.h>
#include "defs.h"
#include <stdlib.h>

/*
Thu Sep 20 14:10:43 PDT 2012
NO these must be cont long int
#define MODULUS  65536
#define MULTIPLIER 25173
#define INCREMENT 13849
*/

/*const long int MODULUS= 65536;     /*  m */
/*const long int MULTIPLIER = 25173; /* a */
/*const long int  INCREMENT = 13849; /*c */

const long int MODULUS= 2147483648 ;     /*  m */
const long int MULTIPLIER = 1103515245; /* a */
const long int  INCREMENT = 12345; /*c */


int
irandom()
{

  /* while ((ceed = ((MULTIPLIER * ceed) + INCREMENT) % MODULUS) <= 0)*/
  ceed=rand();//	;ceed=random()	;
    /*
    printf("irand: %d\n", ceed);
    */
    return (int) ceed;
}
/***********************************************************************/
double
rrandom()
{

  /***********************************************************************
   * This just calls the builtin random() function. Initialization is
   * done in event.c.  In case you don't care for your compiler's
   * random() you cann call real_rrandom() instead real_rrandom
   * implements what wikipedia says is gcc's cheapest/simplest random
   * number generator.
   ************************************************************************/

  double u;
  /* u=real_rrandom(); */
  u= random()/(double) RAND_MAX;  /** using system function !!!! **/
  /*fprintf(fd_allrandom,"%36.30f\n",u);*/
  return(u);
}


/************************************************************************/

double
real_rrandom()
{
  /* Thu Sep 20 14:07:32 PDT 2012 This is NOT used by default. The
     code is here in case we encounter a compiler that does not do
     random() well.
  */


    double t;
    t = (double) MODULUS;

    while ((ceed = ((MULTIPLIER * ceed) + INCREMENT) % MODULUS) <= 0)
	;
    /*
    printf("rand: %e\n", ((double) ceed)/t);
    */

    return ((double) ceed)/t;

}

double
normal()
{
    double theta, r, w;

    theta = rrandom() * 2 * PI;
    w = rrandom();
    while (w == 0)
	w = rrandom();
    r = sqrt(-2. * log(w));
    return  r * sin(theta);
}

double
fertmult()
{
    double u;

    u = rrandom();

    return  ((-1.764 + 1.995 * u) * u + 2.178) * u;
    /*
    return 1;
    */
}

double
flog(x)
double x;
{
    return cycle(x,1) - cycle(x, 2)/2
    + cycle(x, 3)/3 - cycle(x,4)/4
    + cycle(x,5)/5;
    /*
    - cycle(x,6)/6
    + cycle(x,7)/7 - cycle(x,8)/8
    + cycle(x,9)/9 - cycle(x,10)/10
    + cycle(x,11)/11 - cycle(x,12)/12
    + cycle(x,13)/13 - cycle(x,14)/14
    + cycle(x,15)/15 - cycle(x,16)/16;
    */
}

double
cycle(x,p)
double x;
int p;
{
    double y;
    int i;

    y = 1;
    for (i = 1; i <= p; i++) {
	y*=x;
    }
    return y;
}
