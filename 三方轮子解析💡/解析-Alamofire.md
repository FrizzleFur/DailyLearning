
# Alamofire


## What is Alamofire Good For?

Why do you need Alamofire at all? Apple already provides `URLSession` and other classes for downloading content via HTTP, so why complicate things with another third party library?

The short answer is Alamofire is based on `URLSession`, but it frees you from writing boilerplate code which makes writing networking code much easier. You can access data on the Internet with very little effort, and your code will be much cleaner and easier to read.

There are several major functions available with Alamofire:

*   `Alamofire.upload`: Upload files with multipart, stream, file or data methods.
*   `Alamofire.download`: Download files or resume a download already in progress.
*   `Alamofire.request`: Every other HTTP request not associated with file transfers.

These Alamofire methods are global within Alamofire so you don’t have to instantiate a class to use them. There are underlying pieces to Alamofire that are classes and structs, like `SessionManager`, `DataRequest`, and `DataResponse`; however, you don’t need to fully understand the entire structure of Alamofire to start using it.

Here’s an example of the same networking operation with both Apple’s `URLSession` and Alamofire’s `request` function:

```swift
// With URLSession
public func fetchAllRooms(completion: @escaping ([RemoteRoom]?) -> Void) {
  guard let url = URL(string: "http://localhost:5984/rooms/_all_docs?include_docs=true") else {
    completion(nil)
    return
  }

  var urlRequest = URLRequest(url: url,
                              cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                              timeoutInterval: 10.0 * 1000)
  urlRequest.httpMethod = "GET"
  urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

  let task = urlSession.dataTask(with: urlRequest)
  { (data, response, error) -> Void in
    guard error == nil else {
      print("Error while fetching remote rooms: \(String(describing: error)")
      completion(nil)
      return
    }

    guard let data = data,
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        print("Nil data received from fetchAllRooms service")
        completion(nil)
        return
    }

    guard let rows = json?["rows"] as? [[String: Any]] else {
      print("Malformed data received from fetchAllRooms service")
      completion(nil)
      return
    }

    let rooms = rows.flatMap { roomDict in return RemoteRoom(jsonData: roomDict) }
    completion(rooms)
  }

  task.resume()
}
```


Versus:

```swift

// With Alamofire
func fetchAllRooms(completion: @escaping ([RemoteRoom]?) -> Void) {
  guard let url = URL(string: "http://localhost:5984/rooms/_all_docs?include_docs=true") else {
    completion(nil)
    return
  }
  Alamofire.request(url,
                    method: .get,
                    parameters: ["include_docs": "true"])
  .validate()
  .responseJSON { response in
    guard response.result.isSuccess else {
      print("Error while fetching remote rooms: \(String(describing: response.result.error)")
      completion(nil)
      return
    }

    guard let value = response.result.value as? [String: Any],
      let rows = value["rows"] as? [[String: Any]] else {
        print("Malformed data received from fetchAllRooms service")
        completion(nil)
        return
    }

    let rooms = rows.flatMap { roomDict in return RemoteRoom(jsonData: roomDict) }
    completion(rooms)
  }
}
```


You can see the required setup for Alamofire is shorter and it’s much clearer what the function does. You deserialize the response with `responseJSON(options:completionHandler:)` and calling `validate()` to verify the response status code is in the default acceptable range between 200 and 299 simplifies error condition handling.



## Uploading Files

Open _ViewController.swift_ and add the following to the top, below `import SwiftyJSON`:

import Alamofire

This lets you use the functionality provided by the Alamofire module in your code, which you’ll be doing soon!

Next, go to `imagePickerController(_:didFinishPickingMediaWithInfo:)` and add the following to the end, right before the call to `dismiss(animated:)`:


```swift
// 1
takePictureButton.isHidden = true
progressView.progress = 0.0
progressView.isHidden = false
activityIndicatorView.startAnimating()

upload(image: image,
       progressCompletion: { [weak self] percent in
        // 2
        self?.progressView.setProgress(percent, animated: true)
  },
       completion: { [weak self] tags, colors in
        // 3
        self?.takePictureButton.isHidden = false
        self?.progressView.isHidden = true
        self?.activityIndicatorView.stopAnimating()

        self?.tags = tags
        self?.colors = colors

        // 4
        self?.performSegue(withIdentifier: "ShowResults", sender: self)
})

```
Everything with Alamofire is _asynchronous_, which means you’ll update the UI in an asynchronous manner:




### Helpful Links

1.[Alamofire Tutorial: Getting Started](https://www.raywenderlich.com/188427/alamofire-tutorial-getting-started-3)



