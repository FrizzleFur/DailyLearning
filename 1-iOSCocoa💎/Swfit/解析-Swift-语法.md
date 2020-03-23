# 解析-Swift-Codable


## Comparing Codable with NSCoding

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200322144300.png)

```swift
class Product: NSObject, NSCoding {
  var title:String
  var price:Double
  var quantity:Int
  enum Key:String {
    case title = "title"
    case price = "price"
    case quantity = "quantity"
  }
  init(title:String,price:Double, quantity:Int) {
    self.title = title
    self.price = price
    self.quantity = quantity
  }
  func encode(with aCoder: NSCoder) {
    aCoder.encode(title, forKey: Key.title.rawValue)
    aCoder.encode(price, forKey: Key.price.rawValue)
    aCoder.encode(quantity, forKey: Key.quantity.rawValue)
  }
  convenience required init?(coder aDecoder: NSCoder) {
    let price = aDecoder.decodeDouble(forKey: Key.price.rawValue)
    let quantity = aDecoder.decodeInteger(forKey: Key.quantity.rawValue)
    guard let title = aDecoder.decodeObject(forKey: Key.title.rawValue) as? String else { return nil }
    self.init(title:title,price:price,quantity:quantity)
  }
}
```


```swift
struct Product: Codable {
  var title:String
  var price:Double
  var quantity:Int
  enum CodingKeys: String, CodingKey {
    case title
    case price
    case quantity
  }
  init(title:String,price:Double, quantity:Int) {
    self.title = title
    self.price = price
    self.quantity = quantity
  }
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(title, forKey: .title)
    try container.encode(price, forKey: .price)
    try container.encode(quantity, forKey: .quantity)
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    title = try container.decode(String.self, forKey: .title)
    price = try container.decode(Double.self, forKey: .price)
    quantity = try container.decode(Int.self, forKey: .quantity)
  }
}
```

![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20200322144557.png)


# 为什么要手动编写Codable函数？

- 自动生成很棒，但是在某些情况下，您将需要放弃自动生成的便利，而手动组合其中的一个或全部。例如：
  - 类型的一个或多个属性可能不是Codable。在这种情况下，您需要将其与Codable类型进行相互转换。
  - 类型的结构可能与您要编码/解码的结构不同。
  - 您可能要编码和解码与类型的属性不同的属性。
  - 您可能要为类型中的属性使用不同的名称。

# Ref

- [Migrating to Codable from NSCoding - If let swift = Programming! - Medium](https://medium.com/if-let-swift-programming/migrating-to-codable-from-nscoding-ddc2585f28a4)
- [Swift 4之Codable全面解析](https://www.jianshu.com/p/21c8724e7b12)