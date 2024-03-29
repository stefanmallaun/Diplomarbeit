import 'package:flutter/material.dart';
import 'package:earthwise/Pages/QuizPages/Mapquiz/map/country.dart';
import 'package:earthwise/Server/internet.dart';
import 'package:earthwise/Datenbank/quiz_data.dart';
import 'package:earthwise/router/route_constants.dart';

// This class represents the search page.
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// This class represents the state of the search page.
class _SearchPageState extends State<SearchPage> {
  final List<Map> continents = [
    {"name": Continent.northAmerica, "icon": "assets/icons/north_america.svg"},
    {"name": Continent.southAmerica, "icon": "assets/icons/south_america.svg"},
    {"name": Continent.europe, "icon": "assets/icons/europe.svg"},
    {"name": Continent.africa, "icon": "assets/icons/africa.svg"},
    {"name": Continent.asia, "icon": "assets/icons/asia.svg"},
    {"name": Continent.oceania, "icon": "assets/icons/australia.svg"}
  ];

  String searchValue = '';
  TextEditingController textController = TextEditingController();
  FocusNode focusController = FocusNode();

  final List<String> suggestions = getAllQuizTitles();
  List<String> displayList = getAllQuizTitles();

  double suggestionsHeight = 0;

  @override
  void initState() {
    super.initState();
    loadSuggestions();
  }

  // Loads suggestions asynchronously.
  void loadSuggestions() async {
    List<String> loadedSuggestions = getAllQuizTitles();
    setState(() {
      suggestions.addAll(loadedSuggestions);
      displayList.addAll(loadedSuggestions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 10, 199, 196),
              Color.fromARGB(255, 4, 2, 104),
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Text(
                    "EARTHWISE",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.05,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: searchBar(context)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                child: displayList.isEmpty
                    ? const Center(
                        child: Text(
                          "No Result found!",
                        ),
                      )
                    : displaySuggestions(context),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  // Builds the search bar widget.
  Widget searchBar(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.pink,
                Colors.purple,
              ],
            ),
          ),
          child: TextField(
            focusNode: focusController,
            controller: textController,
            onChanged: (value) => updateList(value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              hintText: "e.g. All countries in the world",
              hintStyle:
                  const TextStyle(color: Color.fromARGB(255, 220, 218, 218)),
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  focusController.requestFocus();
                  textController.clear();
                },
              ),
              prefixIconColor: const Color.fromARGB(255, 227, 227, 227),
            ),
          ),
        ),
      ],
    );
  }

  // Displays the suggestions based on the search query.
  Widget displaySuggestions(BuildContext context) {
    return ListView.builder(
      itemCount: displayList.length,
      padding: const EdgeInsets.all(0),
      itemBuilder: (context, index) => ListTile(
        title: buildItem(displayList[index]),
        onTap: () {
          buildSearchedQuestion(context, displayList[index]);
        },
      ),
    );
  }

  // Builds the individual suggestion item.
  Widget buildItem(String title) {
    QuizType? d = getQuizType(title);
    if (d != null) {
      return Card(
        margin: const EdgeInsets.all(0),
        elevation: 5,
        color: Colors.white30,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              Image.asset(
                getIconOfType(d),
                height: 50,
              ),
            ],
          ),
        ),
      );
    }
    return const Text("");
  }

  // Returns the icon asset based on the quiz type.
  String getIconOfType(QuizType type) {
    String basis = "assets/icons/";
    switch (type) {
      case QuizType.flagquiz:
        return "${basis}flag.png";
      case QuizType.mapquiz:
        return "${basis}map.png";
      case QuizType.tablequiz:
        return "${basis}city.png";
      default:
    }
    return "${basis}flag";
  }

  // Updates the displayed list based on the search value.
  void updateList(String value) {
    setState(() {
      List<String> list = suggestions
          .where((term) => term.toLowerCase().contains(value.toLowerCase()))
          .toList();

      Set<String> setOhneDuplikate = list.toSet();

      displayList = setOhneDuplikate.toList();
    });
  }

  // Builds the searched question based on the title.
  void buildSearchedQuestion(BuildContext context, String title) {
    Continent? cont = getContinentFromString(title);
    QuizType? type = getQuizType(title);
    if ((cont != null) || (type != null)) {
      Continent continent = cont!;
      if (type == QuizType.flagquiz) {
        Navigator.pushNamed(context, guessAllRoute, arguments: continent);
      }
      if (type == QuizType.mapquiz) {
        Navigator.pushNamed(context, worldMapRoute, arguments: continent);
      }
      if (type == QuizType.tablequiz) {
        Navigator.pushNamed(context, tableQuizRoute, arguments: continent);
      }
    } else {
      noInternetPopUp(context, "Error", "Das Quiz konnte nicht geladen werden");
    }
  }

  // Retrieves the continent from the given string.
  Continent? getContinentFromString(String text) {
    List<String> words = text.toLowerCase().split(" ");
    if (words.contains("world")) {
      return Continent.world;
    }
    if (words.contains("america")) {
      if (words.contains("south")) {
        return Continent.southAmerica;
      }
      if (words.contains("north")) {
        return Continent.northAmerica;
      }
    }
    if (words.contains("europe")) {
      return Continent.europe;
    }
    if (words.contains("africa")) {
      return Continent.africa;
    }
    if (words.contains("oceania")) {
      return Continent.oceania;
    }
    if (words.contains("asia")) {
      return Continent.asia;
    }
    return null;
  }
}

// Retrieves the quiz type from the given title.
QuizType? getQuizType(String title) {
  List<QuizData> quizzes = getAllData();
  for (QuizData quiz in quizzes) {
    if (quiz.name.toLowerCase() == title.toLowerCase()) {
      return quiz.type;
    }
  }
  return null;
}
