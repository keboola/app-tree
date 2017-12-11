import csv
from keboola import docker

def update_parents(parent, child, roots_map, nodes_map):
  if child in nodes_map:
    children = nodes_map.pop(child)
    for c in children:
      roots_map[c] = parent
    children.add(child)
    parentChildren = nodes_map.get(parent, set())
    parentChildren.update(children)
    nodes_map[parent] = parentChildren
  else:
    newChildren = nodes_map.get(parent, set())
    newChildren.add(child)
    nodes_map[parent] = newChildren
  return (roots_map, nodes_map)


def find_roots(rows, parent_column, child_column):
  # parent - children set pairs map
  nodes_map = {}
  # child - parent pais map
  roots_map = {}
  null_nodes = set()
  for row in rows:
    parent = row[parent_column]
    child = row[child_column]
    if parent == '0' or parent == '':
      nodes_map[child] = set()
      null_nodes.add(child)
    else:
      new_parent = parent
      if parent in roots_map:
        new_parent = roots_map[parent]
      roots_map[child] = new_parent
      roots_map, nodes_map = update_parents(new_parent, child, roots_map, nodes_map)

    #print(row, roots_map, nodes_map)
  #print("roots map", roots_map)
  #print("nodes map", nodes_map)
  print("DONE:", "Number of roots found:", len(null_nodes), "Number of nodes with root found:", len(roots_map))
  return {"roots": roots_map, "null_nodes": null_nodes}



def run():
  cfg = docker.Config()
  parameters = cfg.get_parameters()
  c_parent = parameters.get('parent_column')
  c_child = parameters.get('child_column')
  if c_parent is None or c_child is None:
    raise ValueError("parent_column and child_column are required parameters.")
  # get input and output table and validate them
  tables = cfg.get_input_tables()
  if len(tables) != 1:
      raise ValueError("Input mapping must contain one table only.")
  in_table = tables[0]
  tables = cfg.get_expected_output_tables()
  if len(tables) != 1:
      raise ValueError("Output mapping must contain one table only.")
  out_table = tables[0]
  # physical location of the source file with source data
  in_file_path = in_table['full_path']
  # physical location of the target file with output data
  out_file_path = out_table['full_path']
  result = {}

  with open(in_file_path, mode='rt', encoding='utf-8') as in_file:
    lazy_lines = (line.replace('\0', '') for line in in_file)
    csv_reader = csv.DictReader(lazy_lines, dialect='kbc')
    result = find_roots(csv_reader, c_parent, c_child)
  with open(out_file_path, mode='wt', encoding='utf-8') as out_file:
    writer = csv.DictWriter(out_file, fieldnames=['childId', 'rootId'], dialect='kbc')
    writer.writeheader()
    for child, root in result.get("roots", {}).items():
      out_row = {'childId': child, 'rootId': root}
      writer.writerow(out_row)
    for null_node in result.get("null_nodes", set()):
      out_row = {'childId': null_node, 'rootId': null_node}
      writer.writerow(out_row)
