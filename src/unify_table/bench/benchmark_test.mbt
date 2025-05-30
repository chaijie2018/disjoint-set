///|
pub fn solve(
  n : Int,
  m : Int,
  k : Int,
  edges : Array[(Int, Int)],
  queries : Array[Int],
  answer : Array[Int]
) -> Unit! {
  let destory = FixedArray::makei(n + 10, fn(_) { false })
  let result = FixedArray::makei(k + 10, fn(_) { 0 })
  let adj = FixedArray::makei(n + 10, fn(_) { Array::new() })
  let table = @unify_table.new(capacity=n + 10)
  for i in 0..<n {
    table.push(i)
  }
  for _, item in edges {
    let (u, v) = item
    adj[u].push(v)
    adj[v].push(u)
  }
  for i in 1..<(k + 1) {
    let idx = queries[i]
    destory[idx] = true
  }
  let mut ans = n - k
  fn dfs(u) {
    for v in adj[u] {
      if destory[v] {
        continue
      }
      if table.unioned(@unify_table.new_index(u), @unify_table.new_index(v)) {
        continue
      }
      let _ = table.unite(
        @unify_table.new_index(u),
        @unify_table.new_index(v),
        1,
      ) // 新的值并不重要，该题目并没有考虑到值的合并
      ans -= 1
      // dfs(v)
    }
  }

  for i = 0; i < n; i = i + 1 {
    if destory[i] {
      continue
    }
    dfs(i)
  }
  result[k + 1] = ans
  for i = k; i >= 1; i = i - 1 {
    destory[queries[i]] = false
    ans += 1
    dfs(queries[i])
    result[i] = ans
  }
  for i in 1..<(k + 2) {
    assert_eq(result[i], answer[i - 1])
  }
}

///|
test "benchmark" {
  let data = data()
  let answers = answers()
  for i in 0..<data.length() {
    let ((n, m, k), edges, queries) = data[i]
    let answer = answers[i]
    solve(n, m, k, edges, queries, answer)
  }
}
