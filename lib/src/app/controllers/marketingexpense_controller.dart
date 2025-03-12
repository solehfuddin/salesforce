import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/cashback_rekening.dart';
import 'package:sample/src/domain/entities/marketingexpense_attachment.dart';
import 'package:sample/src/domain/entities/marketingexpense_header.dart';
import 'package:sample/src/domain/entities/marketingexpense_line.dart';
import 'package:sample/src/domain/entities/marketingexpense_paramapprove.dart';
import 'package:sample/src/domain/entities/opticwithaddress.dart';
import 'package:sample/src/domain/entities/trainer.dart';
import 'package:sample/src/domain/service/service_cashback.dart';
import 'package:sample/src/domain/service/service_marketingexpense.dart';

import '../../domain/entities/offline_trainer.dart';
import '../../domain/entities/online_trainer.dart';

class MarketingExpenseController extends GetxController {
  ServiceMarketingExpense serviceMe = ServiceMarketingExpense();
  ServiceCashback serviceCashback = ServiceCashback();
  Rx<TextEditingController> txtOwner = TextEditingController().obs;
  Rx<TextEditingController> txtKtp = TextEditingController().obs;
  Rx<TextEditingController> txtNpwp = TextEditingController().obs;

  var isLoading = true.obs;
  var isLoadingAttachment = true.obs;
  var isHorizontal = false.obs;
  var isTraining = false.obs;
  var isSpSatuan = true.obs;
  var isMePercent = true.obs;
  var isWalletAvail = false.obs;
  var isActiveRekening = false.obs;
  var validateOpticName = false.obs;
  var validateOpticAddress = false.obs;
  var validateDataName = false.obs;
  var validateDataNik = false.obs;
  var validateStartDate = false.obs;
  var validateEndDate = false.obs;
  var validatePayDate = false.obs;
  var validateNomorSp = false.obs;
  var validatePercent = false.obs;
  var validateValues = false.obs;
  var enableRekening = false.obs;
  var dataName = "".obs;
  var dataNik = "".obs;
  var dataNpwp = "".obs;
  var nomorSp = "".obs;
  var startDate = "".obs;
  var endDate = "".obs;
  var payDate = "".obs;
  var percentValues = "".obs;
  var nominalValues = "".obs;
  var trainingMechanism = "OFFLINE KUNJUNGAN".obs;
  var trainingMateri = "PENGENALAN LENSA".obs;
  var selectedPayment = "TRANSFER BANK".obs;
  var selectedDate = "".obs;
  var selectedHour = "09.00 WIB".obs;
  var selectedTrainer = "".obs;
  var dateNow = DateTime.now().obs;
  var dateSelection = DateTime.now().obs;

  var localPath = "".obs;
  var permissionReady = false.obs;

  var selectedOptic = OpticWithAddress(
    namaUsaha: "",
    alamatUsaha: "",
    noAccount: "",
    billNumber: "",
    typeAccount: "",
    phone: "",
    contactPerson: "",
  ).obs;
  var selectedRekening = CashbackRekening().obs;
  var listMELine = <MarketingExpenseLine>[].obs;
  var listMEAttachment = <XFile>[].obs;
  var listMeImages = <MarketingExpenseAttachment>[].obs;
  var listOffline = <OfflineTrainer>[].obs;

  void clearState() {
    txtOwner.value.text = "";
    txtKtp.value.text = "";
    txtNpwp.value.text = "";

    isLoading.value = true;
    isLoadingAttachment.value = true;
    isTraining.value = false;
    isSpSatuan.value = true;
    isMePercent.value = true;
    isWalletAvail.value = false;
    isActiveRekening.value = false;
    validateOpticName.value = false;
    validateOpticAddress.value = false;
    validateDataName.value = false;
    validateDataNik.value = false;
    validateStartDate.value = false;
    validateEndDate.value = false;
    validatePayDate.value = false;
    validateNomorSp.value = false;
    validatePercent.value = false;
    validateValues.value = false;

    trainingMechanism.value = "OFFLINE KUNJUNGAN";
    trainingMateri.value = "PENGENALAN LENSA";
    selectedPayment.value = "DEPOSIT";
    listMELine.clear();
    listMEAttachment.clear();
    listMeImages.clear();

    nomorSp.value = "";
    startDate.value = "";
    endDate.value = "";
    payDate.value = "";
    enableRekening.value = false;
    dataName.value = "";
    dataNik.value = "";
    dataNpwp.value = "";
    selectedDate.value = "";
    selectedHour.value = "09.00 WIB";
    dateNow.value = DateTime.now();
    dateSelection.value = DateTime.now();

    selectedOptic.value = OpticWithAddress(
      namaUsaha: "",
      alamatUsaha: "",
      noAccount: "",
      billNumber: "",
      typeAccount: "",
      phone: "",
      contactPerson: "",
    );

    selectedRekening.value.idRekening = "";
    selectedRekening.value.idBank = "";
    selectedRekening.value.bankName = "";
    selectedRekening.value.nomorRekening = "";
    selectedRekening.value.namaRekening = "";
    selectedRekening.value.billNumber = "";
    selectedRekening.value.shipNumber = "";
    selectedRekening.value.isChecked = false;
  }

  void checkRekening(String noAccount) {
    serviceCashback
        .getRekening(Get.context!, isMounted: false, noAccount: noAccount)
        .then((value) {
      if (value.isNotEmpty) {
        isWalletAvail.value = true;
      } else {
        isWalletAvail.value = false;
      }
    });
  }

