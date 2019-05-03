# 解析-Dart应该这么写


TODO: Change this

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


