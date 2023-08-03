

1. 查看defer关键词

```swift
var check = 1

func doubleCheckTimes() -> Int {
  defer {
    check += 1
  }
  check = check*2
  defer {
    check *= 3
  }
  return check
}
print((doubleCheckTimes(), check))
// (2, 7)
```

