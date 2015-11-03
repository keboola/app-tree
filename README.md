Compute tree levels
==================

This application computes levels in a table representing a tree (e.g. product categories). The tree data must be stored in a child-parent relationship. The table must contain columns **categoryId** and **categoryParentId**. 
A column named **levels** will be added to the table (root nodes will have number 1).

Configuration
-------------------

Both input and output file is named **tree.csv**. The application takes no parameters - see the screenshot for sample configuration

![Configuration screenshot](https://github.com/keboola/r-custom-application-tree/blob/master/doc/screenshot.png)

Sample input 
-------------------

categoryId | categoryParentId	| title
--- | --- | --- 
1 |	0 | foo
2 | 1 | bar
3 | 1 | baz
4 | 2 | buzz


Sample output
-------------------

categoryId | categoryParentId	| title | levels
--- | --- | --- | ---
1 |	0 | foo | 1
2 | 1 | bar | 2
3 | 1 | baz | 2
4 | 2 | buzz | 3
