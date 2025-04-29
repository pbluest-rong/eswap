import 'package:eswap/presentation/widgets/search.dart';
import 'package:eswap/presentation/views/home/search_filter_sort_provider.dart';
import 'package:eswap/presentation/views/home/explore.dart';
import 'package:eswap/presentation/views/search/search_user_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> _recentKeywords = [];

  @override
  void initState() {
    super.initState();
    _loadRecentKeywords();
  }

  Future<void> _loadRecentKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentKeywords = prefs.getStringList('recent_keywords') ?? [];
    });
  }

  Future<void> _saveKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedKeywords = List.from(_recentKeywords);

    updatedKeywords.remove(keyword);
    updatedKeywords.insert(0, keyword);

    if (updatedKeywords.length > 10) {
      updatedKeywords = updatedKeywords.sublist(0, 10);
    }

    await prefs.setStringList('recent_keywords', updatedKeywords);
    setState(() {
      _recentKeywords = updatedKeywords;
    });
  }

  Future<void> _deleteKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedKeywords = List.from(_recentKeywords);

    updatedKeywords.remove(keyword);

    await prefs.setStringList('recent_keywords', updatedKeywords);
    setState(() {
      _recentKeywords = updatedKeywords;
    });
  }

  void _onSearch(String keyword) {
    Provider.of<SearchFilterSortProvider>(context, listen: false).reset();
    if (keyword.isNotEmpty) {
      _saveKeyword(keyword);
      Provider.of<SearchFilterSortProvider>(context, listen: false)
          .updateKeyword(keyword);
      Navigator.pushNamed(context, ExplorePage.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSearch(onSearch: _onSearch),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _recentKeywords.length,
                itemBuilder: (context, index) {
                  final keyword = _recentKeywords[index];
                  return ListTile(
                    leading: Icon(Icons.history),
                    title: Text(keyword),
                    onTap: () => _onSearch(keyword),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey,
                      ),
                      onPressed: () => _deleteKeyword(keyword),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}
