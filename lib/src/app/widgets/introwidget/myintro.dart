import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sample/src/app/utils/colors.dart';

@immutable
class MyIntroData extends StatelessWidget {
  ///This is a builder for an intro screen
  ///
  ///
  /// title of your slide
  ///[String]
  final String title;

  ///description of your slide
  ///[String]
  final String description;

  ///image path for your slide
  ///[String]
  final String imageAsset;

  ///textStyle for your slide
  ///[TextStyle]
  final TextStyle textStyle;

  ///background color for your slide header
  ///[Color]
  final Color headerBgColor;

  ///padding for the your slide header
  ///[EdgeInsets]
  final EdgeInsets headerPadding;

  ///widget to use as the header part of your screen
  ///[Widget]
  final Widget header;
  final isHorizontal;

  int _pageIndex;

  MyIntroData({
    this.isHorizontal,
    @required this.title,
    this.headerPadding = const EdgeInsets.all(12),
    @required this.description,
    this.header,
    this.headerBgColor = Colors.white,
    this.textStyle,
    this.imageAsset,
  })  : assert(title != null),
        assert(description != null),
        assert(title != null);

  set index(val) => this._pageIndex = val;

  TextStyle get textStyles =>
      textStyle ??
      GoogleFonts.lato(
          fontSize: 18,
          color: MyColors.textColor,
          fontWeight: FontWeight.normal);

  @override
  Widget build(BuildContext context) {
    var widthSize = MediaQuery.of(context).size.width;
    var screenSize = MediaQuery.of(context).size;
    return Container(
      width: isHorizontal ? widthSize / 2 : double.infinity,
      height: screenSize.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: isHorizontal
                ? screenSize.height - 50
                : screenSize.height * .666,
            child: isHorizontal
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      imageAsset != null
                          ? Image.asset(
                              imageAsset,
                              fit: BoxFit.cover,
                              width: widthSize / 2,
                              height: screenSize.height,
                            )
                          : this.header ??
                              Container(
                                child: Text(
                                  "${this._pageIndex ?? 1}",
                                  style: TextStyle(
                                      fontSize: 300,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 7,
                            ),
                            Text(
                              title,
                              softWrap: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyles?.apply(
                                color: MyColors.textColor,
                                fontWeightDelta: 12,
                                fontSizeDelta: 10,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                description,
                                style: textStyles?.apply(
                                  color: MyColors.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: imageAsset != null
                        ? Image.asset(
                            imageAsset,
                            fit: BoxFit.cover,
                            width: widthSize,
                            height: screenSize.height,
                          )
                        : this.header ??
                            Container(
                              child: Text(
                                "${this._pageIndex ?? 1}",
                                style: TextStyle(
                                    fontSize: 300, fontWeight: FontWeight.w900),
                              ),
                            ),
                  ),
          ),
        ],
      ),
    );
  }
}
