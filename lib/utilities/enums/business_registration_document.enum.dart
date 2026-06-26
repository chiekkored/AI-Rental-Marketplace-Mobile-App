enum BusinessRegistrationDocumentType { dti, bir, mayorBusinessPermit }

enum BusinessRegistrationDocumentSource { camera, gallery, files }

extension BusinessRegistrationDocumentTypeText
    on BusinessRegistrationDocumentType {
  String get title {
    switch (this) {
      case BusinessRegistrationDocumentType.dti:
        return 'DTI registration';
      case BusinessRegistrationDocumentType.bir:
        return 'BIR registration';
      case BusinessRegistrationDocumentType.mayorBusinessPermit:
        return 'Mayor/Business Permit';
    }
  }

  bool get isRequired =>
      this == BusinessRegistrationDocumentType.dti ||
      this == BusinessRegistrationDocumentType.bir;

  String get fileKey {
    switch (this) {
      case BusinessRegistrationDocumentType.dti:
        return 'dti';
      case BusinessRegistrationDocumentType.bir:
        return 'bir';
      case BusinessRegistrationDocumentType.mayorBusinessPermit:
        return 'mayor_business_permit';
    }
  }
}
