import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/cashback_rekening.dart';
import 'package:sample/src/domain/service/service_cashback.dart';

// ignore: must_be_immutable
class CashbackOldRekening extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  bool isHorizontal = false;
  String noAccount = '';
  CashbackOldRekening({
    Key? key,
    required this.updateParent,
    required this.isHorizontal,
    required this.noAccount,
  }) : super(key: key);

  @override
  State<CashbackOldRekening> createState() => _CashbackOldRekeningState();
}

class _CashbackOldRekeningState extends State<CashbackOldRekening> {
  ServiceCashback serviceCashback = new ServiceCashback();
  Future<List<CashbackRekening>>? _listRekening;
  CashbackRekening selectedRekening = new CashbackRekening();
  String search = "";

  @override
  void initState() {
    super.initState();
    getOldRekening(noAccount: widget.noAccount, search: search);
  }

  getOldRekening({required String noAccount, required String search}) {
    _listRekening = serviceCashback.getRekening(
      context,
      isMounted: mounted,
      noAccount: noAccount,
      search: search,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 350.w,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isHorizontal ? 10.r : 5.r,
              vertical: widget.isHorizontal ? 20.r : 10.r,
            ),
            color: Colors.white,
            height: 80.h,
            child: TextField(
              textInputAction: TextInputAction.search,
              autocorrect: true,
              decoration: InputDecoration(
                hintText: 'Pencarian Data ...',
                prefixIcon: Icon(Icons.search),
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
                filled: true,
                fillColor: Colors.white70,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 3.r,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      12.r,
                    ),
                  ),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 2.r,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      10.r,
                    ),
                  ),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.r,
                  ),
                ),
              ),
              onSubmitted: (value) {
                search = value;
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 100.h,
              child: FutureBuilder(
                future: _listRekening,
                builder:
                    (context, AsyncSnapshot<List<CashbackRekening>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      return snapshot.data!.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Image.asset(
                                    'assets/images/not_found.png',
                                    width: widget.isHorizontal ? 100.w : 180.w,
                                    height: widget.isHorizontal ? 100.h : 180.h,
                                  ),
                                ),
                                Text(
                                  'Data tidak ditemukan',
                                  style: TextStyle(
                                    fontSize:
                                        widget.isHorizontal ? 15.sp : 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[600],
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            )
                          : itemOldRekening(snapshot.data!);
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20.r,
              vertical: 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Batal',
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    print("Selected Rekening : ${selectedRekening.idRekening}");
                    widget.updateParent("updateNewRekening", selectedRekening);

                    Navigator.pop(context);
                  },
                  child: Text(
                    'Pilih',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget itemOldRekening(List<CashbackRekening> item) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        width: double.minPositive.w,
        height: 350.h,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: item.length,
          itemBuilder: (BuildContext context, int index) {
            String _key =
                "${capitalize(item[index].namaRekening!)} (${capitalize(item[index].bankName!)})";
            String _type = "No Rek : ${item[index].nomorRekening!}";
            return InkWell(
              onTap: () {
                setState(() {
                  item.forEach((element) {
                    element.isChecked = false;
                  });
                  item[index].isChecked = true;
                  selectedRekening = item[index];
                });
              },
              child: ListTile(
                title: Text(_key),
                subtitle: Text(
                  _type,
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                trailing: Visibility(
                  visible: item[index].isChecked,
                  child: Icon(
                    Icons.check,
                    color: Colors.blue.shade700,
                    size: 22.r,
                  ),
                  replacement: SizedBox(
                    width: 5.w,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
