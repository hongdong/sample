//
//  ViewController.swift
//  POP
//
//  Created by Abner on 2017/6/24.
//  Copyright © 2017年 abner. All rights reserved.
//
import UIKit

//首先，我们可以抽象一个请求的protocol。对于一个请求，我们需要知道它的请求路径，HTTP 方法，所需要的参数等信息。一开始这个协议可能是这样的：
enum HTTPMethod: String {
    case GET
    case POST
}

protocol Request {
    var host: String { get }
    var path: String { get }
    
    var method: HTTPMethod { get }
    var parameter: [String: Any] { get }
}

//现在，可以新建一个 UserRequest 来实现 Request 协议：

struct UserRequest: Request {
    let host = "https://api.abnerh.com"
    var path: String {
        return "/users/abnerh"
    }
    let method: HTTPMethod = .GET
    let parameter: [String: Any] = [:]
}

//有了协议定义和一个满足定义的具体请求，现在我们需要发送请求。为了任意请求都可以通过同样的方法发送，我们将发送的方法定义在 Request 协议扩展上：

extension Request {
    func send(handler: @escaping (HDModelUser?) -> Void) {
        // ... send 的实现
    }
}

//在 send(handler:) 的参数中，我们定义了可逃逸的 (User?) -> Void，在请求完成后，我们调用这个 handler 方法来通知调用者请求是否完成，如果一切正常，则将一个 User 实例传回，否则传回 nil。
//
//我们想要这个 send 方法对于所有的 Request 都通用，所以显然回调的参数类型不能是 HDModelUser。通过在 Request 协议中添加一个关联类型，我们可以将回调参数进行抽象。在 Request 最后添加：
//protocol Request {
//    ...
//    associatedtype Response
//}
//然后在 UserRequest 中，我们也相应地添加类型定义，以满足协议：
//
//struct UserRequest: Request {
//    ...
//    typealias Response = HDModelUser
//}

