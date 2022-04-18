# 解析-Dart应该这么写


## 注意点

* static
    * 类似java中的staitc，表示一个成员属于类而不是对象
* final
    * 类似java中的final，必须初始化，初始化后值不可变，编译时不能确定值。
* const
    * 编译时可确定，并且不能被修改


## 写法

1. json转换Model数组, map的用法, list数组的元素的处理，可以通过map方法，调用元素处理的方法，感觉挺简洁的

```dart
  List<_ContactListItem> _buildContactList() {
    return _contacts.map((contact) => _ContactListItem(contact))
                    .toList();
  }

class _ContactListItem extends ListTile {

  _ContactListItem(Contact contact) :
    super(
      title : Text(contact.fullName),
      subtitle: Text(contact.email),
      leading: CircleAvatar(
        child: Text(contact.fullName[0])
      )
    );

}
```

```dart
List<String> getDataList() {
    List<String> list = [];
    for (int i = 0; i < 100; i++) {
          list.add(i.toString());
    }
    return list;
  }

  List<Widget> getWidgetList() {
    return getDataList().map((item) => getItemContainer(item)).toList();
  }

  Widget getItemContainer(String item) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        item,
        style: TextStyle(color: Colors.white, fontSize: 20),
              ),
      color: Colors.blue,
    );
  }
```


