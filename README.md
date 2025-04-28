# DecoratableMacro 🎨

[![Swift 6.1.0](https://img.shields.io/badge/Swift-6.1.0-orange.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)

Automatically generate decorator classes for Swift protocols using macros. Just add `@Decoratable` to your protocol — the macro will create a ready-to-use decorator class!

## Features ✨

- 🚀 **Auto-generated decorators** for Swift protocols
- 🔒 **Full access control support** (public, internal, fileprivate, private)
- 📦 **2-minute integration** via Swift Package Manager

## Installation 📦

1. Add the package to your `Package.swift`:
```swift
dependencies: [
    .package(
        url: "https://github.com/Kristalev/DecoratableMacro.git", 
        from: "1.0.0"
    )
]
```

2. Add to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "DecoratableMacro", package: "DecoratableMacro")
    ]
)
```

## Usage 🛠️

1. Annotate your protocol with @Decoratable:

```swift
import DecoratableMacro

@Decoratable
protocol Router {
    func push(viewController: UIViewController) 
}
```

2. The macro generates:

```swift
class RouterDecorator: Router {
    private var decoree: any Router
    
    init(_ decoree: any Router) {
        self.decoree = decoree
    }
    
    func push(viewController: UIViewController) {
        decoree.push(viewController: viewController)
    }
}
```

## Limitations ⚠️

1) Works only with protocols (not classes/structs)
2) Doesn't support generic protocols
3) Not supported method modifier compatibility (async/throws)

## License 📄

This project is MIT licensed. See [LICENSE](https://opensource.org/licenses/MIT) for details.

⭐ If you find this useful, please consider starring the repo!
🐞 Bugs & feature requests: [Issues](https://github.com/Kristalev/DecoratableMacro/issues)
