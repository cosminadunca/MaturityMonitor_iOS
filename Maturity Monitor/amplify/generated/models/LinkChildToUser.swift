// swiftlint:disable all
import Amplify
import Foundation

public struct LinkChildToUser: Model {
  public let id: String
  public var idUser: String
  public var child: Child
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      idUser: String,
      child: Child) {
    self.init(id: id,
      idUser: idUser,
      child: child,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      idUser: String,
      child: Child,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.idUser = idUser
      self.child = child
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}