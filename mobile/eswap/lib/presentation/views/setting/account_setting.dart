import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/components/bottom_sheet.dart';
import 'package:eswap/presentation/components/education_institution_dialog.dart';
import 'package:eswap/presentation/views/forgotpw/forgotpw_email_page.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:eswap/service/user_service.dart';
import 'package:flutter/material.dart';

class AccountSetting extends StatefulWidget {
  final UserInfomation user;

  const AccountSetting({super.key, required this.user});

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  bool _hasChanges = false;
  late final TextEditingController usernameController;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController institutionController;
  late final TextEditingController addressController;
  int oldWaitFollow = 0;
  int waitFollow = 0;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.user.username);
    firstNameController = TextEditingController(text: widget.user.firstname);
    lastNameController = TextEditingController(text: widget.user.lastname);
    institutionController =
        TextEditingController(text: widget.user.educationInstitutionName);
    addressController = TextEditingController(text: widget.user.address);

    usernameController.addListener(_checkForChanges);
    firstNameController.addListener(_checkForChanges);
    lastNameController.addListener(_checkForChanges);
    institutionController.addListener(_checkForChanges);
    addressController.addListener(_checkForChanges);
    if (widget.user.requireFollowApproval != null &&
        widget.user.requireFollowApproval!) {
      oldWaitFollow = 1;
      waitFollow = 1;
    }
  }

  @override
  void dispose() {
    usernameController.removeListener(_checkForChanges);
    firstNameController.removeListener(_checkForChanges);
    lastNameController.removeListener(_checkForChanges);
    institutionController.removeListener(_checkForChanges);
    addressController.removeListener(_checkForChanges);

    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    institutionController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final currentUser = widget.user;
    final hasChanges = waitFollow != oldWaitFollow ||
        usernameController.text != currentUser.username ||
        firstNameController.text != currentUser.firstname ||
        lastNameController.text != currentUser.lastname ||
        institutionController.text != currentUser.educationInstitutionName ||
        (currentUser.role == 'STORE' &&
            addressController.text != currentUser.address);

    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildChangeInfoWidget(widget.user, context);
  }

  Widget _buildChangeInfoWidget(UserInfomation user, BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(16.0),
      child: AppBody(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 20),
              if (user.role != 'ADMIN')
                Column(
                  children: [
                    RadioListTile<int>(
                      value: 0,
                      groupValue: waitFollow,
                      onChanged: (value) {
                        setState(() {
                          waitFollow = 0;
                        });
                        _checkForChanges();
                      },
                      title: Text(
                        "Chế độ mở",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      subtitle: Text(
                        "Mọi người có thể theo dõi bạn ngay lập tức",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      activeColor: Theme.of(context).primaryColor,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      toggleable: true,
                    ),
                    SizedBox(height: 8),
                    RadioListTile<int>(
                      value: 1,
                      groupValue: waitFollow,
                      onChanged: (value) {
                        setState(() {
                          waitFollow = 1;
                        });
                        _checkForChanges();
                      },
                      title: Text(
                        "Chế độ kiểm duyệt",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      subtitle: Text(
                        "Bạn cần duyệt khi có người muốn theo dõi",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      activeColor: Theme.of(context).primaryColor,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      toggleable: true,
                    ),
                  ],
                ),
              // Username Field
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Last Name Field
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'last_name'.tr(),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // First Name Field
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'first_name'.tr(),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Education Institution Field with Button
              if (user.role == 'USER')
                GestureDetector(
                    onTap: () {
                      _showInstitutionDialog(context);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: institutionController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'education_institution'.tr(),
                          prefixIcon: const Icon(Icons.school),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                    )),
              const SizedBox(height: 16),

              if (user.role == 'STORE')
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 2,
                  ),
                ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: _hasChanges ? Colors.blue : Colors.grey,
                  ),
                  onPressed: _hasChanges
                      ? () {
                          // if (formKey.currentState!.validate()) {
                          _saveChanges();
                          // }
                        }
                      : null,
                  child:
                      Text('Lưu thay đổi'.tr(), style: TextStyle(fontSize: 16)),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotpwEmailPage(
                                isAccountSettingScreen: true,
                              )),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.transparent,
                    child: Text(
                      "Thay đổi mật khẩu?",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    await UserService().changeInfo(
        username: usernameController.text,
        firstname: firstNameController.text,
        lastname: lastNameController.text,
        educationInstitutionId: educationInstitutionId,
        requireFollowApproval: waitFollow == 1 ? true : false,
        context: context);
    setState(() {
      _hasChanges = false;
    });
  }

  int? educationInstitutionId;

  void _showInstitutionDialog(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, Object>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.transparent,
        builder: (context) =>
            EnhancedDraggableSheet(child: InstitutionSelectionDialog()));
    if (result != null) {
      educationInstitutionId = result['educationInstitutionId'] as int;
      final educationInstitutionName =
          result['educationInstitutionName'] as String;
      print("$educationInstitutionId $educationInstitutionName");

      if (educationInstitutionName != null) {
        setState(() {
          institutionController.text = educationInstitutionName;
        });
        _checkForChanges();
      }
    }
  }
}
