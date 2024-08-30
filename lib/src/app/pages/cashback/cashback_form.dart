import 'dart:convert';

import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/cashback/cashback_formattachment.dart';
import 'package:sample/src/app/pages/cashback/cashback_formcontract.dart';
import 'package:sample/src/app/pages/cashback/cashback_formcustomer.dart';
import 'package:sample/src/app/pages/cashback/cashback_formproduct.dart';
import 'package:sample/src/app/pages/cashback/cashback_formrekening.dart';
import 'package:sample/src/app/pages/cashback/cashback_formtarget.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/settings_cashback.dart';
import 'package:sample/src/domain/entities/cashback_header.dart';
import 'package:sample/src/domain/entities/cashback_line.dart';
import 'package:sample/src/domain/entities/cashback_rekening.dart';
import 'package:sample/src/domain/entities/proddiv.dart';
import 'package:sample/src/domain/entities/product.dart';
import 'package:sample/src/domain/service/service_cashback.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CashbackForm extends StatefulWidget {
  List<CashbackRekening> listRekening = List.empty(growable: true);
  List<Proddiv> listTargetProddiv = List.empty(growable: true);
  List<Proddiv> listProductProddiv = List.empty(growable: true);
  List<Product> listProductKhusus = List.empty(growable: true);

  String constructIdCashback,
      constructOpticName,
      constructOpticAddress,
      constructOwnerName,
      constructOwnerNik,
      constructOwnerNpwp,
      constructShipNumber,
      constructBillNumber,
      constructTypeAccount,
      constructIdCashbackRekening,
      constructStartDate,
      constructEndDate,
      constructWithdrawProcess,
      constructWithdrawDuration,
      constructPaymentDuration,
      constructTypeCashback,
      constructTargetProduct,
      constructAttachmentSign,
      constructAttachmentOther;

  int constructTargetValue, constructCashbackValue;
  double constructCashbackPercent;
  bool isUpdateForm = false;

  CashbackForm(
      {Key? key,
      required this.listRekening,
      required this.listTargetProddiv,
      required this.listProductProddiv,
      required this.listProductKhusus,
      required this.constructOpticName,
      required this.constructOpticAddress,
      required this.constructOwnerName,
      required this.constructOwnerNik,
      required this.constructOwnerNpwp,
      required this.constructShipNumber,
      required this.constructBillNumber,
      required this.constructTypeAccount,
      required this.isUpdateForm,
      this.constructIdCashback = '',
      this.constructIdCashbackRekening = '',
      this.constructStartDate = '',
      this.constructEndDate = '',
      this.constructWithdrawProcess = '',
      this.constructWithdrawDuration = '',
      this.constructPaymentDuration = '',
      this.constructTypeCashback = '',
      this.constructTargetValue = 0,
      this.constructCashbackPercent = 0,
      this.constructCashbackValue = 0,
      this.constructTargetProduct = '',
      this.constructAttachmentSign = '',
      this.constructAttachmentOther = ''})
      : super(key: key);

  @override
  State<CashbackForm> createState() => _CashbackFormState();
}

class _CashbackFormState extends State<CashbackForm> {
  ServicePosMaterial service = new ServicePosMaterial();
  ServiceCashback serviceCashback = new ServiceCashback();
  CashbackRekening cashbackRekening = new CashbackRekening();
  CashbackType _cashbackType = CashbackType.BY_TARGET;
  TextEditingController controllerOpticName = new TextEditingController();
  TextEditingController controllerOptikAddress = new TextEditingController();
  TextEditingController controllerOwnerName = new TextEditingController();
  TextEditingController controllerOwnerKtp = new TextEditingController();
  TextEditingController controllerOwnerNpwp = new TextEditingController();
  TextEditingController controllerStartDate = new TextEditingController();
  TextEditingController controllerEndDate = new TextEditingController();
  TextEditingController controllerWithdrawDuration =
      new TextEditingController();
  TextEditingController controllerCashbackPercent = new TextEditingController();
  TextEditingController controllerCashbackValue = new TextEditingController();
  TextEditingController controllerTargetValue = new TextEditingController();
  TextEditingController txtAttachmentSign = new TextEditingController();
  TextEditingController txtAttachmentOther = new TextEditingController();

