import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'models/email_group.dart';

// Group Model
class EmailGroup {
  final String name;
  final List<String> emails;

  EmailGroup({required this.name, required this.emails});
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final List<EmailGroup> _groups = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Groups',
      home: EmailEventPage(groups: _groups),
    );
  }
}

// Main Page: Select group and add calendar event
class EmailEventPage extends StatefulWidget {
  final List<EmailGroup> groups;

  EmailEventPage({required this.groups});

  @override
  _EmailEventPageState createState() => _EmailEventPageState();
}

class _EmailEventPageState extends State<EmailEventPage> {
  EmailGroup? _selectedGroup;

  Event buildEvent(List<String> emails, {Recurrence? recurrence}) {
    return Event(
      title: 'Test Event',
      description: 'example',
      location: 'Flutter app',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(minutes: 30)),
      allDay: false,
      iosParams: const IOSParams(
        reminder: Duration(minutes: 40),
        url: "http://example.com",
      ),
      androidParams: AndroidParams(
        emailInvites: emails,
      ),
      recurrence: recurrence,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Event Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () async {
              final newGroup = await Navigator.push<EmailGroup>(
                context,
                MaterialPageRoute(builder: (_) => AddGroupPage()),
              );
              if (newGroup != null) {
                setState(() {
                  widget.groups.add(newGroup);
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Select an Email Group:'),
          ),
          DropdownButton<EmailGroup>(
            hint: const Text('Select Group'),
            value: _selectedGroup,
            items: widget.groups
                .map(
                  (group) => DropdownMenuItem(
                    value: group,
                    child: Text(group.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGroup = value;
              });
            },
          ),
          const Divider(),
          if (_selectedGroup != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Selected group: ${_selectedGroup!.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          if (_selectedGroup != null)
            ListTile(
              title: const Text('Add Event with Selected Group'),
              subtitle:
                  Text("Inviting: ${_selectedGroup!.emails.join(', ')}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                Add2Calendar.addEvent2Cal(
                  buildEvent(_selectedGroup!.emails),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Page 2: Add group name + email list
class AddGroupPage extends StatefulWidget {
  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final List<String> _emails = [];

  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !_emails.contains(email)) {
      setState(() {
        _emails.add(email);
        _emailController.clear();
      });
    }
  }

  void _removeEmail(String email) {
    setState(() {
      _emails.remove(email);
    });
  }

  void _saveGroup() {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty || _emails.isEmpty) return;
    Navigator.pop(
      context,
      EmailGroup(name: groupName, emails: _emails),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Email Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _addEmail(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addEmail,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _emails.length,
                itemBuilder: (context, index) {
                  final email = _emails[index];
                  return ListTile(
                    title: Text(email),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeEmail(email),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveGroup,
              child: const Text('Save Group'),
            ),
          ],
        ),
      ),
    );
  }
}
