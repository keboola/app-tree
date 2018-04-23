from src.root_finder import run
import pytest
from distutils.dir_util import copy_tree
from shutil import copyfile
import csv
from keboola import docker


def test_run_00(tmpdir):
    src = 'tests/data/00'
    config_path = src + '/config.json'
    dst = str(tmpdir.realpath())
    copy_tree(src + "/in", dst + "/in")
    copyfile(config_path, dst + "/config.json")
    tmpdir.mkdir("out").mkdir("tables")
    run(dst)
    current = set(open(dst + "/out/tables/result.csv", "r+").
                  read().splitlines())
    expected = set(open(src + "/out/tables/result.csv", "r+").
                   read().splitlines())
    print(current)
    print(expected)
    assert len(current - expected) == 0


success_dirs_params = [
    ('01', {'1': '1', '2': '2', '3': '2', '4': '3'},
     {'1': '1', '2': '1', '3': '1', '4': '1'}, 'tree.csv'),
    ('02', {'1': '1', '2': '2', '3': '2', '4': '3'},
     {'1': '1', '2': '1', '3': '1', '4': '1'}, 'tree.csv'),
    ('03', {'a': '1', 'b': '2', 'c': '1', 'd': '3'},
     {'a': 'a', 'b': 'c', 'c': 'c', 'd': 'c'}, 'tree.csv'),
    ('04', {'1': '1', '2': '2', '3': '2', '4': '3'},
     {'1': '1', '2': '1', '3': '1', '4': '1'}, 'tree.csv'),
    ('06', {'1': '1', '2': '2', '3': '2', '4': '3'},
     {'1': '1', '2': '1', '3': '1', '4': '1'}, 'some-output.csv')
]


@pytest.fixture(params=success_dirs_params)
def datadir_and_results(request):
    return request.param


def test_success_run(tmpdir, datadir_and_results):
    dir_name, expected_levels, expected_roots, out_file_name = \
        datadir_and_results
    src = 'tests/data/' + dir_name
    dst = str(tmpdir.realpath()) + "/" + dir_name
    copy_tree(src, dst)
    run(dst)
    current = dst + "/out/tables/" + out_file_name
    cfg = docker.Config(dst)
    parameters = cfg.get_parameters()
    c_child = parameters.get('idColumn', 'categoryId')
    with open(current, mode='rt', encoding='utf-8') as in_file:
        lazy_lines = (line.replace('\0', '') for line in in_file)
        csv_reader = csv.DictReader(lazy_lines, dialect='kbc')
        row_count = 0
        for row in csv_reader:
            child = row[c_child]
            level = row['levels']
            root = row['root']
            assert expected_levels[child] == level
            assert expected_roots[child] == root
            row_count = row_count + 1
        assert row_count == len(expected_levels)


def test_invalid_column(tmpdir):
    dir_name = '05'
    src = 'tests/data/' + dir_name
    dst = str(tmpdir.realpath()) + "/" + dir_name
    copy_tree(src, dst)
    with pytest.raises(Exception) as excinfo:
        run(dst)
    assert 'not present in table' in str(excinfo.value)


def test_empty_table(tmpdir):
    dir_name = '07'
    src = 'tests/data/' + dir_name
    dst = str(tmpdir.realpath()) + "/" + dir_name
    copy_tree(src, dst)
    run(dst)
    # cfg = docker.Config(dst)
    # parameters = cfg.get_parameters()
    # c_child = parameters.get('idColumn', 'categoryId')
    current = dst + "/out/tables/some-output.csv"
    with open(current, mode='rt', encoding='utf-8') as in_file:
        lazy_lines = (line.replace('\0', '') for line in in_file)
        csv_reader = csv.DictReader(lazy_lines, dialect='kbc')
        assert len(list(csv_reader)) == 0
        assert csv_reader.fieldnames == ["categoryId", "categoryParentId",
                                         "title", "levels", "root"]
