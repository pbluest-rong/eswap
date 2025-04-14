import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/utils/enums.dart';
import 'package:eswap/core/utils/validation.dart';
import 'package:eswap/view/login/login_page.dart';
import 'package:eswap/view/signup/signup_dob_page.dart';
import 'package:eswap/view/signup/signup_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';

class SignUpEducationPage extends StatefulWidget {
  const SignUpEducationPage({super.key});

  @override
  State<SignUpEducationPage> createState() => _SignUpEducationPageState();
}

class _SignUpEducationPageState extends State<SignUpEducationPage> {
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();

  List<SearchFieldListItem<String>> _provinceSuggestions = [];
  List<SearchFieldListItem<String>> _institutionSuggestions = [];
  String? selectedProvinceId;
  String? selectedInstitutionId;
  String? selectedInstitutionType;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<List<Map<String, dynamic>>> fetchProvinces() async
  {
    try {
      final dio = Dio();
      final response = await dio.get(ServerInfo.getProvinces_url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('API returned unsuccessful response');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchInstitutions(
      String provinceId, String? institutionType) async
  {
    try {
      final dio = Dio();
      final String url = institutionType != null
          ? '${ServerInfo.getProvinces_url}/$provinceId/type?institutionType=$institutionType'
          : '${ServerInfo.getProvinces_url}/$provinceId';

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('API returned unsuccessful response');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> _loadProvinces() async
  {
    try {
      final provinces = await fetchProvinces();
      setState(() {
        _provinceSuggestions = provinces.map((province) {
          return SearchFieldListItem<String>(
            province['name'],
            item: province['id'], // Lưu provinceId vào item
            child: Text(province['name']),
          );
        }).toList();
      });
    } catch (e) {
      e.toString();
    }
  }

  Future<void> _loadInstitutions(
      String provinceId, String? institutionType) async
  {
    try {
      final institutions = await fetchInstitutions(provinceId, institutionType);
      setState(() {
        _institutionSuggestions = institutions.map((institution) {
          return SearchFieldListItem<String>(
            institution['name'],
            item: institution['id'].toString(),
            child: Text(institution['name']),
          );
        }).toList();
      });
    } catch (e) {
      e.toString();
    }
  }

  final Map<String, String> institutionTypeMap = {
    'HIGH_SCHOOL': 'high_school'.tr(),
    'COLLEGE': 'college'.tr(),
    'UNIVERSITY': 'university'.tr(),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "signup_question_2".tr(),
                              style: textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "signup_question_2_desc".tr(),
                              style: textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 32),
                        child: SearchField<String>(
                          controller: provinceController,
                          suggestions: _provinceSuggestions,
                          hint: 'search_province'.tr(),
                          validator: ValidationUtils.validateEmpty,
                          searchInputDecoration: SearchInputDecoration(
                            labelText: "province".tr(),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                            ),
                          ),
                          onSuggestionTap: (value) {
                            if (value.item != null) {
                              setState(() {
                                selectedProvinceId = value.item;
                                _loadInstitutions(selectedProvinceId!,
                                    selectedInstitutionType);
                              });
                            }
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 16),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButton<String>(
                          value: selectedInstitutionType,
                          hint: Text('select_institution_type').tr(),
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedInstitutionType = newValue;
                              if (selectedProvinceId != null) {
                                _loadInstitutions(selectedProvinceId!,
                                    selectedInstitutionType);
                              }
                            });
                          },
                          items: institutionTypeMap.entries
                              .map<DropdownMenuItem<String>>((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 32),
                        child: SearchField<String>(
                          controller: institutionController,
                          suggestions: _institutionSuggestions,
                          hint: 'search_institution'.tr(),
                          validator: ValidationUtils.validateEmpty,
                          searchInputDecoration: SearchInputDecoration(
                            labelText: "education_institution".tr(),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2.0),
                            ),
                          ),
                          onSuggestionTap: (value) {
                            if (value.item != null) {
                              setState(() {
                                selectedInstitutionId = value.item;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedInstitutionId != null) {
                              Provider.of<SignupProvider>(context,
                                      listen: false)
                                  .updateEducationInstitutionId(
                                      int.parse(selectedInstitutionId!));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpBirthdayPage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('alert_null_value'.tr(args: ["education_institution".tr()]))),
                              );
                            }
                          }, // Gọi next()
                          child: Text(
                            "next".tr(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: RichText(
                text: TextSpan(
                  text: "signup_bottom".tr(),
                  style: TextStyle(
                    color: const Color(0xFF1F41BB),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
