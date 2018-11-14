#ifndef BOOSTER_SWITCH__FEC_BOOSTER_PRIMTIVES_H_
#define BOOSTER_SWITCH__FEC_BOOSTER_PRIMTIVES_H_

#ifdef FEC_BOOSTER
int import_fec_booster_primitives(SimpleSwitch *sswitch);
#else
static int import_fec_booster_primitives(SimpleSwitch *sswitch) {}
#endif

#endif  // BOOSTER_SWITCH__FEC_BOOSTER_PRIMTIVES_H_
