import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

class GoalTracker extends StatefulWidget {
  const GoalTracker({super.key});

  @override
  State<GoalTracker> createState() => _GoalTrackerState();
}

class _GoalTrackerState extends State<GoalTracker> {
  final TextEditingController _controller = TextEditingController();
  List<String> savedGoals = [];
  Map<String, bool> checkboxStates = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedGoals = prefs.getStringList('savedGoals') ?? [];
      final checkboxJson = prefs.getString('checkboxStates');
      if (checkboxJson != null) {
        checkboxStates = Map<String, bool>.from(jsonDecode(checkboxJson));
      }
    });
  }

  Future<void> _saveGoal() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final blocks = input
        .split(RegExp(r"Goal:\s*"))
        .where((b) => b.trim().isNotEmpty)
        .map((b) => "Goal: " + b.trim())
        .toList();

    setState(() {
      savedGoals.addAll(blocks);
      _controller.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedGoals', savedGoals);
  }

  Future<void> _deleteGoal(int index) async {
    setState(() => savedGoals.removeAt(index));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedGoals', savedGoals);
  }

  void _updateCheckbox(String id, bool value) async {
    setState(() => checkboxStates[id] = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('checkboxStates', jsonEncode(checkboxStates));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("\u{1F3AF} Goal Tracker"),
        backgroundColor: Colors.green.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder(
              future: Clipboard.getData('text/plain'),
              builder: (context, snapshot) {
                final clipboardHasText =
                    snapshot.hasData && (snapshot.data?.text?.trim().isNotEmpty ?? false);

                return TextField(
                  controller: _controller,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter goals like:\nGoal: Web Dev\nPhase 1:\n- HTML\n- CSS',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: const OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.paste,
                        color: clipboardHasText ? Colors.black : Colors.grey.shade400,
                      ),
                      onPressed: clipboardHasText
                          ? () async {
                        final clipData = await Clipboard.getData('text/plain');
                        if (clipData != null && clipData.text != null) {
                          setState(() {
                            _controller.text = clipData.text!.trim();
                          });
                        }
                      }
                          : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Save Goal"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: savedGoals.length,
                itemBuilder: (context, index) {
                  final block = savedGoals[index];
                  final goalTitle = block.split('\n').first.trim();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    child: ListTile(
                      title: Text(goalTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GoalDetailPage(
                              block: block,
                              index: index,
                              checkboxStates: checkboxStates,
                              onCheckboxChanged: _updateCheckbox,
                              onDelete: () => _deleteGoal(index),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GoalDetailPage extends StatefulWidget {
  final String block;
  final int index;
  final Map<String, bool> checkboxStates;
  final Function(String, bool) onCheckboxChanged;
  final VoidCallback onDelete;

  const GoalDetailPage({
    super.key,
    required this.block,
    required this.index,
    required this.checkboxStates,
    required this.onCheckboxChanged,
    required this.onDelete,
  });

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  late Map<String, bool> localCheckboxStates;

  @override
  void initState() {
    super.initState();
    localCheckboxStates = Map<String, bool>.from(widget.checkboxStates);
  }

  void _handleCheckboxChange(String id, bool value) {
    setState(() {
      localCheckboxStates[id] = value;
    });
    widget.onCheckboxChanged(id, value);
  }

  List<Widget> _buildChecklists() {
    final phases = RegExp(r'Phase\s*\d+:.*?(?=(Phase\s*\d+:|\Z))', dotAll: true)
        .allMatches(widget.block)
        .map((m) => m.group(0)!)
        .toList();

    List<Widget> widgets = [];

    for (int p = 0; p < phases.length; p++) {
      final phaseLines = phases[p]
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();

      if (phaseLines.isEmpty) continue;

      final title = phaseLines[0];
      final tasks = phaseLines.sublist(1);

      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ...tasks.asMap().entries.map((entry) {
              final taskIndex = entry.key;
              final taskText = entry.value.replaceFirst(RegExp(r'^-\s*'), '');
              final id = "g${widget.index}-p$p-t$taskIndex";
              final isChecked = localCheckboxStates[id] ?? false;

              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(taskText),
                value: isChecked,
                onChanged: (val) => _handleCheckboxChange(id, val ?? false),
              );
            }),
          ],
        ),
      ));
    }

    return widgets;
  }

  Widget _buildProgressChart() {
    // Extract all task IDs for this goal from the full block
    final phases = RegExp(r'Phase\s*\d+:.*?(?=(Phase\s*\d+:|\Z))', dotAll: true)
        .allMatches(widget.block)
        .map((m) => m.group(0)!)
        .toList();

    List<String> allTaskIds = [];

    for (int p = 0; p < phases.length; p++) {
      final phaseLines = phases[p]
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();

      final tasks = phaseLines.sublist(1); // skip title

      for (int taskIndex = 0; taskIndex < tasks.length; taskIndex++) {
        final id = "g${widget.index}-p$p-t$taskIndex";
        allTaskIds.add(id);
      }
    }

    final total = allTaskIds.length;
    final done = allTaskIds.where((id) => localCheckboxStates[id] == true).length;

    if (total == 0) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AspectRatio(
        aspectRatio: 1.2,
        child: PieChart(PieChartData(
          sections: [
            PieChartSectionData(value: done.toDouble(), color: Colors.green, title: 'Done'),
            PieChartSectionData(value: (total - done).toDouble(), color: Colors.red, title: 'Left'),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        )),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final goalTitle = widget.block.split('\n').first.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(goalTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressChart(),
            const SizedBox(height: 8),
            ..._buildChecklists(),
          ],
        ),
      ),
    );
  }
}
