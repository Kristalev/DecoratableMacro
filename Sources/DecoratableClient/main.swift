import Decoratable

@Decoratable
public protocol Router {
    mutating func push(view: String)
}

struct ApplicationRouter: Router {
    var path: String = ""

    mutating func push(view: String) {
        path.append(view)
    }
}

final class LoggableRouter: RouterDecorator {
    override func push(view: String) {
        print("Pushed view: \(view)")
        super.push(view: view)
    }
}

let router = LoggableRouter(ApplicationRouter())
router.push(view: "Main")
