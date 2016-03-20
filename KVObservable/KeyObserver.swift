//
//  KeyObserver.swift
//  KVObservable
//
//  Created by Kazunobu Tasaka on 3/20/16.
//  Copyright © 2016 Kazunobu Tasaka. All rights reserved.
//

import Foundation

public protocol KeyObserverType: class {
    typealias Target: NSObject
    typealias Value
    
    var keyPath: String { get }
    var target: Target { get }
    var valueChangeHandler: (old: Value?, new: Value?) -> () { get }
}

public final class AnyKeyObserver<Target: NSObject, Value>: KeyObserverType {
    
    public let target: Target
    public let keyPath: String
    public let valueChangeHandler: (old: Value?, new: Value?) -> ()
    
    private let proxy: ProxyObserver
    
    public init<Inner: KeyObserverType where Target == Inner.Target, Value == Inner.Value>(_ inner: Inner) {
        self.target = inner.target
        self.keyPath = inner.keyPath
        self.valueChangeHandler = inner.valueChangeHandler
        
        proxy = ProxyObserver(keyPaths: [inner.keyPath], target: inner.target)
        proxy.delegate = self
        proxy.resume()
    }
}

extension AnyKeyObserver: ProxyObserverDelegate {
    func valueDidChange(change: (old: AnyObject?, new: AnyObject?), forKeyPath key: String) {
        let o = change.old as? Value
        let n = change.new as? Value
        valueChangeHandler(old: o, new: n)
    }
}