//现在，我们来重新实现 send 方法，现在，我们可以用 Response 代替具体的 User，让 send 一般化。我们这里使用 URLSession 来发送请求：
//    func send(handler: @escaping (Response?) -> Void) {
//        let url = URL(string: host.appending(path))!
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        let task = URLSession.shared.dataTask(with: request) {
//            data, res, error in
//            // 处理结果
//            print(data)
//        }
//        task.resume()
//    }

//通过拼接 host 和 path，可以得到完整的API。根据这个 URL 创建请求，进行配置，生成 data task 并将请求发送。剩下的工作就是将回调中的 data 转换为合适的对象类型，并调用 handler 通知外部调用者了。对于 HDModelUser 我们知道可以使用 HDModelUser.init(data:)，但是对于泛型 Response，我们还不知道要如何将数据转为模型。我们可以在 Request 里再定义一个 parse(data:) 方法，来告诉所有的请求，我们都应该知道怎么把数据转成我们需要的Response。这样一来，提供转换方法的任务就被“下放”到了 UserRequest：

//protocol Request {
//    ...
//    associatedtype Response
//    func parse(data: Data) -> Response?   //告诉所有的请求，我们都应该知道怎么把数据转成我们需要的Response
//}
//
//struct UserRequest: Request {
//    ...
//    typealias Response = HDModelUser
//    func parse(data: Data) -> HDModelUser? {
//        return HDModelUser(data: data)
//    }
//}


//有了将 data 转换为 Response 的具体实现后，我们就可以对请求的结果进行处理了：

//extension Request {
//    func send(handler: @escaping (Response?) -> Void) {
//        let url = URL(string: host.appending(path))!
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        let task = URLSession.shared.dataTask(with: request) {
//            data, _, error in
//            if let data = data, let res = parse(data: data) {
//                DispatchQueue.main.async { handler(res) }
//            } else {
//                DispatchQueue.main.async { handler(nil) }
//            }
//        }
//        task.resume()
//    }
//}

//现在，我们来试试看请求一下这个 API：

let request = UserRequest()
request.send { user in
    if let user = user {
        print("\(user.message) \(user.name)")
    }
}

// Hello Word! Abner



/*=====================================================================*/
//虽然能够实现需求，但是上面的实现可以说非常糟糕。让我们再回头看看现在 Request 的定义和扩展,这里最大的问题在于，Request 管理了太多的东西。一个 Request 应该做的事情应该仅仅是定义请求入口和期望的响应类型，而现在 Request 不光定义了 host 的值，还对如何解析数据了如指掌。最后 send 方法被绑死在了 URLSession 的实现上，而且是作为 Request 的一部分存在。这是很不合理的，因为这意味着我们无法在不更改请求的情况下更新发送请求的方式，它们被耦合在了一起。这样的结构让测试变得异常困难。有了耦合就不能独立测试了。

//接下来开始尝试重构
//首先我们将 send(handler:) 从 Request 分离出来。我们需要一个单独的类型来负责发送请求。这里基于 POP 的开发方式，我们从定义一个可以发送请求的协议开始：
protocol Client {
    func send(_ r: Request, handler: @escaping (Request.Response?) -> Void)
}

// 编译错误

//从上面的声明从语义上来说是挺明确的，但是因为 Request 是含有关联类型的协议，所以它并不能作为独立的类型来使用，我们只能够将它作为类型约束，来限制输入参数 request。正确的声明方式应当是：

protocol Client {
    func send<T: Request>(_ r: T, handler: @escaping (T.Response?) -> Void)
    
    var host: String { get }
}

//除了使用 <T: Request> 这个泛型方式以外，我们还将 host 从 Request 移动到了 Client 里，这是更适合它的地方。现在，我们可以把含有 send 的 Request 协议扩展删除，重新创建一个类型来满足 Client 了。和之前一样，它将使用 URLSession 来发送请求：
struct URLSessionClient: Client {
    let host = "https://api.abner.com"
    
    func send<T: Request>(_ r: T, handler: @escaping (T.Response?) -> Void) {
        let url = URL(string: host.appending(r.path))!
        var request = URLRequest(url: url)
        request.httpMethod = r.method.rawValue
        
        let task = URLSession.shared.dataTask(with: request) {
            data, _, error in
            if let data = data, let res = r.parse(data: data) {
                DispatchQueue.main.async { handler(res) }
            } else {
                DispatchQueue.main.async { handler(nil) }
            }
        }
        task.resume()
    }
}

//现在发送请求的部分和请求本身分离开了，而且我们使用协议的方式定义了 Client。除了 URLSessionClient 以外，我们还可以使用任意的类型来满足这个协议，并发送请求。这样网络层的具体实现和请求本身就不再相关了，我们之后在测试的时候会进一步看到这么做所带来的好处。
//
//现在这个的实现里还有一个问题，那就是 Request 的 parse 方法。请求不应该也不需要知道如何解析得到的数据，这项工作应该交给 Response 来做。而现在我们没有对 Response 进行任何限定。接下来我们将新增一个协议，满足这个协议的类型将知道如何将一个 data 转换为实际的类型：
protocol Decodable {
    static func parse(data: Data) -> Self?
}
//Decodable 定义了一个静态的 parse 方法，现在我们需要在 Request 的 Response 关联类型中为它加上这个限制，这样我们可以保证所有的 Response 都可以对数据进行解析，原来 Request 中的 parse 声明也就可以移除了：
// 最终的 Request 协议
//protocol Request {
//    var path: String { get }
//    var method: HTTPMethod { get }
//    var parameter: [String: Any] { get }
//
//    // associatedtype Response
//    // func parse(data: Data) -> Response?
//    associatedtype Response: Decodable
//}


//最后要做的就是让 HDModelUser 满足 Decodable，并且修改上面 URLSessionClient 的解析部分的代码，让它使用 Response 中的 parse 方法：
//extension HDModelUser: Decodable {
//    static func parse(data: Data) -> User? {
//        return User(data: data)
//    }
//}
//
//struct URLSessionClient: Client {
//    func send<T: Request>(_ r: T, handler: @escaping (T.Response?) -> Void) {
//        ...
//        // if let data = data, let res = parse(data: data) {
//        if let data = data, let res = T.Response.parse(data: data) {
//            //...
//        }
//    }
//}

//最后，将 UserRequest 中不再需要的 host 和 parse 等清理一下，一个类型安全，解耦合的面向协议的网络层就呈现在我们眼前了。想要调用 UserRequest 时，我们可以这样写：
//URLSessionClient().send(UserRequest()) { user in
//    if let user = user {
//        print("\(user.message) from \(user.name)")
//    }
//}
//当然，你也可以为 URLSessionClient 添加一个单例来减少请求时的创建开销。在 POP 的组织下，这些改动都很自然，也不会牵扯到请求的其他部分。你可以用和 UserRequest 类型相似的方式，为网络层添加其他的 API 请求，只需要定义请求所必要的内容，而不用担心会触及网络方面的具体实现。


//将 Client 声明为协议给我们带来了额外的好处，那就是我们不在局限于使用某种特定的技术 (比如这里的 URLSession) 来实现网络请求。利用 POP，你只是定义了一个发送请求的协议，你可以很容易地使用像是 AFNetworking 或者 Alamofire 这样的成熟的第三方框架来构建具体的数据并处理请求的底层实现。我们甚至可以提供一组“虚假”的对请求的响应，用来进行测试。这和传统的 stub & mock 的方式在概念上是接近的，但是实现起来要简单得多，也明确得多。

//因为高度解耦，这种基于 POP 的实现为代码的扩展提供了相对宽松的可能性。 可扩展性非常的好。我们刚才已经说过，你不必自行去实现一个完整的 Client，而可以依赖于现有的网络请求框架，实现请求发送的方法即可。也就是说，你也可以很容易地将某个正在使用的请求方式替换为另外的方式，而不会影响到请求的定义和使用。类似地，在 Response 的处理上，现在我们定义了 Decodable，用自己手写的方式在解析模型。我们完全也可以使用任意的第三方 JSON 解析库，来帮助我们迅速构建模型类型，这仅仅只需要实现一个将 Data 转换为对应模型类型的方法即可。

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

