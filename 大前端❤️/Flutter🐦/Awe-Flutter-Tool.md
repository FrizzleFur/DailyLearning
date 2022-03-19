# Awe-Flutter-Tool

## 编译环境

##### 1. What is the best Flutter IDE?

| IDE |  功能 | 性能  |
|---|---|---|
| 1. Android Studio |  ⭐️⭐️⭐️⭐️⭐️ |  ⭐️⭐️ |
| 2. VSCode  | ⭐️⭐️⭐️  |  ⭐️⭐️⭐️⭐️⭐️ |
| 3. IntelliJ  | ⭐️⭐️⭐️⭐️⭐️  | ⭐  |

之前觉得Android可以，IntelliJ功能强大，但跑大工程时内存太过卡顿，最终选择想用轻量的VSCode.

##### VSCode Running Flutter
下面记录几点VSCode的对Flutter配置过程

1. flavor的配置
如果跑iOS未配置时flavor时容易报错：

```dart
You must specify a --flavor option to select one of the available schemes.
```

需要在 VSCode 的launchConfig里指定flavor:
添加

```dart
{
	"version": "0.2.0",
	"configurations": [
		{
			"name": "xxxxx(debug)",
			"request": "launch",
			"type": "dart",
			"flutterMode": "debug",
			"args": [
				"--flavor",
				"Runner-dev",
			],
		},
	]
}
```
![](https://pic-mike.oss-cn-hongkong.aliyuncs.com/Blog/20220319152938.png)


