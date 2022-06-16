Compute tree levels
==================

This application computes levels in a table representing a tree (e.g. product categories). The tree data must be stored in a child-parent relationship. A column named **levels** will be added to the table (root nodes will have number 1). Additionally a column named
**root** will be added, containing the ID of the root item.

Configuration
-------------------

Names of both input and output files are arbitrary.
You can supply the following parameters to identify column names with **ID** and **parent ID**:

```
{
    "idColumn": "col1",
    "parentColumn": "col2"
}
```

If you do not supply the parameters, the table must contain columns **categoryId** and **categoryParentId**.

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

categoryId | categoryParentId | title | levels | root
--- | --- | --- | --- | --- |
1 |	0 | foo | 1 | 1 |
2 | 1 | bar | 2 | 1 |
3 | 1 | baz | 2 | 1 |
4 | 2 | buzz | 3 | 1 |

## License

MIT licensed, see [LICENSE](./LICENSE) file.
