
#ifdef NS3_MODULE_COMPILATION
# error "Do not include ns3 module aggregator headers from other modules; these are meant only for end user scripts."
#endif

#ifndef NS3_MODULE_LTE
    

// Module headers:
#include "amc-module.h"
#include "bearer-qos-parameters.h"
#include "channel-realization.h"
#include "discrete-time-loss-model.h"
#include "enb-lte-spectrum-phy.h"
#include "enb-mac-entity.h"
#include "enb-net-device.h"
#include "enb-phy.h"
#include "ideal-control-messages.h"
#include "jakes-fading-loss-model.h"
#include "lte-helper.h"
#include "lte-mac-header.h"
#include "lte-mac-queue.h"
#include "lte-net-device.h"
#include "lte-phy.h"
#include "lte-propagation-loss-model.h"
#include "lte-spectrum-phy.h"
#include "lte-spectrum-signal-parameters.h"
#include "lte-spectrum-value-helper.h"
#include "mac-entity.h"
#include "packet-scheduler.h"
#include "path-loss-model.h"
#include "penetration-loss-model.h"
#include "radio-bearer-instance.h"
#include "rlc-entity.h"
#include "rrc-entity.h"
#include "shadowing-loss-model.h"
#include "simple-packet-scheduler.h"
#include "ue-lte-spectrum-phy.h"
#include "ue-mac-entity.h"
#include "ue-manager.h"
#include "ue-net-device.h"
#include "ue-phy.h"
#include "ue-record.h"
#endif