  Future<List<Trainer>> getAllTrainer(bool mounted, BuildContext context, {String key = ''}) {
    return serviceMe.getTrainer(mounted, context, key: key);
  }

  Future<List<OfflineTrainer>> getOfflineTrainer(bool mounted, BuildContext context, {String key = ''}) {
    return serviceMe.getOfflineTrainer(mounted, context, key : key);
  }

  Future<List<OnlineTrainer>> getOnlineTrainer(bool mounted, BuildContext context, {String key = ''}) {
    return serviceMe.getOnlineTrainer(mounted, context, key : key);
  }

  void handleValidation(
    bool isHorizontal, {
    String salesName = '',
    String salesId = '',
    dynamic idSm,
    dynamic tokenSm,
  }) {
    if (!validateOpticName.value || !validateOpticAddress.value) {
      handleStatus(
        Get.context!,
        'Lengkapi data optik terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    } 
    else {
      print('Prepare insert ME');

      bool handleIsSp = false;

      if (isSpSatuan.value) {
          handleIsSp = true;
      } else {
          handleIsSp = true;
      }

      if (handleIsSp) {
        print('Eksekusi header ME');
        // String _idMe = '';

        MarketingExpenseHeader header = new MarketingExpenseHeader();
        header.salesName = salesName;
        header.shipNumber = selectedOptic.value.noAccount;
        header.opticName = selectedOptic.value.namaUsaha;
        header.opticAddress = selectedOptic.value.alamatUsaha;
        header.opticType = selectedOptic.value.typeAccount;
        header.createdBy = salesId;

        serviceMe
            .insertME(
          context: Get.context!,
          item: header,
          salesname: salesName,
          opticname: selectedOptic.value.namaUsaha,
          idSm: idSm,
          tokenSm: tokenSm,
        )
            .then((value) {
          bool checkEntertain = true;

          if (listMELine.length > 0) {
            listMELine.forEach((element) {
              if (element.judul == '' || element.price == '') {
                checkEntertain = false;
              }
            });

            if (checkEntertain) {
              print('Eksekusi line ME');

              listMELine.forEach((element) {
                element.id = value;
                element.price = element.price?.replaceAll(".", "");
              });

              serviceMe
                  .insertLine(context: Get.context!, line: listMELine)
                  .then((_) {
                print('Eksekusi attachment');

                listMEAttachment.forEach((element) {
                  compressImage(File(element.path)).then((output) {
                    serviceMe.insertAttachment(
                      context: Get.context!,
                      attachment: MarketingExpenseAttachment(
                        id: value,
                        attachment: base64Encode(
                          Io.File(output!.path).readAsBytesSync(),
                        ),
                      ),
                    );
                  });
                });

                clearState();
                Get.toNamed('/marketingexpense');

                handleStatus(
                  Get.context!,
                  'New marketing expense has been created',
                  true,
                  isHorizontal: isHorizontal,
                  isLogout: false,
                  isBack: true,
                );
              });
            } else {
              handleStatus(
                Get.context!,
                'Harap lengkapi data entertaint',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );
            }
          } else {
            listMEAttachment.forEach((element) {
              compressImage(File(element.path)).then((output) {
                serviceMe.insertAttachment(
                  context: Get.context!,
                  attachment: MarketingExpenseAttachment(
                    id: value,
                    attachment: base64Encode(
                      Io.File(output!.path).readAsBytesSync(),
                    ),
                  ),
                );
              });
            });

            clearState();
            Get.toNamed('/marketingexpense');

            handleStatus(
              Get.context!,
              'New marketing expense has been created',
              true,
              isHorizontal: isHorizontal,
              isLogout: false,
              isBack: true,
            );
          }
        });
      }
    }
  }

  void handleApprove({
    bool isHorizontal = false,
    bool isMounted = false,
    required MarketingExpenseParamApprove param,
  }) {
    serviceMe.approveME(
      context: Get.context!,
      isHorizontal: isHorizontal,
      mounted: isMounted,
      param: param,
    );
  }

  void handleReject({
    bool isHorizontal = false,
    bool isMounted = false,
    required MarketingExpenseParamApprove param,
  }) {
    serviceMe.rejectME(
      context: Get.context!,
      isHorizontal: isHorizontal,
      mounted: isMounted,
      param: param,
    );
  }

  Future<String?> _findLocalPath() async {
    String? externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        // externalStorageDirPath = await AndroidPathProvider.downloadsPath;
        final directory = Directory('/storage/emulated/0/Download');
        externalStorageDirPath = directory.path;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  Future<void> _prepareSaveDir() async {
    localPath.value = (await _findLocalPath())!;
    final savedDir = Directory(localPath.value);
    final hasExisted = savedDir.existsSync();
    if (!hasExisted) {
      await savedDir.create();
    }
  }

  Future<bool> _checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }

    bool isPermit = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      late final Map<Permission, PermissionStatus> statusess;

      if (androidInfo.version.sdkInt < 33) {
        statusess = await [Permission.storage].request();
      } else {
        statusess =
            await [Permission.notification, Permission.photos].request();
      }

      var allAccepted = true;
      statusess.forEach((permission, status) {
        if (status != PermissionStatus.granted) {
          allAccepted = false;
        }
      });

      if (allAccepted) {
        isPermit = true;
      } else {
        await openAppSettings();
      }
    }
    return isPermit;
  }

  Future<void> retryRequestPermission() async {
    final hasGranted = await _checkPermission();
    if (hasGranted) {
      await _prepareSaveDir();
    }

    permissionReady.value = hasGranted;
  }
}
