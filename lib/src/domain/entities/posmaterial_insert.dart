class PosMaterialInsert {
  String? salesName,
      noAccount,
      namaUsaha,
      alamatUsaha,
      opticType,
      posType,
      productId,
      productName,
      productQty,
      priceEstimate,
      productSizeS,
      productSizeM,
      productSizeL,
      productSizeXL,
      productSizeXXL,
      productSizeXXXL,
      posterDesignOnly,
      posterMaterialId,
      posterMaterial,
      posterWidth,
      posterHeight,
      posterContentId,
      posterContent,
      notes,
      deliveryMethod,
      attachmentDesainParaf,
      attachmentKtp,
      attachmentNpwp,
      attachmentOmzet,
      attachmentRencanaLokasi,
      createdBy;

  String get getSalesName {
    return salesName ?? "";
  }

  String get getNoAccount {
    return noAccount ?? "";
  }

  String get getNamaUsaha {
    return namaUsaha ?? "";
  }

  String get getAlamatUsaha {
    return alamatUsaha ?? "";
  }

  String get getOpticType {
    return opticType ?? "PROSPECT";
  }

  String get getPosType {
    return posType ?? "CUSTOM";
  }

  String get getProductId {
    return productId ?? "";
  }

  String get getProductName {
    return productName ?? "";
  }

  String get getProductQty {
    return productQty ?? "0";
  }

  String get getPriceEstimate {
    return priceEstimate ?? "0";
  }

  String get getProductSizeS {
    return productSizeS ?? "0";
  }

  String get getProductSizeM {
    return productSizeM ?? "0";
  }

  String get getProductSizeL {
    return productSizeL ?? "0";
  }

  String get getProductSizeXL {
    return productSizeXL ?? "0";
  }

  String get getProductSizeXXL {
    return productSizeXXL ?? "0";
  }

  String get getProductSizeXXXL {
    return productSizeXXXL ?? "0";
  }

  String get getPosterDesignOnly {
    return posterDesignOnly ?? "";
  }

  String get getPosterMaterialId {
    return posterMaterialId ?? "";
  }

  String get getPosterMaterial {
    return posterMaterial ?? "";
  }

  String get getPosterWidth {
    return posterWidth ?? "0";
  }

  String get getPosterHeight {
    return posterHeight ?? "0";
  }

  String get getPosterContentId {
    return posterContentId ?? "0";
  }

  String get getPosterContent {
    return posterContent ?? "";
  }

  String get getNotes {
    return notes ?? "";
  }

  String get getDeliveryMethod {
    return deliveryMethod ?? "Kirim ke optik";
  }

  String get getAttachmentDesainParaf {
    return attachmentDesainParaf ?? "";
  }

  String get getAttachmentKtp {
    return attachmentKtp ?? "";
  }

  String get getAttachmentNpwp {
    return attachmentNpwp ?? "";
  }

  String get getAttachmentOmzet {
    return attachmentOmzet ?? "";
  }

  String get getAttachmentRencanaLokasi {
    return attachmentRencanaLokasi ?? "";
  }

  String get getCreatedBy {
    return createdBy ?? "";
  }

  set setSalesName(String _salesName) {
    salesName = _salesName;
  }

  set setNoAccount(String _noAccount) {
    noAccount = _noAccount;
  }

  set setNamaUsaha(String _namaUsaha) {
    namaUsaha = _namaUsaha;
  }

  set setAlamatUsaha(String _alamatUsaha) {
    alamatUsaha = _alamatUsaha;
  }

  set setOpticType(String _opticType) {
    opticType = _opticType;
  }

  set setPosType(String _posType) {
    posType = _posType;
  }

  set setProductId(String _productId) {
    productId = _productId;
  }

  set setProductName(String _productName) {
    productName = _productName;
  }

  set setProductQty(String _productQty) {
    productQty = _productQty;
  }

  set setPriceEstimate(String _priceEstimate) {
    priceEstimate = _priceEstimate;
  }

  set setProductSizeS(String _productSizeS) {
    productSizeS = _productSizeS;
  }

  set setProductSizeM(String _productSizeM) {
    productSizeM = _productSizeM;
  }

  set setProductSizeL(String _productSizeL) {
    productSizeL = _productSizeL;
  }

  set setProductSizeXl(String _productSizeXl) {
    productSizeXL = _productSizeXl;
  }

  set setProductSizeXXL(String _productSizeXXL) {
    productSizeXXL = _productSizeXXL;
  }

  set setProductSizeXXXL(String _productSizeXXXL) {
    productSizeXXXL = _productSizeXXXL;
  }

  set setPosterDesignOnly(String _posterDesignOnly) {
    posterDesignOnly = _posterDesignOnly;
  }

  set setPosterMaterialId(String _posterMaterialId) {
    posterMaterialId = _posterMaterialId;
  }

  set setPosterMaterial(String _posterMaterial) {
    posterMaterial = _posterMaterial;
  }

  set setPosterWidth(String _posterWidth) {
    posterWidth = _posterWidth;
  }

  set setPosterHeight(String _posterHeight) {
    posterHeight = _posterHeight;
  }

  set setPosterContentId(String _posterContentId) {
    posterContentId = _posterContentId;
  }

  set setPosterContent(String _posterContent) {
    posterContent = _posterContent;
  }

  set setNotes(String _notes) {
    notes = _notes;
  }

  set setDeliveryMethod(String _deliveryMethod) {
    deliveryMethod = _deliveryMethod;
  }

  set setAttachmentDesainParaf(String _attachmentDesainParaf) {
    attachmentDesainParaf = _attachmentDesainParaf;
  }

  set setAttachmentKtp(String _attachmentKtp) {
    attachmentKtp = _attachmentKtp;
  }

  set setAttachmentNpwp(String _attachmentNpwp) {
    attachmentNpwp = _attachmentNpwp;
  }

  set setAttachmentOmzet(String _attachmentOmzet) {
    attachmentOmzet = _attachmentOmzet;
  }

  set setAttachmentRencanaLokasi(String _attachmentRencanaLokasi) {
    attachmentRencanaLokasi = _attachmentRencanaLokasi;
  }

  set setCreatedBy(String _createdBy) {
    createdBy = _createdBy;
  }

  String toString() {
    return """
      salesname : $salesName, 
      noAccount : $noAccount, 
      namaUsaha : $namaUsaha, 
      alamatUsaha : $alamatUsaha, 
      opticType : $opticType, 
      posType : $posType, 
      productId : $productId,
      productName : $productName,
      productQty : $productQty,t
      priceEstimate : $priceEstimate,
      productSizeS : $productSizeS,
      productSizeM : $productSizeM,
      productSizeL : $productSizeL,
      productSizeXL : $productSizeXL,
      productSizeXXL : $productSizeXXL,
      productSizeXXXL : $productSizeXXXL,
      posterDesignOnly : $posterDesignOnly,
      posterMaterialId : $posterMaterialId,
      posterMaterial : $posterMaterial,
      posterWidth : $posterWidth,
      posterHeight : $posterHeight,
      posterContentId : $posterContentId,
      posterContent : $posterContent,
      notes : $notes,
      deliveryMethod : $deliveryMethod,
      attachmentDesainParaf : ${attachmentDesainParaf != null ? 'base64DesainParaf' : ''},
      attachmentKtp : ${attachmentKtp != null ? 'base64Ktp' : ''},
      attachmentNpwp : ${attachmentNpwp != null ? 'base64Npwp' : ''},
      attachmentOmzet : ${attachmentOmzet != null ? 'base64Omzet' : ''},
      attachmentRencanaLokasi : ${attachmentRencanaLokasi != null ? 'base64RencanaLokasi' : ''},
      createdBy : $createdBy,
      """;
  }
}
