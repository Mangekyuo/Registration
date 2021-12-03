import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:async';                                    // new
import 'package:cloud_firestore/cloud_firestore.dart';  // new
import 'package:firebase_core/firebase_core.dart'; // new
import 'package:firebase_auth/firebase_auth.dart'; // new
import 'package:provider/provider.dart';           // new
import 'package:fluttertoast/fluttertoast.dart';   // new
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(
    MaterialApp(
        debugShowCheckedModeBanner: false, //hide debug banner
        home: MainScreen()),
    );
}
class MainScreen extends StatelessWidget{
  bool usersigned = false;
  //VOIDS :
  //SIGN IN TO SYSTEM VIA EMAIL & PASSWORD
  void signInWithEmailAndPassword(String email, String password, void Function(FirebaseAuthException e) errorCallback) async {
    await Firebase.initializeApp();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      FirebaseAuth.instance
          .userChanges()
          .listen((User? user) {
        if (user == null) {
          //to do if user logged out
          FirebaseAuth.instance.signOut();
        } else {
          //to do if user signed in
          usersigned=true;
        }
      });
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        Fluttertoast.showToast(
            msg: "Wrong password or email",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0
        );
      }
    }
  }
  void signOut() {
    FirebaseAuth.instance.signOut();
  }


  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(child: Column(
        children: [
          Padding(padding: EdgeInsets.only(
              left: width/25 , top: height/4, right: width/25
          ),child: Align(alignment: Alignment.centerLeft,child: Text("Login",style: GoogleFonts.comicNeue(textStyle: TextStyle(fontSize: 34, fontWeight: FontWeight.bold))))),
          Padding(padding: EdgeInsets.symmetric(vertical: height/25 , horizontal: width/25),child: Align(alignment: Alignment.centerLeft,child:  Text("Please sign in to continue" , style: GoogleFonts.comicNeue(textStyle: TextStyle(fontSize: 18,color: Colors.grey))))),

          SizedBox(width: width, child: Padding(padding: EdgeInsets.only(top:height/50 , right: width/25 , left: width/25),child:Align(alignment: Alignment.centerLeft,
              child:TextFormField(controller: email,decoration: const InputDecoration( prefixIcon: Padding(padding: EdgeInsets.only() , child: Icon(Icons.email)),
                  enabledBorder:UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)), hintStyle: TextStyle(fontSize: 22 , color: Colors.black),
                  hintText: "user1234@email.com" , labelText: "EMAIL" , labelStyle: TextStyle(fontSize: 18, color: Colors.green)), style: GoogleFonts.comicNeue(),validator: (String?value){
                if(value == null ||value.isEmpty){
                  return "PLEASE ENTER YOUR LOGIN OR EMAIL";}
                return null;}))
          )),
          SizedBox(width:width, child: Padding(padding: EdgeInsets.symmetric(vertical: height/50 , horizontal: width/25),child: Align(alignment: Alignment.centerLeft,
              child:TextFormField( controller: password,decoration: const InputDecoration( prefixIcon: Padding(padding: EdgeInsets.only() ,child: Icon(Icons.password)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),hintStyle: TextStyle(fontSize: 22 , color: Colors.black),
                  hintText: "" , labelText: "PASSWORD" , labelStyle: TextStyle(fontSize: 18 , color: Colors.green)),style: GoogleFonts.comicNeue(),validator: (String?value){
                if(value == null ||value.isEmpty){
                  return "PLEASE ENTER YOUR PASSWORD";}
                return null;})))),
          Padding(padding:  EdgeInsets.symmetric(vertical: height/50),
              child: SizedBox(width: width/2,height:height/20, child: ElevatedButton(child: Text("LOGIN " , style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18))),
                  onPressed:(){
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    print(email.text); //email
                    print(password.text); //password
                    //we have void signInWithEmailAndPassword ==> so let's use it :
                    signInWithEmailAndPassword(email.text, password.text, (e) { });
                    //after this was successfully logged in navigate it to hello page ==>
                    Future.delayed(const Duration(milliseconds: 2000), () {
                      // Here you can write your code
                      if(usersigned==true){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> SystemIN()));
                      }
                    });
                  },style:ElevatedButton.styleFrom(primary: Colors.green)
              ),
              )),
          Padding(padding: EdgeInsets.only(top: height/5,bottom: 10),
              child: Align(alignment: Alignment.center,child: Text.rich(TextSpan(
                  text: "Don't have an account?", style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18)),
                  children: <TextSpan>[
                    TextSpan(text: " Sign up" , style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18 , fontWeight: FontWeight.bold , color: Colors.green)) , recognizer: TapGestureRecognizer()
                      ..onTap =(){
                        //go to sign up screen ==>
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpPage()));
                      })
                  ]
              )))),
        ],
      )),
    );
  }
}

