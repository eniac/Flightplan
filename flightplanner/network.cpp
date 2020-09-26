/*
Flightplanner
Nik Sultana, UPenn, February 2019 -- July 2020
*/

#include <cassert>
#include <cmath>
#include <iostream>
#include <map>
#include <set>
#include <list>
#include <vector>
#include <numeric>
#include <iostream>
#include <fstream>

#include <boost/bind.hpp>
#include <boost/coroutine/coroutine.hpp>
#include <boost/none.hpp>
#include <boost/optional.hpp>
#include <boost/program_options.hpp>

#include <boost/property_tree/ptree.hpp>
#include <boost/property_tree/json_parser.hpp>

#include "json/single_include/nlohmann/json.hpp"

#include "table.h"
#include "network.h"

const PortID nonExistantPortID = "";

std::string Point::toString(void) const {
  return node->name + "." + port;
}

Point Point::conjugate() {
  return node->getExternalPeer(port);
}

std::string Node::toString (void) const
{
  return this->name;
}

std::string Link::toString (void) const
{
  //return a->toString() + " -- "/*FIXME const*/ + b->toString();
  return a->toString() + "." + a_port + " -- "/*FIXME const*/ + b->toString() + "." + b_port;
}

Point Node::getExternalPeer(PortID port) {
  Link *link = this->ports[port];
  Point result = link->getA();
  if (result.node != this) {
    return result;
  }
  result = link->getB();
  if (result.node != this) {
    return result;
  }
  assert(false);
}

std::vector<Point> Node::getInternalPeers(PortID exclude_port) {
  std::vector<Point> result;
  for (const std::pair<PortID, Link*>& port : ports) {
    if (port.first != exclude_port) {
      bool found_link = false;
      Point pt = port.second->getA();
      if (pt.node == this && pt.port == port.first) {
        result.push_back(pt);
        found_link = true;
      }
      if (!found_link) {
        pt = port.second->getB();
        if (pt.node == this && pt.port == port.first) {
          result.push_back(pt);
          found_link = true;
        }
      }
      assert(found_link);
    }
  }
  return result;
}

std::string Network::toString (void) const
{
  std::string result;

  for (const Node *node : Nodes) {
    result += node->toString() + "\n"/*FIXME const separator*/;
  }

  for (const Link *link : Links) {
    result += link->toString() + "\n"/*FIXME const separator*/;
  }

  return result;
}

void Node::link (Link *link) {
  Point linkTip;
  linkTip = link->getA();
  if (linkTip.node == this) {
    std::map<PortID, Link*>::iterator it;
    it = ports.find(linkTip.port);
    assert(it == ports.end());
    ports[linkTip.port] = link;
    return;
  }

  linkTip = link->getB();
  if (linkTip.node == this) {
    std::map<PortID, Link*>::iterator it;
    it = ports.find(linkTip.port);
    assert(it == ports.end());
    ports[linkTip.port] = link;
    return;
  }

  assert(0); // FIXME raise exception since this link doesn't involve this node.
};

void Node::formNetwork (Network &result) const
{
  std::set<Node*> nodes;
  nodes.insert((Node *)this);
  while (!nodes.empty()) {
    std::set<Node*>::iterator it = nodes.begin();
    Node *node = *it;
    nodes.erase(it);
    it = result.Nodes.find(node);
    if (it == result.Nodes.end()) {
      result.Nodes.insert(node);

      for (const std::pair<PortID, Link*> pair : node->ports) {
        result.Links.insert(pair.second);
        nodes.insert(pair.second->getA().node);
        nodes.insert(pair.second->getB().node);
      }
    }
  }
}

void Link::formNetwork (Network &network) const
{
  a->formNetwork(network);
}

Link::Link (Node *a, PortID a_port, std::vector<Data::BoundRel> a_bounds, Node *b, PortID b_port, std::vector<Data::BoundRel> b_bounds) : a_bounds(a_bounds), b_bounds(b_bounds), a(a), a_port(a_port), b(b), b_port(b_port)
{
    assert(a != b);
    assert(a != nullptr);
    assert(b != nullptr);
    a->link(this);
    b->link(this);
};

Point Link::getA (void) const
{
  Point point;
  point.node = a;
  point.port = a_port;
  point.bounds = a_bounds;
  return point;
}

Point Link::getB (void) const
{
  Point point;
  point.node = b;
  point.port = b_port;
  point.bounds = b_bounds;
  return point;
}

std::vector<Point> radius (bool intra_node, Point& start) {
  if (intra_node) {
    return start.node->getInternalPeers(start.port);
  } else {
    return std::vector<Point>{start.node->getExternalPeer(start.port)};
  }
}

const int loop_check_threshold = 2;

void all_paths (path_coroutine::push_type& yield, bool internal, bool seek_loop, std::vector<Point> path_so_far, Network& network, unsigned maximum_length, Point& start, Point& end) {
// NOTE I alternate internal/external points
  if (maximum_length < path_so_far.size()) {
    return;
  }

  path_so_far.push_back(start);
  if (end == start) {
    if (!seek_loop || (seek_loop && path_so_far.size() > 1)) {
      yield(path_so_far);
      return;
    }
  }

  std::vector<Point> points = radius(internal, start);
  if (points.size() == 0) {
    internal = !internal;
    points = radius(internal, start);
  }

  for (const Point& point : points) {
    path_coroutine::pull_type rest{std::bind(all_paths, std::placeholders::_1, !internal, seek_loop, path_so_far, network, maximum_length, point, end)};
    while (!rest == 0) {
      yield(rest.get());
      rest();
    }
  }
}

std::set<Link*> Network::getLinksUndirected(const Node *node_a, const Node *node_b) const
{
  std::set<Link*> result;
  for (Link *link : this->Links) {
    if ((link->getA().node == node_a && link->getB().node == node_b) ||
        (link->getA().node == node_b && link->getB().node == node_a)) {
      result.insert(link);
    }
  }
  return result;
}
