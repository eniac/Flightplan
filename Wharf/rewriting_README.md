# BMv2 configuration rewriting

The `booster_switch` requires that externs can create new packets
that begin their processing in the extern that generated them
(in essence, the extern returns twice -- once with the original packet,
and once with the new one).

With the code output by the bmv2 compiler, this is not possible because:
* externs may be grouped with other primitives into a single action
* new packets may only start processing at the beginning of an action

Thus, the script [split_extern_event.py](split_extern_event.py)
splits externs into an isolated action, and thus
must be run on json files before they are used by the `booster_switch`.

## BMv2 compiler format
There are two sections of the json file output by the bmv2 compiler which
are relevant for the rewiter:

* `"actions"`: each action consists of one or more primitives. A primitive is
either a built-in operation (like "drop"), or an extern
* `"tables"` (within `"pipelines"): Tables are the top-level unit of
execution in BMv2. They consist of one or more actions which may be taken
depending on a condition, and the next table which should be executed.

In order for an extern to be isolated, both the corresponding action
and the table which references it must be split into two or more parts.

## Isolation procedure
The isolation of externs within an action consists of up to three steps:
* (If there are primitives before the extern) modify the original action to include only the primitives that occur prior to the extern
* Create a new action (copied from the original action, but with an incremented ID and new name)
which contains only the extern's primitive
* (If there are primitives after the extern) create a new action which contains
only the primtiives which occur after the extern

Because of the fact that the ID of the new actions are incremented from the old ones,
any actions which occur after that must have their IDs incremented as well, to ensure
that there are no overlapping IDs.
Thus, the script maintains a mapping of old IDs to new IDs.

After the actions is isolated, the tables which reference it must be isolated.
That procedure is as follows:
* Update the `"action_ids"` of all tables to match the id of actions that have been modified
* If the table references an action which has been split into multiple actions,
create one or two new tables (depending on whether the action has been split into
two or three parts), which reference the appropriate actions, and link to each other via
the `"next_tables"`field.

## TODOs

* There is a bug in the script that does not affect bmv2 functionality,
but does affect labeling:
In the case where a table must be split into three parts to isolate the
extern primtiive, the "name" field of the third table is not updated to match
the name of the third action. The "action_id" is however updated,
and that seems to be what bmv2 cares about.
* It is possible that an extern does not truly need to be isolated in an action,
and that instead it must just be the first primitive in the action. If that is the case,
the third action never needs to be created. This should be tested at some point
so the code can be simplified.
