import Foundation
import UniformTypeIdentifiers

enum VaultStorageService {
    static var vaultDirectory: URL {
        let base = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.lukebillings.Staydayo")
            ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Vault", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func store(data: Data, suggestedName: String) throws -> String {
        let safe = suggestedName.replacingOccurrences(of: "/", with: "-")
        let fileName = "\(UUID().uuidString)-\(safe)"
        let url = vaultDirectory.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return fileName
    }

    static func url(for storedFileName: String) -> URL {
        vaultDirectory.appendingPathComponent(storedFileName)
    }

    static func delete(storedFileName: String) throws {
        let url = url(for: storedFileName)
        try FileManager.default.removeItem(at: url)
    }
}
