// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "b5c3b7f2e78a34e3957fb221e1518483"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Child.self)
    ModelRegistry.register(modelType: Entry.self)
    ModelRegistry.register(modelType: LinkChildToUser.self)
  }
}