import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:worldfavor/kamerun_page.dart';



class SearchGroupPage extends StatefulWidget {


  const SearchGroupPage({super.key});

  @override
  _SearchGroupPageState createState() => _SearchGroupPageState();
}

class _SearchGroupPageState extends State<SearchGroupPage> {
  String? selectedCourse;
  String? selectedSemester;
  List<String> courses = [];
  List<String> semesters = ['Africa', 'Europe', 'America', 'Asia', 'Australia'];
  List<Map<String, dynamic>> userData= [];
  // Declare groups as a list of maps
  List<Map<String, dynamic>> groups = []; // Initialize as an empty list
  bool isLoading = false; // Loading state
  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _fetchGroups(); // Fetch all groups initially
  }

  Future<void> _fetchCourses() async {
    setState(() {
      isLoading = true; // Start loading
    });



    final response = await http.post(
      Uri.parse('http://192.168.1.187/api/recipes/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name' : "",
        'description' : "",
        'file' : "",
        'user' : "",
        'country' : "",
        'city' : ""
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> courseData = jsonDecode(response.body)['courses'];
      setState(() {
        courses = courseData.map((course) => course['name'].toString()).toList();
      });
    } else {
      print('Failed to load courses');
    }
    setState(() {
      isLoading = false; // Stop loading
    });
  }

  // Fetch last message for a given group
  Future<Map<String, dynamic>?> _fetchLastMessage(String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('http://34.107.57.61/api/messages/$groupId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> messages = responseData['messages'];

        if (messages.isNotEmpty) {
          return messages.last; // Return the last message
        }
      }
    } catch (e) {
      print('Error fetching last message: $e');
    }
    return null; // Return null if no message or error
  }

  Future<void> _fetchGroups() async {
    setState(() {
      isLoading = true; // Start loading
    });


    final response = await http.post(
      Uri.parse('http://34.107.57.61/api/groups/find-groups'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({

      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> groupData = responseData['groupen'];

      // Fetch the last message for each group and store it
      for (var group in groupData) {
        final lastMessage = await _fetchLastMessage(group['_id']); // Fetch last message for each group
        final groupMessages = await _fetchMessagesWithUserData(group['_id']);
        setState(() {
          groups.add({
            'groupId': group['_id'],
            'name': group['groupName'] ?? '',
            'description': group['groupDescription'] ?? '',
            'image': group['groupImageUrl'] != null
                ? 'http://34.107.57.61/${group['groupImageUrl']}'
                : 'https://example.com/default-group-image.jpg',
            'lastMessage': lastMessage?['messageContent'] ?? 'No messages yet',
            'lastMessageTime': lastMessage != null
                ? DateTime.parse(lastMessage['createdAt']).toLocal().toString()
                : '',
            'mediaFiles': (group['mediaFiles'] as List<dynamic>)
                .map((file) => file.toString())
                .toList(),
            'members': (group['members'] as List<dynamic>)
                .map((file) => file.toString())
                .toList(),
            'groupMessages': groupMessages,
          });
        });
      }
    } else {
      print('Failed to load groups');
    }
    setState(() {
      isLoading = false; // Stop loading
    });
  }
  Future<List?> _fetchMessage(String groupId) async {
    try {
      final response = await http.get(
        Uri.parse('http://34.107.57.61/api/messages/$groupId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> messages = responseData['messages'];

        if (messages.isNotEmpty) {
          return messages ;// Return the last message
        }
      }
    } catch (e) {
      print('Error fetching last message: $e');
    }
    return null; // Return null if no message or error
  }

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://34.107.57.61/api/users/user-data/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['searchedUser'];
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null; // Return null if no data or error
  }


  Future<List<Map<String, dynamic>>> _fetchMessagesWithUserData(String groupId) async {
    List<Map<String, dynamic>> messagesWithUserData = [];
    List<String> senderIds = []; // Track unique sender IDs

    // Fetch messages first
    final messagesResponse = await _fetchMessage(groupId);
    if (messagesResponse != null) {
      for (var message in messagesResponse) {
        senderIds.add(message['senderId']);
        messagesWithUserData.add(message); // Store messages for later processing
      }
    }

    // Fetch user data for unique sender IDs
    Map<String, Map<String, dynamic>> usersData = {};
    for (String senderId in senderIds.toSet()) {
      final userData = await _fetchUserData(senderId);
      if (userData != null) {
        usersData[senderId] = userData;
      }
    }

    // Update messages with user data
    for (var message in messagesWithUserData) {
      message['senderUsername'] = usersData[message['senderId']]?['username'];
      message['senderProfilePic'] = usersData[message['senderId']]?['profileImageUrl'];
    }

    return messagesWithUserData;
  }


  Future<void> _fetchuserGroups() async {


    if (selectedCourse == null || selectedSemester == null) {
      print('Please select both course and semester');
      return;
    }

    final response = await http.post(
      Uri.parse('http://34.107.57.61/api/groups/find-user-groups'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({

        'course': selectedCourse,
        'semester': selectedSemester,
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> groupData = responseData['groupen']; // Adjusted to match your API response

      // Await all futures using Future.wait
      List<Map<String, dynamic>> updatedGroups = await Future.wait(groupData.map((group) async {
        final lastMessage = await _fetchLastMessage(group['_id']); // Fetch last message for each group
        final groupMessages = await _fetchMessagesWithUserData(group['_id']);
        return {
          'groupId': group['_id'],
          'name': group['groupName'] ?? '',
          'description': group['groupDescription'] ?? '',
          'image': group['groupImageUrl'] != null
              ? 'http://34.107.57.61/${group['groupImageUrl']}'
              : 'https://example.com/default-group-image.jpg',
          'lastMessage': lastMessage?['messageContent'] ?? 'No messages yet',
          'lastMessageTime': lastMessage != null
              ? DateTime.parse(lastMessage['createdAt']).toLocal().toString()
              : '',
          'mediaFiles': (group['mediaFiles'] as List<dynamic>)
              .map((file) => file.toString())
              .toList(),
          'members': (group['members'] as List<dynamic>)
              .map((file) => file.toString())
              .toList(),
          'groupMessages': groupMessages,
        };
      }).toList());

      setState(() {
        groups = updatedGroups;
      });
    } else {
      print('Failed to load groups. Status code: ${response.statusCode}');
    }
  }

  String formatTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return ''; // Return empty string if the date is null or empty
    }

    try {
      // Parse the incoming string to a DateTime object
      DateTime parsedDateTime = DateTime.parse(dateTimeString);

      // Use DateFormat to format it to only show hours and minutes
      String formattedTime = DateFormat('HH:mm').format(parsedDateTime);

      return formattedTime;
    } catch (e) {
      print('Invalid date format: $dateTimeString'); // Log the invalid format for debugging
      return ''; // Return empty string in case of an error
    }
  }
  void _refreshGroupList() {
    _fetchuserGroups(); // Method to fetch user groups
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSemester,
              hint: const Text('Select Continent'),
              items: semesters.map((String semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedSemester = newValue;
                  selectedCourse = null; // Reset course selection
                  courses = []; // Clear existing courses
                });
                _fetchCourses(); // Fetch courses based on selected semester
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Continent',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedCourse,
              hint: const Text('Select Country'),
              items: courses.map((String course) {
                return DropdownMenuItem<String>(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCourse = newValue;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Country',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _fetchuserGroups(); // Fetch groups based on selected filters
              },
              child: const Text('Find Country'),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(), // Show loading spinner
              )
                  : ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];

                  // Check if the user is a member of the group
                  bool isUserMember = group['members'].contains('_id'); // Assuming 'members' contains a list of user IDs

                  return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(group['image'] ?? 'default_image_url_here'),
                        radius: 25,
                      ),
                      title: Text(
                        group['name']!, // Always display the group name as the title
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: isUserMember
                          ? Row(
                        children: [
                          const Icon(Icons.done_all, size: 16),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              group['lastMessage']!, // Display the last message if the user is a member
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis, // Truncate the message if it's too long
                            ),
                          ),
                        ],
                      )
                          : LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth * 0.7, // Set the max width to 70% of available space
                            ),
                            child: Text(
                              '@${group['name']} , ${group['members'].length} Mitglieds', // Group name and member count
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis, // Truncate if the text is too long
                            ),
                          );
                        },
                      ),

                      trailing: isUserMember
                          ? Text(
                        formatTime(group['lastMessageTime']!), // Display the last message time for members
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      )
                          : null, // No trailing text if the user is not a member
                      onTap: () {

                        // Navigate to group details page if the user is a member
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => kamerunpage(

                            ),
                          ),
                        );

                      }
                  );
                },
              ),


            ),
          ],
        ),
      ),
    );
  }
}
