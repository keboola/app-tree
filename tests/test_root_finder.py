import pytest
import io
import csv
from root_finder import find_roots
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

def test_find_roots():
  result = find_roots(input, 'parent', 'child')
  assert 'roots' in result
  assert 'null_nodes' in result
  assert result['roots'] == {'2': '1', '777': '1', '77': '1', '7': '1', '3': '1', '4': '1', '8': '1', '5': '1'}
  assert result['null_nodes'] == {'1'}
