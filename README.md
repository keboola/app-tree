Sample config

```
{
  "storage": {
    "input": {
      "tables": [
        {
          "destination": "test.csv"
        }
      ]
    },
    "output": {
      "tables": [
        {
          "source": "result.csv",
          "destination": "result.csv"
        }
      ]
    }
  },
  "parameters": {
    "parent_column": "parent",
    "child_column": "child",
    "null_node_value": "0"
  }
}
```
