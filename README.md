# SnapshotVec + UnificationTable

```moonbit
///|
test "UnificationTable::union_test" {
  let table = new(capacity=5)
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