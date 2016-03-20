//
//  ProxyObserver.swift
//  KVObservable
//
//  Created by Kazunobu Tasaka on 3/20/16.
//  Copyright © 2016 Kazunobu Tasaka. All rights reserved.
//

import Foundation

protocol ProxyObserverDelegate: class {
    func valueDidChange(change: (old: AnyObject?, new: AnyObject?), forKeyPath key: String)
}

final class ProxyObserver: NSObject {
    let keyPaths: [String]
    let target: NSObject
    
    weak var delegate: ProxyObserverDelegate?
    
    init(keyPaths: [String], target: NSObject) {
        self.keyPaths = keyPaths
        self.target = target
    }
    
    deinit {
        stop()
    }
    
    func resume() {
        let options: NSKeyValueObservingOptions = [.New, .Old]
        for key in keyPaths {
            target.addObserver(self, forKeyPath: key, options: options, context: nil)
        }
    }
    
    func stop()  {
        for key in keyPaths {
            target.removeObserver(self, forKeyPath: key)
        }
    }
    
    // MARK: KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath,
            let change = change,
            let delegate = delegate
            where target === object else { return }
        
        for key in keyPaths where key == keyPath {
            let old = change[NSKeyValueChangeOldKey]
            let new = change[NSKeyValueChangeNewKey]
            delegate.valueDidChange((old: old, new: new), forKeyPath: keyPath)
            return
        }
    }
}