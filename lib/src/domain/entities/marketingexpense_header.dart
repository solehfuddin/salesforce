class MarketingExpenseHeader {
  String? id,
      salesName,
      shipNumber,
      billNumber,
      opticName,
      opticAddress,
      opticType,
      approvalSM,
      approverSM,
      reasonSM,
      dateApprovalSM,
      approvalADM,
      approverADM,
      reasonADM,
      dateApprovalADM,
      approvalGM,
      approverGM,
      reasonGM,
      dateApprovalGM,
      status,
      createdBy,
      insertDate,
      updateDate,
      updateBy,
      smName,
      admName,
      gmName;

  MarketingExpenseHeader();

  MarketingExpenseHeader.fromJson(Map json)
      : id = json['id_marketing_expense'],
        salesName = json['salesname'],
        shipNumber = json['customer_ship_number'],
        billNumber = json['bill_number'],
        opticName = json['optic_name'],
        opticAddress = json['optic_address'],
        opticType = json['optic_type'],
        approvalSM = json['approval_sm'],
        approverSM = json['approver_sm'] ?? '',
        reasonSM = json['reason_sm'] ?? '',
        dateApprovalSM = json['date_approval_sm'] ?? '2024-01-01 08:00:00',
        approvalADM = json['approval_adm'],
        approverADM = json['approver_adm'] ?? '',
        reasonADM = json['reason_adm'] ?? '',
        dateApprovalADM = json['date_approval_adm'] ?? '2024-01-01 08:00:00',
        approvalGM = json['approval_gm'],
        approverGM = json['approver_gm'] ?? '',
        reasonGM = json['reason_gm'] ?? '',
        dateApprovalGM = json['date_approval_gm'] ?? '2024-01-01 08:00:00',
        status = json['status'],
        createdBy = json['created_by'] ?? '',
        insertDate = json['insert_date'] ?? '',
        updateBy = json['update_by'] ?? '',
        updateDate = json['update_date'] ?? '',
        smName = json['sm_name'] ?? '',
        admName = json['adm_name'] ?? '',
        gmName = json['gm_name'] ?? '';

  Map toJson() {
    return {
      'id_marketing_expense': id,
      'salesname': salesName,
      'customer_ship_number': shipNumber,
      'bill_number': billNumber,
      'optic_name': opticName,
      'optic_address': opticAddress,
      'optic_type': opticType,
      'approval_sm': approvalSM,
      'approver_sm': approverSM,
      'reason_sm': reasonSM,
      'date_approval_sm': dateApprovalSM,
      'approval_adm': approvalADM,
      'approver_adm': approverADM,
      'reason_adm': reasonADM,
      'date_approval_adm': dateApprovalADM,
      'approval_gm': approvalGM,
      'approver_gm': approverGM,
      'reason_gm': reasonGM,
      'date_approval_gm': dateApprovalGM,
      'status': status,
      'created_by': createdBy,
      'insert_date': insertDate,
      'update_by': updateBy,
      'update_date': updateDate,
      'sm_name': smName,
      'adm_name': admName,
      'gm_name': gmName,
    };
  }
}
