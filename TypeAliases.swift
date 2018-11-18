//
//  TypeAliases.swift
//  CEPSwift
//
//  Created by Filipe Jordão on 17/11/18.
//

import Foundation
public typealias EventEntry<T> = (time: Int, event: T)

public typealias StreamsToComplex<T,K> = (EventStream<T>, EventStream<K>) -> ComplexEvent
public typealias StreamToComplex<T> = (EventStream<T>) -> ComplexEvent
public typealias StreamToStream<T,K> = (EventStream<T>) -> EventStream<K>
public typealias StreamsToStream<T,K> = (EventStream<T>, EventStream<T>) -> EventStream<K>
