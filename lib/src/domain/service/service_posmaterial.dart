import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/config.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/manager_token.dart';
import 'package:sample/src/domain/entities/opticwithaddress.dart';
import 'package:sample/src/domain/entities/posmaterial_attachment.dart';
import 'package:sample/src/domain/entities/posmaterial_content.dart';
import 'package:sample/src/domain/entities/posmaterial_header.dart';
import 'package:sample/src/domain/entities/posmaterial_insert.dart';
import 'package:sample/src/domain/entities/posmaterial_item.dart';
import 'package:sample/src/domain/entities/posmaterial_poster.dart';
import 'package:sample/src/domain/entities/posmaterial_resheader.dart';
import 'package:sample/src/domain/entities/posmaterial_review.dart';

class ServicePosMaterial {
  Future<PosMaterialResHeader> getPosMaterialHeader(
    bool mounted,
    BuildContext context, {
    int idSales = 0,
    int idManager = 0,
    int status = 0,
    int limit = 4,
    int offset = 0,
    String search = '',
  }) async {
    late PosMaterialResHeader list;
    late var url;
    if (idSales == 0) {
      url =
          '$API_URL/posmaterial?id_sales_manager=$idManager&approval_status=$status&search=$search&limit=$limit&offset=$offset';
    } else {
      url =
          '$API_URL/posmaterial?id_sales=$idSales&search=$search&limit=$limit&offset=$offset';
    }

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos Material Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new PosMaterialResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              header: data['data']
                  .map<PosMaterialHeader>(
                      (json) => PosMaterialHeader.fromJson(json))
                  .toList());
        } else {
          list = new PosMaterialResHeader(
            status: data['status'],
            message: data['message'],
            count: 0,
            total: 0,
            header: [],
          );
        }
      } on FormatException catch (e) {
        print('Format Exception : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return list;
  }

  Future<PosMaterialResHeader> getPosMaterialHeaderByManager(
    bool mounted,
    BuildContext context, {
    bool isBrandManager = true,
    int status = 0,
    int limit = 4,
    int offset = 0,
    String search = '',
  }) async {
    late PosMaterialResHeader list;
    var url =
        '$API_URL/posmaterial/getPosManager?is_brand_manager=$isBrandManager&approval_status=$status&search=$search&limit=$limit&offset=$offset';

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos Material Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new PosMaterialResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              header: data['data']
                  .map<PosMaterialHeader>(
                      (json) => PosMaterialHeader.fromJson(json))
                  .toList());
        } else {
          list = new PosMaterialResHeader(
            status: data['status'],
            message: data['message'],
            count: 0,
            total: 0,
            header: [],
          );
        }
      } on FormatException catch (e) {
        print('Format Exception : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return list;
  }

  Future<PosMaterialResHeader> getPosMaterialDashboard(
    bool mounted,
    BuildContext context, {
    int idManager = 0,
    bool isBrandManager = true,
    int status = 0,
  }) async {
    late PosMaterialResHeader list;
    var url =
        '$API_URL/posmaterial/dashboard?id_sales_manager=$idManager&is_brand_manager=$isBrandManager&approval_status=$status';

    print(url);

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos Material Status: ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          list = new PosMaterialResHeader(
              status: data['status'],
              message: data['message'],
              count: data['count'],
              total: data['total'],
              header: data['data']
                  .map<PosMaterialHeader>(
                      (json) => PosMaterialHeader.fromJson(json))
                  .toList());
        } else {
          list = new PosMaterialResHeader(
            status: data['status'],
            message: data['message'],
            count: 0,
            total: 0,
            header: [],
          );
        }
      } on FormatException catch (e) {
        print('Format Exception : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return list;
  }

  Future<List<PosMaterialItem>> getPosMaterialItem(
      BuildContext context, bool mounted,
      {String productType = 'CUSTOM'}) async {
    List<PosMaterialItem> itemList = List.empty(growable: true);
    var url = '$API_URL/PosMaterial/getMaterialItem?product_type=$productType';

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos material item : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          itemList = rest
              .map<PosMaterialItem>((json) => PosMaterialItem.fromJson(json))
              .toList();
        }
      } on FormatException catch (e) {
        print('Format Exception : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return itemList;
  }

  Future<List<PosMaterialPoster>> getPosMaterialPoster(
    BuildContext context,
    bool mounted,
  ) async {
    List<PosMaterialPoster> posterList = List.empty(growable: true);
    var url = '$API_URL/PosMaterial/getMaterialPoster';

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos material poster : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          posterList = rest
              .map<PosMaterialPoster>(
                  (json) => PosMaterialPoster.fromJson(json))
              .toList();
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return posterList;
  }

  Future<List<PosMaterialContent>> getPosMaterialContent(
    BuildContext context,
    bool mounted,
  ) async {
    List<PosMaterialContent> contentList = List.empty(growable: true);
    var url = '$API_URL/PosMaterial/getMaterialContent';

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos material content : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          contentList = rest
              .map<PosMaterialContent>(
                  (json) => PosMaterialContent.fromJson(json))
              .toList();
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');

      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return contentList;
  }

  Future<PosMaterialAttachment> getPosMaterialAttachment(
    BuildContext context,
    bool mounted,
    String idPos,
  ) async {
    late PosMaterialAttachment attachment;
    var url = "$API_URL/posMaterial/getDetail?id_pos_material=$idPos";

    try {
      var response = await http.get(Uri.parse(url));
      print('Pos attachment : ${response.statusCode}');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];

          attachment = new PosMaterialAttachment(
            id: rest['id_pos_material'],
            attachmentParaf: rest['attachment_desain_paraf'],
            attachmentKtp: rest['attachment_ktp'],
            attachmentNpwp: rest['attachment_npwp'],
            attachmentOmzet: rest['attachment_omzet'],
            attachmentLokasi: rest['attachment_rencana_lokasi'],
          );
        } else {
          attachment = new PosMaterialAttachment(
            id: "",
            attachmentParaf: "",
            attachmentKtp: "",
            attachmentNpwp: "",
            attachmentOmzet: "",
            attachmentLokasi: "",
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');

      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return attachment;
  }

  Future<List<OpticWithAddress>> findAllCustWithAddress(
    BuildContext context,
    bool mounted,
    dynamic keyword,
  ) async {
    List<OpticWithAddress> opticList = List.empty(growable: true);
    var url = '$API_URL/customers/findCustAll?search=$keyword';

    try {
      var response = await http.get(Uri.parse(url));
      print('Get all optic : $response');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          opticList = rest
              .map<OpticWithAddress>((json) => OpticWithAddress.fromJson(json))
              .toList();
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');

      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return opticList;
  }

  Future<ManagerToken> generateTokenSm({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required int idSales,
  }) async {
    late ManagerToken managerToken;

    var url = '$API_URL/users/manager?id=$idSales';

    try {
      var response = await http.get(Uri.parse(url));
      print('Get all optic : $response');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          managerToken = new ManagerToken(
              id: rest['id'],
              name: rest['name'],
              username: rest['username'],
              divisi: rest['divisi'],
              role: rest['role'],
              token: rest['gentoken']);
        } else {
          managerToken = new ManagerToken(
              id: '', name: '', username: '', divisi: '', role: '', token: '');
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');

      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return managerToken;
  }

  Future<ManagerToken> generateTokenSales({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required String idPosMaterial,
  }) async {
    late ManagerToken managerToken;

    var url = '$API_URL/posmaterial/sales?id_pos=$idPosMaterial';

    try {
      var response = await http.get(Uri.parse(url));
      print('Get all optic : $response');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          managerToken = new ManagerToken(
              id: rest['id'],
              name: rest['name'],
              username: rest['username'],
              divisi: rest['divisi'],
              role: rest['role'],
              token: rest['gentoken']);
        } else {
          managerToken = new ManagerToken(
              id: '', name: '', username: '', divisi: '', role: '', token: '');
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');

      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return managerToken;
  }

  Future<PosMaterialReview> getReviewPos({
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required String shipNumber,
    required int priceEstimate,
  }) async {
    late PosMaterialReview posMaterialReview;
    var url =
        "$API_URL/PosMaterial/calcPos?ship_number=$shipNumber&price_estimate=$priceEstimate";

    try {
      var response = await http.get(Uri.parse(url));
      print('Get review pos : $response');

      try {
        var data = json.decode(response.body);
        final bool status = data['status'];

        if (status) {
          var rest = data['data'];
          posMaterialReview = new PosMaterialReview(
            total: rest['278073934'],
            posAllocation: rest['max_alokasipos'],
            posEstimation: rest['perc_estimasipos'],
            status: rest['status_pos'],
            review: rest['kesimpulan_pos'],
          );
        } else {
          posMaterialReview = new PosMaterialReview(
            total: '',
            posAllocation: '',
            posEstimation: 0,
            status: false,
            review: '',
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');

      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      handleSocket(context);
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
    }

    return posMaterialReview;
  }

  insertPostMaterial(
    Function stop, {
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required PosMaterialInsert item,
    required salesname,
    required opticname,
    required idSm,
    required tokenSm,
  }) async {
    print("""
            'sales_name' : ${item.getSalesName},
            'no_account' : ${item.getNoAccount},
            'nama_usaha' : ${item.getNamaUsaha},
            'alamat_usaha' : ${item.getAlamatUsaha},
            'pos_type' : ${item.getPosType},
            'optic_type' : ${item.getOpticType},
            'product_id' : ${item.getProductId},
            'product_name' : ${item.getProductName},
            'product_qty' : ${item.getProductQty.replaceAll('.', '')},
            'price_estimate' : ${item.getPriceEstimate.replaceAll('.', '')},
            'product_size_s' : ${item.getProductSizeS},
            'product_size_m' : ${item.getProductSizeM},
            'product_size_l' : ${item.getProductSizeL},
            'product_size_xl' : ${item.getProductSizeXL},
            'product_size_xxl' : ${item.getProductSizeXXL},
            'product_size_xxxl' : ${item.getProductSizeXXXL},
            'poster_design_only' : ${item.getPosterDesignOnly},
            'poster_material_id' : ${item.getPosterMaterialId},
            'poster_material' : ${item.getPosterMaterial},
            'poster_width' : ${item.getPosterWidth},
            'poster_height' : ${item.getPosterHeight},
            'poster_content_id' : ${item.getPosterContentId},
            'poster_content' : ${item.getPosterContent},
            'notes' : ${item.getNotes},
            'delivery_method' : ${item.getDeliveryMethod},
            'attachment_desain_paraf' : ${item.getAttachmentDesainParaf},
            'attachment_ktp' : ${item.getAttachmentKtp},
            'attachment_npwp' : ${item.getAttachmentNpwp},
            'attachment_omzet' : ${item.getAttachmentOmzet},
            'attachment_rencana_lokasi' : ${item.getAttachmentRencanaLokasi},
            'created_by' : ${item.getCreatedBy},
            """);

    var url = '$API_URL/PosMaterial';
    const timeout = 15;

    try {
      var response = await http.post(Uri.parse(url), body: {
        'sales_name': item.getSalesName,
        'no_account': item.getNoAccount,
        'nama_usaha': item.getNamaUsaha,
        'alamat_usaha': item.getAlamatUsaha,
        'pos_type': item.getPosType,
        'optic_type': item.getOpticType,
        'product_id': item.getProductId,
        'product_name': item.getProductName,
        'product_qty': item.getProductQty.replaceAll('.', ''),
        'price_estimate': item.getPriceEstimate.replaceAll('.', ''),
        'product_size_s': item.getProductSizeS,
        'product_size_m': item.getProductSizeM,
        'product_size_l': item.getProductSizeL,
        'product_size_xl': item.getProductSizeXL,
        'product_size_xxl': item.getProductSizeXXL,
        'product_size_xxxl': item.getProductSizeXXXL,
        'poster_design_only' : item.getPosterDesignOnly,
        'poster_material_id': item.getPosterMaterialId,
        'poster_material': item.getPosterMaterial,
        'poster_width': item.getPosterWidth,
        'poster_height': item.getPosterHeight,
        'poster_content_id': item.getPosterContentId,
        'poster_content': item.getPosterContent,
        'notes': item.getNotes,
        'delivery_method': item.getDeliveryMethod,
        'attachment_desain_paraf': item.getAttachmentDesainParaf,
        'attachment_ktp': item.getAttachmentKtp,
        'attachment_npwp': item.getAttachmentNpwp,
        'attachment_omzet': item.getAttachmentOmzet,
        'attachment_rencana_lokasi': item.getAttachmentRencanaLokasi,
        'created_by': item.getCreatedBy,
      }).timeout(Duration(seconds: timeout));

      print('Response status : ${response.statusCode}');
      print('Response body : ${response.body}');

      try {
        var res = json.decode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (mounted) {
          handleStatus(
            context,
            capitalize(msg),
            sts,
            isHorizontal: isHorizontal,
            isLogout: false,
            isNewCust: false,
          );

          pushNotif(
            17,
            3,
            salesName: salesname,
            idUser: idSm,
            rcptToken: tokenSm,
            opticName: opticname,
          );
        }
      } on FormatException catch (e) {
        print('Format Error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout Error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket Error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General Error : ${e.stackTrace}');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: isHorizontal,
          isLogout: false,
        );
      }
    }

    stop();
  }

  approvePos(
    Function stop, {
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required String idPos,
    required String idSales,
    required String nameSales,
    required String tokenSales,
    required String opticName,
    required String managerName,
    String approverSm = '',
    String approverBm = '',
    String approverGm = '',
  }) async {
    var url = "$API_URL/PosMaterial/approve";

    try {
      var response = await http.post(Uri.parse(url), body: {
        'id_pos_material': idPos,
        'approver_sm': approverSm,
        'approver_bm': approverBm,
        'approver_gm': approverGm,
      }).timeout(
        Duration(
          seconds: 10,
        ),
      );

      try {
        var res = jsonDecode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          handleStatus(
            context,
            msg,
            sts,
            isHorizontal: isHorizontal,
            isLogout: false,
            isNewCust: false,
          );

          if (approverSm != '') {
            pushNotif(17, 5,
                salesName: nameSales, opticName: opticName, idUser: '');
            pushNotif(17, 6,
                salesName: nameSales, opticName: opticName, idUser: '');
          }

          pushNotif(
            18,
            3,
            idUser: idSales,
            rcptToken: tokenSales,
            admName: managerName,
            opticName: opticName,
          );
        }
      } on FormatException catch (e) {
        print('Format error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: false,
          isLogout: false,
        );
      }
    }

    stop();
  }

  rejectPos(
    Function stop, {
    bool isHorizontal = false,
    bool mounted = false,
    required BuildContext context,
    required String idPos,
    required String idSales,
    required String nameSales,
    required String tokenSales,
    required String opticName,
    required String managerName,
    String approverSm = '',
    String approverBm = '',
    String approverGm = '',
    String reasonSm = '',
    String reasonBm = '',
    String reasonGm = '',
  }) async {
    var url = "$API_URL/PosMaterial/reject";

    try {
      var response = await http.post(Uri.parse(url), body: {
        'id_pos_material': idPos,
        'approver_sm': approverSm,
        'approver_bm': approverBm,
        'approver_gm': approverGm,
        'reason_sm': reasonSm,
        'reason_bm': reasonBm,
        'reason_gm': reasonGm,
      }).timeout(
        Duration(
          seconds: 10,
        ),
      );

      try {
        var res = jsonDecode(response.body);
        final bool sts = res['status'];
        final String msg = res['message'];

        if (sts) {
          handleStatus(
            context,
            msg,
            sts,
            isHorizontal: isHorizontal,
            isLogout: false,
            isNewCust: false,
          );

          pushNotif(
            19,
            3,
            idUser: idSales,
            rcptToken: tokenSales,
            admName: managerName,
            opticName: opticName,
          );
        }
      } on FormatException catch (e) {
        print('Format error : $e');
      }
    } on TimeoutException catch (e) {
      print('Timeout error : $e');
      if (mounted) {
        handleTimeout(context);
      }
    } on SocketException catch (e) {
      print('Socket error : $e');
      if (mounted) {
        handleSocket(context);
      }
    } on Error catch (e) {
      print('General error : ${e.stackTrace}');
      if (mounted) {
        handleStatus(
          context,
          e.toString(),
          false,
          isHorizontal: false,
          isLogout: false,
        );
      }
    }

    stop();
  }
}
