import 'package:flutter/material.dart';
import 'package:grupomarrom20211/const/cards.dart';

class SearchCountry extends SearchDelegate<String> {
  var amordemae = InfoCountry().countryName;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(onPressed: () {}, icon: Icon(Icons.clear))];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        // close(context, null);
      },
      icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty ? [] : amordemae;
    return ListView.builder(
      itemBuilder: (context, index) => Text(
        suggestionList[index],
      ),
      itemCount: suggestionList.length,
    );
  }
}
