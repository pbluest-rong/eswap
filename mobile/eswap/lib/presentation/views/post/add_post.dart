import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/core/validation/validators.dart';
import 'package:eswap/model/category_brand_model.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/presentation/components/pick_media.dart';
import 'package:eswap/presentation/views/post/add_post_provider.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:eswap/service/category_brand_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _originalPriceController =
      TextEditingController();
  final TextEditingController _salePricePriceController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  List<SearchFieldListItem<Brand>> _brandSuggestions = [];
  final _categoryBrandService = CategoryBrandService();
  Brand? _selectedBrand;

  Future<void> _loadBrands(int categoryId) async {
    try {
      final brands =
          await _categoryBrandService.fetchBrandsByCategoryId(categoryId);
      setState(() {
        _brandSuggestions = brands.map((brand) {
          return SearchFieldListItem<Brand>(
            brand.name,
            item: brand,
            child: Text(brand.name),
          );
        }).toList();
      });
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load institutions: $e')),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    int categoryId =
        Provider.of<AddPostProvider>(context, listen: false).categoryId!;
    _loadBrands(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Consumer<AddPostProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              Text("add_post".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    provider.privacy == "PUBLIC"
                        ? Icons.public
                        : Icons.person_sharp,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                      provider.privacy == "PUBLIC"
                          ? "privacy_public".tr()
                          : "privacy_follower".tr(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => provider.togglePrivacy(),
                    child: Icon(Icons.sync_alt, size: 20),
                  )
                ],
              ),
            ],
          );
        }),
        leading: IconButton(
          icon: Icon(Icons.close_sharp),
          onPressed: () {
            Navigator.pop(context);
            Provider.of<AddPostProvider>(context, listen: false).reset();
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child:
                Provider.of<AddPostProvider>(context, listen: true).isCanPost()
                    ? RichText(
                        text: TextSpan(
                          style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightPrimary),
                          text: "Đăng",
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          text: "Đăng",
                        ),
                      ),
          )
        ],
      ),
      body: AppBody(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCategoryWidget(context, textTheme),
              _buildMediaSection(true), // Images section
              _buildMediaSection(false), // Videos section
              SizedBox(height: 14),
              _buildChoiceCondition(textTheme),
              SizedBox(height: 14),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "item_name".tr(),
                ),
                controller: _nameController,
                validator: (value) =>
                    ValidationUtils.validatePostEmpty(value, "item_name".tr()),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onEditingComplete: () {
                  Provider.of<AddPostProvider>(context, listen: false)
                      .updateName(_nameController.text);
                },
              ),
              SizedBox(height: 14),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "item_desc".tr(),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                controller: _descController,
                validator: (value) =>
                    ValidationUtils.validatePostEmpty(value, "item_desc".tr()),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                minLines: 5,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                onEditingComplete: () {
                  Provider.of<AddPostProvider>(context, listen: false)
                      .updateDesc(_descController.text);
                },
              ),
              SizedBox(height: 14),
              _buildSelectBrandWidget(),
              SizedBox(height: 14),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "item_original_price".tr(),
                ),
                controller: _originalPriceController,
                validator: (value) => ValidationUtils.validatePostEmpty(
                    value, "item_original_price".tr()),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onEditingComplete: () {
                  Provider.of<AddPostProvider>(context, listen: false)
                      .updateOriginalPrice(
                          _originalPriceController.text as double);
                },
              ),
              SizedBox(height: 14),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "item_sale_price".tr(),
                ),
                controller: _salePricePriceController,
                validator: (value) => ValidationUtils.validatePostEmpty(
                    value, "item_sale_price".tr()),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onEditingComplete: () {
                  Provider.of<AddPostProvider>(context, listen: false)
                      .updateSalePrice(
                          _salePricePriceController.text as double);
                },
              ),
              SizedBox(height: 14),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "item_address".tr(),
                ),
                controller: _addressController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onEditingComplete: () {
                  Provider.of<AddPostProvider>(context, listen: false)
                      .updateAddress(_addressController.text);
                },
              ),
              SizedBox(height: 14),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "item_phone_number".tr(),
                ),
                controller: _phoneNumberController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onEditingComplete: () {
                  Provider.of<AddPostProvider>(context, listen: false)
                      .updateAddress(_phoneNumberController.text);
                },
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection(bool isImages) {
    return Consumer<AddPostProvider>(
      builder: (context, provider, child) {
        final medias = isImages ? provider.images : provider.videos;
        final hasMedia = medias != null && medias.isNotEmpty;

        return Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: hasMedia ? 2 : 1,
                    child: buildSelectMediaWidget(
                      desc: isImages ? 'Đăng từ 1 đến 5 hình' : 'Đăng 1 video',
                      icon: isImages
                          ? Icons.image
                          : Icons.video_camera_back_outlined,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MediaLibraryScreen(
                              maxSelection: isImages
                                  ? (5 - medias!.length)
                                  : (1 - medias!.length),
                              isSelectImage: isImages,
                              isSelectVideo: !isImages,
                              enableCamera: isImages,
                            ),
                          ),
                        );
                        if (result != null && result.isNotEmpty) {
                          for (var asset in result) {
                            final file = await asset.file;
                            if (isImages) {
                              provider.addImage(file!.path);
                            } else {
                              provider.addVideo(file!.path);
                            }
                          }
                        }
                      },
                    ),
                  ),
                  if (hasMedia)
                    Expanded(
                      flex: 4,
                      child: Container(
                          margin: EdgeInsets.only(left: 8),
                          child: _buildSelectedMediaPreview(context, isImages)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildSelectMediaWidget({
    required String desc,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(12),
          dashPattern: [4, 2],
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 50,
                  color: AppColors.lightPrimary,
                ),
                Text(
                  desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMediaPreview(BuildContext context, bool isImages) {
    final medias = isImages
        ? Provider.of<AddPostProvider>(context).images
        : Provider.of<AddPostProvider>(context).videos;
    if (medias!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: 100,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: medias.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 8),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: isImages
                  ? DecorationImage(
                      image: FileImage(File(medias[index])),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: !isImages ? Colors.black12 : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  child: !isImages
                      ? Center(
                          child: Icon(Icons.play_circle_fill,
                              size: 40, color: Colors.white),
                        )
                      : SizedBox.shrink(),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      if (isImages) {
                        Provider.of<AddPostProvider>(context, listen: false)
                            .removeImage(index);
                      } else {
                        Provider.of<AddPostProvider>(context, listen: false)
                            .removeVideo(index);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _buildCategoryWidget(BuildContext context, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Danh mục",
          style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: TextEditingController(
            text:
                "${Provider.of<AddPostProvider>(context, listen: false).categoryName}",
          ),
          readOnly: true,
          scrollPhysics: const ClampingScrollPhysics(),
          decoration: InputDecoration(
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: const Color(0xFFF1F4FF),
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
          ),
          style: TextStyle(color: Colors.black),
          maxLines: 1,
          scrollPadding: EdgeInsets.zero,
        )
      ],
    );
  }

  Widget _buildChoiceCondition(TextTheme textTheme) {
    Condition? condition =
        Provider.of<AddPostProvider>(context, listen: true).condition;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "condition".tr(),
          style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            ChoiceChip(
              label: Text("new".tr()),
              showCheckmark: false,
              selectedColor: AppColors.lightSecondary,
              selected: (condition != null && condition == Condition.NEW)
                  ? true
                  : false,
              onSelected: (_) => {
                Provider.of<AddPostProvider>(context, listen: false)
                    .updateCondition(Condition.NEW)
              },
            ),
            SizedBox(
              width: 6,
            ),
            ChoiceChip(
              label: Text("used".tr()),
              showCheckmark: false,
              selectedColor: AppColors.lightSecondary,
              selected: (condition != null && condition == Condition.USED)
                  ? true
                  : false,
              onSelected: (_) => {
                Provider.of<AddPostProvider>(context, listen: false)
                    .updateCondition(Condition.USED)
              },
            )
          ],
        ),
      ],
    );
  }

  _buildSelectBrandWidget() {
    return SearchField<Brand>(
      controller: _brandController,
      suggestions: _brandSuggestions,
      hint: "item_brand".tr(),
      searchInputDecoration: SearchInputDecoration(
        labelText: "item_brand".tr(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        suffixIcon: _selectedBrand != null
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _selectedBrand = null;
                    _brandController.clear();
                    Provider.of<AddPostProvider>(context, listen: false)
                        .updateBrandId(null);
                  });
                },
              )
            : null,
      ),
      onSuggestionTap: (value) {
        if (value.item != null) {
          setState(() {
            _selectedBrand = value.item;
            _brandController.text = value.item!.name;
          });
          Provider.of<AddPostProvider>(context, listen: false)
              .updateBrandId(value.item!.id);
        }
      },
    );
  }
}
