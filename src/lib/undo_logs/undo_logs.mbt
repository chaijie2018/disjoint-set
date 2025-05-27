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
  self.num_open_snapshots
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

// TODO: Implement 
// Because the rollback function I dont know how to implement it
// This Array only stores the logs, but it does not store the state of the array
///|
pub fn[T] rollback_to(self : UndoLogs[T], snapshot : Snapshot) -> Unit {
  self.assert_valid_snapshot(snapshot)
}

///|
pub fn[T] pop(self : UndoLogs[T]) -> Undo[T] {
  self.logs.pop().unwrap()
}
