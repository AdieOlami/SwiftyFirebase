//
//  FirebaseService.swift
//  SwiftyFirebase
//
//  Created by Morten Bek Ditlevsen on 29/07/2018.
//  Copyright © 2018 Ka-ching. All rights reserved.
//

import FirebaseDatabase
import Foundation

public protocol PathType {
    associatedtype PathElement
    var rendered: String { get }
}

public protocol CollectionPathType {
    associatedtype PathElement
    var rendered: String { get }
}

// A small wrapper so that we prevent the user from calling collection observation with .value
public enum CollectionEventType {
    case childAdded, childChanged, childRemoved
    var firebaseEventType: DataEventType {
        switch self {
        case .childAdded:
            return .childAdded
        case .childChanged:
            return .childChanged
        case .childRemoved:
            return .childRemoved
        }
    }
}

public class FirebaseService {
    private let rootRef: DatabaseReference
    public init(ref: DatabaseReference) {
        self.rootRef = ref.root
    }

    // MARK: Observing Paths
    func observeSingleEvent<T, P>(at path: P,
                               with block: @escaping (DecodeResult<T>) -> Void)
        where T: Decodable, P: PathType, P.PathElement == T {
            let ref = rootRef.child(path.rendered)
            
            ref.observeSingleEvent(of: .value, with: block)
    }

    func observe<T, P>(at path: P,
                    with block:  @escaping (DecodeResult<T>) -> Void) -> UInt
        where T: Decodable, P: PathType, P.PathElement == T {
            let ref = rootRef.child(path.rendered)
            return ref.observe(eventType: .value, with: block)
    }

    // MARK: Observing Collection Paths
    func observeSingleEvent<T, P>(of type: CollectionEventType,
                               at path: P,
                               with block: @escaping (DecodeResult<T>) -> Void)
        where T: Decodable, P: PathType, P.PathElement == T {
            let ref = rootRef.child(path.rendered)

            ref.observeSingleEvent(of: type.firebaseEventType, with: block)
    }

    func observe<T, P>(eventType type: CollectionEventType,
                    at path: P,
                    with block:  @escaping (DecodeResult<T>) -> Void) -> UInt
        where T: Decodable, P: CollectionPathType, P.PathElement == T {
            let ref = rootRef.child(path.rendered)
            return ref.observe(eventType: type.firebaseEventType, with: block)
    }

    // MARK: Adding and Setting
    func setValue<T, P>(at path: P, value: T) throws where T: Encodable, P: PathType, P.PathElement == T {
        let ref = rootRef.child(path.rendered)
        try ref.setValue(value)
    }

    func addValue<T, P>(at path: P, value: T) throws where T: Encodable, P: CollectionPathType, P.PathElement == T {
        let ref = rootRef.child(path.rendered)
        let childRef = ref.childByAutoId()
        try childRef.setValue(value)
    }
}
