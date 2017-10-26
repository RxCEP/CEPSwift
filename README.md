# CEPSwift

[![CI Status](http://img.shields.io/travis/guedesbgeorge/CEPSwift.svg?style=flat)](https://travis-ci.org/guedesbgeorge/CEPSwift)
[![Version](https://img.shields.io/cocoapods/v/CEPSwift.svg?style=flat)](http://cocoapods.org/pods/CEPSwift)
[![License](https://img.shields.io/cocoapods/l/CEPSwift.svg?style=flat)](http://cocoapods.org/pods/CEPSwift)
[![Platform](https://img.shields.io/cocoapods/p/CEPSwift.svg?style=flat)](http://cocoapods.org/pods/CEPSwift)

## What's CEPSwift

CEPSwift is a Complex Event Processing Engine for Swift built on top of [RxSwift](https://github.com/ReactiveX/RxSwift)! You can create event streams, apply common CEP operators and deal with them asynchronous.

## Requirements

* Xcode 9.0
* Swift 4.0

## Example

To run the example project, clone the repo, open the  `CEPSwift.xcworkspace` from the Example directory and hit run.

## Usage

This sections is under construction. But for now we are currently supporting some common CEP operators like agregational operators (max and min), window, filter, followedBy, map, merge. All this operators will be explanained here  and more will be available soon!

## Installation

CEPSwift uses [RxSwift](https://github.com/ReactiveX/RxSwift) as external dependency.

### Manual

Copy all the files located at CEPSwift/Classes folder and copy to your project. Also add [RxSwift](https://github.com/ReactiveX/RxSwift) as dependency.

### [CocoaPods](http://cocoapods.org)

CEPSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CEPSwift'
```

## Author

George Guedes, guedesbgeorge42@gmail.com

## Acknowledgment

CEPSwift was conceived as part of a thesis during undergraduation. We would like to thank the advisor and mentor of this project, professor [Kiev Gama](http://cin.ufpe.br/~kiev/).

Also we would like to thank [RxSwift](https://github.com/ReactiveX/RxSwift) for the great framework that we use here!

## License

CEPSwift is available under the MIT license. See the LICENSE file for more info.

## Contributions

If you run into problems, please open up an issue. We also actively welcome pull requests, we simply ask that you strive to maintain consistency with the structure and formatting of existing code. By contributing to CEPSwift you agree that your contributions will be licensed under its MIT license.

