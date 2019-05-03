import sys
import json
import copy
from argparse import ArgumentParser
from collections import defaultdict
from collections import OrderedDict

parser = ArgumentParser()
parser.add_argument('input', type=str)
parser.add_argument('output', type=str)
parser.add_argument('ops', nargs='+')

args = parser.parse_args()


def split_op(j, op):
    actions = []
    id_offset = 0

    id_map = {}
    split_actions = defaultdict(list)

    for action in j['actions']:
        p1 = []
        p2 = None
        p3 = []
        id_map[action['id']] = action['id'] + id_offset
        action['id'] += id_offset
        for primitive in action['primitives']:
            if primitive['op'] != op:
                if p2 is None:
                    p1.append(primitive)
                else:
                    p3.append(primitive)
            else:
                p2 = primitive

        has_p1 = False
        if len(p1) > 0 or (len(p1) == 0 and p2 is None):
            action['primitives'] = p1
            actions.append(action)
            has_p1 = True

        if p2 is None:
            continue

        a2 = copy.deepcopy(action)
        a2['primitives'] = [p2]
        if has_p1:
            a2['name'] += '_2'
            a2['id'] += 1
            a2['primitives'] = [p2]
            id_offset += 1
            split_actions[action['name']].append(a2)

        actions.append(a2)

        if len(p3) == 0:
            continue

        a3 = copy.deepcopy(action)
        a3['name'] += '_3'
        a3['id'] += 2 if has_p1 else 1
        a3['primitives'] = p3
        id_offset += 1

        actions.append(a3)
        split_actions[action['name']].append(a3)
    j['actions'] = actions

    id_offset = 0
    for pipeline in j['pipelines']:
        tables = []
        for table in pipeline['tables']:
            found = False
            table['action_ids'] = [id_map[x] for x in table['action_ids']]
            if table['default_entry']['action_id'] in id_map:
                table['default_entry']['action_id'] = \
                        id_map[table['default_entry']['action_id']]
            table['id'] += id_offset

            for name in split_actions:
                if name in table['actions']:
                    found = True
                    break

            tables.append(table)
            if not found:
                continue

            t_prev = table
            t_init = copy.deepcopy(table)
            for i, action in enumerate(split_actions[name]):
                t_next = copy.deepcopy(t_init)
                t_next['name'] += '_' + str(i + 2)
                t_next['id'] += i + 1
                id_offset += 1

                t_next['action_ids'] = [x+1 + i for x in t_next['action_ids']]
                t_next['actions'] = [x + "_" + str(i + 2) for x in t_next['actions']]
                t_next['default_entry']['action_id'] = t_next['action_ids'][0]

                t_prev['base_default_next'] = t_next['name']
                t_prev['next_tables'] = {
                        t_prev['actions'][0] : t_next['name']
                }
                #t_prev['default_entry']['action_id'] = t_next['id']
                tables.append(t_next)
                t_prev = t_next

            next_key, next_val  = t_prev['next_tables'].items()[0]
            t_prev['next_tables'][t_prev['actions'][0]]  = next_val
            del t_prev['next_tables'][next_key]

        pipeline['tables'] = tables

def add_externs(j):
    externs = dict()
    for action in j['actions']:
        for primitive in action['primitives']:
            if len(primitive['parameters']) == 0:
                continue
            parameter = primitive['parameters'][0]
            if parameter['type'] == 'extern':
                if primitive['op'].startswith('_'):
                    externs[parameter['value']] = primitive['op'].split('_')[1]
    print(externs)
    for extern_instance in j['extern_instances']:
        if extern_instance['name'] in externs:
            del externs[extern_instance['name']]

    for name, typ in externs.items():
        j['extern_instances'].append({"name": name, "type": typ, "id": len(j['extern_instances'])})



j = json.load(open(args.input), object_pairs_hook=OrderedDict)
for op in args.ops:
    split_op(j, op)
add_externs(j)



class MyJSONEncoder(json.JSONEncoder):
    def __init__(self, *args, **kwargs):
        super(MyJSONEncoder, self).__init__(*args, **kwargs)
        self.current_indent = 0
        self.current_indent_str = ""

    def encode(self, o):
        #Special Processing for lists
        if isinstance(o, (list, tuple)):
            primitives_only = True
            for item in o:
                if isinstance(item, (list, tuple, dict)):
                    primitives_only = False
                    break
            output = []
            if primitives_only:
                for item in o:
                    output.append(json.dumps(item))
                return "[" + ", ".join(output) + "]"
            else:
                self.current_indent += self.indent
                self.current_indent_str = "".join( [ " " for x in range(self.current_indent) ])
                for item in o:
                    output.append(self.current_indent_str + self.encode(item))
                self.current_indent -= self.indent
                self.current_indent_str = "".join( [ " " for x in range(self.current_indent) ])
                return "[\n" + ",\n".join(output) + "\n" + self.current_indent_str + "]"
        elif isinstance(o, (dict, OrderedDict)):
            output = []
            self.current_indent += self.indent
            self.current_indent_str = "".join( [ " " for x in range(self.current_indent) ])
            for key, value in o.iteritems():
                output.append(self.current_indent_str + json.dumps(key) + " : " + self.encode(value))
            self.current_indent -= self.indent
            self.current_indent_str = "".join( [ " " for x in range(self.current_indent) ])
            return "{\n" + ",\n".join(output) + "\n" + self.current_indent_str + "}"
        else:
            return json.dumps(o)

# For some reason was only working with json.dumps, not json.dump
open(args.output, 'w').write(json.dumps(j, indent=2, cls=MyJSONEncoder))
