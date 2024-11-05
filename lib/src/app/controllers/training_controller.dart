import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sample/src/domain/entities/trainer.dart';
import 'package:sample/src/domain/entities/training_attachment.dart';
import 'package:sample/src/domain/entities/training_header.dart';
import 'package:sample/src/domain/service/service_training.dart';

import '../../domain/entities/opticwithaddress.dart';
import '../../domain/entities/training_paramapprove.dart';
import '../utils/custom.dart';

class TrainingController extends GetxController {
  ServiceTraining service = new ServiceTraining();

  var trainer = Trainer().obs;
  var selectedDate = "".obs;
  var dateNow = DateTime.now().obs;
  var dateSelection = DateTime.now().obs;
  var trainingTime = "00:00".obs;
  var trainingDuration = 1.obs;
  var trainingMechanism = "OFFLINE KUNJUNGAN".obs;
  var trainingMateri = "PENGENALAN LENSA".obs;
  var trainingNotes = "".obs;
  var isProspect = false.obs;
  var isHorizontal = false.obs;
  var validateOpticName = false.obs;
  var validateOpticAddress = false.obs;
  var search = "".obs;
  var selectedOptic = OpticWithAddress(
    namaUsaha: "",
    alamatUsaha: "",
    noAccount: "",
    billNumber: "",
    typeAccount: "",
    phone: "",
    contactPerson: "",
  ).obs;

  var listTrainingAttachment = <XFile>[].obs;

  void handleValidation(
    bool isHorizontal, {
    String salesId = '',
    String salesName = '',
    dynamic idSm,
    dynamic tokensSm,
  }) {
    if (!validateOpticName.value && !validateOpticAddress.value) {
      handleStatus(
        Get.context!,
        'Lengkapi data optik terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    } else {
      print("""
      Sales name : $salesName,
      No akun : ${selectedOptic.value.noAccount},
      Nama usaha : ${selectedOptic.value.namaUsaha},
      Alamat : ${selectedOptic.value.alamatUsaha},
      Optic type : ${selectedOptic.value.typeAccount},
      Trainer id : ${trainer.value.id},
      Trainer name : ${trainer.value.name}
      Training date : $selectedDate,
      Training time : ${trainingTime.trim()},
      Training duration : $trainingDuration,
      Training mechanism : $trainingMechanism,
      Training materi : $trainingMateri,
      notes : $trainingNotes,
      Created by : $salesId
      """);

      TrainingHeader header = new TrainingHeader();
      header.shipNumber = selectedOptic.value.noAccount;
      header.opticName = selectedOptic.value.namaUsaha;
      header.opticAddress = selectedOptic.value.alamatUsaha;
      header.opticType = selectedOptic.value.typeAccount;
      header.trainerId = trainer.value.id;
      header.trainerName = trainer.value.name;
      header.scheduleDate = selectedDate.value;
      header.scheduleStartTime = trainingTime.value.trim();
      header.duration = trainingDuration.value.toString();
      header.mechanism = trainingMechanism.value;
      header.agenda = trainingMateri.value;
      header.notes = trainingNotes.value;
      header.createdBy = salesId;

      service
          .insertHeader(
        context: Get.context!,
        item: header,
        salesname: salesName,
        opticname: selectedOptic,
        idSm: idSm,
        tokenSm: tokensSm,
      )
          .then(
        (value) {
          if (listTrainingAttachment.isNotEmpty) {
            listTrainingAttachment.forEach((element) {
              print("""
                  Element : ${element.path}
            """);

              compressImage(File(element.path)).then((output) {
                service.insertAttachment(
                  context: Get.context!,
                  attachment: TrainingAttachment(
                    id: value,
                    attachment: base64Encode(
                      Io.File(output!.path).readAsBytesSync(),
                    ),
                  ),
                );
              });
            });
          }

          if (value != '')
          {
            Get.toNamed('/tabTraining');

            handleStatus(
              Get.context!,
              'Training task has been created',
              true,
              isHorizontal: isHorizontal,
              isLogout: false,
              isBack: true,
            );
          }
          else 
          {
            handleStatus(
              Get.context!,
              'Training schedule has exist, change time or date training',
              false,
              isHorizontal: isHorizontal,
              isLogout: false,
              isBack: true,
            );
          }
        },
      );
    }
  }

  void handleApprove({
    bool isHorizontal = false,
    bool isMounted = false,
    required TrainingParamApprove param,
  }) {
    service.approveTraining(
      context: Get.context!,
      isHorizontal: isHorizontal,
      mounted: isMounted,
      param: param,
    );
  }

  void handleReject({
    bool isHorizontal = false,
    bool isMounted = false,
    required TrainingParamApprove param,
  }) {
    service.rejectTraining(
      context: Get.context!,
      isHorizontal: isHorizontal,
      mounted: isMounted,
      param: param,
    );
  }
}
