//
//  TargetObserver.swift
//  KVObservable
//
//  Created by Kazunobu Tasaka on 3/20/16.
//  Copyright © 2016 Kazunobu Tasaka. All rights reserved.
//

import Foundation

public struct ValueChange {
    let keyPath: String
    let oldValue: AnyObject?
    let newValue: AnyObject?
}

public protocol TargetObserverType {
    typealias Target: NSObject
    var target: Target { get }
    var keyPaths: [String] { get }
    var valueChangeHandler: (ValueChange) -> () { get }
}

// MARK:
public class AnyTargetObserver<Target: NSObject>: NSObject, TargetObserverType {
    public let target: Target
    public let keyPaths: [String]
    public let valueChangeHandler: (ValueChange) -> ()
    
    public init<Base: TargetObserverType where Target == Base.Target>(_ base: Base) {
        self.target = base.target
        self.keyPaths = base.keyPaths
        self.valueChangeHandler = base.valueChangeHandler
    }
    
    deinit {
        stop()
    }
    
    public func resume() {
        keyPaths.forEach {
            let options: NSKeyValueObservingOptions = [.New, .Old]
            target.addObserver(self, forKeyPath: $0, options: options, context: nil)
        }
    }
    
    private func stop() {
        keyPaths.forEach {
            target.removeObserver(self, forKeyPath: $0)
        }
    }
    
    // MARK: KVO
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath,
            let change = change
            where target === object else { return }
        
        for key in keyPaths where key == keyPath {
            let new = change[NSKeyValueChangeNewKey]
            let old = change[NSKeyValueChangeOldKey]
            
            let vc = ValueChange(keyPath: keyPath, oldValue: old, newValue: new)
            
            valueChangeHandler(vc)
            return
        }
    }
}