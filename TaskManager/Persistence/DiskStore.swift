//
//  DiskStore.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation

public struct DiskStore {
    public enum StoreError: Error, LocalizedError {
        case notFound, decodeFailed, encodeFailed, writeFailed
        public var errorDescription: String? {
            switch self {
            case .notFound: "File not found"
            case .decodeFailed: "Failed to decode file"
            case .encodeFailed: "Failed to encode content"
            case .writeFailed: "Failed to write file"
            }
        }
    }

    public let url: URL

    public init(filename: String, directory: URL? = nil) {
        let dir: URL
        if let directory {
            dir = directory
        } else {
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!
            dir = appSupport.appendingPathComponent(
                "TaskManager",
                isDirectory: true
            )
        }
        try? FileManager.default.createDirectory(
            at: dir,
            withIntermediateDirectories: true
        )
        self.url = dir.appendingPathComponent(filename, isDirectory: false)
    }

    public func save(_ value: some Encodable) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(value) else {
            throw StoreError.encodeFailed
        }
        do { try data.write(to: self.url, options: .atomic) } catch {
            throw StoreError.writeFailed
        }
    }

    public func load<T: Decodable>(_ type: T.Type) throws -> T {
        guard FileManager.default.fileExists(atPath: self.url.path) else {
            throw StoreError.notFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let value = try? decoder.decode(type, from: data) else {
            throw StoreError.decodeFailed
        }
        return value
    }

    public func loadOrDefault<T: Codable>(_ defaultValue: @autoclosure () -> T)
        -> T
    {
        (try? self.load(T.self)) ?? defaultValue()
    }
}
