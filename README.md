# UnificationTable

> **Note:** Snapshot operations should follow a stack-like (LIFO) order.  
> A root snapshot is required for snapshot operations.  
>  Avoid using the `new_index` method; use `table.index` to obtain the index instead.

```moonbit
///|
test "UnificationTable::union_test" {
  let table = UnificationTable::new(capacity=5)
  for i in 0..<5 {
    table.push(i)
  }
  let index1 = table.index(1)
  let index2 = table.index(2)
  let index3 = table.index(3)
  assert_false!(table.unioned(index1, index2))
  let _ = table.unite(index1, index2, 8)
  assert_true!(table.unioned(index1, index2))
  assert_false!(table.unioned(index1, index3))
  assert_true!(table.unioned(index2, index1))
  assert_false!(table.unioned(index2, index3))
}
```

# Snapshot

```moonbit
///|
test "UnificationTable::snapshot_unite_test" {
  let table = UnificationTable::new(capacity=5)
  let _ = table.start_snapshot()
  for i in 0..<5 {
    table.push(i)
  }
  let s1 = table.start_snapshot()
  let index1 = table.index(1)
  let index2 = table.index(2)
  let index3 = table.index(3)
  assert_false!(table.unioned(index1, index2))
  let _ = table.unite(index1, index2, 8)
  assert_true!(table.unioned(index1, index2))
  assert_false!(table.unioned(index1, index3))
  assert_false!(table.unioned(index2, index3))
  table.rollback_to(s1)
  assert_false!(table.unioned(index1, index2))
  assert_false!(table.unioned(index1, index3))
  assert_false!(table.unioned(index2, index1))
}
```
