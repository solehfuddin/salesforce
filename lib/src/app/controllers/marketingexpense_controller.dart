import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:android_path_provider/android_path_provider.dart';
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
  var selectedPayment = "DEPOSIT".obs;
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

  Future<List<Trainer>> getAllTrainer(bool mounted, BuildContext context) {
    return serviceMe.getTrainer(mounted, context);
  }

  void handleValidation(
    bool isHorizontal,
    Function stop, {
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

      stop();
    } else if (!validateDataName.value || !validateDataNik.value) {
      handleStatus(
        Get.context!,
        'Lengkapi data pemilik terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );

      stop();
    } else if (payDate.value.isEmpty) {
      handleStatus(
        Get.context!,
        'Lengkapi data pembayaran terlebih dahulu',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );

      stop();
    } else {
      print('Prepare insert ME');

      bool handleIsSp = false;
      bool handleIsPersen = false;

      if (isSpSatuan.value) {
        if (!validateNomorSp.value) {
          handleStatus(
            Get.context!,
            'Lengkapi nomor sp terlebih dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );

          stop();
        } else {
          handleIsSp = true;
        }
      } else {
        if (!validateStartDate.value || !validateEndDate.value) {
          handleStatus(
            Get.context!,
            'Lengkapi periode kontrak terlebih dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );

          stop();
        } else {
          handleIsSp = true;
        }
      }

      if (handleIsSp) {
        if (isMePercent.value) {
          if (!validatePercent.value) {
            handleStatus(
              Get.context!,
              'Lengkapi persentase marketing expense terlebih dahulu',
              false,
              isHorizontal: isHorizontal,
              isLogout: false,
            );

            stop();
          } else {
            handleIsPersen = true;
          }
        } else {
          if (!validateValues.value) {
            handleStatus(
              Get.context!,
              'Lengkapi nominal marketing expense terlebih dahulu',
              false,
              isHorizontal: isHorizontal,
              isLogout: false,
            );

            stop();
          } else {
            handleIsPersen = true;
          }
        }
      }

      if (handleIsPersen && handleIsSp) {
        print('Eksekusi header ME');
        // String _idMe = '';

        MarketingExpenseHeader header = new MarketingExpenseHeader();
        header.salesName = salesName;
        header.shipNumber = selectedOptic.value.noAccount;
        header.opticName = selectedOptic.value.namaUsaha;
        header.opticAddress = selectedOptic.value.alamatUsaha;
        header.opticType = selectedOptic.value.typeAccount;
        header.dataName = dataName.value;
        header.dataNik = dataNik.value;
        header.dataNpwp = dataNpwp.value;
        header.isSpSatuan = isSpSatuan.value ? 'YES' : 'NO';
        header.spNumber = nomorSp.value;
        header.isSpPercent = isMePercent.value ? 'YES' : 'NO';
        header.spStartPeriode = startDate.value;
        header.spEndPeriode = endDate.value;
        header.totalValue = nominalValues.value.replaceAll('.', "");
        header.totalPercent = percentValues.value;
        header.paymentMechanism = selectedPayment.value;
        header.paymentDate = payDate.value;
        header.idRekening = selectedRekening.value.idRekening ?? '';
        header.notes = '';
        header.isTraining = isTraining.value ? 'YES' : 'NO';
        header.trainingMekanisme = '';
        header.trainingMateri = '';
        header.trainingDate = '';
        header.trainingTime = '';
        header.trainingDuration = '';
        header.createdBy = salesId;

        serviceMe
            .insertME(
          stop,
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
                  .insertLine(stop, context: Get.context!, line: listMELine)
                  .then((_) {
                print('Eksekusi attachment');

                listMEAttachment.forEach((element) {
                  compressImage(File(element.path)).then((output) {
                    serviceMe.insertAttachment(
                      stop,
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

                stop();

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
              stop();

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
                  stop,
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

            stop();

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

  void handleApprove(
    Function stop, {
    bool isHorizontal = false,
    bool isMounted = false,
    required MarketingExpenseParamApprove param,
  }) {
    serviceMe.approveME(
      stop,
      context: Get.context!,
      isHorizontal: isHorizontal,
      mounted: isMounted,
      param: param,
    );
  }

  void handleReject(
    Function stop, {
    bool isHorizontal = false,
    bool isMounted = false,
    required MarketingExpenseParamApprove param,
  }) {
    serviceMe.rejectME(
      stop,
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
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
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

      if (androidInfo.version.sdkInt! < 33) {
        statusess = await [Permission.storage].request();
      } else {
        statusess =
            await [Permission.notification, Permission.mediaLibrary].request();
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
