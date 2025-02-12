// swiftlint:disable all
import Amplify
import Foundation

extension Entry {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case idUser
    case userName
    case userSurname
    case weight
    case height
    case sittingHeigh
    case dateOfEntry
    case child
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let entry = Entry.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.read]),
      rule(allow: .owner, ownerField: "idUser", identityClaim: "cognito:username", provider: .userPools, operations: [.read, .create, .update, .delete])
    ]
    
    model.listPluralName = "Entries"
    model.syncPluralName = "Entries"
    
    model.attributes(
      .index(fields: ["childId"], name: "byChild"),
      .primaryKey(fields: [entry.id])
    )
    
    model.fields(
      .field(entry.id, is: .required, ofType: .string),
      .field(entry.idUser, is: .required, ofType: .string),
      .field(entry.userName, is: .required, ofType: .string),
      .field(entry.userSurname, is: .required, ofType: .string),
      .field(entry.weight, is: .required, ofType: .string),
      .field(entry.height, is: .required, ofType: .string),
      .field(entry.sittingHeigh, is: .required, ofType: .string),
      .field(entry.dateOfEntry, is: .required, ofType: .string),
      .belongsTo(entry.child, is: .required, ofType: Child.self, targetNames: ["childId"]),
      .field(entry.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(entry.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Entry: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}