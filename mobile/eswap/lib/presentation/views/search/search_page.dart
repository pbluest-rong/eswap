import 'package:eswap/presentation/widgets/search.dart';
import 'package:eswap/presentation/views/home/search_filter_sort_provider.dart';
import 'package:eswap/presentation/views/home/explore.dart';
import 'package:eswap/presentation/views/search/search_user_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            AppSearch(onSearch: (keyword) {
              Provider.of<SearchFilterSortProvider>(context, listen: false)
                  .reset();
              if(keyword.isNotEmpty){
                Provider.of<SearchFilterSortProvider>(context, listen: false)
                    .updateKeyword(keyword);
                Navigator.pushNamed(context, ExplorePage.route);
              }
            }),
            SingleChildScrollView(
              child: Column(
                children: [],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
