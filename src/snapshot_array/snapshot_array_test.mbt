test "init snapshot array" {
  let arr = new(capacity=5)
  assert_true!(arr.length() == 0)
  let _ = arr.start_snapshot()
  arr.push(1)
  assert_eq!(arr.length(), 1)
  assert_eq!(arr.logs.length(), 1)
}

test "get snapshot" {
  let arr = new(capacity=5)
  let s1 = arr.start_snapshot()
  arr.push(1)
  arr.push(2)
  assert_eq!(arr.length(), 2)

  let actions = arr.action_since_snapshot(s1)
  assert_eq!(actions.length(), 2)
  assert_eq!(arr.get(0).unwrap(), 1)
  assert_eq!(arr.get(1).unwrap(), 2)
}

test "rollback to snapshot" {
  let arr = new(capacity=5)
  let _ = arr.start_snapshot()
  arr.push(1)
  let s2 = arr.start_snapshot()
  arr.push(2)
  assert_eq!(arr.length(), 2)

  arr.rollback_to(s2)
  assert_eq!(arr.length(), 1)
}

test "set and get" {
  let arr = new(capacity=5)
  arr.push(1)
  arr.push(2)
  arr.set(0, 3)
  assert_eq!(arr.get(0).unwrap(), 3)
  assert_eq!(arr.get(1).unwrap(), 2)

  let s1 = arr.start_snapshot()
  arr.set(1, 4)
  assert_eq!(arr.get(1).unwrap(), 4)

  let actions = arr.action_since_snapshot(s1)
  assert_eq!(actions.length(), 1)
}

test "set all" {
  let arr = new(capacity=5)
  let _ = arr.start_snapshot()
  let s1 = arr.start_snapshot()
  arr.push(1)
  arr.push(2)
  arr.set_all(fn(i) {i + 10})
  assert_eq!(arr.get(0).unwrap(), 11)
  assert_eq!(arr.get(1).unwrap(), 12)
  let s2 = arr.start_snapshot()
  arr.set_all(fn(i) {i * 2})
  assert_eq!(arr.get(0).unwrap(), 22)
  assert_eq!(arr.get(1).unwrap(), 24)

  let actions = arr.action_since_snapshot(s1)
  assert_eq!(actions.length(), 6)
  let actions = arr.action_since_snapshot(s2)
  assert_eq!(actions.length(), 2)
  
}