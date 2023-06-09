import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:final_task/common/com_helper.dart';
import 'package:final_task/common/getTextFromField.dart';

import 'package:final_task/database_handler/db_helper.dart';
import 'package:final_task/database_handler/sql_helper.dart';
import 'package:final_task/model/user_model.dart';

import 'package:final_task/screens/login_form.dart';

import 'package:final_task/theme/my_theme.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Map<String, dynamic>> _journals = [];  //все пользователи
  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }



  final _formKey = new GlobalKey<FormState>();
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();

  late DbHelper dbHelper;
  final _conUserId = TextEditingController();
  final _conDelUserId = TextEditingController();
  final _conUserName = TextEditingController();
  final _conEmail = TextEditingController();
  final _conPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserData();
    _refreshJournals(); // Loading the diary when the app starts

    dbHelper = DbHelper();
  }

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      _conUserId.text = sp.getString("user_id")!;
      _conDelUserId.text = sp.getString("user_id")!;
      _conUserName.text = sp.getString("user_name")!;
      _conEmail.text = sp.getString("email")!;
      _conPassword.text = sp.getString("password")!;

    });
  }

  update() async {
    String uid = _conUserId.text;
    String uname = _conUserName.text;
    String email = _conEmail.text;
    String passwd = _conPassword.text;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      UserModel user = UserModel(uid, uname, email, passwd);
      await dbHelper.updateUser(user).then((value) {
        if (value == 1) {
          alertDialog(context, "Successfully Updated");

          updateSP(user, true).whenComplete(() {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginForm()),
                    (Route<dynamic> route) => false);
          });
        } else {
          alertDialog(context, "Error Update");
        }
      }).catchError((error) {
        print(error);
        alertDialog(context, "Error");
      });
    }
  }

  delete() async {
    String delUserID = _conDelUserId.text;

    await dbHelper.deleteUser(delUserID).then((value) {
      if (value == 1) {
        alertDialog(context, "Successfully Deleted");
        UserModel user = UserModel('dd','da','fa','fdas');
        updateSP(user, false).whenComplete(() {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginForm()),
                  (Route<dynamic> route) => false);
        });
      }
    });
  }

  Future updateSP(UserModel user, bool add) async {
    final SharedPreferences sp = await _pref;

    if (add) {
      sp.setString("user_name", user.user_name);
      sp.setString("email", user.email);
      sp.setString("password", user.password);
    } else {
      sp.remove('user_id');
      sp.remove('user_name');
      sp.remove('email');
      sp.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.colorDark,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Update
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: getTextFormField(
                          controller: _conUserId,
                          isEnable: false,
                          icon: Icons.person,
                          hintName: 'User ID'),
                    ),
                  ),


                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: getTextFormField(
                          controller: _conUserName,
                          icon: Icons.person_outline,
                          inputType: TextInputType.name,
                          hintName: 'User Name'),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: getTextFormField(
                          controller: _conEmail,
                          icon: Icons.email,
                          inputType: TextInputType.emailAddress,
                          hintName: 'Email'),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: getTextFormField(
                        controller: _conPassword,
                        icon: Icons.lock,
                        hintName: 'Password',
                        isObscureText: true,),
                    ),
                  ),


                  Container(
                    margin: const EdgeInsets.all(30.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: ElevatedButton(
                      style: MyTheme.buttonStyleUsual1,
                      child: const Text(
                        'Update', style: TextStyle(color: MyTheme.colorBrightPurple)),
                      onPressed: update,
                    ),
                  ),

                  //Delete
                  Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: getTextFormField(
                          controller: _conDelUserId,
                          isEnable: false,
                          icon: Icons.person,
                          hintName: 'User ID'),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.all(30.0),
                    width: double.infinity,

                    child: ElevatedButton(
                      style: MyTheme.buttonStyleUsual1,
                      child: const Text(
                        'Delete', style: TextStyle(color: MyTheme.colorBrightPurple),
                      ),
                      onPressed: delete,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
