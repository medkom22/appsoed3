import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:appsoed/app/modules/infokost/bindings/helper.dart';

// Mengambil data dari API
Future<dynamic> getKost(dynamic id) async {
  final url = 'https://api.bem-unsoed.com/api/kost/$id';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Something went wrong");
  }
}

Future<void> openMap(String url) async {
  if (!await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

Future<void> openInstagram() async {
  var url = "https://www.instagram.com/infokost.purwokerto/";
  if (!await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

Future<void> openWhatsApp(String owner, String kostName) async {
  String kost = kostName.capitalize();
  String phoneNumber = owner;
  String message =
      "Permisi, saya ingin bertanya ketersediaan kamar kost di *$kost*";
  final url = "https://wa.me/+62$phoneNumber?text=$message";
  if (!await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}

// Untuk Mengubah harga menjadi format rupiah
class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp. ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }
}

// ignore: must_be_immutable
class LocationKost extends StatefulWidget {
  LocationKost({super.key, required this.url});
  final String url;
  late List locs;
  @override
  State<LocationKost> createState() => _LocationKostState();
}

class _LocationKostState extends State<LocationKost> {
  @override
  Widget build(BuildContext context) {
    return const Text("Ini adalah bagian lokasis");
  }
}

// print(runtimeType())
class DetailKost extends StatefulWidget {
  const DetailKost({super.key, required this.id});
  final dynamic id;

  @override
  State<DetailKost> createState() => _DetailKostState();
}

enum AppBarState { expanded, collapsed }

class _DetailKostState extends State<DetailKost> {
  final ScrollController _scrollController = ScrollController();
  late AppBarState _appBarState;
  late int _currentImg;
  late dynamic kost;

  @override
  void initState() {
    super.initState();
    _appBarState = AppBarState.expanded;
    _currentImg = 1;
    _scrollController.addListener(_handleScroll);
    kost = getKost(widget.id);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.offset > 150 &&
        _appBarState == AppBarState.expanded) {
      setState(() {
        _appBarState = AppBarState.collapsed;
      });
    } else if (_scrollController.offset <= 150 &&
        _appBarState == AppBarState.collapsed) {
      setState(() {
        _appBarState = AppBarState.expanded;
      });
    }
  }

  Future<dynamic> displayKost() async {
    return kost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            title: _appBarState == AppBarState.collapsed
                ? FutureBuilder(
                    future: displayKost(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final String nameDump = snapshot.data['name'];
                        final String name = nameDump.capitalize();
                        return Text(
                          name,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 17),
                        );
                      } else if (snapshot.hasError) {
                        return Container();
                      } else {
                        return Container(); // Placeholder while loading
                      }
                    })
                : Container(),
            pinned: true,
            snap: false,
            floating: false,
            stretch: true,
            leading: GestureDetector(
              onTap: () => {Navigator.pop(context)},
              child: Icon(CupertinoIcons.back,
                  color: _appBarState == AppBarState.expanded
                      ? Colors.white
                      : Colors.black),
            ),
            expandedHeight: 250,
            flexibleSpace:
                Stack(alignment: AlignmentDirectional.bottomStart, children: [
              FlexibleSpaceBar(
                background: Stack(
                    alignment: AlignmentDirectional.bottomStart,
                    children: [
                      Builder(
                        builder: (context) {
                          final double height =
                              MediaQuery.of(context).size.height;
                          return FutureBuilder(
                              future: displayKost(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List images = snapshot.data['kost_images'];
                                  // Convert JSON to array

                                  List<String> imageList = images
                                      .map<String>(
                                          (image) => image['image'].toString())
                                      .toList();

                                  final String nameDump = snapshot.data['name'];
                                  final name = nameDump.capitalize();

                                  return CarouselSlider(
                                    options: CarouselOptions(
                                        height: height,
                                        viewportFraction: 1.0,
                                        enlargeCenterPage: false,
                                        initialPage: _currentImg - 1,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _currentImg = index + 1;
                                          });
                                        }
                                        // autoPlay: false,
                                        ),
                                    items: imageList
                                        .map((item) => InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewImage(
                                                                name: name,
                                                                images:
                                                                    imageList,
                                                                currentImage:
                                                                    _currentImg)));
                                              },
                                              child: (imageList.isNotEmpty)
                                                  ? Image.network(
                                                      "https://api.bem-unsoed.com/api/kost/image/$item",
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      fit: BoxFit.cover,
                                                      // height: height,
                                                    )
                                                  : Image.asset(
                                                      'asset/images/kost_no_image.png',
                                                      fit: BoxFit.cover,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                    ),
                                            ))
                                        .toList(),
                                  );
                                } else if (snapshot.hasError) {
                                  return Container();
                                } else {
                                  return Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        width: 600,
                                        height: 300,
                                        decoration: const BoxDecoration(
                                            color: Colors.black),
                                      ));
                                }
                              });
                        },
                      ),
                    ]),
              ),
              _appBarState == AppBarState.expanded
                  ? FutureBuilder(
                      future: displayKost(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var imgLength =
                              snapshot.data['kost_images'].length > 0
                                  ? snapshot.data['kost_images'].length
                                  : 1;
                          return ClipRRect(
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5)),
                                margin:
                                    const EdgeInsets.only(left: 10, bottom: 10),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 7),
                                child: Text("$_currentImg" "/$imgLength")),
                          );
                        } else if (snapshot.hasError) {
                          return Container();
                        } else {
                          return Container();
                        }
                      },
                    )
                  : Container()
            ]),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                  padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
                  child: FutureBuilder(
                    future: displayKost(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var kost = snapshot.data;

                        final String nameDump = kost['name'];
                        final name = nameDump.capitalize();
                        final type = kost['type'].toLowerCase();
                        final address = kost['address'] ?? '';
                        final location = kost['location'] ?? '';
                        final facilitiesDump = kost['kost_facilities'] ?? [];

                        // Convert JSON to array
                        List<String> facilities = facilitiesDump
                            .map<String>((fasilitas) =>
                                fasilitas['facility'].toString().capitalize())
                            .toList();

                        bool hasLocation = location != '' ? true : false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Judul
                            Text(
                              name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            //Jenis
                            Row(
                              children: [
                                type == 'l'
                                    ? const TypeKost(type: 'l')
                                    : Container(),
                                type == 'p'
                                    ? const TypeKost(type: 'p')
                                    : Container(),
                                type == 'campur'
                                    ? const TypeKost(type: 'campur')
                                    : Container(),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // Alamat
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.placemark,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                  child: Text(
                                    '$address',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromRGBO(0, 0, 0, 0.5),
                                        fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Divider(),

                            // Fasilitas
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Fasilitas",
                                  style: TextStyle(fontSize: 17),
                                ),
                                facilitiesDump == []
                                    ? const Text(
                                        "Fasilitas Terbaik Hanya untuk Anda!")
                                    : Container(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    children: facilities
                                        .map((facility) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2),
                                              child: Row(children: [
                                                Icon(
                                                  Icons.circle,
                                                  size: 5,
                                                  color: Colors.black
                                                      .withOpacity(0.6),
                                                ),
                                                const SizedBox(
                                                  width: 7,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    facility,
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.6),
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            ))
                                        .toList(),
                                  ),
                                )
                              ],
                            ),
                            // Lokasi
                            const SizedBox(
                              height: 10,
                            ),
                            hasLocation
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Lokasi",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () => {openMap(location)},
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 150,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Image.asset(
                                              'assets/images/location_kost.png',
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : Container(),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: GestureDetector(
                                  onTap: () {
                                    openInstagram();
                                  },
                                  child: RichText(
                                      text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: const [
                                        TextSpan(
                                            text: "Powered by : ",
                                            style: TextStyle(fontSize: 15)),
                                        TextSpan(
                                            text: "@infokost.purwokerto",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600))
                                      ]))),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset("assets/images/error.png")),
                            const Text(
                              "Terjadi Kesalahan",
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        );
                      } else {
                        return const ShimmerArea();
                      }
                    },
                  )),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]),
        child: BottomAppBar(
            height: 90,
            elevation: 0,
            child: FutureBuilder(
              future: displayKost(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final price = int.parse(snapshot.data['price_start']);
                  final owner = snapshot.data['owner'];
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              price != 0
                                  ? const Text(
                                      "Mulai dari :",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color.fromRGBO(0, 0, 0, 1)),
                                    )
                                  : const Text(
                                      "Harga Terbaik Hanya untuk Anda!",
                                      style: TextStyle(fontSize: 15),
                                    ),
                              Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    price != 0
                                        ? Text(
                                            CurrencyFormat.convertToIdr(
                                                price, 0),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Color.fromRGBO(
                                                    253, 183, 49, 1)),
                                          )
                                        : Container(),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        owner != '0'
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  onTap: () => openWhatsApp(
                                      snapshot.data['owner'],
                                      snapshot.data['name']),
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: const BoxDecoration(
                                          color:
                                              Color.fromRGBO(253, 183, 49, 1)),
                                      child: const Text(
                                        "Hubungi Pemilik",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      )),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Container();
                } else {
                  return const ShimmerBottom();
                }
              },
            )),
      ),
    );
  }
}

