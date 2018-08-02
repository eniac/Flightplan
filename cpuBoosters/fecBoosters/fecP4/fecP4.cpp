#include <chrono>
#include <unordered_map>
#include "fecBooster.h"

using std::chrono::steady_clock;


static std::unordered_map<uint8_t, steady_clock::time_point> port_statuses;

#define PORT_TIMEOUT_S 9999

bool get_fec_port_status(uint8_t port) {
    auto it = port_statuses.find(port);
    if (it == port_statuses.end()) {
        LOG_INFO("Port %d not in port statuses", (int)port);
        return false;
    }
    steady_clock::time_point start = it->second;
    auto now = steady_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::seconds>( now - start );
    if (duration > std::chrono::seconds(PORT_TIMEOUT_S)) {
        LOG_INFO("Port on for too long: %d seconds", (int)duration.count());
        port_statuses.erase(it);
        return false;
    }
    return true;
}

void set_fec_port_status(uint8_t port) {
    auto now = steady_clock::now();
    port_statuses[port] = now;
    LOG_INFO("Inserted port %d into port statuses", (int)port);
}

