// swiftlint:disable all
import Amplify
import Foundation

public struct Child: Model {
  public let id: String
  public var idUser: String
  public var userName: String
  public var userSurname: String
  public var name: String
  public var surname: String
  public var dateOfBirth: String
  public var gender: String
  public var motherHeight: String
  public var fatherHeight: String
  public var parentsMeasurements: String
  public var country: String
  public var ethnicity: String
  public var primarySport: String
  public var approveData: Bool
  public var disserartionApproval: Bool
  public var uniqueId: Int
  public var status: ChildStatus
  public var entries: List<Entry>?
  public var linkChildToUser: List<LinkChildToUser>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      idUser: String,
      userName: String,
      userSurname: String,
      name: String,
      surname: String,
      dateOfBirth: String,
      gender: String,
      motherHeight: String,
      fatherHeight: String,
      parentsMeasurements: String,
      country: String,
      ethnicity: String,
      primarySport: String,
      approveData: Bool,
      disserartionApproval: Bool,
      uniqueId: Int,
      status: ChildStatus,
      entries: List<Entry>? = [],
      linkChildToUser: List<LinkChildToUser>? = []) {
    self.init(id: id,
      idUser: idUser,
      userName: userName,
      userSurname: userSurname,
      name: name,
      surname: surname,
      dateOfBirth: dateOfBirth,
      gender: gender,
      motherHeight: motherHeight,
      fatherHeight: fatherHeight,
      parentsMeasurements: parentsMeasurements,
      country: country,
      ethnicity: ethnicity,
      primarySport: primarySport,
      approveData: approveData,
      disserartionApproval: disserartionApproval,
      uniqueId: uniqueId,
      status: status,
      entries: entries,
      linkChildToUser: linkChildToUser,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      idUser: String,
      userName: String,
      userSurname: String,
      name: String,
      surname: String,
      dateOfBirth: String,
      gender: String,
      motherHeight: String,
      fatherHeight: String,
      parentsMeasurements: String,
      country: String,
      ethnicity: String,
      primarySport: String,
      approveData: Bool,
      disserartionApproval: Bool,
      uniqueId: Int,
      status: ChildStatus,
      entries: List<Entry>? = [],
      linkChildToUser: List<LinkChildToUser>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.idUser = idUser
      self.userName = userName
      self.userSurname = userSurname
      self.name = name
      self.surname = surname
      self.dateOfBirth = dateOfBirth
      self.gender = gender
      self.motherHeight = motherHeight
      self.fatherHeight = fatherHeight
      self.parentsMeasurements = parentsMeasurements
      self.country = country
      self.ethnicity = ethnicity
      self.primarySport = primarySport
      self.approveData = approveData
      self.disserartionApproval = disserartionApproval
      self.uniqueId = uniqueId
      self.status = status
      self.entries = entries
      self.linkChildToUser = linkChildToUser
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}