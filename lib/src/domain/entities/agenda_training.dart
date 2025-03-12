class AgendaTraining {
  String agenda;
  bool ischecked = false;

  AgendaTraining.fromJson(Map json):
    agenda = json['agenda'] ?? '';

  Map toJson(){
    return {
      'agenda' : agenda,
    };
  }
}