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
pub fn[T] new(capacity~ : Int = 0) -> SnapshotArray[T] {
  { logs: @logs.new(), values: Array::new(capacity~) }
}

///|
pub fn[T] length(self : SnapshotArray[T]) -> Int {
  self.values.length()
}

///|
pub fn[T] get(self : SnapshotArray[T], index : Int) -> T? {
  self.values.get(index)
}

///|
fn[T] rollback(self : SnapshotArray[T]) -> Unit {
  let undo = self.logs.pop()
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
pub fn[T] set_all(self : SnapshotArray[T], values : (Int) -> T) -> Unit {
  if self.in_snapshot() {
    let old_values = self.values
    for i in 0..<self.values.length() {
      let new_value = values(i)
      self.values[i] = new_value
      self.logs.push(@logs.setElem(i, old_values[i]))
    }
  } else {
    for i in 0..<self.values.length() {
      self.values[i] = values(i)
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
