///|
pub struct SnapshotArray[T] {
  logs : @logs.UndoLogs[T]
  values : Array[T]
}

///|
pub struct Snapshot {
  value_count : Int
  undo_count : Int
}

///|
/// Creates a new `SnapshotArray` with an optional initial capacity.
/// 
/// Examples
/// ```moonbit
/// test "SnapshotArray::new" {
///   let arr = new(capacity=5)
///   assert_true!(arr.length() == 0)
/// }
/// ```
pub fn[T] new(capacity~ : Int = 0) -> SnapshotArray[T] {
  { logs: @logs.new(), values: Array::new(capacity~) }
}

///|
pub fn[T] from_iter(iter : Iter[T], capacity~ : Int = 0) -> SnapshotArray[T] {
  let arr = new(capacity~)
  arr.extend(iter)
  arr
}

///|
/// Returns the number of elements in the `SnapshotArray`.
/// 
/// Examples
/// ```moonbit
/// test "SnapshotArray::length" {
///   let arr = new(capacity=5)
///   assert_eq!(arr.length(), 0)
///   arr.push(1)
///   assert_eq!(arr.length(), 1)
/// }
/// ```
pub fn[T] length(self : SnapshotArray[T]) -> Int {
  self.values.length()
}

///|
/// Returns the value at the specified index
/// 
/// Examples
/// ```moonbit
/// test "SnapshotArray::get" {
///   let arr = new(capacity=5)
///   arr.push(1)
///   arr.push(2)
///   assert_eq!(arr.get(0).unwrap(), 1)
///   assert_eq!(arr.get(1).unwrap(), 2)
/// }
/// ```
pub fn[T] get(self : SnapshotArray[T], index : Int) -> T? {
  self.values.get(index)
}

///|
/// Revert the last action.
///
/// Examples
/// ```moonbit
/// ///|
/// test "SnapshotArray::rollback" {
///   let arr = SnapshotArray::new()
///   let snapshot = arr.start_snapshot()
///   arr.push(1)
///   arr.push(2)
///   arr.rollback()
///   inspect!(arr.length(), content="1")
///   inspect!(arr.get(0).unwrap(), content="1")
/// }
/// ```
fn[T] rollback(self : SnapshotArray[T]) -> Unit {
  let undo = self.logs.pop().unwrap()
  match undo {
    NewElem(idx) => {
      let _ = self.values.pop().unwrap()
      guard idx == self.values.length() else { abort("Index mismatch") }
    }
    SetElem(idx, value) => self.values[idx] = value
  }
}

// UndoLogs

///|
/// Checks SnapshotArray for an open snapshot.
/// Returns true if there is at least one open snapshot.
///
/// Examples
///
/// ```moonbit
/// ///|
/// test "SnapshotArray::in_snapshot" {
///   let arr = SnapshotArray::new()
///   inspect!(arr.in_snapshot(), content="false")
///   let _ = arr.start_snapshot()
///   inspect!(arr.in_snapshot(), content="true")
/// }
/// ```
pub fn[T] in_snapshot(self : SnapshotArray[T]) -> Bool {
  self.logs.in_snapshot()
}

///|
pub fn[T] push(self : SnapshotArray[T], elem : T) -> Unit {
  let len = self.values.length()
  self.values.push(elem)
  if self.in_snapshot() {
    self.logs.push(@logs.newElem(len))
  }
}

///|
pub fn[T] extend(self : SnapshotArray[T], iter : Iter[T]) -> Unit {
  iter.each(fn(elem) { self.push(elem) })
}

///|
pub fn[T] set(self : SnapshotArray[T], index : Int, value : T) -> Unit {
  if index >= self.values.length() {
    abort("Index out of bounds")
  }
  let old_value = self.values[index]
  self.values[index] = value
  if self.in_snapshot() {
    self.logs.push(@logs.setElem(index, old_value))
  }
}

///|
pub fn[T] set_all(self : SnapshotArray[T], func : (T) -> T) -> Unit {
  if self.in_snapshot() {
    let old_values = self.values
    for i in 0..<self.values.length() {
      let new_value = func(self.values[i])
      self.values[i] = new_value
      self.logs.push(@logs.setElem(i, old_values[i]))
    }
  } else {
    for i in 0..<self.values.length() {
      self.values[i] = func(self.values[i])
    }
  }
}

// Snapshot
///|
pub fn[T] start_snapshot(self : SnapshotArray[T]) -> Snapshot {
  { value_count: self.values.length(), undo_count: self.logs.start_snapshot() }
}

///|
pub fn[T] action_since_snapshot(
  self : SnapshotArray[T],
  snapshot : Snapshot
) -> ArrayView[@logs.Undo[T]] {
  self.logs.action_since_snapshot(snapshot.undo_count)
}

///|
pub fn[T] rollback_to(self : SnapshotArray[T], snapshot : Snapshot) -> Unit {
  let actions = self.action_since_snapshot(snapshot)
  for _ in actions {
    self.rollback()
  }
}

///|
pub fn[T] commit(self : SnapshotArray[T], snapshot : Snapshot) -> Unit {
  self.logs.commit(snapshot.undo_count)
}

///|
impl[T : Show] Show for SnapshotArray[T] with output(self, logger : &Logger) {
  logger.write_iter(
    self.values.iter(),
    prefix="SnapshotArray[ ",
    suffix=" ]",
    sep=", ",
  )
}

///|
impl Show for Snapshot with output(self, logger : &Logger) {
  logger
  ..write_string("Snapshot { value_count: ")
  ..write_object(self.value_count)
  ..write_string(", undo_count: ")
  ..write_object(self.undo_count)
  ..write_string(" }")
}
