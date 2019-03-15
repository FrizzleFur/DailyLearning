# 工具-Markdown


## 展开技巧


## How to install

<details>
<summary> :package: :penguin: Linux</summary>
<h4>From binaries</h4>
Check out the <a href="https://github.com/go-flutter-desktop/go-flutter/releases">Release</a> page for prebuilt versions.

<h4>From source</h4>

Go read first: [go-gl/glfw](https://github.com/go-gl/glfw/)  


```bash
# Clone
git clone https://github.com/go-flutter-desktop/go-flutter.git
cd go-flutter

# Build the flutter simpleDemo project
cd example/simpleDemo/
cd flutter_project/demo/
flutter build bundle
cd ../..

# Download the share library, the one corresponding to your flutter version.
go run engineDownloader.go

# REQUIRED before every `go build`. The CGO compiler need to know where to look for the share library
export CGO_LDFLAGS="-L${PWD}"
# The share library must stay next to the generated binary.

# Get the libraries
go get -u -v github.com/go-flutter-desktop/go-flutter

# Build the example project
go build main.go

# `go run main.go` is not working ATM.
```

</details>

<details>
<summary> :package: :checkered_flag: Windows</summary>
<h4>From binaries</h4>
Check out the <a href="https://github.com/go-flutter-desktop/go-flutter/releases">Release</a> page for prebuilt versions.

<h4>From source</h4>

Go read first: [go-gl/glfw](https://github.com/go-gl/glfw/)  


```bash
# Clone
git clone https://github.com/go-flutter-desktop/go-flutter.git
cd go-flutter

# Build the flutter simpleDemo project
cd example/simpleDemo/
cd flutter_project/demo/
flutter build bundle
cd ../..

# Download the share library, the one corresponding to your flutter version.
go run engineDownloader.go

# REQUIRED before every `go build`. The CGO compiler need to know where to look for the share library
set CGO_LDFLAGS=-L%cd%
# The share library must stay next to the generated binary.
# If you ran into a MinGW ld error, checkout: https://github.com/go-flutter-desktop/go-flutter/issues/34

# Get the libraries
go get -u -v github.com/go-flutter-desktop/go-flutter

# Build the example project
go build main.go

# `go run main.go` is not working ATM.
```

</details>

<details>
<summary> :package: :apple: MacOS</summary>
<h4>From binaries</h4>
Check out the <a href="https://github.com/go-flutter-desktop/go-flutter/releases">Release</a> page for prebuilt versions.

<h4>From source</h4>

Go read first: [go-gl/glfw](https://github.com/go-gl/glfw/)  


```bash
# Clone
git clone https://github.com/go-flutter-desktop/go-flutter.git
cd go-flutter

# Build the flutter simpleDemo project
cd example/simpleDemo/
cd flutter_project/demo/
flutter build bundle
cd ../..

# Download the share library, the one corresponding to your flutter version.
go run engineDownloader.go

# REQUIRED before every `go build`. The CGO compiler need to know where to look for the share library
export CGO_LDFLAGS="-F${PWD} -Wl,-rpath,@executable_path"
# The share library must stay next to the generated binary.

# Get the libraries
go get -u -v github.com/go-flutter-desktop/go-flutter

# Build the example project
go build main.go

# `go run main.go` is not working ATM.
```

</details>

