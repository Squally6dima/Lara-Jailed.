import Foundation

public enum ManifestDecoder {
    /// Decode and validate a JSON package manifest before it is displayed or stored.
    public static func decode(_ data: Data) throws -> PackageManifest {
        let manifest = try JSONDecoder().decode(PackageManifest.self, from: data)
        try manifest.validate()
        return manifest
    }
}
