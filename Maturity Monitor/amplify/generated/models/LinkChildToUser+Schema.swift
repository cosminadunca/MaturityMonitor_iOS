// swiftlint:disable all
import Amplify
import Foundation

extension LinkChildToUser {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case idUser
    case child
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let linkChildToUser = LinkChildToUser.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.read]),
      rule(allow: .owner, ownerField: "idUser", identityClaim: "cognito:username", provider: .userPools, operations: [.read, .create, .update, .delete])
    ]
    
    model.listPluralName = "LinkChildToUsers"
    model.syncPluralName = "LinkChildToUsers"
    
    model.attributes(
      .index(fields: ["idChild"], name: "byChildLink"),
      .primaryKey(fields: [linkChildToUser.id])
    )
    
    model.fields(
      .field(linkChildToUser.id, is: .required, ofType: .string),
      .field(linkChildToUser.idUser, is: .required, ofType: .string),
      .belongsTo(linkChildToUser.child, is: .required, ofType: Child.self, targetNames: ["idChild"]),
      .field(linkChildToUser.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(linkChildToUser.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension LinkChildToUser: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}