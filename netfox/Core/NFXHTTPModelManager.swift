//
//  NFXHTTPModelManager.swift
//  netfox
//
//  Copyright © 2016 netfox. All rights reserved.
//

import Foundation

public protocol NFXHTTPModelManagerDelegate: AnyObject {
    func nfxHTTPModelManagerShouldAdd(_ model: NFXHTTPModel) -> Bool
    func nfxHTTPModelManagerWillAdd(_ model: NFXHTTPModel)
}


final class NFXHTTPModelManager: NSObject {
    
    static let shared = NFXHTTPModelManager()
    
    weak var delegate: NFXHTTPModelManagerDelegate?
    let publisher = Publisher<[NFXHTTPModel]>()
       
    /// Not thread safe. Use only from main thread/queue
    private(set) var models = [NFXHTTPModel]() {
        didSet {
            notifySubscribers()
        }
    }
    
    /// Not thread safe. Use only from main thread/queue
    var filters = [Bool](repeating: true, count: HTTPModelShortType.allCases.count) {
        didSet {
            notifySubscribers()
        }
    }
    
    /// Not thread safe. Use only from main thread/queue
    var filteredModels: [NFXHTTPModel] {
        let filteredTypes = getCachedFilterTypes()
        return models.filter { filteredTypes.contains($0.shortType) }
    }
    
    /// Thread safe
    func add(_ obj: NFXHTTPModel) {
        DispatchQueue.main.async {
            guard self.delegate?.nfxHTTPModelManagerShouldAdd(obj) ?? true else { return }
            self.delegate?.nfxHTTPModelManagerWillAdd(obj)
            self.models.insert(obj, at: 0)
        }
    }
    
    /// Not thread safe. Use only from main thread/queue
    func clear() {
        models.removeAll()
    }
    
    private func getCachedFilterTypes() -> [HTTPModelShortType] {
        return filters
            .enumerated()
            .compactMap { $1 ? HTTPModelShortType.allCases[$0] : nil }
    }
    
    private func notifySubscribers() {
        if publisher.hasSubscribers {
            publisher(filteredModels)
        }
    }
    
}
