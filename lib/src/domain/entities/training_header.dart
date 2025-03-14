class TrainingHeader {
  String? id, 
  salesName,
  shipNumber,
  billNumber,
  opticName,
  opticAddress,
  opticType,
  trainerId,
  trainerName,
  trainerRole,
  trainerPhoto,
  scheduleDate,
  scheduleStartTime,
  scheduleEndTime,
  duration,
  mechanism,
  agenda,
  notes,
  approvalSm,
  approverSm,
  reasonSm,
  dateSm,
  nameSm,
  approvalAdm,
  approverAdm,
  reasonAdm,
  dateAdm,
  nameAdm,
  status,
  rescheduleNotes,
  invitationTraining,
  salesToken,
  trainerToken,
  createdBy,
  insertDate,
  updateBy,
  updateDate;

  TrainingHeader();

  TrainingHeader.fromJson(Map json) 
      : id = json['id_training'],
        salesName = json['salesname'],
        shipNumber = json['customer_ship_number'],
        billNumber = json['bill_number'],
        opticName = json['optic_name'],
        opticAddress = json['optic_address'],
        opticType = json['optic_type'],
        trainerId = json['trainer_id'],
        trainerName = json['trainer_name'],
        trainerRole = json['trainer_role'],
        trainerPhoto = json['imgprofile'] ?? '',
        scheduleDate = json['training_date'],
        scheduleStartTime = json['training_time_st'],
        scheduleEndTime = json['training_time_ed'],
        duration = json['training_duration'],
        mechanism = json['training_mechanism'],
        agenda = json['training_agenda'],
        notes = json['notes'],
        approvalSm = json['approval_sm'],
        approverSm = json['approver_sm'] ?? '',
        reasonSm = json['reason_sm'] ?? '',
        dateSm = json['date_approval_sm'] ?? '2024-01-01 08:00:00',
        approvalAdm = json['approval_adm'],
        approverAdm = json['approver_adm'] ?? '',
        reasonAdm = json['reason_adm'] ?? '',
        dateAdm = json['date_approval_adm'] ?? '2024-01-01 08:00:00',
        status = json['status'],
        rescheduleNotes = json['reschedule_notes'] ?? '',
        invitationTraining = json['invitation_training'] ?? '',
        salesToken = json['salestoken'] ?? '',
        trainerToken = json['trainertoken'] ?? '',
        createdBy = json['created_by'],
        insertDate = json['insert_date'],
        updateBy = json['update_by'] ?? '',
        updateDate = json['update_date'] ?? '',
        nameSm = json['sm_name'] ?? '',
        nameAdm = json['adm_name'] ?? '';

  Map toJson() {
    return {
        'id_training' : id,
        'salesname' : salesName,
        'customer_ship_number' : shipNumber ,
        'bill_number' : billNumber,
        'optic_name' : opticName,
        'optic_address' : opticAddress,
        'optic_type' : opticType,
        'trainer_id' : trainerId,
        'trainer_name' : trainerName,
        'trainer_role' : trainerRole,
        'imgprofile' : trainerPhoto,
        'training_date' : scheduleDate,
        'training_time_st' : scheduleStartTime,
        'training_time_ed' : scheduleEndTime,
        'training_duration' : duration,
        'training_mechanism' : mechanism,
        'training_agenda' : agenda,
        'notes' : notes,
        'approval_sm' : approvalSm,
        'approver_sm' : approverSm,
        'reason_sm' : reasonSm,
        'date_approval_sm' : dateSm,
        'approval_adm' : approvalAdm,
        'approver_adm' : approverAdm,
        'reason_adm' : reasonAdm,
        'date_approval_adm' : dateAdm,
        'status' : status,
        'reschedule_notes' : rescheduleNotes,
        'invitation_training' : invitationTraining,
        'salestoken' : salesToken,
        'trainertoken' : trainerToken,
        'created_by' : createdBy,
        'insert_date' : insertDate,
        'update_by' : updateBy,
        'update_date' : updateDate,
        'sm_name' : nameSm,
        'adm_name' : nameAdm,
    };
  }
}