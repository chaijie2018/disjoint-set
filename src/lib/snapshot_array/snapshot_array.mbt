
pub struct SnapshotArray[T] {
  logs: @logs.UndoLogs[T]
  values: Array[T]
}

typealias Snapshot = Int

pub fn length[T](self: SnapshotArray[T]) -> Int {
  self.values.length()
}

pub fn get[T](self: SnapshotArray[T], index: Int) -> T {
  self.values[index]
}

fn rollback[T](self: SnapshotArray[T]) -> Unit {
  let undo = self.logs.pop()
  match undo {
    NewElem(idx) => {
      let _ = self.values.pop().unwrap()
      guard idx == self.values.length() else {
        abort("Index mismatch")
      }
    }
    SetElem(idx, value) => {
      self.values[idx] = value
    }
  }
}

pub fn start_snapshot[T](self: SnapshotArray[T]) -> Snapshot {
  
  1
}