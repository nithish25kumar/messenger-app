import 'package:flutter/material.dart';

import '../../../domain/constants/appcolors.dart';
import '../widgets/Uihelper.dart';

class Chatscreen extends StatelessWidget {
  var arrchat = [
    {
      "img": "Frame 3293.png",
      "name": "Athalia Putri",
      "msg": "Good morning ,did you sleep well",
      "date": "Today",
      "msgcount": " 1"
    },
    {
      "img": "Avatar.png",
      "name": "Erlan Sadewa",
      "msg": "How is it going",
      "date": "Today",
      "msgcount": " 1"
    },
    {
      "img": "Avatar (1).png",
      "name": "Midala Huera",
      "msg": "Heyy",
      "date": "Today",
      "msgcount": " 1"
    },
  ];
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.scaffolddark
            : AppColors.scaffoldlight,
        elevation: 0,
        title: Uihelper.CustomText(
            text: "Chats",
            fontsize: 25,
            fontweight: FontWeight.bold,
            fontfamily: "bold",
            context: context),
        actions: [
          IconButton(
              onPressed: () {}, icon: Icon(Icons.mark_chat_unread_outlined)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_rounded))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Uihelper.CustomImage(imgurl: "Avatar (1).png"),
                  SizedBox(
                    width: 10,
                  ),
                  Uihelper.CustomImage(imgurl: "Avatar (3).png"),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Row(
                children: [
                  Uihelper.CustomText(
                      text: "Jenny",
                      fontsize: 15,
                      fontweight: FontWeight.bold,
                      fontfamily: "bold",
                      context: context),
                  SizedBox(
                    width: 25,
                  ),
                  Uihelper.CustomText(
                      text: "Sagar",
                      fontsize: 15,
                      fontweight: FontWeight.bold,
                      fontfamily: "bold",
                      context: context),
                ],
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            SizedBox(
              height: 20,
            ),
            Uihelper.CustomTextField(
                controller: searchController,
                text: "Search",
                textinputtype: TextInputType.text,
                context: context,
                icondata: Icons.search),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Uihelper.CustomImage(
                        imgurl: arrchat[index]["img"].toString()),
                    title: Uihelper.CustomText(
                        text: arrchat[index]["name"].toString(),
                        fontsize: 14,
                        fontweight: FontWeight.w600,
                        context: context),
                    subtitle: Uihelper.CustomText(
                        text: arrchat[index]["msg"].toString(),
                        fontsize: 12,
                        context: context),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Uihelper.CustomText(
                            text: arrchat[index]["date"].toString(),
                            fontsize: 10,
                            context: context,
                            color: Colors.green),
                        CircleAvatar(
                          radius: 12,
                          child: Uihelper.CustomText(
                              text: arrchat[index]["msgcount"].toString(),
                              fontsize: 10,
                              context: context),
                          backgroundColor: Color(0xFFD2D5F9),
                        )
                      ],
                    ),
                  );
                },
                itemCount: arrchat.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
