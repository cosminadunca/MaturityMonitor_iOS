// swiftlint:disable all
import Amplify
import Foundation

public enum ChildStatus: String, EnumPersistable {
  case active = "ACTIVE"
  case inactive = "INACTIVE"
}