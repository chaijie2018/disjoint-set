test "init snapshot array" {
  let arr = new(capacity=5)
  assert_true!(arr.length() == 0)
  let s1 = arr.start_snapshot()
  arr.push(1)
  assert_eq!(arr.length(), 1)
  assert_eq!(arr.logs.length(), 1)
}