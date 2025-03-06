// swiftlint:disable all
import Amplify
import Foundation

extension Child {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case idUser
    case userName
    case userSurname
    case name
    case surname
    case dateOfBirth
    case gender
    case motherHeight
    case fatherHeight
    case parentsMeasurements
    case country
    case ethnicity
    case primarySport
    case approveData
    case uniqueId
    case status
    case entries
    case linkChildToUser
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let child = Child.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.read]),
      rule(allow: .owner, ownerField: "idUser", identityClaim: "cognito:username", provider: .userPools, operations: [.read, .create, .update, .delete])
    ]
    
    model.listPluralName = "Children"
    model.syncPluralName = "Children"
    
    model.attributes(
      .primaryKey(fields: [child.id])
    )
    
    model.fields(
      .field(child.id, is: .required, ofType: .string),
      .field(child.idUser, is: .required, ofType: .string),
      .field(child.userName, is: .required, ofType: .string),
      .field(child.userSurname, is: .required, ofType: .string),
      .field(child.name, is: .required, ofType: .string),
      .field(child.surname, is: .required, ofType: .string),
      .field(child.dateOfBirth, is: .required, ofType: .string),
      .field(child.gender, is: .required, ofType: .string),
      .field(child.motherHeight, is: .required, ofType: .string),
      .field(child.fatherHeight, is: .required, ofType: .string),
      .field(child.parentsMeasurements, is: .required, ofType: .string),
      .field(child.country, is: .required, ofType: .string),
      .field(child.ethnicity, is: .required, ofType: .string),
      .field(child.primarySport, is: .required, ofType: .string),
      .field(child.approveData, is: .required, ofType: .bool),
      .field(child.uniqueId, is: .required, ofType: .int),
      .field(child.status, is: .required, ofType: .enum(type: ChildStatus.self)),
      .hasMany(child.entries, is: .optional, ofType: Entry.self, associatedWith: Entry.keys.child),
      .hasMany(child.linkChildToUser, is: .optional, ofType: LinkChildToUser.self, associatedWith: LinkChildToUser.keys.child),
      .field(child.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(child.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Child: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}