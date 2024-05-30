import Foundation

struct Level: Identifiable {
    let id: String
    let level: Int
    let time: Int
    let vulkan: Bool
    let rain: Bool
    let wind: Bool
    let complicationsCount: Int
}
