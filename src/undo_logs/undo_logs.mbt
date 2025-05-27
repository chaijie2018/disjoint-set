///|
pub enum Undo[T] {
  NewElem(Int)
  SetElem(Int, T)
}

///|
typealias Snapshot = Int

///|
pub fn[T] newElem(index : Int) -> Undo[T] {
  NewElem(index)
}

///|
pub fn[T] setElem(index : Int, value : T) -> Undo[T] {
  SetElem(index, value)
}

///|
pub struct UndoLogs[T] {
  logs : Array[Undo[T]]
  mut num_open_snapshots : Snapshot
}

///|
pub fn[T] new(capacity~ : Int = 0) -> UndoLogs[T] {
  { logs: Array::new(capacity~), num_open_snapshots: 0 }
}

// UndoLogs

///|
pub fn[T] in_snapshot(self : UndoLogs[T]) -> Bool {
  self.num_open_snapshots > 0
}

pub fn [T]length(self : UndoLogs[T]) -> Int {
  self.logs.length()
}

///|
pub fn[T] num_open_snapshots(self : UndoLogs[T]) -> Int {
  self.num_open_snapshots
}

///|
pub fn[T] push(self : UndoLogs[T], log : Undo[T]) -> Unit {
  self.logs.push(log)
}

///|
pub fn[T] clear(self : UndoLogs[T]) -> Unit {
  self.logs.clear()
  self.num_open_snapshots = 0
}

///|
pub fn[T] extend(self : UndoLogs[T], logs : Iter[Undo[T]]) -> Unit {
  logs.each(fn(log) { self.push(log) })
}

// Snapshots

///|
pub fn[T] action_since_snapshot(
  self : UndoLogs[T],
  snapshot : Snapshot
) -> ArrayView[Undo[T]] {
  self.logs[snapshot:]
}

///|
pub fn[T] has_changes(self : UndoLogs[T], snapshot : Snapshot) -> Bool {
  self.action_since_snapshot(snapshot).length() > 0
}

///|
pub fn[T] start_snapshot(self : UndoLogs[T]) -> Snapshot {
  self.num_open_snapshots += 1
  self.logs.length()
}

///|
fn[T] assert_valid_snapshot(self : UndoLogs[T], snapshot : Snapshot) -> Unit {
  guard self.logs.length() > snapshot else { abort("Invalid snapshot") }
  guard self.num_open_snapshots > 0 else { abort("No open snapshots") }

}

///|
pub fn[T] commit(self : UndoLogs[T], snapshot : Snapshot) -> Unit {
  self.assert_valid_snapshot(snapshot)
  if self.num_open_snapshots == 1 {
    // The root snapshot. It's safe to clear the undo log because
    // there's no snapshot further out that we might need to roll back to.
    guard snapshot == 0 else { abort("Invalid snapshot") }
    self.logs.clear()
  }
  self.num_open_snapshots -= 1
}

///|
pub fn[T] rollback_to(
  self : UndoLogs[T],
  snapshot : Snapshot
) -> Array[Undo[T]] {
  self.assert_valid_snapshot(snapshot)
  let logs = self.action_since_snapshot(snapshot).to_array()
  for i in 0..<logs.length() {
    let _ = self.pop()

  }
  logs
}

///|
pub fn[T] pop(self : UndoLogs[T]) -> Undo[T] {
  self.logs.pop().unwrap()
}

///|
pub impl[T : Show] Show for Undo[T] with to_string(self) {
  match self {
    NewElem(index) => "NewElem(" + index.to_string() + ")"
    SetElem(index, value) =>
      "SetElem(" + index.to_string() + ", " + value.to_string() + ")"
  }
}

///|
pub impl[T : Show] Show for Undo[T] with output(self, logger : &Logger) {
  logger.write_string(self.to_string())
}
