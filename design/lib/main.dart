import 'package:demmo/colors.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key });
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Wallet App',
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index =0;
  PageController controller = PageController(initialPage: 0);
  var data=[
    {'icon':'assets/netflix.png','title':'Netflix','subtitle':'Month subscription','amount':r'$12'},
    {'icon':'assets/pay.png','title':'Pay','subtitle':'Tax','amount':r'$10'},
    {'icon':'assets/paypal.png','title':'Paypal','subtitle':'Buy Item','amount':r'$9'},
    {'icon':'assets/netflix.png','title':'Netflix','subtitle':'Month subscription','amount':r'$12'},
    {'icon':'assets/pay.png','title':'Pay','subtitle':'Tax','amount':r'$10'},
    {'icon':'assets/paypal.png','title':'Paypal','subtitle':'Buy Item','amount':r'$9'},
    {'icon':'assets/paypal.png','title':'Paypal','subtitle':'Buy Item','amount':r'$9'},
    {'icon':'assets/netflix.png','title':'Netflix','subtitle':'Month subscription','amount':r'$12'},
    {'icon':'assets/pay.png','title':'Pay','subtitle':'Tax','amount':r'$10'},
    {'icon':'assets/paypal.png','title':'Paypal','subtitle':'Buy Item','amount':r'$9'},



  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: controller ,
                children: [
                  SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Wallet",style: GoogleFonts.poppins(fontSize:20,fontWeight :FontWeight.bold ),),
                                  const SizedBox(height: 2,),
                                  Text("Actve",style: GoogleFonts.poppins(fontSize:14,fontWeight :FontWeight.w500 )),
                                ],
                              ),
                              const CircleAvatar(
                                radius: 26,

                                backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSeqG8b5R5jfp4Emf6_TVFUyqIywNhkiBoOTw&s'),
                                backgroundColor: Colors.transparent,
                              )
                            ],
                          ),
                          const SizedBox(height: 25,),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 140,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: secondColor,borderRadius: BorderRadius.circular(24)),
                            child: Row(
                              children: [
                                Expanded(
                                flex: 1,
                                    child:Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Balance",style: GoogleFonts.poppins(fontSize:14,fontWeight :FontWeight.bold ,color: Colors.white),),
                                        Text("\$ 1.234",style: GoogleFonts.poppins(fontSize:20,fontWeight :FontWeight.bold,color: Colors.white)),
                                      ],
                                    )
                                ),
                            Expanded(
                              flex: 1,
                              child:Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Card",style: GoogleFonts.poppins(fontSize:14,fontWeight :FontWeight.w500 ,color: Colors.white),),
                                  Text("MeCard",style: GoogleFonts.poppins(fontSize:20,fontWeight :FontWeight.bold,color: Colors.white)),
                                ],
                              )
                            )

                              ],
                            ),
                          ),
                          const SizedBox(height: 30,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ButtonWidget(text: 'Transfer',icon : Iconsax.convert,callback:(){}),
                              ButtonWidget(text: 'Payment',icon : Iconsax.export,callback:(){}),
                              ButtonWidget(text: 'Pay out',icon : Iconsax.money_send,callback:(){}),
                              ButtonWidget(text: 'Top Up',icon : Iconsax.add,callback:(){}),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Last Transactions",style: GoogleFonts.poppins(fontSize:20,fontWeight :FontWeight.bold ,color: secondColor),),
                              Text("View All",style: GoogleFonts.poppins(fontSize:14,fontWeight :FontWeight.w500 ,color: secondColor),),

                            ],
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: data.length,
                            // physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context,index)=>
                          ListTile(
                            leading: CircleAvatar(
                                child: Image.asset(data[index]['icon'].toString())
                            ),
                            title: Text(data[index]['title'].toString(),style: GoogleFonts.poppins(fontSize:14,fontWeight :FontWeight.w600 ,color: secondColor),),
                            subtitle:Text(data[index]['subtitle'].toString(),style: GoogleFonts.poppins(fontSize:13,fontWeight :FontWeight.w300 ,color: secondColor),),
                            trailing: Text(data[index]['amount'].toString(),style: GoogleFonts.poppins(fontSize:13,fontWeight :FontWeight.bold ,color: secondColor),),
                          )
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 110,
                  child: FloatingNavbar(
                    onTap: (i){
                        setState(() {
                          index=i;
                          controller.jumpToPage(index);
                        });
                    },
                    currentIndex: index,
                    borderRadius: 24,

                    iconSize: 32,


                    selectedBackgroundColor: Colors.transparent,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.white70,
                    backgroundColor: primaryColor,
                    items: [
                      FloatingNavbarItem(icon: Iconsax.home1),
                      FloatingNavbarItem(icon: Iconsax.chart),
                      FloatingNavbarItem(icon: Iconsax.notification),
                      FloatingNavbarItem(icon: Iconsax.setting),
                    ],
                  ),
                ),
              )
            ],
          )),

    );
  }
}

class ButtonWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback callback;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.callback,


  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [OutlinedButton(
          onPressed: callback,
          style:OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            side: const BorderSide(color: Colors.black),
            padding: const EdgeInsets.all(16),
            elevation: 5,
            backgroundColor: Colors.white,
            shadowColor: Colors.grey.withOpacity(0.2)

          ),
          child: Icon(
              icon,
            color: secondColor,
          ),
      ),
        const SizedBox(height: 4),
        Text(text,style: GoogleFonts.poppins(fontSize:12,fontWeight :FontWeight.w500 ,color: Colors.black),),

      ],
    );
  }
}