import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/core/onboarding/onboarding_page_position.dart';
import 'package:eswap/model/education_institution_model.dart';
import 'package:eswap/model/province_model.dart';
import 'package:eswap/service/education_instiitution_service.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class InstitutionSelectionDialog extends StatefulWidget {
  bool? isNationwide;

  InstitutionSelectionDialog({super.key, this.isNationwide = false});

  @override
  State<InstitutionSelectionDialog> createState() =>
      _InstitutionSelectionDialogState();
}

class _InstitutionSelectionDialogState
    extends State<InstitutionSelectionDialog> {
  final EducationInstitutionService educationInstitutionService =
      EducationInstitutionService();

  final TextEditingController provinceController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();

  List<SearchFieldListItem<String>> _provinceSuggestions = [];
  List<SearchFieldListItem<EducationInstitution>> _institutionSuggestions = [];
  String? selectedProvinceId;
  String? selectedProvinceName;
  String? selectedInstitutionType;
  bool isNationwide = false;

  final Map<String, String> institutionTypeMap = {
    'HIGH_SCHOOL': 'high_school'.tr(),
    'COLLEGE': 'college'.tr(),
    'UNIVERSITY': 'university'.tr(),
  };

  @override
  void initState() {
    super.initState();
    if (widget.isNationwide != null) {
      isNationwide = widget.isNationwide!;
    }
    _loadProvinces();
  }

  @override
  void dispose() {
    provinceController.dispose();
    institutionController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    try {
      final provinces = await educationInstitutionService.fetchProvinces();
      setState(() {
        _provinceSuggestions = provinces.map((province) {
          return SearchFieldListItem<String>(
            province.name,
            item: province.id,
            child: Text(province.name),
          );
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load provinces: $e')),
      );
    }
  }

  Future<void> _loadInstitutions(
      String provinceId, String? institutionType) async {
    try {
      final institutions = await educationInstitutionService.fetchInstitutions(
          provinceId, institutionType);
      setState(() {
        _institutionSuggestions = institutions.map((institution) {
          return SearchFieldListItem<EducationInstitution>(
            institution.name,
            item: institution,
            child: Text(institution.name),
          );
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load institutions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.7;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: dialogHeight,
          minWidth: double.infinity,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nationwide checkbox
                if (isNationwide)
                  InkWell(
                    onTap: () {
                      setState(() {
                        isNationwide = !isNationwide;
                        if (isNationwide) {
                          provinceController.clear();
                          institutionController.clear();
                          selectedProvinceId = null;
                          selectedProvinceName = null;
                          selectedInstitutionType = null;
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isNationwide,
                            onChanged: (bool? value) {
                              setState(() {
                                isNationwide = value!;
                                if (isNationwide) {
                                  provinceController.clear();
                                  institutionController.clear();
                                  selectedProvinceId = null;
                                  selectedProvinceName = null;
                                  selectedInstitutionType = null;
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          Text("nationwide".tr()),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                AbsorbPointer(
                  absorbing: isNationwide,
                  child: Opacity(
                    opacity: isNationwide ? 0.6 : 1.0,
                    child: SearchField<String>(
                      controller: provinceController,
                      suggestions: _provinceSuggestions,
                      hint: "search_province".tr(),
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
                            selectedProvinceName = value.searchKey;
                            institutionController.clear();
                            _loadInstitutions(
                                selectedProvinceId!, selectedInstitutionType);
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Institution type dropdown
                AbsorbPointer(
                  absorbing: isNationwide,
                  child: Opacity(
                    opacity: isNationwide ? 0.6 : 1.0,
                    child: DropdownButtonFormField<String>(
                      value: selectedInstitutionType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      hint: Text("select_institution_type".tr()),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedInstitutionType = newValue;
                          if (selectedProvinceId != null) {
                            institutionController.clear();
                            _loadInstitutions(
                                selectedProvinceId!, selectedInstitutionType);
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
                ),

                const SizedBox(height: 16),

                // Institution search field
                AbsorbPointer(
                  absorbing: isNationwide,
                  child: Opacity(
                    opacity: isNationwide ? 0.6 : 1.0,
                    child: SearchField<EducationInstitution>(
                      controller: institutionController,
                      suggestions: _institutionSuggestions,
                      hint: "search_institution".tr(),
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
                            institutionController.text = value.item!.name;
                          });
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "cancel".tr(),
                        style: textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        if (isNationwide) {
                          Navigator.pop(context, {
                            'isNationwide': isNationwide,
                          });
                        } else {
                          final selectedItem =
                              _institutionSuggestions.firstWhere(
                            (item) =>
                                item.item?.name == institutionController.text,
                            orElse: () =>
                                SearchFieldListItem<EducationInstitution>(''),
                          );

                          final institution = selectedItem.item;
                          if (institution != null) {
                            Navigator.pop(context, {
                              'isNationwide': isNationwide,
                              'isProvince': false,
                              'educationInstitutionId': institution.id,
                              'educationInstitutionName': institution.name,
                            });
                          } else if (selectedProvinceId != null) {
                            Navigator.pop(context, {
                              'isNationwide': isNationwide,
                              'isProvince': true,
                              'provinceId': selectedProvinceId!,
                              'provinceName': selectedProvinceName!,
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("alert_null_value".tr(args: [
                                  "${"province".tr()} ${"or".tr()} ${"education_institution".tr()}"
                                ])),
                              ),
                            );
                          }
                        }
                      },
                      child: Text("next".tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
