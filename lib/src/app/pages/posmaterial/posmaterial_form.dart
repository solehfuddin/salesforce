import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formcustom.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formkemeja.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formkit.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formoptik.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formposter.dart';
import 'package:sample/src/app/pages/posmaterial/posmaterial_formother.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/posmaterial_insert.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/omzet_optic.dart';
import '../../../domain/entities/posmaterial_lineposter.dart';

// ignore: camel_case_types
class Posmaterial_Form extends StatefulWidget {
  const Posmaterial_Form({Key? key}) : super(key: key);

  @override
  State<Posmaterial_Form> createState() => _Posmaterial_FormState();
}

// ignore: camel_case_types
class _Posmaterial_FormState extends State<Posmaterial_Form> {
  ServicePosMaterial service = new ServicePosMaterial();
  List<PosMaterialLinePoster> listPosterLine = List.empty(growable: true);

  TextEditingController controllerOptikName = new TextEditingController();
  TextEditingController controllerOptikAddress = new TextEditingController();
  TextEditingController controllerProductQty = new TextEditingController();
  TextEditingController controllerProductEstimate = new TextEditingController();
  TextEditingController controllerNotes = new TextEditingController();
  TextEditingController controllerProductName = new TextEditingController();
  TextEditingController controllerProductSizeS = new TextEditingController();
  TextEditingController controllerProductSizeM = new TextEditingController();
  TextEditingController controllerProductSizeL = new TextEditingController();
  TextEditingController controllerProductSizeXL = new TextEditingController();
  TextEditingController controllerProductSizeXXL = new TextEditingController();
  TextEditingController controllerProductSizeXXXL = new TextEditingController();
  TextEditingController controllerProductWidth = new TextEditingController();
  TextEditingController controllerProductHeight = new TextEditingController();

  TextEditingController txtAttachmentDesainParaf = new TextEditingController();
  TextEditingController txtAttachmentKtp = new TextEditingController();
  TextEditingController txtAttachmentNpwp = new TextEditingController();
  TextEditingController txtAttachmentOmzet = new TextEditingController();

  Future<OmzetOptic>? futureOmzet;
  OmzetOptic? _omzetOptic;

  String? id, role, username, name;
  String? idSm, nameSm, tokenSm;
  String productId = 'PRDID-001';
  String kemejaId = 'PRDID-016';
  String kitId = 'PRDID-006';
  String accountNo = '';
  String accountType = 'PROSPECT';
  String selectedTypePos = 'CUSTOM';
  String selectedProductCustom = 'Sticker Label';
  String selectedProductKemeja = 'Kemeja Hijau Leinz';
  String selectedProductKit = 'Tas Punggung Leinz Hijau-Hitam';
  String selectedDeliveryMethod = 'Kirim ke optik';
  String selectedMaterialId = 'POSID-001';
  String selectedMaterial = 'Albatros';
  String selectedContentId = 'CONID-001';
  String selectedContent = 'Leinz Logo';

  String base64DesainParaf = '';
  String base64Ktp = '';
  String base64Npwp = '';
  String base64Omzet = '';
  String base64Rencana = '';

  bool _isHorizontal = false;
  bool _isDesignOnly = false;
  bool _isProspectCustomer = false;
  bool _validateOpticName = false;
  bool _validateOpticAddress = false;
  bool _validateQtyItem = false;
  bool _validateEstimatePrice = false;
  bool _validateProductName = false;
  bool _validateProductWidth = false;
  bool _validateProductHeight = false;

  bool _validateLampiranParaf = false;
  bool _validateLampiranKtp = false;
  bool _validateLampiranOmzet = false;
  bool _validateLampiranRencana = false;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id") ?? "0";
      role = preferences.getString("role") ?? '';
      username = preferences.getString("username") ?? '';
      name = preferences.getString("name") ?? '';

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

