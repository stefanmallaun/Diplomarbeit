import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:earthwise/Pages/QuizPages/Mapquiz/map/country.dart';

import 'package:earthwise/router/route_constants.dart';

// Widget for selecting quiz types based on the continent
class SelectionPage extends StatefulWidget {
  const SelectionPage({Key? key, required this.continent}) : super(key: key);

  final Continent continent;

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  final Map<Continent, String> continents = {
    Continent.northAmerica: "assets/icons/north_america.svg",
    Continent.southAmerica: "assets/icons/south_america.svg",
    Continent.europe: "assets/icons/europe.svg",
    Continent.africa: "assets/icons/africa.svg",
    Continent.asia: "assets/icons/asia.svg",
    Continent.oceania: "assets/icons/australia.svg",
    Continent.world: "assets/icons/world.svg",
  };

  final Color buttonColour = Colors.white30;
  final Color iconColour = const Color.fromARGB(200, 255, 255, 255);
  late double height;

  List<String> routes = [
    tableQuizRoute,
    worldMapRoute,
    prepareMCQRoute,
    guessAllRoute
  ];
  String basis = "assets/icons/";

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Choose a Quiztype",
              style: TextStyle(color: Colors.white)),
          backgroundColor:
              Colors.transparent, // Make AppBar background transparent
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        extendBodyBehindAppBar:
            true, // Let Body content start behind the AppBar

        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 10, 199, 196), // Start color
                Color.fromARGB(255, 4, 2, 104),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                child: Column(
                  children: [
                    SizedBox(height: height * 0.1),
                    SvgPicture.asset(
                      continents[widget.continent]!,
                      width: double.infinity,
                      height: height * 0.27,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    Text(
                      getNameofContinent(widget.continent),
                      style: const TextStyle(
                          fontSize: 35,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ],
                ),
              ),
              // Use Expanded directly inside the Column
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                padding: const EdgeInsets.all(
                    16.0), // Set padding around the GridView here

                mainAxisSpacing: 16.0,
                children: List.generate(
                  4,
                  (index) {
                    return Card(
                      elevation: 4,
                      color: buttonColour,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, routes[index],
                              arguments: widget.continent);
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  [
                                    "${basis}city.png",
                                    "${basis}map.png",
                                    "${basis}mc.png",
                                    "${basis}flag.png"
                                  ][index],
                                  height: height * 0.085, // Size of the icon
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  [
                                    "Capitals",
                                    "Countries",
                                    "Multiple Choice",
                                    "Flags"
                                  ][index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: iconColour,
                                    fontSize: height * 0.023,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
