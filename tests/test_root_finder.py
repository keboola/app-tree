import pytest
import io
import csv
from root_finder import parse_tree, walk_tree
from collections import OrderedDict

input_csv_string = """
child,parent
1,0
2,1
777,7
77,7
7,3
3,1
4,2
8,5
5,777
"""

input = (
  OrderedDict([('child', '1'), ('parent', '0')]),
  OrderedDict([('child', '2'), ('parent', '1')]),
  OrderedDict([('child', '777'), ('parent', '7')]),
  OrderedDict([('child', '77'), ('parent', '7')]),
  OrderedDict([('child', '7'), ('parent', '3')]),
  OrderedDict([('child', '3'), ('parent', '1')]),
  OrderedDict([('child', '4'), ('parent', '2')]),
  OrderedDict([('child', '8'), ('parent', '5')]),
  OrderedDict([('child', '5'), ('parent', '777')])
)

def test_parse_tree():
  result = parse_tree(input, 'parent', 'child')
  assert result == ({'1'}, {'1': {'3', '2'}, '7': {'77', '777'}, '3': {'7'}, '2': {'4'}, '5': {'8'}, '777': {'5'}})

walk_tree_result  = {
  ('1', 1, '1'),
  ('3', 2, '1'),
  ('7', 3, '1'),
  ('77', 4, '1'),
  ('777', 4, '1'),
  ('5', 5, '1'),
  ('8', 6, '1'),
  ('2', 2, '1'),
  ('4', 3, '1')
}
def test_walk_tree():
  roots, relations = parse_tree(input, 'parent', 'child')
  result = walk_tree(roots, relations)
  assert set(result) == walk_tree_result