  onButtonPressed() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
      () => handleValidationForm(
        isHorizontal: _isHorizontal,
      ),
    );

    return () {};
  }

  void _getOmzet() async {
    futureOmzet = service.getOmzetOptic(context, mounted, accountNo);
    _omzetOptic = await futureOmzet;

    setState(() {
      print("""
          Max Pos : ${_omzetOptic?.maxPos}
        """);
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(
          isHorizontal: true,
        );
      }

      return childWidget(
        isHorizontal: false,
      );
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.darkColor,
        title: Text(
          'Entri Pos Material',
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
            Posmaterial_Formoptik(
              isHorizontal: isHorizontal,
              accountNo: accountNo,
              accountType: accountType,
              controllerOptikName: controllerOptikName,
              controllerOptikAddress: controllerOptikAddress,
              selectedTypePos: selectedTypePos,
              notifyParent: reloadChild,
              updateParent: updateSelected,
              validateOpticName: _validateOpticName,
              validateOpticAddress: _validateOpticAddress,
            ),
            getWidgetPosmaterial(
              selectedTypePos,
              isHorizontal,
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
                      "Simpan",
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
                    buttonColor: Colors.blue.shade700,
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

  reloadChild(dynamic returnVal) {
    setState(() {
      selectedTypePos = returnVal;

      resetForm();
    });
  }

  resetForm() {
    productId = 'PRDID-001';
    kemejaId = 'PRDID-016';
    kitId = 'PRDID-006';
    accountNo = '';
    accountType = 'PROSPECT';
    selectedProductCustom = 'Sticker Label';
    selectedProductKemeja = 'Kemeja Hijau Leinz';
    selectedProductKit = 'Tas Punggung Leinz Hijau-Hitam';
    selectedDeliveryMethod = 'Kirim ke optik';

    selectedMaterialId = 'POSID-001';
    selectedMaterial = 'Albatros';
    selectedContentId = 'CONID-001';
    selectedContent = 'Leinz Logo';

    _isProspectCustomer = false;
    _validateOpticName = false;
    _validateOpticAddress = false;
    _validateQtyItem = false;
    _validateEstimatePrice = false;
    _validateProductName = false;
    _validateProductWidth = false;
    _validateProductHeight = false;

    _validateLampiranParaf = false;
    _validateLampiranKtp = false;
    _validateLampiranOmzet = false;
    _validateLampiranRencana = false;

    base64DesainParaf = '';
    base64Ktp = '';
    base64Npwp = '';
    base64Omzet = '';
    base64Rencana = '';

    controllerOptikName.clear();
    controllerOptikAddress.clear();
    controllerProductQty.clear();
    controllerProductEstimate.clear();
    controllerNotes.clear();
    controllerProductName.clear();
    controllerProductSizeS.clear();
    controllerProductSizeM.clear();
    controllerProductSizeL.clear();
    controllerProductSizeXL.clear();
    controllerProductSizeXXL.clear();
    controllerProductSizeXXXL.clear();
    controllerProductWidth.clear();
    controllerProductHeight.clear();

    txtAttachmentDesainParaf.clear();
    txtAttachmentKtp.clear();
    txtAttachmentNpwp.clear();
    txtAttachmentOmzet.clear();
  }

  updateSelected(dynamic variableName, dynamic returVal) {
    setState(() {
      switch (variableName) {
        case 'isProspectCustomer':
          _isProspectCustomer = returVal;
          break;
        case 'selectedProductCustom':
          selectedProductCustom = returVal;
          break;
        case 'selectedProductKemeja':
          selectedProductKemeja = returVal;
          break;
        case 'selectedDeliveryMethod':
          selectedDeliveryMethod = returVal;
          break;
        case 'isDesignOnly':
          _isDesignOnly = returVal;
          break;
        case 'selectedProductKit':
          selectedProductKit = returVal;
          break;
        case 'selectedMaterialId':
          selectedMaterialId = returVal;
          break;
        case 'selectedMaterial':
          selectedMaterial = returVal;
          break;
        case 'selectedContentId':
          selectedContentId = returVal;
          break;
        case 'selectedContent':
          selectedContent = returVal;
          break;
        case 'productId':
          productId = returVal;
          break;
        case 'kemejaId':
          kemejaId = returVal;
          break;
        case 'kitId':
          kitId = returVal;
          break;
        case 'accountNo':
          accountNo = returVal;
          _getOmzet();
          break;
        case 'accountType':
          accountType = returVal;
          break;
        case 'Lampiran Desain Paraf':
          base64DesainParaf = returVal;
          break;
        case 'Lampiran KTP':
          base64Ktp = returVal;
          break;
        case 'Lampiran NPWP':
          base64Npwp = returVal;
          break;
        case 'Lampiran Omzet':
          base64Omzet = returVal;
          break;
        case 'Lampiran Rencana Lokasi':
          base64Rencana = returVal;
          break;
        case 'validateOpticName':
          _validateOpticName = returVal;
          break;
        case 'validateOpticAddress':
          _validateOpticAddress = returVal;
          break;
        case 'validateProductName':
          _validateProductName = returVal;
          break;
        case 'validateProductWidth':
          _validateProductWidth = returVal;
          break;
        case 'validateProductHeight':
          _validateProductHeight = returVal;
          break;
        case 'validateQtyItem':
          _validateQtyItem = returVal;
          break;
        case 'validateEstimatePrice':
          _validateEstimatePrice = returVal;
          break;
        case 'validateLampiranKtp':
          _validateLampiranKtp = returVal;
          break;
        case 'validateLampiranParaf':
          _validateLampiranParaf = returVal;
          break;
        case 'validateLampiranOmzet':
          _validateLampiranOmzet = returVal;
          break;
        case 'validateLampiranRencanaLokasi':
          _validateLampiranRencana = returVal;
          break;
        default:
      }
    });
  }

  Widget getWidgetPosmaterial(String? input, bool isHorizontal) {
    Widget widget = Center();
    switch (input) {
      case 'CUSTOM':
        widget = Posmaterial_formcustom(
          isHorizontal: isHorizontal,
          isProspectCustomer: _isProspectCustomer,
          controllerProductQty: controllerProductQty,
          controllerNotes: controllerNotes,
          controllerProductEstimate: controllerProductEstimate,
          txtAttachmentDesainParaf: txtAttachmentDesainParaf,
          txtAttachmentKtp: txtAttachmentKtp,
          txtAttachmentNpwp: txtAttachmentNpwp,
          txtAttachmentOmzet: txtAttachmentOmzet,
          selectedProductId: productId,
          selectedProductCustom: selectedProductCustom,
          selectedDeliveryMethod: selectedDeliveryMethod,
          notifyParent: updateSelected,
          validateQtyItem: _validateQtyItem,
          validateEstimatePrice: _validateEstimatePrice,
          validateLampiranParaf: _validateLampiranParaf,
          validateLampiranKtp: _validateLampiranKtp,
          validateLampiranOmzet: _validateLampiranOmzet,
        );
        break;
      case 'KEMEJA_LEINZ_HIJAU':
        widget = Posmaterial_Formkemeja(
          isHorizontal: isHorizontal,
          isProspectCustomer: _isProspectCustomer,
          selectedProductId: kemejaId,
          selectedProductName: selectedProductKemeja,
          controllerProductSizeS: controllerProductSizeS,
          controllerProductSizeM: controllerProductSizeM,
          controllerProductSizeL: controllerProductSizeL,
          controllerProductSizeXL: controllerProductSizeXL,
          controllerProductSizeXXL: controllerProductSizeXXL,
          controllerProductSizeXXXL: controllerProductSizeXXXL,
          selectedDeliveryMethod: selectedDeliveryMethod,
          notifyParent: updateSelected,
          validateLampiranKtp: _validateLampiranKtp,
          validateLampiranOmzet: _validateLampiranOmzet,
        );
        break;
      case 'MATERIAL_KIT':
        widget = Posmaterial_Formkit(
          isHorizontal: isHorizontal,
          isProspectCustomer: _isProspectCustomer,
          controllerProductQty: controllerProductQty,
          selectedProductId: kitId,
          selectedProductKit: selectedProductKit,
          selectedDeliveryMethod: selectedDeliveryMethod,
          notifyParent: updateSelected,
          validateQtyItem: _validateQtyItem,
          validateLampiranKtp: _validateLampiranKtp,
          validateLampiranOmzet: _validateLampiranOmzet,
        );
        break;
      case 'POSTER':
        widget = Posmaterial_Formposter(
          isHorizontal: isHorizontal,
          isProspectCustomer: _isProspectCustomer,
          isDesignOnly: _isDesignOnly,
          listPosterLine: listPosterLine,
          // controllerProductWidth: controllerProductWidth,
          // controllerProductHeight: controllerProductHeight,
          // controllerProductQty: controllerProductQty,
          omzetOptik: _omzetOptic?.maxPos ?? "0",
          controllerNotes: controllerNotes,
          // selectedMaterialId: selectedMaterialId,
          // selectedMaterial: selectedMaterial,
          // selectedContentId: selectedContentId,
          // selectedContent: selectedContent,
          selectedDeliveryMethod: selectedDeliveryMethod,
          notifyParent: updateSelected,
          validateProductWidth: _validateProductWidth,
          validateProductHeight: _validateProductHeight,
          validateQtyItem: _validateQtyItem,
          validateLampiranRencana: _validateLampiranRencana,
          validateLampiranKtp: _validateLampiranKtp,
          validateLampiranOmzet: _validateLampiranOmzet,
        );
        break;
      default:
        widget = Posmaterial_formother(
          isHorizontal: isHorizontal,
          isCustomerProspect: _isProspectCustomer,
          controllerProductName: controllerProductName,
          controllerProductQty: controllerProductQty,
          selectedDeliveryMethod: selectedDeliveryMethod,
          notifyParent: updateSelected,
          validateProductName: _validateProductName,
          validateProductQty: _validateQtyItem,
          validateLampiranKtp: _validateLampiranKtp,
          validateLampiranOmzet: _validateLampiranOmzet,
        );
    }

    return widget;
  }

  handleValidationPoster({bool isHorizontal = false}) {
    bool readyExecute = false;
    bool isShowError = false;
    if (listPosterLine.isNotEmpty) {
      listPosterLine.forEach((element) {
        if (element.width!.isEmpty && isShowError == false) {
          handleStatus(
            context,
            'Harap lengkapi lebar poster',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );

          isShowError = true;
        } else if (element.height!.isEmpty && isShowError == false) {
          handleStatus(
            context,
            'Harap lengkapi tinggi poster',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
          isShowError = true;
        } else if (element.qty!.isEmpty && isShowError == false) {
          handleStatus(
            context,
            'Harap lengkapi qty poster',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
          isShowError = true;
        } else {
          if (element.material == 'Duratrans' && isShowError == false) {
            int width = int.parse(element.width ?? "0");
            int height = int.parse(element.height ?? "0");

            bool checkWidthMore150 = width > 150;
            bool checkHeightMore150 = height > 150;

            bool checkWidthMore400 = width > 400;
            bool checkHeightMore400 = height > 400;

            print("Width ($width) : $checkWidthMore150");
            print("Height ($height) : $checkHeightMore150");
            print("Width ($width) : $checkWidthMore400");
            print("Height ($height) : $checkHeightMore400");

            if (checkWidthMore150 ||
                checkHeightMore150 ||
                checkWidthMore400 ||
                checkHeightMore400) {
              handleStatus(
                context,
                'Ukuran max 150 * 400 / sebaliknya',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );

              isShowError = true;
            } else if (!_validateLampiranRencana) {
              handleStatus(
                context,
                'Harap lengkapi lampiran',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );
              isShowError = true;
            } else {
              readyExecute = true;
            }
          } else {
            if (!_validateLampiranRencana) {
              handleStatus(
                context,
                'Harap lengkapi lampiran',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );
              isShowError = true;
            } else {
              readyExecute = true;
            }
          }
        }
      });

      if (readyExecute) {
        print('Ready Execute');

        processInsert(
          isHorizontal: isHorizontal,
        );

        readyExecute = false;
      }
    } else {
      handleStatus(
        context,
        'Belum ada data spesifikasi poster',
        false,
        isHorizontal: isHorizontal,
        isLogout: false,
      );
      isShowError = true;
    }
  }

  handleValidationForm({bool isHorizontal = false}) {
    switch (selectedTypePos) {
      case 'CUSTOM':
        setState(() {
          if (controllerOptikName.text.isNotEmpty) {
            _validateOpticName = true;
          }

          if (controllerOptikAddress.text.isNotEmpty) {
            _validateOpticAddress = true;
          }

          if (controllerProductQty.text.isNotEmpty) {
            _validateQtyItem = true;
          }

          if (base64DesainParaf.isNotEmpty) {
            _validateLampiranParaf = true;
          }

          if (base64Ktp.isNotEmpty) {
            _validateLampiranKtp = true;
          }

          if (base64Omzet.isNotEmpty) {
            _validateLampiranOmzet = true;
          }
        });

        if (_validateOpticName &&
            _validateOpticAddress &&
            _validateQtyItem &&
            _validateEstimatePrice) {
          if (productId == 'PRDID-002' || productId == 'PRDID-003') {
            if (int.parse(
                    controllerProductQty.text.replaceAll('.', '').toString()) <
                1000) {
              handleStatus(
                context,
                'Qty min : 1000 (pcs)',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );

              return false;
            }
          }

          if (accountNo.isEmpty) {
            if (_validateLampiranParaf) {
              processInsert(
                isHorizontal: isHorizontal,
              );
            } else {
              handleStatus(
                context,
                'Harap lengkapi lampiran',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );
            }
          } else {
            if (_validateLampiranParaf) {
              processInsert(
                isHorizontal: isHorizontal,
              );
            } else {
              handleStatus(
                context,
                'Harap lengkapi lampiran',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );
            }
          }
        } else {
          handleStatus(
            context,
            'Harap lengkapi data terlebih dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
        break;
      case 'KEMEJA_LEINZ_HIJAU':
        setState(() {
          if (controllerOptikName.text.isNotEmpty) {
            _validateOpticName = true;
          }

          if (controllerOptikAddress.text.isNotEmpty) {
            _validateOpticAddress = true;
          }

          if (base64Ktp.isNotEmpty) {
            _validateLampiranKtp = true;
          }

          if (base64Omzet.isNotEmpty) {
            _validateLampiranOmzet = true;
          }
        });

        if (_validateOpticName && _validateOpticAddress) {
          if (accountNo.isEmpty) {
            if (_validateLampiranKtp) {
              processInsert(
                isHorizontal: isHorizontal,
              );
            } else {
              handleStatus(
                context,
                'Harap lengkapi lampiran',
                false,
                isHorizontal: isHorizontal,
                isLogout: false,
              );
            }
          } else {
            processInsert(
              isHorizontal: isHorizontal,
            );
          }
        } else {
          handleStatus(
            context,
            'Harap lengkapi data terlebih dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
        break;

      case 'MATERIAL_KIT':
        setState(() {
          if (controllerOptikName.text.isNotEmpty) {
            _validateOpticName = true;
          }

          if (controllerOptikAddress.text.isNotEmpty) {
            _validateOpticAddress = true;
          }

          if (controllerProductQty.text.isNotEmpty) {
            _validateQtyItem = true;
          }

          if (base64Ktp.isNotEmpty) {
            _validateLampiranKtp = true;
          }

          if (base64Omzet.isNotEmpty) {
            _validateLampiranOmzet = true;
          }
        });

        if (_validateOpticName && _validateOpticAddress && _validateQtyItem) {
          if (accountNo.isEmpty) {
            processInsert(
              isHorizontal: isHorizontal,
            );
          } else {
            processInsert(
              isHorizontal: isHorizontal,
            );
          }
        } else {
          handleStatus(
            context,
            'Harap lengkapi data terlebih dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
        break;

      case 'POSTER':
        listPosterLine.forEach((element) {
          print("""
          Item Material id : ${element.materialId}
          Item Material : ${element.material}
          Item Content id : ${element.contentId}
          Item Content : ${element.content}
          Item Qty : ${element.qty}
          Item Width : ${element.width}
          Item Height : ${element.height}
          """);
        });

        setState(() {
          if (controllerOptikName.text.isNotEmpty) {
            _validateOpticName = true;
          }

          if (controllerOptikAddress.text.isNotEmpty) {
            _validateOpticAddress = true;
          }

          if (base64Rencana.isNotEmpty) {
            _validateLampiranRencana = true;
          }

          if (base64Ktp.isNotEmpty) {
            _validateLampiranKtp = true;
          }

          if (base64Omzet.isNotEmpty) {
            _validateLampiranOmzet = true;
          }
        });

        if (_validateOpticName && _validateOpticAddress) {
          if (accountNo.isEmpty) {
            handleValidationPoster(isHorizontal: _isHorizontal);
          } else {
            handleValidationPoster(isHorizontal: _isHorizontal);
          }
        } else {
          handleStatus(
            context,
            'Harap lengkapi data terlebih dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }
        break;
      default:
        setState(() {
          if (controllerProductName.text.isNotEmpty) {
            _validateProductName = true;
          }

          if (controllerProductQty.text.isNotEmpty) {
            _validateQtyItem = true;
          }

          if (base64Ktp.isNotEmpty) {
            _validateLampiranKtp = true;
          }

          if (base64Omzet.isNotEmpty) {
            _validateLampiranOmzet = true;
          }
        });

        if (_validateProductName && _validateQtyItem) {
          if (accountNo.isEmpty) {
            processInsert(
              isHorizontal: isHorizontal,
            );
          } else {
            processInsert(
              isHorizontal: isHorizontal,
            );
          }
        } else {
          handleStatus(
            context,
            'Harap lengkapi data terlebih dahulu',
            false,
            isHorizontal: isHorizontal,
            isLogout: false,
          );
        }

        break;
    }
  }

  void processInsert({bool isHorizontal = false}) {
    PosMaterialInsert objectInsert = new PosMaterialInsert();

    objectInsert.setSalesName = username ?? '';
    objectInsert.setNoAccount = accountNo;
    objectInsert.setNamaUsaha = controllerOptikName.text;
    objectInsert.setAlamatUsaha = controllerOptikAddress.text;
    objectInsert.setPosType = selectedTypePos;
    objectInsert.setOpticType = accountNo.isNotEmpty ? accountType : 'PROSPECT';
    objectInsert.setProductId = selectedTypePos == 'CUSTOM'
        ? productId
        : selectedTypePos == 'MATERIAL_KIT'
            ? kitId
            : selectedTypePos == 'KEMEJA_LEINZ_HIJAU'
                ? kemejaId
                : '';
    objectInsert.setProductName = selectedTypePos == 'CUSTOM'
        ? selectedProductCustom
        : selectedTypePos == 'MATERIAL_KIT'
            ? selectedProductKit
            : selectedTypePos == 'KEMEJA_LEINZ_HIJAU'
                ? selectedProductKemeja
                : selectedTypePos == 'OTHER'
                    ? controllerProductName.text.toString()
                    : '';
    objectInsert.setProductQty = controllerProductQty.text;
    objectInsert.setPriceEstimate = controllerProductEstimate.text.isEmpty
        ? '0'
        : controllerProductEstimate.text;
    objectInsert.setProductSizeS =
        controllerProductSizeS.text.isEmpty ? '0' : controllerProductSizeS.text;
    objectInsert.setProductSizeM =
        controllerProductSizeM.text.isEmpty ? '0' : controllerProductSizeM.text;
    objectInsert.setProductSizeL =
        controllerProductSizeL.text.isEmpty ? '0' : controllerProductSizeL.text;
    objectInsert.setProductSizeXl = controllerProductSizeXL.text.isEmpty
        ? '0'
        : controllerProductSizeXL.text;
    objectInsert.setProductSizeXXL = controllerProductSizeXXL.text.isEmpty
        ? '0'
        : controllerProductSizeXXL.text;
    objectInsert.setProductSizeXXXL = controllerProductSizeXXXL.text.isEmpty
        ? '0'
        : controllerProductSizeXXXL.text;
    objectInsert.setPosterDesignOnly = _isDesignOnly ? '1' : '0';
    objectInsert.setPosterMaterialId =
        selectedTypePos == 'POSTER' ? selectedMaterialId : '';
    objectInsert.setPosterMaterial =
        selectedTypePos == 'POSTER' ? selectedMaterial : '';
    objectInsert.setPosterWidth =
        controllerProductWidth.text.isEmpty ? '0' : controllerProductWidth.text;
    objectInsert.setPosterHeight = controllerProductHeight.text.isEmpty
        ? '0'
        : controllerProductHeight.text;
    objectInsert.setPosterContentId =
        selectedTypePos == 'POSTER' ? selectedContentId : '';
    objectInsert.setPosterContent =
        selectedTypePos == 'POSTER' ? selectedContent : '';
    objectInsert.setNotes = controllerNotes.text;
    objectInsert.setDeliveryMethod = selectedDeliveryMethod;
    objectInsert.setAttachmentDesainParaf =
        base64DesainParaf.isEmpty ? '' : base64DesainParaf;
    objectInsert.setAttachmentKtp = base64Ktp.isEmpty ? '' : base64Ktp;
    objectInsert.setAttachmentNpwp = base64Npwp.isEmpty ? '' : base64Npwp;
    objectInsert.setAttachmentOmzet = base64Omzet.isEmpty ? '' : base64Omzet;
    objectInsert.setAttachmentRencanaLokasi =
        base64Rencana.isEmpty ? '' : base64Rencana;
    objectInsert.setCreatedBy = id ?? '';

    //eksekusi service post
    service.insertPostMaterial(
      isHorizontal: isHorizontal,
      mounted: mounted,
      context: context,
      item: objectInsert,
      line: listPosterLine,
      salesname: name,
      opticname: controllerOptikName.text,
      idSm: idSm,
      tokenSm: tokenSm,
    );
  }
}
