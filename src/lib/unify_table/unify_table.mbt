
pub struct UnificationTable[T] {
  values: @snapshot_array.SnapshotArray[VarValue[T]]
}


// 如果 value 是 VarValue 的 value，那就是指向自己
// 否则就是指向 VarIndex 的 value
pub struct VarIndex[T] {
  value: T
  index: Int
}

impl[T: Eq] Eq for VarIndex[T] with op_equal(self, other) {
  if self.value == other.value {
    return true;
  }
  return false;
}


pub struct VarValue[T] {
  mut value : T
  mut rank: Int
  mut parent: VarIndex[T]
}

pub fn redirect[T: Eq](self: VarValue[T], to: VarIndex[T]) -> Unit {
  self.parent = to;
}

pub fn root[T: Eq](self: VarValue[T], rank: Int, value: T) -> Unit {
  self.value = value;
  self.rank = rank;
}

pub fn new_index[T: Eq](value: T, index: Int) -> VarIndex[T] {
  { value, index }
}

pub fn new[T: Eq](capacity~: Int) -> UnificationTable[T] {
  {
    values: @snapshot_array.new(capacity~)
  }
}

pub fn push[T: Eq](self: UnificationTable[T], value: T) -> VarIndex[T] {
  let index = self.values.push( {
    value,
    rank: 0,
    parent:  { value, index: self.values.length() - 1 }
  });
  { value, index }
}

pub fn union[T: Eq](self: UnificationTable[T], index1: VarIndex[T], index2: VarIndex[T]) -> Bool {
  return self.find(index1) == self.find(index2)
}

pub fn set[T: Eq](self: UnificationTable[T], index: VarIndex[T], value: VarValue[T]) -> Unit {
  self.values.set(index.index, value);
}

pub fn update[T: Eq](self: UnificationTable[T], index: VarIndex[T], value: (VarValue[T]) -> Unit) -> Unit {
  let current_value = self.get(index).unwrap();
  value(current_value);
}

pub fn redirect_root[T: Eq](self: UnificationTable[T], new_rank: Int, old_index: VarIndex[T], new_index: VarIndex[T], new_value: T) -> Unit {
  self.update(old_index, fn(old_value)  {
    old_value.redirect(new_index)
  })
  self.update(new_index, fn(new_root_value) {
    new_root_value.root(new_rank, new_value)
  });
}


pub fn unite[T: Eq](self: UnificationTable[T], index1: VarIndex[T], index2: VarIndex[T]) -> VarIndex[T] {
  let root1 = self.find(index1);
  let root2 = self.find(index2);

  if root1 == root2 {
    return root1;
  }

  let rank_a = self.get(root1).unwrap()
  let rank_b = self.get(root2).unwrap()

  ...
}

pub fn get[T: Eq](self: UnificationTable[T], index: VarIndex[T]) -> VarValue[T]? {
  self.values.get(index.index)
}

pub fn find[T: Eq](self: UnificationTable[T], index: VarIndex[T]) -> VarIndex[T] {
    let value = self.get(index).unwrap();
    if value.parent == index {
      return index;
    }

    let redirect = value.parent;
    let root = self.find(redirect);
    if root != redirect {
      self.values.set(index.index, {
        value: value.value,
        rank: value.rank,
        parent: root
      })
    }
    return root;
}