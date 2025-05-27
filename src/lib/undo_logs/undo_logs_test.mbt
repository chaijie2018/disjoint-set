///|
test "init log" {
  let logs = new()
  logs.push(newElem(0))
  logs.push(setElem(1, "test"))
}
