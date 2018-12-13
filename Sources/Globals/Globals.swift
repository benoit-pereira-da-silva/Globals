//
//  Globals.swift
//  Globals
//
//  Created by Benoit Pereira da silva on 20/11/2018.
//  Copyright © 2018 Benoit Pereira da Silva. All rights reserved.
//

import Foundation

public typealias Path = String

// MARK: - Time

public func AbsoluteTimeGetCurrent() -> Double{
    return Double(CFAbsoluteTimeGetCurrent())
}


// The start Time is define when launching.
fileprivate let _startTime: Double = AbsoluteTimeGetCurrent()

/// Returns the elapsed time since launch time.
///
/// - Returns: the elapsed tile
public func getElapsedTime()->Double {
    return AbsoluteTimeGetCurrent() - _startTime
}

/// Measure the execution duration of a given block
///
///   - execute: the execution block to be evaluated
/// - Returns: the execution time
public func measure(_ execute: () throws -> Void) rethrows -> Double {
    let ts: Double = AbsoluteTimeGetCurrent()
    try execute()
    return (AbsoluteTimeGetCurrent()-ts)
}

// MARK: - Main Thread

public func syncOnMain(execute block: () throws -> Void) rethrows-> (){
    if Thread.isMainThread {
        try block()
    } else {
        try DispatchQueue.main.sync(execute: block)
    }
}


public func syncOnMainAndReturn<T>(execute work: () throws -> T) rethrows -> T {
    if Thread.isMainThread {
        return try work()
    } else {
        return try DispatchQueue.main.sync(execute: work)
    }
}

// MARK: - Hashes


public func combineHashes(_ hashes: [Int]) -> Int {
    return hashes.reduce(0, combineHashValues)
}

public func combineHashValues(_ initial: Int, _ other: Int) -> Int {
    #if arch(x86_64) || arch(arm64)
    let magic: UInt = 0x9e3779b97f4a7c15
    #elseif arch(i386) || arch(arm)
    let magic: UInt = 0x9e3779b9
    #endif
    var lhs = UInt(bitPattern: initial)
    let rhs = UInt(bitPattern: other)
    lhs ^= rhs &+ magic &+ (lhs << 6) &+ (lhs >> 2)
    return Int(bitPattern: lhs)
}


// MARK: - Collection persistency

public func saveCollection<T:Codable>(collection: [T], to url: URL) throws ->(){
    let data: Data = try JSONEncoder().encode(collection)
    try _write(data: data, to: url)
}


public func loadCollection<T:Codable>(from url:URL) throws -> [T]{
    let data: Data = try Data(contentsOf: url)
    return try JSONDecoder().decode([T].self, from: data)
}


public func save<T:Codable>(instance: T, to url: URL) throws ->(){
    let data: Data = try JSONEncoder().encode(instance)
    try _write(data: data, to: url)
}

public func load<T:Codable>(from url:URL) throws -> T{
    let data: Data = try Data(contentsOf: url)
    return try JSONDecoder().decode(T.self, from: data)
}


fileprivate func _write(data:Data, to url:URL) throws -> (){
    do{
        try data.write(to: url)
    }catch{
        let parentFolder:URL = url.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: parentFolder.path){
            // Let's try to create the parent folder
            try FileManager.default.createDirectory(at: parentFolder, withIntermediateDirectories: true, attributes: nil)
            // Retry
            try data.write(to: url)
        }
    }
}


// MARK: - Paths

/// The document directory URL
/// - Returns: the base directory URL
public func getDocumentsDirectoryURL() -> URL {
    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    if let url = urls.first {
        return url
    }
    #elseif os(Linux)
    #endif
    return URL(fileURLWithPath: "Invalid")
}

// MARK: - Log

public var USE_ECHO_MODE:Bool = false

public func log(_ message: Any, file: String = #file, function: String = #function, line: Int = #line, decorative: Bool = false) {
    if !USE_ECHO_MODE{
        let filestr: NSString = NSString(string:file)
        print ("\(Date()) -\(filestr.lastPathComponent).\(line).\(function): \(message)")
    }else{
        print (message)
    }

}

public func doCatchLog(_ block:@escaping() throws -> Void, file: String = #file, function: String = #function, line: Int = #line, decorative: Bool = false){
    do{
        try block()
    } catch{
        log("Error: \(error)",file: file,function: function, line: line,decorative: decorative)
    }
}

// MARK: - Random


public func random<T: BinaryInteger> (_ n: T) -> T {
    return numericCast( arc4random_uniform( numericCast(n) ) )
}

public func random<T: BinaryInteger> (_ from: T, _ to: T) -> T{
    let minV:T = min(from, to)
    let maxV:T = max(from, to)
    let distance = maxV - minV
    if distance > 0{
        return random(distance + 1) + minV
    }else{
        return minV
    }
}




// MARK: - UIDs


public var BASE64_ENCODED_UIDS = true

public func createUID() -> String {
    if BASE64_ENCODED_UIDS {
        let uid: String = UUID.init().uuidString
        let encoded: Data = uid.data(using: .utf8)!
        return encoded.base64EncodedString()
    } else {
        let uid: String = UUID.init().uuidString.replacingOccurrences(of: "-", with: "")
        return uid
    }
}


// MARK: - String utilities

public func ltrim(_ string: String, characterSet: CharacterSet=CharacterSet.whitespacesAndNewlines) -> String {
    if let range = string.rangeOfCharacter(from: characterSet.inverted) {
        return String(string[range.lowerBound..<string.endIndex])
    }
    return string
}

/**
 Left trims the characters specified in the characters

 E.g:
 + PString.ltrim("   *   Hello    *    ",characters:" *") // returns "Hello    *    "
 + PString.ltrim(",A,B,C",characters:",")) // Returns "A,B,C"

 - parameter string:       the string
 - parameter characterSet: the character set (White spaces and new line by default)

 - returns: the string
 */
public func ltrim(_ string: String, characters: String) -> String {
    return ltrim(string, characterSet: CharacterSet(charactersIn:characters) )
}


/**
 Right trim the characters specified in the characterSet

 - parameter string:       the string
 - parameter characters: the character set (White spaces and new line by default)

 - returns: the string
 */

public func rtrim(_ string: String, characterSet: CharacterSet=CharacterSet.whitespacesAndNewlines) -> String {
    if let range = string.rangeOfCharacter(from: characterSet.inverted, options: NSString.CompareOptions.backwards) {
        return String(string[string.startIndex...range.lowerBound])
    }
    return string
}

public func rtrim(_ string: String, characters: String) -> String {
    return rtrim(string, characterSet: CharacterSet(charactersIn:characters) )
}


public func trim(_ string: String,characters: String) -> String {
    return rtrim(ltrim(string,characters:characters),characters:characters)
}


public func trim(_ string: String) -> String {
    return rtrim(ltrim(string))
}


// MARK: Assigment


// The `=? operator allows simplify optional assignements :
//  `a = b ?? a` can be written : `a =? b`
infix operator =?: AssignmentPrecedence

public func =?<T> ( left: inout T?, right: T? ){
    left = right ?? left
}

public func =?<T> ( left: inout T, right: T? ){
    left = right ?? left
}