class TypeKost extends StatelessWidget {
  const TypeKost({super.key, required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    late String typeIn;
    late Color color;
    if (type.toLowerCase() == 'l') {
      typeIn = 'Pria';
      color = Colors.blue;
    } else if (type.toLowerCase() == 'p') {
      typeIn = 'Wanita';
      color = Colors.red;
    } else {
      typeIn = 'Campur';
      color = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 1, color: color)),
      child: Text(
        typeIn,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w300, fontSize: 13),
      ),
    );
  }
}

class ViewImage extends StatefulWidget {
  const ViewImage(
      {super.key,
      required this.name,
      required this.images,
      required this.currentImage});
  final List<String> images;
  final int currentImage;
  final String name;
  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
            onTap: () => {Navigator.pop(context)},
            child: const Icon(CupertinoIcons.back, color: Colors.white)),
        title: Text(widget.name, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            final double height = MediaQuery.of(context).size.height;

            return CarouselSlider(
              options: CarouselOptions(
                height: height,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                initialPage: widget.currentImage - 1,
              ),
              items: widget.images
                  .map((item) => Center(
                          child: Image.network(
                        "https://api.bem-unsoed.com/api/kost/image/$item",
                        fit: BoxFit.cover,
                      )))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  const ShimmerContainer(
      {super.key, required this.width, required this.height});
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(20)),
      width: width,
      height: height,
    );
  }
}

