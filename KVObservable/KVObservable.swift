//
//  KVObservable.swift
//  KVObservable
//
//  Created by Kazunobu Tasaka on 3/17/16.
//  Copyright © 2016 Kazunobu Tasaka. All rights reserved.
//

import Foundation



public protocol KeyObserverType {
    typealias Target: NSObject
    typealias Value
    
    var keyPath: String { get }
    var target: Target { get }
    var valueChangeHandler: (old: Value?, new: Value?) -> () { get }
}

public final class AnyKeyObserver<Target: NSObject, Value>: NSObject, KeyObserverType {
    
    public let target: Target
    public let keyPath: String
    public let valueChangeHandler: (old: Value?, new: Value?) -> ()
    
    public init<Inner: KeyObserverType where Target == Inner.Target, Value == Inner.Value>(_ inner: Inner) {
        self.target = inner.target
        self.keyPath = inner.keyPath
        self.valueChangeHandler = inner.valueChangeHandler
    }
    
    deinit {
        stop()
    }
    
    public func resume() {
        let options: NSKeyValueObservingOptions = [.New, .Old]
        target.addObserver(self, forKeyPath: keyPath, options: options, context: nil)
    }
    
    private func stop() {
        target.removeObserver(self, forKeyPath: keyPath)
    }
    
    // MARK: KVO
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath,
            let change = change
            where target === object else { return }
        
        if keyPath == self.keyPath {
            let old = change[NSKeyValueChangeOldKey] as? Value
            let new = change[NSKeyValueChangeNewKey] as? Value
            valueChangeHandler(old: old, new: new)
        }
    }
}

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