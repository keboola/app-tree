import csv
from keboola import docker


def get_rest(row, child_column):
    return {k: row[k] for k in row if k != child_column}


def parse_tree(rows, parent_column, child_column):
    grouped_relations = {}
    roots = set()
    rest = {}
    orphaned_parents = set()
    all_children = set()
    for row in rows:
        parent = row[parent_column]
        child = row[child_column]
        rest[child] = get_rest(row, child_column)
        if child == parent:
            roots.add(child)
        else:
            group = grouped_relations.get(parent, set())
            group.add(child)
            grouped_relations[parent] = group
            if child in orphaned_parents:
                orphaned_parents.remove(child)
            if parent not in all_children:
                orphaned_parents.add(parent)
            all_children.add(child)

    # take all children of non existent parents and make them roots
    for orphaned_parent in orphaned_parents:
        if orphaned_parent not in roots:
            orphaned_children = grouped_relations[orphaned_parent]
            roots.update(orphaned_children)
            grouped_relations.pop(orphaned_parent)
    return roots, grouped_relations, rest


def walk_tree_r(node, relations, level, root):
    yield (node, level, root)
    for child in relations.get(node, set()):
        yield from walk_tree_r(child, relations, level + 1, root)


def walk_tree(roots, relations):
    for root in roots:
        yield from walk_tree_r(root, relations, 1, root)


def run(datadir):
    cfg = docker.Config(datadir)
    parameters = cfg.get_parameters()
    c_parent = parameters.get('parentColumn', 'categoryParentId')
    c_child = parameters.get('idColumn', 'categoryId')

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
    roots = set()
    relations = {}
    with open(in_file_path, mode='rt', encoding='utf-8') as in_file:
        lazy_lines = (line.replace('\0', '') for line in in_file)
        csv_reader = csv.DictReader(lazy_lines, dialect='kbc')
        input_csv_header = csv_reader.fieldnames
        if c_child not in input_csv_header:
            raise Exception('Column ' + c_child + 'not present in table')
        if c_parent not in input_csv_header:
            raise Exception('Column ' + c_parent + 'not present in table')
        roots, relations, rest = parse_tree(csv_reader, c_parent, c_child)

    with open(out_file_path, mode='wt', encoding='utf-8') as out_file:
        out_csv_header = input_csv_header + ['levels', 'root']
        writer = csv.DictWriter(out_file, fieldnames=out_csv_header,
                                dialect='kbc')
        writer.writeheader()
        for child, level, root in walk_tree(roots, relations):
            base_row = {c_child: child, 'levels': level, 'root': root}
            rest_row = rest[child]
            out_row = {**base_row, **rest_row}
            writer.writerow(out_row)
