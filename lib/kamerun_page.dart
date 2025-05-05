import 'package:flutter/material.dart';
import 'package:get/get.dart';

class kamerunpage extends StatelessWidget {
  const kamerunpage({super.key});

  @override
  Widget build(BuildContext context) {
    double w= MediaQuery.of(context).size.width;
    double h= MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
            children: [
              /*           Container(
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
                        radius: 60,
                        backgroundImage: AssetImage(
                            "Img/img.png"
                        ),
                      )
                    ],
                  )
              ), */


              Container(
                width: w,

                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Here is a list of berühmte Essen",
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:Colors.black54
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                width: w,

                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select a country:",
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:Colors.black54
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                width: w,

                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select a country:",
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:Colors.black54
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                width: w,

                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select a country:",
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:Colors.black54
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                width: w,

                margin: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select a country:",
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:Colors.black54
                      ),
                    ),

                  ],
                ),
              ),

              SizedBox(height: 100,),
              GestureDetector(
                onTap: (){
                  Get.back();
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
                        "Back",
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