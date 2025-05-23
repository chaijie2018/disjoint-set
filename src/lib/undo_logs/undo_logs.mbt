///|
pub enum Undo[T] {
  NewElem(Int)
  SetElem(Int, T)
}

typealias Snapshot = Int
// /|
// pub trait UndoLogs {
//   in_snapshot(Self) -> Bool = _
//   num_open_snapshots(Self) -> Int
//   push(Self, Undo) -> Unit
//   clear(Self) -> Unit
//   extend(Self, Iter[Undo]) -> Unit = _
// }

// ///|
// impl UndoLogs with in_snapshot(self) {
//   self.num_open_snapshots() > 0
// }

// ///|
// impl UndoLogs with extend(self, logs : Iter[Undo[T]]) {
//   logs.each(fn(log) { self.push(log) })
// }

// pub trait Snapshots: UndoLogs {
//   has_changes(Self, Snapshot) -> Bool = _
//   action_since_snapshot(Self, Snapshot) -> ArrayView[Undo[T]]
//   start_snapshot(Self) -> Snapshot
//   rollback(Self, Snapshot) -> Unit
//   commit(Self, Snapshot) -> Unit
// }

// impl Snapshots with has_changes(self, snapshot : Snapshot) {
//   self.action_since_snapshot(snapshot).length() > 0
// }

pub struct UndoLogs[T] {
  logs : Array[Undo[T]]
  mut num_open_snapshots : Snapshot
}

pub fn new[T](capacity~: Int = 0) -> UndoLogs[T] {
   {
    logs : Array::new(capacity=capacity),
    num_open_snapshots : 0
  }
}

// UndoLogs
pub fn num_open_snapshots[T](self : UndoLogs[T]) -> Int {
  self.num_open_snapshots
}

pub fn push[T](self : UndoLogs[T], log : Undo[T]) -> Unit {
  self.logs.push(log)
}

pub fn clear[T](self : UndoLogs[T]) -> Unit {
  self.logs.clear()
  self.num_open_snapshots = 0
}

pub fn extend[T](self : UndoLogs[T], logs : Iter[Undo[T]]) -> Unit {
  logs.each(fn(log) { self.push(log) })
}

// Snapshots

pub fn action_since_snapshot[T](self : UndoLogs[T], snapshot : Snapshot) -> ArrayView[Undo[T]] {
  self.logs[snapshot:]
}

pub fn has_changes[T](self : UndoLogs[T], snapshot : Snapshot) -> Bool {
  self.action_since_snapshot(snapshot).length() > 0
}

pub fn start_snapshot[T](self : UndoLogs[T]) -> Snapshot {
  self.num_open_snapshots += 1
  self.num_open_snapshots
}

fn assert_valid_snapshot[T](self : UndoLogs[T], snapshot : Snapshot) -> Unit {
  guard self.logs.length() > snapshot else {
    abort("Invalid snapshot")
  }

  guard self.num_open_snapshots > 0 else {
    abort("No open snapshots")
  }
}
pub fn commit[T](self : UndoLogs[T], snapshot : Snapshot) -> Unit {
  self.assert_valid_snapshot(snapshot)

  if self.num_open_snapshots == 1 {
    // The root snapshot. It's safe to clear the undo log because
    // there's no snapshot further out that we might need to roll back to.
    guard snapshot == 0 else {
      abort("Invalid snapshot")
    }
    self.logs.clear()
  }
  self.num_open_snapshots -= 1
}

// TODO: Implement 
// Because the rollback function I dont know how to implement it
// This Array only stores the logs, but it does not store the state of the array
pub fn rollback_to[T](self: UndoLogs[T], snapshot : Snapshot) -> Unit {
  self.assert_valid_snapshot(snapshot)
}

pub fn pop[T](self: UndoLogs[T]) -> Undo[T] {
  self.logs.pop().unwrap()
}