// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "7363832662469ff2d2a14652a2bad73a"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Child.self)
    ModelRegistry.register(modelType: Entry.self)
    ModelRegistry.register(modelType: LinkChildToUser.self)
  }
}