import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

import '../../../domain/constants/appcolors.dart';

class Contactscreen extends StatelessWidget {
  TextEditingController searchController = TextEditingController();
  var arrContacts = [
    {
      "img": "Frame 3293.png",
      "name": "Athalia Putri",
      "lastseen": "Last seen yesterday"
    },
    {"img": "Avatar.png", "name": "Erlan Sadewa", "lastseen": "Online"},
    {
      "img": "Avatar (1).png",
      "name": "Midala Huera",
      "lastseen": "Last seen 3 hours ago"
    },
    {"img": "Avatar (2).png", "name": "Nafisa Gitari", "lastseen": "Online"},
    {"img": "Frame 3293 (1).png", "name": "Raki Devon", "lastseen": "Online"},
    {
      "img": "Avatar (3).png",
      "name": "Salsabila Akira",
      "lastseen": "Last seen 30 minutes ago"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.scaffolddark
            : AppColors.scaffoldlight,
        elevation: 0,
        title: Uihelper.CustomText(
            text: "Contacts",
            fontsize: 25,
            fontweight: FontWeight.bold,
            fontfamily: "bold",
            context: context),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: Center(
        child: Column(
          children: [
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
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Uihelper.CustomImage(
                        imgurl: arrContacts[index]["img"].toString()),
                    title: Uihelper.CustomText(
                        text: arrContacts[index]["name"].toString(),
                        fontsize: 14,
                        fontweight: FontWeight.w600,
                        context: context),
                    subtitle: Uihelper.CustomText(
                        text: arrContacts[index]["lastseen"].toString(),
                        fontsize: 12,
                        context: context),
                  );
                },
                itemCount: arrContacts.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
