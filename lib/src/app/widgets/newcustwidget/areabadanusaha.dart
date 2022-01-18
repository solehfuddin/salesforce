import 'package:flutter/material.dart';

Widget areaBadanUsaha(Map<String, TextEditingController> editingMap) {
    bool _isNamaOptik = false;

    return Container(
      padding: EdgeInsets.all(
        15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A. DATA BADAN USAHA',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Segoe ui',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nama Optik/Dr/RS/Klinik/PT/dll',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
               Text(
                '(wajib diisi)',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w600,
                  // color: Colors.red[600],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          TextFormField(
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Optik Timur',
              // labelText: 'Nama Optik/Dr/RS/Klinik/PT/dll',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              errorText: _isNamaOptik ? 'Data wajib diisi' : null,
            ),
            // controller: textNamaOptik,
            controller: editingMap[0],
          ),
          SizedBox(
            height: 10,
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       'Alamat',
          //       style: TextStyle(
          //         fontSize: 12,
          //         fontFamily: 'Segoe ui',
          //         fontWeight: FontWeight.w600,
          //         color: Colors.black,
          //       ),
          //     ),
          //      Text(
          //       '(wajib diisi)',
          //       style: TextStyle(
          //         fontSize: 12,
          //         fontFamily: 'Segoe ui',
          //         fontWeight: FontWeight.w600,
          //         // color: Colors.red[600],
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(
          //   height: 8,
          // ),
          // TextFormField(
          //   textCapitalization: TextCapitalization.characters,
          //   decoration: InputDecoration(
          //     hintText: 'Jl Kebun raya no 57 Bogor',
          //     // labelText: 'Alamat',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     errorText: _isAlamatUsaha ? 'Data wajib diisi' : null,
          //   ),
          //   keyboardType: TextInputType.multiline,
          //   minLines: 1,
          //   maxLines: 3,
          //   controller: textAlamatOptik,
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       'Nomor Telp',
          //       style: TextStyle(
          //         fontSize: 12,
          //         fontFamily: 'Segoe ui',
          //         fontWeight: FontWeight.w600,
          //         color: Colors.black,
          //       ),
          //     ),
          //     Text(
          //       '(wajib diisi)',
          //       style: TextStyle(
          //         fontSize: 12,
          //         fontFamily: 'Segoe ui',
          //         fontWeight: FontWeight.w600,
          //         // color: Colors.red[600],
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(
          //   height: 8,
          // ),
          // TextFormField(
          //   keyboardType: TextInputType.number,
          //   decoration: InputDecoration(
          //     hintText: '02112XXX',
          //     // labelText: 'Telp',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     errorText: _isTlpUsaha ? 'Data wajib diisi' : null,
          //   ),
          //   controller: textTelpOptik,
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          // Text(
          //   'Nomor Fax',
          //   style: TextStyle(
          //     fontSize: 12,
          //     fontFamily: 'Segoe ui',
          //     fontWeight: FontWeight.w600,
          //     color: Colors.black,
          //   ),
          // ),
          // SizedBox(
          //   height: 8,
          // ),
          // TextFormField(
          //   keyboardType: TextInputType.number,
          //   decoration: InputDecoration(
          //     hintText: '02112XXX',
          //     // labelText: 'Fax',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //   ),
          //   controller: textFaxOptik,
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          // Text(
          //   'Alamat Email',
          //   style: TextStyle(
          //     fontSize: 12,
          //     fontFamily: 'Segoe ui',
          //     fontWeight: FontWeight.w600,
          //     color: Colors.black,
          //   ),
          // ),
          // SizedBox(
          //   height: 8,
          // ),
          // TextFormField(
          //   textCapitalization: TextCapitalization.none,
          //   decoration: InputDecoration(
          //     hintText: 'nama@email.com',
          //     // labelText: 'Email',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     errorText: !_isEmailValid ? 'Alamat email salah' : null,
          //   ),
          //   controller: textEmailOptik,
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       'Nama Penanggung Jawab di tempat',
          //       style: TextStyle(
          //         fontSize: 12,
          //         fontFamily: 'Segoe ui',
          //         fontWeight: FontWeight.w600,
          //         color: Colors.black,
          //       ),
          //     ),
          //     Text(
          //       '(wajib diisi)',
          //       style: TextStyle(
          //         fontSize: 12,
          //         fontFamily: 'Segoe ui',
          //         fontWeight: FontWeight.w600,
          //         // color: Colors.red[600],
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(
          //   height: 8,
          // ),
          // TextFormField(
          //   textCapitalization: TextCapitalization.characters,
          //   decoration: InputDecoration(
          //     hintText: 'John Doe',
          //     // labelText: 'Nama Penanggung Jawab di tempat',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     errorText: _isNamaPic ? 'Data wajib diisi' : null,
          //   ),
          //   controller: textPicOptik,
          // ),
          // SizedBox(
          //   height: 5,
          // ),
        ],
      ),
    );
  }