class ShimmerArea extends StatelessWidget {
  const ShimmerArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerContainer(width: 200, height: 25),
            const SizedBox(
              height: 10,
            ),
            //Jenis
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  width: 50,
                  height: 20,
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  width: 50,
                  height: 20,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            // // Alamat
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  width: 60,
                  height: 60,
                ),
                const SizedBox(
                  width: 15,
                ),
                const Expanded(
                    child: Column(children: [
                  ShimmerContainer(
                    width: 300,
                    height: 15,
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  ShimmerContainer(
                    width: 300,
                    height: 15,
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  ShimmerContainer(
                    width: 300,
                    height: 15,
                  )
                ]))
              ],
            ),
            const Divider(),

            // // Fasilitas
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(
                  height: 17,
                  width: 80,
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(children: [
                    ShimmerContainer(width: 120, height: 12),
                    SizedBox(
                      height: 7,
                    ),
                    ShimmerContainer(width: 120, height: 12),
                    SizedBox(
                      height: 7,
                    ),
                    ShimmerContainer(width: 120, height: 12),
                    SizedBox(
                      height: 7,
                    ),
                    ShimmerContainer(width: 120, height: 12)
                  ]),
                )
              ],
            ),
            // // Lokasi
            const SizedBox(
              height: 10,
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(
                  height: 17,
                  width: 80,
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                    child: ShimmerContainer(
                  height: 150,
                  width: 300,
                ))
              ],
            ),
          ],
        ));
  }
}

class ShimmerBottom extends StatelessWidget {
  const ShimmerBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(
                  width: 100,
                  height: 15,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerContainer(
                        width: 100,
                        height: 15,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const ShimmerContainer(
                width: 60,
                height: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
