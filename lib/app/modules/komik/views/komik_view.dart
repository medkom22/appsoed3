import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:appsoed/app/routes/app_pages.dart';
import 'package:appsoed/app/modules/komik/bindings/komik_api_services.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/komik_controller.dart';
import '../model/komik_model.dart';

class KomikView extends GetView<KomikController> {
  const KomikView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          SliverAppBar(
              backgroundColor: Colors.white,
              leading: GestureDetector(
                  onTap: () => {Navigator.pop(context)},
                  child: Obx(() {
                    return Icon(
                        size: 30,
                        CupertinoIcons.back,
                        color: controller.appBarState.value ==
                                (AppBarState.expanded)
                            ? Colors.white
                            : Colors.black);
                  })
                  // ,
                  ),
              title: Obx(() {
                return controller.appBarState.value == (AppBarState.collapsed)
                    ? const Text(
                        "Komik",
                        style: TextStyle(color: Colors.black),
                      )
                    : Container();
              }),
              pinned: true,
              snap: false,
              floating: false,
              expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 183, 49, 1)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Komik",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Bacalah Komik terbaru kami",
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
            Stack(
              children: [
                Obx(() {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: controller.appBarState.value ==
                              (AppBarState.expanded)
                          ? const Color.fromRGBO(255, 183, 49, 1)
                          : Colors.white);
                }),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Column(children: [
                    Container(
                      width: 40,
                      height: 10,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: controller.appBarState.value ==
                                  AppBarState.expanded
                              ? const Color.fromRGBO(217, 217, 217, 1)
                              : Colors.transparent),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ComicBuilder()
                  ]),
                )
              ],
            )
          ]))
        ],
      ),
    );
  }
}

class ComicBuilder extends StatelessWidget {
  ComicBuilder({super.key});
  final ComicAPIService comicAPIService = ComicAPIService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: comicAPIService.getComics(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ComicLoadError();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const ComicsViewShimmer();
          } else if (snapshot.hasData) {
            return ComicsView(comics: snapshot.data);
          } else {
            return const Text("Komik tidak tersedia");
          }
        });
  }
}

class ComicLoadError extends StatelessWidget {
  const ComicLoadError({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset("assets/images/error.png")),
      const Text(
        "Terjadi Kesalahan",
        style: TextStyle(fontSize: 20),
      )
    ]);
  }
}

class ComicsView extends StatelessWidget {
  const ComicsView({super.key, required this.comics});
  final dynamic comics;

  @override
  Widget build(BuildContext context) {
    List<Comic> comicsDump = comics.toList();
    return Wrap(
        spacing: 25,
        runSpacing: 25,
        children: comicsDump.map((comic) {
          return ComicView(
            comic: comic,
          );
        }).toList());
  }
}

class ComicsViewShimmer extends StatelessWidget {
  const ComicsViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ComicViewShimmer(),
                SizedBox(
                  width: 20,
                ),
                ComicViewShimmer()
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ComicViewShimmer(),
                SizedBox(
                  width: 20,
                ),
                ComicViewShimmer()
              ],
            ),
          ]),
    );
  }
}

class ComicViewShimmer extends StatelessWidget {
  const ComicViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            width: Get.height / 4 * (3 / 4),
            height: Get.height / 4,
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            width: Get.height / 6 * (3 / 4),
            height: 20,
          )
        ],
      ),
    );
  }
}

class ComicView extends StatelessWidget {
  const ComicView({super.key, required this.comic});
  final Comic comic;
  @override
  Widget build(BuildContext context) {
    ComicAPIService comicAPIService = ComicAPIService();
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.DETAIL_KOMIK, arguments: comic);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: Container(
              color: const Color.fromRGBO(217, 217, 217, 1),
              width: Get.height / 4 * (3 / 4),
              height: Get.height / 4,
              child: Image.network(
                comicAPIService.getCoverUri(comic.cover),
                height: 120,
                width: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/comic_no_image.png');
                },
              )),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "${comic.title}",
          style: const TextStyle(fontWeight: FontWeight.w500),
        )
      ]),
    );
  }
}
