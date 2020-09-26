/*
Flightplanner
Nik Sultana, UPenn, February 2019 -- July 2020
*/

#ifndef FLIGHTPLAN_NETWORK_H
#define FLIGHTPLAN_NETWORK_H

using PortID = std::string;
extern const PortID nonExistantPortID;

class Node;
class Network;
class Link;

struct Point {
  Node *node = nullptr;
  PortID port;
  std::vector<Data::BoundRel> bounds;
  bool operator==( const Point& rhs ) const {
    return (this->node == rhs.node && this->port == rhs.port);
  }
  bool operator!=( const Point& rhs ) const {
    return !(*this == rhs);
  }
  std::string toString (void) const;
  Point conjugate();
};

namespace Objective {
class Allocation;
}

class Node {
 private:
  friend class Link;
  friend struct Point;
  friend class Objective::Allocation;

  std::string name;
  std::map<PortID, Link*> ports;
  void link (Link *link);
  std::set<Data::Prop> props; // provided
  std::vector<Data::BoundRel> bounds; // required

 public:
  Node () = delete;
  Node (std::string name, std::set<Data::Prop> props, std::vector<Data::BoundRel> bounds) : name(name), props(props), bounds(bounds) {};
  std::string getName() const {
    return this->name;
  }
  void formNetwork (Network &network) const;
  std::string toString(void) const;
  Point getExternalPeer(PortID port);
  std::vector<Point> getInternalPeers(PortID port);
  std::set<Data::Prop> getProps(void) const {
    return props;
  }
  std::vector<Data::BoundRel> getBounds(void) const {
    return bounds;
  }
  std::vector<PortID> getPorts (void) const {
    std::vector<PortID> result;
    for (std::pair<PortID, Link*> port_mapping : ports) {
      result.push_back(port_mapping.first);
    }
    return result;
  }
  std::vector<Point> getPoints() {
    return getInternalPeers(nonExistantPortID);
  }
};

class Link {
 private:
  Node *a;
  PortID a_port;
  std::vector<Data::BoundRel> a_bounds;
  Node *b;
  PortID b_port;
  std::vector<Data::BoundRel> b_bounds;
 public:
  Link (Node *a, PortID a_port, std::vector<Data::BoundRel> a_bounds, Node *b, PortID b_port, std::vector<Data::BoundRel> b_bounds);
  Point getA (void) const;
  Point getB (void) const;
  void formNetwork (Network &network) const;
  std::string toString (void) const;
};

class Network {
 public:
  Network () {}
  std::set<Node*> Nodes;
  std::set<Link*> Links;
  std::string toString (void) const;
  std::set<Link*> getLinksUndirected(const Node *node_a, const Node *node_b) const;
};

extern const int loop_check_threshold;

typedef boost::coroutines::coroutine<std::vector<Point>> path_coroutine;
#endif // FLIGHTPLAN_NETWORK_H
