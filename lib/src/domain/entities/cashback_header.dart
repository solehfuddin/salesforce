class CashbackHeader {
  String? id,
			salesName,
			shipNumber,
      billNumber,
			opticName,
			opticAddress,
			opticType,
			startPeriode,
			endPeriode,
      dataNama,
			dataNik,
		  dataNpwp,
      isSpSatuan,
      spNumber,
      isSpPercent,
			withdrawDuration,
			withdrawProcess,
			idCashbackRekening,
			cashbackType,
			targetValue,
			targetDuration,
			targetProduct,
			paymentDuration,
      paymentMechanism,
      paymentDate,
			approvalSm,
			approverSm,
			reasonSm,
			dateApprovalSm,
			approvalGm,
			approverGm,
			reasonGm,
			dateApprovalGm,
			status,
			createdBy,
			insertDate,
			updateDate,
      bankName,
      bankId,
      accountNumber,
      accountName,
			smName,
			gmName,
      cashbackValue,
			cashbackPercentage,
      attachmentSign,
      attachmentOther;

  CashbackHeader();

  String get getSalesName {
    return salesName ?? "";
  }

  String get getShipNumber {
    return shipNumber ?? "";
  }

  String get getOpticName {
    return opticName ?? "";
  }

  String get getOpticAddress {
    return opticAddress?? "";
  }

  String get getOpticType {
    return opticType?? "";
  }

  String get getStartPeriode {
    return startPeriode ?? "";
  }

  String get getEndPeriode {
    return endPeriode ?? "";
  }

  String get getDataNama {
    return dataNama ?? "";
  }

  String get getDataNik {
    return dataNik ?? "";
  }

  String get getDataNpwp {
    return dataNpwp ?? "";
  }

  String get getWithdrawDuration {
    return withdrawDuration ?? "";
  }

  String get getWithdrawProcess {
    return withdrawProcess ?? "";
  }

  String get getIdCashbackRekening {
    return idCashbackRekening?? "";
  }

  String get getCashbackType {
    return cashbackType?? "";
  }

  String get getTargetValue {
    return targetValue ?? "";
  }

  String get getTargetDuration {
    return targetDuration ?? "";
  }

  String get getTargetProduct {
    return targetProduct?? "";
  }

  String get getCashbackValue {
    return cashbackValue ?? "";
  }

  String get getCashbackPercentage {
    return cashbackPercentage ?? "";
  }

  String get getPaymentDuration {
    return paymentDuration ?? "";
  }

  String get getCreatedBy {
    return createdBy ?? "";
  }

  String get getAttachmentSign {
    return attachmentSign?? "";
  }

  String get getAttachmentOther {
    return attachmentOther?? "";
  }

  String get getBillNumber {
    return billNumber ?? "";
  }

  set setSalesName(String _value) {
    salesName = _value;
  }

  set setShipNumber(String _value) {
    shipNumber = _value;
  }

  set setOpticName(String _value) {
    opticName = _value;
  }

  set setOpticAddress(String _value) {
    opticAddress = _value;
  }

  set setOpticType(String _value) {
    opticType = _value;
  }

  set setStartPeriode(String _value) {
    startPeriode = _value;
  }

  set setEndPeriode(String _value) {
    endPeriode = _value;
  }

  set setDataNama(String _value) {
    dataNama = _value;
  }

  set setDataNik(String _value) {
    dataNik = _value;
  }

  set setDataNpwp(String _value) {
    dataNpwp = _value;
  }

  set setDataIsSpSatuan(String _value) {
    isSpSatuan = _value;
  }

  set setDataSpNumber(String _value) {
    spNumber = _value;
  }

  set setDataIsSpPercent(String _value) {
    isSpPercent = _value;
  }

  set setWithdrawDuration(String _value) {
    withdrawDuration = _value;
  }

  set setWithdrawProcess(String _value) {
    withdrawProcess = _value;
  }

  set setIdCashbackRekening(String _value) {
    idCashbackRekening = _value;
  }

  set setCashbackType(String _value) {
    cashbackType = _value;
  }

  set setTargetValue(String _value) {
    targetValue = _value;
  }

  set setTargetDuration(String _value) {
    targetDuration = _value;
  }

  set setTargetProduct(String _value) {
    targetProduct = _value;
  }

  set setCashbackValue(String? _value) {
    cashbackValue = _value;
  }

  set setCashbackPercentage(String? _value) {
    cashbackPercentage = _value;
  }

  set setPaymentDuration(String _value) {
    paymentDuration = _value;
  }

  set setPaymentMechanism(String _value) {
    paymentMechanism = _value;
  }

  set setPaymentDate(String _value) {
    paymentDate = _value;
  }

  set setCreatedBy(String _value) {
    createdBy = _value;
  }

  set setAttachmentSign(String _value) {
    attachmentSign = _value;
  }

  set setAttachmentOther(String _value) {
    attachmentOther = _value;
  }

  set setBillNumber(String _value) {
    billNumber = _value;
  }

  CashbackHeader.fromJson(Map json)
   :  id = json['id_cashback'],
			salesName = json['salesname'],
			shipNumber = json['ship_number'],
			billNumber = json['bill_number'],
      opticName = json['optic_name'],
		  opticAddress = json['optic_address'],
		  opticType = json['optic_type'],
		  startPeriode = json['start_periode'],
		  endPeriode = json['end_periode'],
      dataNama = json['data_nama'],
		  dataNik = json['data_nik'],
		  dataNpwp = json['data_npwp'],
      isSpSatuan = json['is_sp_satuan'],
      spNumber = json['sp_number'],
      isSpPercent = json['is_sp_percent'],
		  withdrawDuration	= json['withdraw_duration'],
		  withdrawProcess = json['withdraw_process'],
			idCashbackRekening = json['id_cashback_rekening'],
		  cashbackType = json['cashback_type'],
		  targetValue	= json['target_value'],
			targetDuration = json['target_duration'],
		  targetProduct = json['target_product'],
			cashbackValue = json['cashback_value'] ?? '0',
		 	cashbackPercentage = json['cashback_percentage'] ?? '0',
		  paymentDuration = json['payment_duration'],
      paymentMechanism = json['payment_mechanism'],
      paymentDate = json['payment_date'],
		  approvalSm = json['approval_sm'],
			approverSm = json['approver_sm'],
			reasonSm = json['reason_sm'] ?? '',
		  dateApprovalSm = json['date_approval_sm'] ?? '',
			approvalGm = json['approval_gm'],
		  approverGm = json['approver_gm'],
		  reasonGm = json['reason_gm'] ?? '',
		  dateApprovalGm = json['date_approval_gm'] ?? '',
			status = json['status'],
		  createdBy = json['created_by'],
			insertDate = json['insert_date'],
			updateDate = json['update_date'],
      bankName = json['bank_name'],
      bankId = json['bank_id'],
      accountNumber = json['account_number'],
      accountName = json['account_name'],
			smName = json['sm_name'] ?? '-',
		  gmName = json['gm_name'] ?? '-';

  Map toJson() {
    return {
      'id_cashback' : id,
      'salesname' : salesName,
      'ship_number' : shipNumber,
      'bill_number' : billNumber,
      'optic_name' : opticName,
      'optic_address' : opticAddress,
      'optic_type' : opticType,
      'start_periode' : startPeriode,
      'end_periode': endPeriode,
      'data_nama' : dataNama,
			'data_nik': dataNik,
			'data_npwp': dataNpwp,
      'is_sp_satuan' : isSpSatuan,
      'sp_number' : spNumber,
      'is_sp_percent' : isSpPercent,
			'withdraw_duration': withdrawDuration,
			'withdraw_process': withdrawProcess,
			'id_cashback_rekening': idCashbackRekening,
			'cashback_type': cashbackType,
			'target_value': targetValue,
			'target_duration': targetDuration,
			'target_product': targetProduct,
			'cashback_value': cashbackValue,
			'cashback_percentage': cashbackPercentage,
			'payment_duration': paymentDuration,
      'payment_mechanism' : paymentMechanism,
      'payment_date' : paymentDate,
			'approval_sm': approvalSm,
			'approver_sm': approverSm,
			'reason_sm': reasonSm,
			'date_approval_sm': dateApprovalSm,
			'approval_gm': approvalGm,
			'approver_gm': approverGm,
			'reason_gm': reasonGm,
			'date_approval_gm': dateApprovalGm,
			'status': status,
			'created_by': createdBy,
			'insert_date': insertDate,
			'update_date': updateDate,
			'bank_name': bankName,
			'bank_id': bankId,
			'account_number': accountNumber,
			'account_name': accountName,
			'sm_name': smName,
			'gm_name': gmName
    };
  }
}