  List<Proddiv> selectedTargetProdDiv = List.empty(growable: true);
  List<Proddiv> selectedItemProdDiv = List.empty(growable: true);
  List<Product> selectedItemProduct = List.empty(growable: true);
  List<CashbackLine> listLineCashback = List.empty(growable: true);

  DateTime dateStart = new DateTime(2024);
  DateTime dateEnd = new DateTime(2024);

  String? id, role, username, idSm, nameSm, tokenSm;
  String _shipNumber = '';
  String _billNumber = '';
  String _opticType = '';
  String _targetProduct = '';

  bool _isWalletAvail = false;
  bool _isCashbackValue = true;
  bool _isActiveRekening = false;
  bool _enableRekening = false;
  bool _validateOpticName = false;
  bool _validateOpticAddress = false;
  bool _validateOwnerName = false;
  bool _validateKtp = false;
  bool _validateStartDate = false;
  bool _validateEndDate = false;
  bool _validateWithdrawDuration = false;
  bool _validateCashbackValue = false;
  bool _validateTargetValue = false;
  bool _validateLampiranSign = false;
  bool _isHorizontal = false;
  String _selectedWithdrawProcess = 'TAGIHAN LUNAS';
  String _selectedPaymentTermint = '7 hari';
  String base64Sign = '';
  String base64Other = '';

  @override
  void initState() {
    super.initState();
    getRole();
    resetForm();
    initializeValue();
  }

  initializeValue() {
    controllerOpticName.text = widget.constructOpticName;
    controllerOptikAddress.text = widget.constructOpticAddress;
    controllerOwnerName.text = widget.constructOwnerName;
    controllerOwnerKtp.text = widget.constructOwnerNik;
    controllerOwnerNpwp.text = widget.constructOwnerNpwp;
    controllerStartDate.text = widget.constructStartDate != ''
        ? convertDateWithMonth(widget.constructStartDate)
        : '';
    controllerEndDate.text = widget.constructEndDate != ''
        ? convertDateWithMonth(widget.constructEndDate)
        : '';

    if (widget.constructIdCashbackRekening.isNotEmpty) {
      _isActiveRekening = true;
      serviceCashback
          .getRekening(
        context,
        isMounted: mounted,
        idRekening: widget.constructIdCashbackRekening,
      )
          .then((value) {
        setState(() {
          cashbackRekening = value.first;
        });
      });
    }

    if (widget.constructStartDate.isNotEmpty) {
      updateSelected('validateStartDate', true);
      updateSelected('setDateStart', DateTime.parse(widget.constructStartDate));
    }

    if (widget.constructEndDate.isNotEmpty) {
      updateSelected('validateEndDate', true);
      updateSelected('setDateEnd', DateTime.parse(widget.constructEndDate));
    }

    if (widget.constructWithdrawDuration.isNotEmpty) {
      controllerWithdrawDuration.text = widget.constructWithdrawDuration;
      updateSelected('validateWithdrawDuration', true);
    }

    if (widget.constructWithdrawProcess.isNotEmpty) {
      _selectedWithdrawProcess = widget.constructWithdrawProcess;
    }

    if (widget.constructPaymentDuration.isNotEmpty) {
      _selectedPaymentTermint = widget.constructPaymentDuration;
    }

    if (widget.constructTypeCashback.isNotEmpty) {
      setState(() {
        switch (widget.constructTypeCashback) {
          case 'BY TARGET':
            _cashbackType = CashbackType.BY_TARGET;
            break;
          case 'BY PRODUCT':
            _cashbackType = CashbackType.BY_PRODUCT;
            break;
          default:
            _cashbackType = CashbackType.COMBINE;
        }
      });
    }

    if (widget.constructTargetValue > 0) {
      controllerTargetValue.value = TextEditingValue(
          text: convertThousand(widget.constructTargetValue, 0));
      updateSelected('validateTargetValue', true);
    }

    if (widget.constructCashbackValue > 0) {
      controllerCashbackValue.value = TextEditingValue(
          text: convertThousand(widget.constructCashbackValue, 0));
      updateSelected('validateCashbackValue', true);
    }

    if (widget.constructCashbackPercent > 0) {
      controllerCashbackPercent.value =
          TextEditingValue(text: widget.constructCashbackPercent.toString());
      updateSelected('validateCashbackValue', true);
    }

    if (widget.constructTargetProduct != '') {
      setState(() {
        selectedTargetProdDiv.clear();
        selectedTargetProdDiv.addAll(widget.listTargetProddiv);
        _targetProduct =
            selectedTargetProdDiv.map((i) => i.alias).toList().join(',');
      });
    }

    if (widget.listProductProddiv.isNotEmpty) {
      selectedItemProdDiv.addAll(widget.listProductProddiv);
    }

    if (widget.listProductKhusus.isNotEmpty) {
      selectedItemProduct.addAll(widget.listProductKhusus);
    }

    if (widget.constructOpticName.length > 0) {
      updateSelected('validateOpticName', true);
    }

    if (widget.constructOpticAddress.length > 0) {
      updateSelected('validateOpticAddress', true);
    }

    if (widget.constructOwnerName.length > 0) {
      updateSelected('validateOwnerName', true);
    }

    if (widget.listRekening.isNotEmpty) {
      updateSelected('setWalletAvail', true);
      updateSelected('setEnableRekening', false);
    } else {
      updateSelected('setWalletAvail', false);
      updateSelected('setEnableRekening', true);
    }

    if (widget.constructOwnerNik.length >= 16) {
      updateSelected('setKtp', widget.constructOwnerNik);
      updateSelected('validateOwnerKtp', true);
    }

    if (widget.constructAttachmentSign.isNotEmpty) {
      base64Sign = widget.constructAttachmentSign;

      setState(() {
        _validateLampiranSign = true;
      });
    }

    if (widget.constructAttachmentOther.isNotEmpty) {
      base64Other = widget.constructAttachmentOther;
    }

    updateSelected('setNpwp', widget.constructOwnerNpwp);
    updateSelected('setShipNumber', widget.constructShipNumber);
    updateSelected('setBillNumber', widget.constructBillNumber);
    updateSelected('setOpticType', widget.constructTypeAccount);

    print('Ship number : ${widget.constructShipNumber}');
    print('Bill number : ${widget.constructBillNumber}');
  }

