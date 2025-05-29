///|
test "init table" {
  let table = new(capacity=5)
  table.push(1)
  assert_true!(table.values.length() == 1)
}

///|
test "union table" {
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

///|
test "find root" {
  let table = new(capacity=5)
  for i in 0..<5 {
    table.push(i)
  }
  let index1 = table.index(1)
  let index2 = table.index(2)
  let index3 = table.index(3)
  let _ = table.unite(index1, index2, 8)
  assert_eq!(table.value(index1).value, 8)
  let _ = table.unite(index3, index1, 9)
  assert_eq!(table.value(index1).value, 9)
}
