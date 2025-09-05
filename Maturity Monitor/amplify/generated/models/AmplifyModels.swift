// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "58199e9b2c764cc93a796f5ac52ceb5b"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Child.self)
    ModelRegistry.register(modelType: Entry.self)
    ModelRegistry.register(modelType: LinkChildToUser.self)
  }
}