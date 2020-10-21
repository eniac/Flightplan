# Firewall example
In this example, [ALV routing](https://github.com/eniac/Flightplan/blob/master/Wharf/splits/ALV_Complete_2_FW/ALV_FW_split1.p4#L104)
is combined with the P4 tutorial
[firewall](https://github.com/p4lang/tutorials/blob/76a9067deaf35cd399ed965aa19997776f72ec55/exercises/firewall/solution/firewall.p4#L189), but instead of running this firewall on the router, it is offloaded to a supporting device (`D_FW_1`) as shown in the [control program profile](https://github.com/eniac/Flightplan/blob/master/Wharf/splits/ALV_Complete_2_FW/FPControlData.yml).
The firewall's configuration can be seen in the topology entry for [D_FW_1](https://github.com/eniac/Flightplan/blob/master/Wharf/splits/ALV_Complete_2_FW/alv_k%3D4.yml#L1239).
