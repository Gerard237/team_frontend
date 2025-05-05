import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:worldfavor/auth_control.dart';
import 'package:worldfavor/favori_page.dart';
import 'package:worldfavor/formular_page.dart';
import 'package:worldfavor/pays_page.dart';
import 'package:worldfavor/SearchCountry.dart';
import 'package:worldfavor/recipe.dart';

class WelcomePage extends StatelessWidget {
  String email;
  WelcomePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    double w= MediaQuery.of(context).size.width;
    double h= MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            children: [
              Container(
                  width: w,
                  height: h*0.3,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image:AssetImage(
                              "Img/images.jpg"
                          ),
                          fit: BoxFit.cover
                      )

                  ),
                  child: Column(
                    children: [
                      SizedBox(height: h*0.16,),
                      CircleAvatar(
                        backgroundColor: Colors.white70,
                        radius: 50,
                        backgroundImage: AssetImage(
                            "Img/img.png"
                        ),
                      )
                    ],
                  )
              ),

              const SizedBox(height: 30,),
              Container(
                width: w,

                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome",
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:Colors.black54
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                          fontSize: 36,
                          color:Colors.grey[500]
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              GestureDetector(
                onTap: (){
                  Get.to(()=> RecipeListPage(email));//SearchGroupPage());
                },
                child: Container(
                    width: w*0.5,
                    height: h*0.08,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                            image:AssetImage(
                                "Img/loginpge.png"
                            ),
                            fit: BoxFit.cover
                        )

                    ),
                    child:  const Center(
                      child: Text(
                        "learn to cook",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:Colors.white,
                        ), //TextStyle
                      ),
                    )
                ),
              ),
              const SizedBox(height: 30,),
              GestureDetector(
                onTap: (){
                  Get.to(()=>FavoriListPage(email));
                },
                child: Container(
                    width: w*0.5,
                    height: h*0.08,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                            image:AssetImage(
                                "Img/loginpge.png"
                            ),
                            fit: BoxFit.cover
                        )

                    ),
                    child:  const Center(
                      child: Text(
                        "Favori",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:Colors.white,
                        ), //TextStyle
                      ),
                    )
                ),
              ),

              SizedBox(height: 50,),
              GestureDetector(
                onTap: (){
                  AuthController.instance.logOut();
                },
                child: Container(
                    width: w*0.5,
                    height: h*0.08,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                            image:AssetImage(
                                "Img/loginpge.png"
                            ),
                            fit: BoxFit.cover
                        )

                    ),
                    child:  const Center(
                      child: Text(
                        "Sign Out",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:Colors.white,
                        ), //TextStyle
                      ),
                    )
                ),
              ),


            ]

        )
    );
  }
}
