import 'package:flutter/material.dart';
import 'package:messenger_app/repositary/screens/widgets/Uihelper.dart';

import '../../../domain/constants/appcolors.dart';

class Morescreen extends StatelessWidget {
  var arrMore = [
    {"icon": Icons.person, "txt": "Account"},
    {"icon": Icons.chat_sharp, "txt": "Chats"},
    {"icon": Icons.sunny, "txt": "Appereance"},
    {"icon": Icons.notifications_active, "txt": "Notification"},
    {"icon": Icons.privacy_tip, "txt": "Privacy"},
    {"icon": Icons.folder, "txt": "Data Usage"},
    {"icon": Icons.help, "txt": "Help"},
    {"icon": Icons.mail, "txt": "Invite Your Friends"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.scaffolddark
            : AppColors.scaffoldlight,
        title: Uihelper.CustomText(
            text: "More",
            fontsize: 23,
            fontweight: FontWeight.bold,
            fontfamily: "bold",
            context: context),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Theme.of(context).brightness == Brightness.dark
                ? Uihelper.CustomImage(imgurl: "darkprofile.png")
                : Uihelper.CustomImage(imgurl: "lightprofile.png"),
            title: Uihelper.CustomText(
                text: "Nithishkumar.k",
                fontsize: 14,
                fontweight: FontWeight.bold,
                context: context),
            subtitle: Uihelper.CustomText(
                text: "+91 94545xxxxx", fontsize: 12, context: context),
            trailing:
                IconButton(onPressed: () {}, icon: Icon(Icons.arrow_right)),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(arrMore[index]["icon"] as IconData),
                  title: Uihelper.CustomText(
                      text: arrMore[index]["txt"].toString(),
                      fontsize: 14,
                      fontweight: FontWeight.bold,
                      context: context),
                  trailing: Icon(Icons.forward),
                );
              },
              itemCount: arrMore.length,
            ),
          )
        ],
      ),
    );
  }
}
