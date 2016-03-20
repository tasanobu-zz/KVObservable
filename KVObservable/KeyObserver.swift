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
    
    init(target: Target, keyPath: String, handler: (old: Value?, new: Value?) -> ())
}

public final class AnyKeyObserver<Target: NSObject, Value>: KeyObserverType {

    private let valueChangeHandler: ((old: Value?, new: Value?) -> ())
    
    private let proxy: ProxyObserver
    
    public init(target: Target, keyPath: String, handler: (old: Value?, new: Value?) -> ()) {
        
        self.valueChangeHandler = handler
        
        proxy = ProxyObserver(keyPaths: [keyPath], target: target)
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