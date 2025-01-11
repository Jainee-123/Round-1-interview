import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import "package:http/http.dart" as http;
import 'package:timeago/timeago.dart' as timeago;
import 'dart:convert';

Map responcedata = Map();
class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  List Posts=[];
  Future apicall()async{
    final url = Uri.parse('https://api.hive.blog/');
    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json, text/plain, /',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        "id": 1,
        "jsonrpc": "2.0",
        "method": "bridge.get_ranked_posts",
        "params": {
          "sort": "trending",
          "tag": "",
          "observer": "hive.blog"
        },
      }),
    );
    if(response.statusCode==200){
      responcedata=json.decode(response.body);
      setState(() {
        Posts = responcedata['result'];

      });
    }
  }
  @override
  void initState() {
    apicall();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Posts'),
        backgroundColor: Colors.redAccent,
      ),
      body: Posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: Posts.length,
        itemBuilder: (context, index) {
          final post = Posts[index];
          final postTime = DateTime.parse(post['created']);
          final relativeTime = timeago.format(postTime);

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          post['json_metadata']['image'] != null &&
                              post['json_metadata']['image']
                                  .isNotEmpty
                              ? post['json_metadata']['image'][0]
                              : 'https://via.placeholder.com/150',
                        ),
                        radius: 30,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${post['author']} (${post['author_reputation']})",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "in ${post['community_title']} • $relativeTime",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    post['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    post['body']
                        .toString()
                        .replaceAll(RegExp(r'\n'), ' ')
                        .substring(0, 100) + '...',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.thumb_up_alt_sharp, size: 18, color: Colors.black87),
                          SizedBox(width: 5),
                          Text(post['net_votes'].toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.comment_bank, size: 18, color: Colors.blueGrey),
                          SizedBox(width: 5),
                          Text(post['children'].toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.money,
                              size: 18, color: Colors.green),
                          SizedBox(width: 5),
                          Text("\$${post['pending_payout_value']}"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
