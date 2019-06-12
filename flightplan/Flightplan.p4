/*
Flightplan
Nik Sultana, UPenn, August 2018
*/

#ifndef _FLIGHTPLAN_
#define _FLIGHTPLAN_

typedef bit<32> Landing;

#define LANDING(NAME) extern Landing NAME()
LANDING(Flight_Start);

extern void flyto(in Landing dest);
extern Landing currentLanding();

#endif  /* FLIGHTPLAN_ */
