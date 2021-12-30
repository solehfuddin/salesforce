import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/domain/entities/intro.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final List<ModelIntro> introList = [
    ModelIntro(
      image: "assets/images/icon_search.png",
      title: "Search",
      description: "Dapat melakukan pencarian data dengan cepat",
    ),
    ModelIntro(
      image: "assets/images/icon_hamburger.png",
      title: "Favorite Menu",
      description: "Dapatkan makanan cepat saji terbaik",
    ),
    ModelIntro(
      image: "assets/images/icon_otw.png",
      title: "Free Delivery",
      description: "Dengan biaya pengiriman gratis",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Swiper.children(
        index: 0,
        autoplay: false,
        loop: false,
        pagination: SwiperPagination(
          margin: EdgeInsets.only(bottom: 10),
          builder: DotSwiperPaginationBuilder(
              color: MyColors.dotColor,
              activeColor: MyColors.dotActiveColor,
              size: 10,
              activeSize: 10),
        ),
        control: SwiperControl(iconNext: null, iconPrevious: null),
        children: _buildPage(context),
      ),
    );
  }

  List<Widget> _buildPage(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < introList.length; i++) {
      ModelIntro mIntro = introList[i];
      widgets.add(
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 6,
          ),
          child: ListView(
            children: <Widget>[
              Image.asset(
                mIntro.image,
                height: MediaQuery.of(context).size.height / 3.5,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 12,
                ),
              ),
              Center(
                child: Text(
                  mIntro.title,
                  style: TextStyle(
                    color: MyColors.titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 20,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height / 20,
                ),
                child: Text(
                  mIntro.description,
                  style: TextStyle(
                    color: MyColors.desciptionColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}
