import 'package:appsoed/app/modules/infokost/bindings/helper.dart';
import 'package:appsoed/app/modules/infokost/views/kost_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> getKosts() async {
  const url = 'https://api.bem-unsoed.com/api/kost';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Something went wrong");
  }
}

class ListKost extends StatefulWidget {
  const ListKost({super.key});

  @override
  State<ListKost> createState() => _ListKostState();
}

class _ListKostState extends State<ListKost> {
  final ScrollController _scrollController = ScrollController();
  late AppBarState _appBarState;

  @override
  void initState() {
    super.initState();
    _appBarState = AppBarState.expanded;
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.offset > 130 &&
        _appBarState == AppBarState.expanded) {
      setState(() {
        _appBarState = AppBarState.collapsed;
      });
    } else if (_scrollController.offset <= 130 &&
        _appBarState == AppBarState.collapsed) {
      setState(() {
        _appBarState = AppBarState.expanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
              backgroundColor: const Color.fromRGBO(241, 239, 239, 1),
              elevation: 1,
              leading: GestureDetector(
                onTap: () => {Navigator.pop(context)},
                child: Icon(
                    size: 30,
                    CupertinoIcons.back,
                    color: _appBarState == AppBarState.collapsed
                        ? Colors.black
                        : Colors.white),
              ),
              title: _appBarState == AppBarState.collapsed
                  ? const Text(
                      "Info Kost",
                      style: TextStyle(color: Colors.black),
                    )
                  : Container(),
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 183, 49, 1)),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20, top: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Lagi Cari Kos - Kosan ?",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Coba liat-liat dulu sini",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
              )),
          SliverList(
              delegate: SliverChildListDelegate([
            Container(
              color: const Color.fromRGBO(241, 239, 239, 1),
              child: Stack(
                children: [
                  Container(
                      color: _appBarState == AppBarState.expanded
                          ? const Color.fromRGBO(255, 183, 49, 1)
                          : Colors.transparent,
                      height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Container(
                        alignment: Alignment.topCenter,
                        // padding: const EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _appBarState == AppBarState.expanded
                                ? Colors.white
                                : const Color.fromRGBO(241, 239, 239, 1)),
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Container(
                                  width: 40,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          _appBarState == AppBarState.expanded
                                              ? const Color.fromRGBO(
                                                  217, 217, 217, 1)
                                              : Colors.transparent),
                                ),
                              ),
                              const KostDatas()
                            ],
                          ),
                        )),
                  )
                ],
              ),
            ),
          ]))
        ],
      ),
    );
  }
}

class KostDatas extends StatelessWidget {
  const KostDatas({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getKosts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Kosts(kosts: snapshot.data);
        } else if (snapshot.hasError) {
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset("assets/images/error.png")),
            const Text(
              "Terjadi Kesalahan",
              style: TextStyle(fontSize: 20),
            )
          ]);
        } else {
          return const Column(
            children: [
              KostsShimmer(),
              SizedBox(
                height: 25,
              ),
              KostsShimmer()
            ],
          );
        }
      },
    );
  }
}

class KostsShimmer extends StatelessWidget {
  const KostsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerContainer(
              width: MediaQuery.of(context).size.width, height: 150),
          const SizedBox(
            height: 10,
          ),
          const ShimmerContainer(
            width: 150,
            height: 30,
          ),
          const SizedBox(height: 5),
          const ShimmerContainer(height: 25, width: 120),
          const SizedBox(height: 5),
          const Row(children: [
            ShimmerContainer(
              height: 20,
              width: 50,
            ),
            SizedBox(width: 10),
            ShimmerContainer(
              height: 20,
              width: 50,
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(child: ShimmerContainer(width: 80, height: 20))
          ])
        ],
      ),
    );
  }
}

class Kosts extends StatelessWidget {
  const Kosts({super.key, required this.kosts});
  final List<dynamic> kosts;
  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 10,
        runSpacing: 30,
        children: kosts.map((kost) {
          return Kost(
            id: kost['id'],
            name: kost['name'],
            images: kost['kost_images'],
            region: kost['region'],
            type: kost['type'].toLowerCase(),
            priceStart: int.parse(kost['price_start']),
          );
        }).toList());
  }
}

// ignore: must_be_immutable
class Kost extends StatelessWidget {
  const Kost(
      {super.key,
      required this.id,
      required this.name,
      required this.images,
      required this.region,
      required this.priceStart,
      required this.type});

  final dynamic id;
  final String name;
  final List images;
  final String region;
  final int priceStart;
  final String type;

  @override
  Widget build(BuildContext context) {
    bool hasPrice = priceStart > 0 ? true : false;
    bool hasImages = images.isNotEmpty ? true : false;

    // Convert JSON to array
    List<String> imageList =
        images.map<String>((image) => image['image'].toString()).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () => {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DetailKost(id: id)))
        },
        child: Container(
          color: Colors.white,
          // padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: hasImages
                  ? Image.network(
                      "https://api.bem-unsoed.com/api/kost/image/${imageList[0]}",
                      fit: BoxFit.cover,
                    )
                  : Image.asset('assets/images/kost_no_image.png',
                      fit: BoxFit.cover),
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              padding: const EdgeInsets.only(
                  bottom: 20, left: 15, right: 15, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.capitalize(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.placemark,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                  size: 15,
                                ),
                                Text(
                                  region.capitalize(),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: Color.fromRGBO(0, 0, 0, 0.5)),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Wrap(
                              runSpacing: 7,
                              children: [
                                type == 'l'
                                    ? const TypeKost(type: "L")
                                    : Container(),
                                type == 'p'
                                    ? const TypeKost(type: "P")
                                    : Container(),
                                type == 'campur'
                                    ? const TypeKost(type: "Campur")
                                    : Container()
                              ],
                            )
                          ],
                        ),
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            hasPrice
                                ? const Text(
                                    "Mulai dari ",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color.fromRGBO(0, 0, 0, 0.7),
                                        fontWeight: FontWeight.w300),
                                  )
                                : Container(),
                            const SizedBox(
                              height: 5,
                            ),
                            hasPrice
                                ? Text(
                                    CurrencyFormat.convertToIdr(priceStart, 0),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  )
                                : Container(),
                          ])
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