class SignUpPage extends StatelessWidget{
  //VOIDS :
  //register account
  void registerAccount(String email, String displayName, String password, void Function(FirebaseAuthException e) errorCallback) async {
    await Firebase.initializeApp();
    try {
      var credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateProfile(displayName: displayName);
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: "The account already exists for that email",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0
        );
      }
      errorCallback(e);
    }
  }

  TextEditingController FullName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController retrypassword = TextEditingController();
  Widget build(BuildContext context){
    //width and height of device
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false, // to avoid show bottom overflow
        body:Container(child: Column(
      children: [
        Padding(padding: EdgeInsets.only(
            left: width/25 , top: height/8, right: width/25
        ),child: Align(alignment: Alignment.centerLeft,child: Text("Create Account",style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold))))),

        SizedBox(width: width, child: Padding(padding: EdgeInsets.only(top:height/50 , right: width/25 , left: width/25),child:Align(alignment: Alignment.centerLeft,
            child:TextFormField(controller: FullName,decoration: const InputDecoration( prefixIcon: Padding(padding: EdgeInsets.only() , child: Icon(Icons.account_circle)),
                enabledBorder:UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                hintText: "" , labelText: "NAME OR NICK" , labelStyle: TextStyle(fontSize: 18, color: Colors.green)), style: GoogleFonts.comicNeue(),validator: (String?value){
              if(value == null ||value.isEmpty){
                return "PLEASE ENTER YOUR NAME OR NICK";}
              return null;}))
        )),
        SizedBox(width: width, child: Padding(padding: EdgeInsets.only(top:height/50 , right: width/25 , left: width/25),child:Align(alignment: Alignment.centerLeft,
            child:TextFormField(controller: email,decoration: const InputDecoration( prefixIcon: Padding(padding: EdgeInsets.only() , child: Icon(Icons.email)),
                enabledBorder:UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                hintText: "user1234@email.com" , labelText: "EMAIL" , labelStyle: TextStyle(fontSize: 18, color: Colors.green)), style: GoogleFonts.comicNeue(),validator: (String?value){
              if(value == null ||value.isEmpty){
                return "PLEASE ENTER YOUR LOGIN OR EMAIL";}
              return null;}))
        )),
        SizedBox(width:width, child: Padding(padding: EdgeInsets.symmetric(vertical: height/50 , horizontal: width/25),child: Align(alignment: Alignment.centerLeft,
            child:TextFormField( controller: password,decoration: const InputDecoration( prefixIcon: Padding(padding: EdgeInsets.only() ,child: Icon(Icons.password)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                hintText: "" , labelText: "PASSWORD" , labelStyle: TextStyle(fontSize: 18 , color: Colors.green)),style: GoogleFonts.comicNeue(),validator: (String?value){
              if(value == null ||value.isEmpty){
                return "PLEASE ENTER YOUR PASSWORD";}
              return null;})))),
        SizedBox(width:width, child: Padding(padding: EdgeInsets.symmetric(vertical: height/50 , horizontal: width/25),child: Align(alignment: Alignment.centerLeft,
            child:TextFormField( controller: retrypassword,decoration: const InputDecoration( prefixIcon: Padding(padding: EdgeInsets.only() ,child: Icon(Icons.password)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                hintText: "" , labelText: " CONFIRM PASSWORD" , labelStyle: TextStyle(fontSize: 18 , color: Colors.green)),style: GoogleFonts.comicNeue(),validator: (String?value){
              if(value == null ||value.isEmpty){
                return "PLEASE ENTER YOUR PASSWORD";}
              return null;})))),
        Padding(padding:  EdgeInsets.symmetric(vertical: height/50),
            child: SizedBox(width: width/2,height:height/20, child: ElevatedButton(child: Text("SIGN UP " , style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18))),
                onPressed:(){
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  print(FullName.text); // Name of account holder
                  print(email.text); //email
                  print(password.text); //password
                  print(retrypassword.text); //retry password ==> let's check if they are the same ==>
                  //check if email name is not empty
                  if(email.text!=""){
                    if(password.text==retrypassword.text){
                      //do if passwords is correct :
                      //create new user to System
                      if(FullName.text==""){
                        Fluttertoast.showToast(
                            msg: "NAME OR NICK CAN'T BE EMPTY",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0
                        );
                      }
                      else{
                        if(password.text.length<6){
                          Fluttertoast.showToast(
                              msg: "PASSWORD SHOULD CONSIST NON LESS THEN 6 CHARACTERS",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 14.0
                          );
                        }
                        else{
                          registerAccount(email.text, FullName.text, password.text, (e) { });
                          //show that user creation was success and navigate it to log in screen
                          Fluttertoast.showToast(
                              msg: "CONGRATULATION!USER CREATED!",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 16.0
                          );
                          //navigate to log in screen
                          Navigator.pop(context);
                        }
                      }
                    }
                    else{
                      //if passwords non match ==> show that they are non same
                      Fluttertoast.showToast(
                          msg: "Passwords non match",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          fontSize: 16.0
                      );
                    }
                  }
                  else{
                    //if email address is empty
                    Fluttertoast.showToast(
                        msg: "Email is empty",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0
                    );
                  }
                  //check on full name is not empty
                },style:ElevatedButton.styleFrom(primary: Colors.green)
            ),
            )),
        Padding(padding: EdgeInsets.only(top: height/8 ,bottom: 10),
            child: Align(alignment: Alignment.center,child: Text.rich(TextSpan(
                text: "Already have an account?", style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18)),
                children: <TextSpan>[
                  TextSpan(text: " Sign in" , style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18 , fontWeight: FontWeight.bold , color: Colors.green)) , recognizer: TapGestureRecognizer()
                    ..onTap =(){
                      //go to sign up screen ==>
                      Navigator.pop(context);
                  })
                ]
            ))))
      ],
    )));
  }
}

class SystemIN extends StatelessWidget{
  //implement methods if needed

  final FirebaseAuth auth = FirebaseAuth.instance;

  String text (){
    final User? user = auth.currentUser;
    final uid = user!.displayName;
    String string = uid!;
    return 'Hello $string ';
  }
  Widget build(BuildContext context){
    //width and height of device
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(body:Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Center(child: Text(text(),style: GoogleFonts.comicNeue(textStyle: const TextStyle(fontSize: 18 , fontWeight: FontWeight.bold ))))
      ],),
    ));
}
}