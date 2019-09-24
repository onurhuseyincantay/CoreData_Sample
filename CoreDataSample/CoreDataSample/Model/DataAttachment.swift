import Foundation

@objc(DataAttachment)
open class DataAttachment: _DataAttachment {
	// Custom logic goes here.
}


 @objc public enum DataAttachmentType: UInt16 {
  case photo
  case xml
  case json
}