  void resetForm() {
    updateSelected('setEnableRekening', false);
    updateSelected('setNamaOwner', '');
    updateSelected('setKtp', '');
    updateSelected('setNpwp', '');
    updateSelected('validateOwnerName', false);
    updateSelected('validateOwnerKtp', false);
    updateSelected('setActiveRekening', false);
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");

      getManagerToken(int.parse(id!));
    });
  }

  getManagerToken(int idSales) {
    service.generateTokenSm(context: context, idSales: idSales).then((value) {
      idSm = value.id;
      nameSm = value.name;
      tokenSm = value.token;
    });
  }

  updateSelected(dynamic variableName, dynamic returVal) {
    setState(() {
      switch (variableName) {
        case 'setDateStart':
          dateStart = returVal;
          break;
        case 'setDateEnd':
          dateEnd = returVal;
          break;
        case 'setWalletAvail':
          _isWalletAvail = returVal;
          break;
        case 'setIsCashbackValue':
          _isCashbackValue = returVal;
          break;
        case 'setEnableRekening':
          _enableRekening = returVal;
          break;
        case 'setActiveRekening':
          _isActiveRekening = returVal;
          break;
        case 'updateNewRekening':
          cashbackRekening = returVal;
          break;
        case 'setShipNumber':
          _shipNumber = returVal;
          break;
        case 'setBillNumber':
          _billNumber = returVal;
          break;
        case 'setOpticType':
          _opticType = returVal;
          break;
        case 'setNamaOwner':
          controllerOwnerName.text = returVal;
          break;
        case 'setKtp':
          controllerOwnerKtp.text = returVal;
          break;
        case 'setNpwp':
          controllerOwnerNpwp.text = returVal;
          break;
        case 'setTargetProduct':
          _targetProduct = returVal;
          break;
        case 'setLineProddiv':
          selectedItemProdDiv.clear();
          selectedItemProdDiv.addAll(returVal);
          break;
        case 'setLineProduct':
          selectedItemProduct.clear();
          selectedItemProduct.addAll(returVal);
          break;
        case 'setSelectedWithdrawProcess':
          _selectedWithdrawProcess = returVal;
          break;
        case 'setSelectedPaymentTermint':
          _selectedPaymentTermint = returVal;
          break;
        case 'setSelectedCashbackType':
          _cashbackType = returVal;
          break;
        case 'Lampiran Sign':
          print(returVal);
          base64Sign = returVal;
          break;
        case 'Lampiran Tambahan':
          print(returVal);
          base64Other = returVal;
          break;
        case 'validateOpticName':
          _validateOpticName = returVal;
          break;
        case 'validateOpticAddress':
          _validateOpticAddress = returVal;
          break;
        case 'validateOwnerName':
          _validateOwnerName = returVal;
          break;
        case 'validateOwnerKtp':
          _validateKtp = returVal;
          break;
        case 'validateStartDate':
          _validateStartDate = returVal;
          break;
        case 'validateEndDate':
          _validateEndDate = returVal;
          break;
        case 'validateWithdrawDuration':
          _validateWithdrawDuration = returVal;
          break;
        case 'validateCashbackValue':
          _validateCashbackValue = returVal;
          break;
        case 'validateTargetValue':
          _validateTargetValue = returVal;
          break;
        case 'validateLampiranSign':
          _validateLampiranSign = returVal;
          break;
        default:
      }
    });
  }

  onButtonPressed() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => handleValidationForm(isHorizontal: _isHorizontal),
    );

    return () {};
  }

  handleValidationForm({bool isHorizontal = false}) {
    if (!_isActiveRekening) {
      handleStatus(
        context,
        'Harap lengkapi data rekening',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    } else if (!_validateOwnerName && !_validateKtp) {
      handleStatus(
        context,
        'Harap lengkapi data pemilik',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    } else if (!_validateStartDate &&
        !_validateEndDate &&
        !_validateWithdrawDuration) {
      handleStatus(
        context,
        'Harap lengkapi data cashback',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    } else if (!_validateLampiranSign) {
      handleStatus(
        context,
        'Harap lengkapi lampiran',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
    } else if (_cashbackType == CashbackType.BY_TARGET) {
      if (!_validateTargetValue && !_validateCashbackValue) {
        handleStatus(
          context,
          'Harap lengkapi target cashback',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      } else if (_targetProduct.isEmpty) {
        handleStatus(
          context,
          'Belum ada data pada target cashback',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      } else {
        widget.isUpdateForm
            ? updateToDb(
                isHorizontal: isHorizontal,
                idCashback: widget.constructIdCashback)
            : saveToDb(isHorizontal: isHorizontal);
      }
    } else if (_cashbackType == CashbackType.BY_PRODUCT) {
      if (selectedItemProdDiv.isEmpty && selectedItemProduct.isEmpty) {
        handleStatus(
          context,
          'Belum ada data pada product cashback',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      } else {
        widget.isUpdateForm
            ? updateToDb(
                isHorizontal: isHorizontal,
                idCashback: widget.constructIdCashback)
            : saveToDb(isHorizontal: isHorizontal);
      }
    } else if (_cashbackType == CashbackType.COMBINE) {
      if (!_validateTargetValue && !_validateCashbackValue) {
        handleStatus(
          context,
          'Harap lengkapi target cashback',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      } else if (_targetProduct.isEmpty) {
        handleStatus(
          context,
          'Belum ada data pada target combine cashback',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      } else if (selectedItemProdDiv.isEmpty && selectedItemProduct.isEmpty) {
        handleStatus(
          context,
          'Belum ada data pada product combine cashback',
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      } else {
        widget.isUpdateForm
            ? updateToDb(
                isHorizontal: isHorizontal,
                idCashback: widget.constructIdCashback)
            : saveToDb(isHorizontal: isHorizontal);
      }
    } else {
      widget.isUpdateForm
          ? updateToDb(
              isHorizontal: isHorizontal,
              idCashback: widget.constructIdCashback)
          : saveToDb(isHorizontal: isHorizontal);
    }
  }

  void saveToDb({bool isHorizontal = false}) {
    if (_cashbackType == CashbackType.BY_PRODUCT) {
      controllerTargetValue.text = '';
      controllerCashbackPercent.text = '';
      controllerCashbackValue.text = '';

      _targetProduct = '';
    } else if (_cashbackType == CashbackType.BY_TARGET) {
      selectedItemProdDiv.clear();
      selectedItemProduct.clear();
    }

    print("""
          Optic name : ${controllerOpticName.text}
          Optic address : ${controllerOptikAddress.text.substring(0, 2)}
          Bill number : $_billNumber
          Ship number : $_shipNumber
          Optic type : $_opticType
          Owner name : ${controllerOwnerName.text}
          Owner ktp : ${controllerOwnerKtp.text}
          Owner npwp : ${controllerOwnerNpwp.text}
          Is wallet : $_isWalletAvail
          Has active wallet : $_isActiveRekening
          Bank id : ${cashbackRekening.getIdBank}
          Bank name : ${cashbackRekening.getBankName}
          Id rekening : ${cashbackRekening.getIdRekening}
          Nomor rekening : ${cashbackRekening.getNomorRekening}
          Nama tertera : ${cashbackRekening.getNamaRekening}
          Bill number : ${cashbackRekening.getBillNumber}
          Ship number : ${cashbackRekening.getShipNumber}
          Periode start : ${controllerStartDate.text}
          Periode end : ${controllerEndDate.text}
          """);

    print("""
          Termin pembayaran : $_selectedPaymentTermint
          Pencarian diproses : $_selectedWithdrawProcess
          Durasi pencarian : ${controllerWithdrawDuration.text} Hari
          Is cashback by value : $_isCashbackValue
          Cashback Type : $_cashbackType
          Target pembelian : ${controllerTargetValue.text}
          Target duration : ${getMonthBetweenTwoDates(dateStart, dateEnd)} Bulan
          Target cashback : ${controllerCashbackValue.text.isNotEmpty ? controllerCashbackValue.text : controllerCashbackPercent.text}
          Target produk : ${_targetProduct.toString()}
          """);

    // stop();

    CashbackHeader cashbackHeader = new CashbackHeader();
    cashbackHeader.setSalesName = username ?? '';
    cashbackHeader.setShipNumber = cashbackRekening.getShipNumber;
    cashbackHeader.setOpticName = controllerOpticName.text;
    cashbackHeader.setOpticAddress = controllerOptikAddress.text;
    cashbackHeader.setOpticType = _opticType;
    cashbackHeader.setStartPeriode = controllerStartDate.text;
    cashbackHeader.setEndPeriode = controllerEndDate.text;
    cashbackHeader.setDataNama = controllerOwnerName.text;
    cashbackHeader.setDataNik = controllerOwnerKtp.text;
    cashbackHeader.setDataNpwp = controllerOwnerNpwp.text;
    cashbackHeader.setWithdrawDuration = controllerWithdrawDuration.text;
    cashbackHeader.setWithdrawProcess = _selectedWithdrawProcess;
    cashbackHeader.setIdCashbackRekening = cashbackRekening.getIdRekening;
    cashbackHeader.setCashbackType = getCashbackType(_cashbackType);
    cashbackHeader.setTargetValue =
        controllerTargetValue.text.replaceAll('.', '');
    cashbackHeader.setTargetDuration =
        getMonthBetweenTwoDates(dateStart, dateEnd).toString();
    cashbackHeader.setTargetProduct = _targetProduct.toString();
    cashbackHeader.setCashbackValue = controllerCashbackValue.text.isNotEmpty
        ? controllerCashbackValue.text.replaceAll('.', '')
        : '';
    cashbackHeader.setCashbackPercentage =
        controllerCashbackPercent.text.isNotEmpty
            ? controllerCashbackPercent.text
            : '';
    cashbackHeader.setPaymentDuration = _selectedPaymentTermint;
    cashbackHeader.setCreatedBy = id ?? '0';
    cashbackHeader.setAttachmentSign = base64Sign;
    cashbackHeader.setAttachmentOther = base64Other;
    cashbackHeader.setBillNumber = _billNumber;

    serviceCashback
        .insertHeader(
      isHorizontal: isHorizontal,
      mounted: mounted,
      context: context,
      header: cashbackHeader,
      tokenSm: tokenSm ?? '',
    )
        .then(
      (value) {
        listLineCashback.clear();

        for (Proddiv item in selectedItemProdDiv) {
          print("${item.alias} : ${item.diskon}");

          listLineCashback.add(
            CashbackLine(
              idCashback: value,
              categoryId: '',
              prodDiv: item.proddiv,
              prodCat: '',
              prodCatDescription: item.alias,
              cashback: item.diskon.contains(',')
                  ? item.diskon.replaceAll(',', '.')
                  : item.diskon.replaceAll('.', ''),
              status: 'ACTIVE',
            ),
          );
        }

        for (Product item in selectedItemProduct) {
          print("${item.proddesc} : ${item.diskon}");

          listLineCashback.add(
            CashbackLine(
              idCashback: value,
              categoryId: item.categoryid,
              prodDiv: item.proddiv,
              prodCat: item.prodcat,
              prodCatDescription: item.proddesc,
              cashback: item.diskon.contains(',')
                  ? item.diskon.replaceAll(',', '.')
                  : item.diskon.replaceAll('.', ''),
              status: 'ACTIVE',
            ),
          );
        }

        if (listLineCashback.isNotEmpty) {
          serviceCashback
              .insertLine(
            isHorizontal: isHorizontal,
            mounted: mounted,
            context: context,
            line: listLineCashback,
          )
              .then((value) {
            if (value) {
              handleStatus(
                context,
                'New cashback has been created',
                true,
                isHorizontal: isHorizontal,
                isLogout: false,
                isBack: true,
              );

              Navigator.of(context).pop();
            }
          });
        } else {
          handleStatus(
            context,
            'New cashback has been created',
            true,
            isHorizontal: isHorizontal,
            isLogout: false,
            isBack: true,
          );
          Navigator.of(context).pop();
        }
      },
    );
  }

  void updateToDb({bool isHorizontal = false, required String idCashback}) {
    if (_cashbackType == CashbackType.BY_PRODUCT) {
      controllerTargetValue.text = '';
      controllerCashbackPercent.text = '';
      controllerCashbackValue.text = '';

      _targetProduct = '';
    } else if (_cashbackType == CashbackType.BY_TARGET) {
      selectedItemProdDiv.clear();
      selectedItemProduct.clear();
    }

    if (!controllerStartDate.text.contains("-")) {
      controllerStartDate.text = convertDateSql(controllerStartDate.text);
    }

    if (!controllerEndDate.text.contains("-")) {
      controllerEndDate.text = convertDateSql(controllerEndDate.text);
    }

    print("""
          Optic name : ${controllerOpticName.text}
          Optic address : ${controllerOptikAddress.text.substring(0, 2)}
          Bill number : $_billNumber
          Ship number : $_shipNumber
          Optic type : $_opticType
          Owner name : ${controllerOwnerName.text}
          Owner ktp : ${controllerOwnerKtp.text}
          Owner npwp : ${controllerOwnerNpwp.text}
          Is wallet : $_isWalletAvail
          Has active wallet : $_isActiveRekening
          Bank id : ${cashbackRekening.getIdBank}
          Bank name : ${cashbackRekening.getBankName}
          Id rekening : ${cashbackRekening.getIdRekening}
          Nomor rekening : ${cashbackRekening.getNomorRekening}
          Nama tertera : ${cashbackRekening.getNamaRekening}
          Bill number : ${cashbackRekening.getBillNumber}
          Ship number : ${cashbackRekening.getShipNumber}
          Periode start : ${controllerStartDate.text}
          Periode end : ${controllerEndDate.text}
          """);

    print("""
          Id cashback : $idCashback
          Termin pembayaran : $_selectedPaymentTermint
          Pencarian diproses : $_selectedWithdrawProcess
          Durasi pencarian : ${controllerWithdrawDuration.text} Hari
          Is cashback by value : $_isCashbackValue
          Cashback Type : $_cashbackType
          Target pembelian : ${controllerTargetValue.text}
          Target duration : ${getMonthBetweenTwoDates(dateStart, dateEnd)} Bulan
          Target cashback : ${controllerCashbackValue.text.isNotEmpty ? controllerCashbackValue.text : controllerCashbackPercent.text}
          Target produk : ${_targetProduct.toString()}
          """);

    print("""
          Base 64 sign : $base64Sign
          """);

    // stop();

    CashbackHeader cashbackHeader = new CashbackHeader();
    cashbackHeader.setSalesName = username ?? '';
    cashbackHeader.setShipNumber = cashbackRekening.getShipNumber;
    cashbackHeader.setOpticName = controllerOpticName.text;
    cashbackHeader.setOpticAddress = controllerOptikAddress.text;
    cashbackHeader.setOpticType = _opticType;
    cashbackHeader.setStartPeriode = controllerStartDate.text;
    cashbackHeader.setEndPeriode = controllerEndDate.text;
    cashbackHeader.setDataNama = controllerOwnerName.text;
    cashbackHeader.setDataNik = controllerOwnerKtp.text;
    cashbackHeader.setDataNpwp = controllerOwnerNpwp.text;
    cashbackHeader.setWithdrawDuration = controllerWithdrawDuration.text;
    cashbackHeader.setWithdrawProcess = _selectedWithdrawProcess;
    cashbackHeader.setIdCashbackRekening = cashbackRekening.getIdRekening;
    cashbackHeader.setCashbackType = getCashbackType(_cashbackType);
    cashbackHeader.setTargetValue =
        controllerTargetValue.text.replaceAll('.', '');
    cashbackHeader.setTargetDuration =
        getMonthBetweenTwoDates(dateStart, dateEnd).toString();
    cashbackHeader.setTargetProduct = _targetProduct.toString();
    cashbackHeader.setCashbackValue = controllerCashbackValue.text.isNotEmpty
        ? controllerCashbackValue.text.replaceAll('.', '')
        : '';
    cashbackHeader.setCashbackPercentage =
        controllerCashbackPercent.text.isNotEmpty
            ? controllerCashbackPercent.text
            : '';
    cashbackHeader.setPaymentDuration = _selectedPaymentTermint;
    cashbackHeader.setCreatedBy = id ?? '0';
    cashbackHeader.setAttachmentSign = base64Sign;
    cashbackHeader.setAttachmentOther = base64Other;
    cashbackHeader.setBillNumber = _billNumber;

    serviceCashback
        .updateHeader(
      isHorizontal: isHorizontal,
      mounted: mounted,
      context: context,
      header: cashbackHeader,
      idCashback: idCashback,
      tokenSm: tokenSm ?? '',
    )
        .then(
      (value) {
        listLineCashback.clear();

        for (Proddiv item in selectedItemProdDiv) {
          print("${item.alias} : ${item.diskon.replaceAll(',', ".")}");

          listLineCashback.add(
            CashbackLine(
              idCashback: idCashback,
              categoryId: '',
              prodDiv: item.proddiv,
              prodCat: '',
              prodCatDescription: item.alias,
              // cashback:  item.diskon.contains(',') ? item.diskon.replaceAll(',', '.') : item.diskon.replaceAll('.', ''),
              cashback: item.diskon.contains(',')
                  ? item.diskon.replaceAll(',', '.')
                  : item.diskon,
              status: 'ACTIVE',
            ),
          );
        }

        for (Product item in selectedItemProduct) {
          print("${item.proddesc} : ${item.diskon.replaceAll(',', '.')}");

          listLineCashback.add(
            CashbackLine(
              idCashback: idCashback,
              categoryId: item.categoryid,
              prodDiv: item.proddiv,
              prodCat: item.prodcat,
              prodCatDescription: item.proddesc,
              // cashback:  item.diskon.contains(',') ? item.diskon.replaceAll(',', '.') : item.diskon.replaceAll('.', ''),
              cashback: item.diskon.contains(',')
                  ? item.diskon.replaceAll(',', '.')
                  : item.diskon,
              status: 'ACTIVE',
            ),
          );
        }

        if (listLineCashback.isNotEmpty) {
          var body = json.encode(listLineCashback);
          print(body);

          serviceCashback
              .updateLine(
            isHorizontal: isHorizontal,
            mounted: mounted,
            context: context,
            line: listLineCashback,
          )
              .then((value) {
            if (value) {
              handleStatus(
                context,
                'Cashback has been updated',
                true,
                isHorizontal: isHorizontal,
                isLogout: false,
                isBack: true,
              );
              Navigator.of(context).pop();
            }
          });
        } else {
          handleStatus(
            context,
            'Cashback has been updated',
            true,
            isHorizontal: isHorizontal,
            isLogout: false,
            isBack: true,
          );
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      if (MediaQuery.of(context).orientation == Orientation.landscape ||
          constraint.maxWidth > 600) {
        childWidget(isHorizontal: true);
      }

      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    _isHorizontal = isHorizontal;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.greenAccent,
        title: Text(
          'Pengajuan Kontrak Cashback',
          style: TextStyle(
            color: Colors.white,
            fontSize: isHorizontal ? 20.sp : 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: isHorizontal ? 20.r : 18.r,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CashbackFormCustomer(
              isHorizontal: isHorizontal,
              validateOpticAddress: _validateOpticAddress,
              validateOpticName: _validateOpticName,
              controllerOpticName: controllerOpticName,
              controllerOptikAddress: controllerOptikAddress,
              billNumber: _billNumber,
              shipNumber: _shipNumber,
              opticType: _opticType,
              updateParent: updateSelected,
            ),
            CashbackFormRekening(
              isHorizontal: isHorizontal,
              cashbackRekening: cashbackRekening,
              isWalletAvail: _isWalletAvail,
              isActiveRekening: _isActiveRekening,
              enableRekening: _enableRekening,
              validateKtp: _validateKtp,
              validateName: _validateOwnerName,
              controllerNama: controllerOwnerName,
              controllerKtp: controllerOwnerKtp,
              controllerNpwp: controllerOwnerNpwp,
              billNumber: _billNumber,
              shipNumber: _shipNumber,
              updateParent: updateSelected,
            ),
            CashbackFormContract(
              cashbackType: _cashbackType,
              updateParent: updateSelected,
              isHorizontal: isHorizontal,
              isCashbackValue: _isCashbackValue,
              validateStartDate: _validateStartDate,
              validateEndDate: _validateEndDate,
              validateWithdrawDuration: _validateWithdrawDuration,
              selectedWithdrawProcess: _selectedWithdrawProcess,
              selectedPaymentTermint: _selectedPaymentTermint,
              controllerStartDate: controllerStartDate,
              controllerEndDate: controllerEndDate,
              controllerWithdrawDuration: controllerWithdrawDuration,
            ),
            Visibility(
              maintainAnimation: true,
              maintainState: true,
              visible: _cashbackType != CashbackType.BY_PRODUCT ? true : false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 2000),
                curve: Curves.fastOutSlowIn,
                opacity: _cashbackType != CashbackType.BY_PRODUCT ? 1 : 0,
                child: CashbackFormTarget(
                  updateParent: updateSelected,
                  isHorizontal: isHorizontal,
                  targetDuration:
                      '${getMonthBetweenTwoDates(dateStart, dateEnd)} Bulan',
                  targetProduct: _targetProduct,
                  validateTargetValue: _validateTargetValue,
                  validateCashbackValue: _validateCashbackValue,
                  selectedItemProdDiv: selectedTargetProdDiv,
                  controllerTargetValue: controllerTargetValue,
                  controllerCashbackPercent: controllerCashbackPercent,
                  controllerCashbackValue: controllerCashbackValue,
                ),
              ),
              replacement: SizedBox(
                width: 5.w,
              ),
            ),
            Visibility(
              maintainAnimation: true,
              maintainState: true,
              visible: _cashbackType != CashbackType.BY_TARGET ? true : false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 2000),
                curve: Curves.fastOutSlowIn,
                opacity: _cashbackType != CashbackType.BY_TARGET ? 1 : 0,
                child: CashbackFormProduct(
                  isHorizontal: isHorizontal,
                  isUpdateForm: widget.isUpdateForm,
                  updateParent: updateSelected,
                  idCashback: widget.constructIdCashback,
                  selectedItemProdDiv: widget.listProductProddiv,
                  selectedItemProduct: widget.listProductKhusus,
                ),
              ),
              replacement: SizedBox(
                width: 5.w,
              ),
            ),
            CashbackFormAttachment(
              isHorizontal: isHorizontal,
              isUpdateForm: widget.isUpdateForm,
              notifyParent: updateSelected,
              validateLampiranSign: _validateLampiranSign,
              txtAttachmentSign: txtAttachmentSign,
              txtAttachmentOther: txtAttachmentOther,
              base64Sign: base64Sign,
              base64Other: base64Other,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 30.r : 15.r,
                vertical: isHorizontal ? 10.r : 5.r,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  EasyButton(
                    idleStateWidget: Text(
                      widget.isUpdateForm ? "Perbarui" : "Simpan",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isHorizontal ? 18.sp : 14.sp,
                          fontWeight: FontWeight.w700),
                    ),
                    loadingStateWidget: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                    useEqualLoadingStateWidgetDimension: true,
                    useWidthAnimation: true,
                    height: isHorizontal ? 50.h : 40.h,
                    width: isHorizontal ? 90.w : 100.w,
                    borderRadius: isHorizontal ? 60.r : 30.r,
                    buttonColor: widget.isUpdateForm
                        ? Colors.amber.shade700
                        : Colors.blue.shade700,
                    elevation: 2.0,
                    contentGap: 6.0,
                    onPressed: onButtonPressed,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }
}
