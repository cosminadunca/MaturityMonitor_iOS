// swiftlint:disable all
import Amplify
import Foundation

public struct Entry: Model {
  public let id: String
  public var idUser: String
  public var userName: String
  public var userSurname: String
  public var weight: String
  public var height: String
  public var sittingHeigh: String
  public var dateOfEntry: String
  public var child: Child
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      idUser: String,
      userName: String,
      userSurname: String,
      weight: String,
      height: String,
      sittingHeigh: String,
      dateOfEntry: String,
      child: Child) {
    self.init(id: id,
      idUser: idUser,
      userName: userName,
      userSurname: userSurname,
      weight: weight,
      height: height,
      sittingHeigh: sittingHeigh,
      dateOfEntry: dateOfEntry,
      child: child,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      idUser: String,
      userName: String,
      userSurname: String,
      weight: String,
      height: String,
      sittingHeigh: String,
      dateOfEntry: String,
      child: Child,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.idUser = idUser
      self.userName = userName
      self.userSurname = userSurname
      self.weight = weight
      self.height = height
      self.sittingHeigh = sittingHeigh
      self.dateOfEntry = dateOfEntry
      self.child = child
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}