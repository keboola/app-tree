from root_finder import run
import pytest
from distutils.dir_util import copy_tree
from shutil import copyfile

def test_run(tmpdir):
  src = 'tests/data'
  configPath = src + '/config.json'
  dst = str(tmpdir.realpath())
  copy_tree(src + "/in", dst + "/in")
  copyfile(configPath, dst + "/config.json")
  tmpdir.mkdir("out").mkdir("tables")
  run(dst)
  current = set(open(dst + "/out/tables/result.csv", "r+").read().splitlines())
  expected = set(open(src + "/out/tables/result.csv", "r+").read().splitlines())
  print(current)
  print(expected)
  assert len(current - expected) == 0
